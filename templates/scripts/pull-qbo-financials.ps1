<#
.SYNOPSIS
    Pull real financials from QBO into the warehouse fin_* tables (CWDB HQ Tab 4).

.DESCRIPTION
    Sources (all read-only against the QBO API):
      1. reports/ProfitAndLoss (cash basis, summarized by month, YTD window)
             -> fin_pl_monthly   (one row per month x account path)
      2. query: Account (Bank + Credit Card balances)
      3. query: Invoice (open balance = A/R; per-customer totals = job revenue)
      4. query: Purchase (customer-tagged expense lines = job direct costs)
             -> fin_position     (snapshot row: cash, card liability, A/R, YTD)
             -> fin_job_profit   (per-QBO-customer revenue vs tagged costs)

    Job profitability honesty note: costs only count when the QBO expense line
    is tagged to a Customer. Most early expenses are untagged, so GP% reads
    high; the dashboard says so on the tab.

    Requires PowerShell 7+ (qbo-common.ps1 uses -ResponseHeadersVariable).
    Environment (sandbox vs production) follows QBO_ENVIRONMENT in .env.local.

.PARAMETER Year
    Calendar year for the P&L window. Default: current year.

.PARAMETER DryRun
    Parse and report, write nothing to Supabase.

.EXAMPLE
    pwsh -File templates/scripts/pull-qbo-financials.ps1
#>
[CmdletBinding()]
param(
    [int]    $Year = (Get-Date).Year,
    [switch] $DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "qbo-common.ps1")
. (Join-Path $scriptDir "load-supabase.ps1")

Import-QboEnv
Initialize-SupabaseClient

$pulledAt  = (Get-Date).ToUniversalTime().ToString("o")
$startDate = "{0}-01-01" -f $Year
$endDate   = (Get-Date).ToString("yyyy-MM-dd")

function ConvertTo-Cents {
    param($Value)
    if ($null -eq $Value -or "$Value" -eq "") { return 0 }
    try { return [long][Math]::Round([decimal]$Value * 100) } catch { return 0 }
}

# ===========================================================================
# 1. ProfitAndLoss report -> fin_pl_monthly
# ===========================================================================

Write-Verbose "Fetching ProfitAndLoss $startDate..$endDate (cash, by month)"
$plPath = "reports/ProfitAndLoss?start_date=$startDate&end_date=$endDate" +
          "&summarize_column_by=Month&accounting_method=Cash"
$pl = Invoke-QboApi -Path $plPath

# Column map: index within ColData -> month start date. The first column is the
# account name; the trailing "Total" column has no StartDate metadata and is
# skipped (we recompute totals in SQL).
$monthByIdx = @{}
$colIdx = 0
foreach ($col in @($pl.Columns.Column)) {
    if ($colIdx -gt 0) {
        $start = $null
        $meta = if ($col.PSObject.Properties.Name -contains 'MetaData') { $col.MetaData } else { $null }
        foreach ($m in @($meta)) {
            if ($null -eq $m) { continue }
            $mName = $null; $mValue = $null
            foreach ($p in $m.PSObject.Properties) {
                if ($p.Name -ieq 'Name')  { $mName  = $p.Value }
                if ($p.Name -ieq 'Value') { $mValue = $p.Value }
            }
            if ($mName -eq 'StartDate' -and $mValue) { $start = $mValue; break }
        }
        if ($start) { $monthByIdx[$colIdx] = ([datetime]::Parse($start)).ToString("yyyy-MM-01") }
    }
    $colIdx++
}

# Top-level report groups -> account_type. Summary-only groups (GrossProfit,
# NetIncome, ...) are stored as single synthetic rows under their group name.
$GroupTypeMap = @{
    Income = 'Income'; COGS = 'COGS'; Expenses = 'Expense'
    OtherIncome = 'OtherIncome'; OtherExpenses = 'OtherExpense'
}
$SummaryGroups = @('GrossProfit','NetOperatingIncome','NetOtherIncome','NetIncome')

$plRecords = New-Object System.Collections.Generic.List[hashtable]

function Add-PlAmounts {
    param($ColData, [string] $AccountPath, [string] $AccountName, [string] $AccountType)
    $cells = @($ColData)
    for ($i = 1; $i -lt $cells.Count; $i++) {
        if (-not $monthByIdx.ContainsKey($i)) { continue }
        $raw = $cells[$i].value
        if ($null -eq $raw -or "$raw" -eq "") { continue }
        $cents = ConvertTo-Cents $raw
        if ($cents -eq 0) { continue }
        $plRecords.Add(@{
            period       = $monthByIdx[$i]
            account_path = $AccountPath
            account_name = $AccountName
            account_type = $AccountType
            amount_cents = $cents
            basis        = 'cash'
            pulled_at    = $pulledAt
        })
    }
}

function Walk-PlRows {
    param($Rows, [string] $AccountType, [string] $Prefix)
    foreach ($row in @($Rows)) {
        $rowType = if ($row.PSObject.Properties.Name -contains 'type') { $row.type } else { '' }
        $group   = if ($row.PSObject.Properties.Name -contains 'group') { $row.group } else { $null }

        if ($group -and $SummaryGroups -contains $group) {
            if ($row.PSObject.Properties.Name -contains 'Summary' -and $row.Summary) {
                Add-PlAmounts -ColData $row.Summary.ColData -AccountPath $group `
                    -AccountName $group -AccountType $group
            }
            continue
        }

        $childType = $AccountType
        if ($group -and $GroupTypeMap.ContainsKey($group)) { $childType = $GroupTypeMap[$group] }

        if ($rowType -eq 'Section') {
            $headerName = $null
            if ($row.PSObject.Properties.Name -contains 'Header' -and $row.Header) {
                $headerName = $row.Header.ColData[0].value
            }
            $childPrefix = if ($headerName) { "$Prefix$headerName`:" } else { $Prefix }
            if ($row.PSObject.Properties.Name -contains 'Rows' -and $row.Rows) {
                Walk-PlRows -Rows $row.Rows.Row -AccountType $childType -Prefix $childPrefix
            }
        } elseif ($rowType -eq 'Data' -or ($row.PSObject.Properties.Name -contains 'ColData')) {
            $name = $row.ColData[0].value
            if ($name) {
                Add-PlAmounts -ColData $row.ColData -AccountPath "$Prefix$name" `
                    -AccountName $name -AccountType $AccountType
            }
        }
    }
}

$hasPlRows = ($pl.PSObject.Properties.Name -contains 'Rows') -and $pl.Rows -and
             ($pl.Rows.PSObject.Properties.Name -contains 'Row')
if ($hasPlRows) {
    Walk-PlRows -Rows $pl.Rows.Row -AccountType 'Expense' -Prefix ''
}
Write-Output "P&L parsed: $($plRecords.Count) month x account rows"

# YTD rollups (from parsed rows; the report's Total column is intentionally unused)
function Get-TypeTotal {
    param([string[]] $Types)
    $sum = 0L
    foreach ($r in $plRecords) { if ($Types -contains $r.account_type) { $sum += $r.amount_cents } }
    return $sum
}
$ytdRevenue = Get-TypeTotal @('Income','OtherIncome')
$ytdExpense = Get-TypeTotal @('COGS','Expense','OtherExpense')
$ytdNet     = Get-TypeTotal @('NetIncome')
if ($ytdNet -eq 0 -and ($ytdRevenue -ne 0 -or $ytdExpense -ne 0)) {
    $ytdNet = $ytdRevenue - $ytdExpense
}

# ===========================================================================
# 2. Balances (Bank + Credit Card accounts)
# ===========================================================================

function Invoke-QboQuery {
    param([Parameter(Mandatory)] [string] $Sql)
    $resp = Invoke-QboApi -Path ("query?query=" + [uri]::EscapeDataString($Sql))
    return $resp.QueryResponse
}

$acctResp = Invoke-QboQuery "select * from Account where AccountType in ('Bank','Credit Card')"
$accounts = if ($acctResp.PSObject.Properties.Name -contains 'Account') { @($acctResp.Account) } else { @() }
$cashCents = 0L; $cardCents = 0L
foreach ($a in $accounts) {
    $bal = ConvertTo-Cents $a.CurrentBalance
    if ($a.AccountType -eq 'Bank') { $cashCents += $bal }
    # QBO reports credit-card liability as a negative CurrentBalance on some
    # tenants and positive on others; store the owed amount as positive.
    elseif ($a.AccountType -eq 'Credit Card') { $cardCents += [Math]::Abs($bal) }
}

# ===========================================================================
# 3. Invoices -> A/R + per-customer (job) revenue
# ===========================================================================

$invResp   = Invoke-QboQuery "select * from Invoice maxresults 1000"
$invoices  = if ($invResp.PSObject.Properties.Name -contains 'Invoice') { @($invResp.Invoice) } else { @() }
$arCents   = 0L
$openInvoices = New-Object System.Collections.Generic.List[hashtable]
$revenueByCustomer = @{}
$invoicesByCustomer = @{}
foreach ($inv in $invoices) {
    $balance = ConvertTo-Cents $inv.Balance
    $total   = ConvertTo-Cents $inv.TotalAmt
    $cust    = if ($inv.CustomerRef) { $inv.CustomerRef.name } else { '(no customer)' }
    if ($balance -gt 0) {
        $arCents += $balance
        $openInvoices.Add(@{
            doc_number    = $inv.DocNumber
            customer      = $cust
            amount_cents  = $total
            balance_cents = $balance
            due_date      = $inv.DueDate
        })
    }
    if (-not $revenueByCustomer.ContainsKey($cust)) {
        $revenueByCustomer[$cust] = 0L
        $invoicesByCustomer[$cust] = New-Object System.Collections.Generic.List[hashtable]
    }
    $revenueByCustomer[$cust] += $total
    $invoicesByCustomer[$cust].Add(@{
        doc_number = $inv.DocNumber; amount_cents = $total
        txn_date = $inv.TxnDate; balance_cents = $balance
    })
}

# ===========================================================================
# 4. Customer-tagged expense lines -> job direct costs
# ===========================================================================

$purchResp = Invoke-QboQuery "select * from Purchase maxresults 1000"
$purchases = if ($purchResp.PSObject.Properties.Name -contains 'Purchase') { @($purchResp.Purchase) } else { @() }
$costByCustomer = @{}
$expensesByCustomer = @{}
foreach ($p in $purchases) {
    foreach ($line in @($p.Line)) {
        $detailProp = 'AccountBasedExpenseLineDetail'
        if ($line.PSObject.Properties.Name -notcontains $detailProp) { continue }
        $detail = $line.$detailProp
        if ($null -eq $detail -or $detail.PSObject.Properties.Name -notcontains 'CustomerRef' -or -not $detail.CustomerRef) { continue }
        $cust  = $detail.CustomerRef.name
        $cents = ConvertTo-Cents $line.Amount
        if (-not $costByCustomer.ContainsKey($cust)) {
            $costByCustomer[$cust] = 0L
            $expensesByCustomer[$cust] = New-Object System.Collections.Generic.List[hashtable]
        }
        $costByCustomer[$cust] += $cents
        $expensesByCustomer[$cust].Add(@{
            txn_date = $p.TxnDate; amount_cents = $cents
            account  = $detail.AccountRef.name
            memo     = $line.Description
        })
    }
}

# ===========================================================================
# 5. fin_job_profit records (map QBO customer -> dim_jobs.job_number if known)
# ===========================================================================

$jobs = Invoke-SupabaseSelect -Table "dim_jobs" -Select "job_number,client_name"
$jobNumberByClient = @{}
foreach ($j in @($jobs)) {
    if ($j.client_name) { $jobNumberByClient[$j.client_name.ToLowerInvariant()] = $j.job_number }
}
function Resolve-JobNumber {
    param([string] $CustomerName)
    if (-not $CustomerName) { return $null }
    $k = $CustomerName.Trim().ToLowerInvariant()
    if ($jobNumberByClient.ContainsKey($k)) { return $jobNumberByClient[$k] }
    foreach ($client in $jobNumberByClient.Keys) {
        # last-name style partial match ("Overbeck" vs "Sarah Overbeck")
        if ($client -like "*$k*" -or $k -like "*$client*") { return $jobNumberByClient[$client] }
    }
    return $null
}

$jobRecords = New-Object System.Collections.Generic.List[hashtable]
$allCustomers = @($revenueByCustomer.Keys) + @($costByCustomer.Keys) | Select-Object -Unique
foreach ($cust in $allCustomers) {
    $jobRecords.Add(@{
        job_key       = $cust
        job_number    = (Resolve-JobNumber $cust)
        revenue_cents = [long]($revenueByCustomer[$cust] ?? 0)
        cost_cents    = [long]($costByCustomer[$cust] ?? 0)
        invoices      = if ($invoicesByCustomer.ContainsKey($cust)) { $invoicesByCustomer[$cust].ToArray() } else { @() }
        expenses      = if ($expensesByCustomer.ContainsKey($cust)) { $expensesByCustomer[$cust].ToArray() } else { @() }
        updated_at    = $pulledAt
    })
}

# ===========================================================================
# 6. Write to Supabase
# ===========================================================================

$positionRecord = @{
    as_of                = $pulledAt
    cash_cents           = $cashCents
    card_liability_cents = $cardCents
    ar_total_cents       = $arCents
    ytd_net_income_cents = $ytdNet
    ytd_revenue_cents    = $ytdRevenue
    ytd_expense_cents    = $ytdExpense
    open_invoices        = $openInvoices.ToArray()
    ar_aging             = @()   # v1: open invoice list stands in for aging buckets
}

if ($DryRun) {
    Write-Output "DryRun: fin_pl_monthly=$($plRecords.Count) rows, fin_job_profit=$($jobRecords.Count) rows"
    Write-Output ('DryRun: position cash=${0:N2} card=${1:N2} AR=${2:N2} ytdNet=${3:N2}' -f `
        ($cashCents/100), ($cardCents/100), ($arCents/100), ($ytdNet/100))
} else {
    if ($plRecords.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "fin_pl_monthly" -Records $plRecords.ToArray() -ConflictColumns "period,account_path"
        Write-Output "Upserted $n rows into fin_pl_monthly"
    }
    # position_id is serial and absent from the payload, so on_conflict never
    # fires: this is an append (point-in-time snapshot history).
    Invoke-SupabaseUpsert -Table "fin_position" -Records @($positionRecord) -ConflictColumns "position_id" | Out-Null
    Write-Output ('Appended fin_position snapshot: cash=${0:N2} card=${1:N2} AR=${2:N2} ytdNet=${3:N2}' -f `
        ($cashCents/100), ($cardCents/100), ($arCents/100), ($ytdNet/100))
    if ($jobRecords.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "fin_job_profit" -Records $jobRecords.ToArray() -ConflictColumns "job_key"
        Write-Output "Upserted $n rows into fin_job_profit"
    }
    Invoke-SupabaseUpsert -Table "platform_health" -Records @(@{
        platform = 'qbo'; check_name = 'financials_pull'
        status = 'ok'; detail = "P&L $($plRecords.Count) rows, $($invoices.Count) invoices"
        checked_at = $pulledAt
    }) -ConflictColumns "platform,check_name" | Out-Null
}

Write-Output "QBO financials pull complete ($startDate..$endDate, $(Get-QboEnvironment))"
