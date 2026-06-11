<#
.SYNOPSIS
    Push a CWDB invoice JSON (finance/invoices/_data/*.json) into QBO as a
    draft invoice. Idempotent on DocNumber.

.DESCRIPTION
    Per operations/data-warehouse/design/hubspot-qbo-flow.md:
    1. Ensures the Customer exists (lookup by DisplayName, create if missing).
    2. Ensures the Service item exists (default "Customer Deposit"; created
       against the first Income account if missing).
    3. Creates the invoice with our DocNumber, no sales tax (owner decision
       2026-06-10), deposit-hold customer memo, and the homeowner's email.
    4. -Send emails it from QBO (with the Payments pay button if enabled).
    Skips creation if an invoice with the same DocNumber already exists.

.EXAMPLE
    pwsh templates/scripts/push-qbo-invoice.ps1 `
        -DataFile finance/invoices/_data/INV-2026-001-overbeck-deposit.json
    pwsh templates/scripts/push-qbo-invoice.ps1 -DataFile ... -Send
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $DataFile,
    [string] $ItemName = "Customer Deposit",
    [switch] $Send,
    [switch] $DryRun
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\qbo-common.ps1"
Import-QboEnv

function Strip-Html { param([string] $s) ($s -replace '<[^>]+>', '') }
function Escape-Qql { param([string] $s) ($s -replace "'", "\'") }

$inv = Get-Content (Resolve-Path $DataFile) -Raw | ConvertFrom-Json
$docNumber = $inv.invoice_number
$client = $inv.bill_to
$txnDate = ([datetime]::Parse($inv.date_issued)).ToString("yyyy-MM-dd")

# --- idempotency: bail if the DocNumber already exists ---------------------
$q = "select * from Invoice where DocNumber = '$(Escape-Qql $docNumber)'"
$existing = Invoke-QboApi -Path ("query?query=" + [uri]::EscapeDataString($q))
if ((Get-Member -InputObject $existing.QueryResponse -Name Invoice -ErrorAction SilentlyContinue)) {
    Write-Output "Invoice $docNumber already exists in QBO (Id $($existing.QueryResponse.Invoice[0].Id)); nothing to do."
    return
}

# --- customer ---------------------------------------------------------------
$q = "select * from Customer where DisplayName = '$(Escape-Qql $client.name)'"
$found = Invoke-QboApi -Path ("query?query=" + [uri]::EscapeDataString($q))
if (Get-Member -InputObject $found.QueryResponse -Name Customer -ErrorAction SilentlyContinue) {
    $customerId = $found.QueryResponse.Customer[0].Id
    Write-Output "Customer '$($client.name)' exists (Id $customerId)"
} elseif ($DryRun) {
    Write-Output "DryRun: would create customer '$($client.name)'"
    $customerId = "DRYRUN"
} else {
    $addrParts = $client.address_line -split ',\s*'
    $newCust = @{
        DisplayName      = $client.name
        PrimaryEmailAddr = @{ Address = $client.email }
        PrimaryPhone     = @{ FreeFormNumber = $client.phone }
        BillAddr         = @{ Line1 = $addrParts[0]
                              City  = ($addrParts[1] ?? "")
                              CountrySubDivisionCode = "WI" }
    }
    $created = Invoke-QboApi -Method Post -Path "customer" -Body $newCust
    $customerId = $created.Customer.Id
    Write-Output "Created customer '$($client.name)' (Id $customerId)"
}

# --- service item -----------------------------------------------------------
$q = "select * from Item where Name = '$(Escape-Qql $ItemName)'"
$found = Invoke-QboApi -Path ("query?query=" + [uri]::EscapeDataString($q))
if (Get-Member -InputObject $found.QueryResponse -Name Item -ErrorAction SilentlyContinue) {
    $itemId = $found.QueryResponse.Item[0].Id
    Write-Output "Item '$ItemName' exists (Id $itemId)"
} elseif ($DryRun) {
    Write-Output "DryRun: would create service item '$ItemName'"
    $itemId = "DRYRUN"
} else {
    $q = "select * from Account where AccountType = 'Income' maxresults 1"
    $acct = Invoke-QboApi -Path ("query?query=" + [uri]::EscapeDataString($q))
    $acctId = $acct.QueryResponse.Account[0].Id
    $created = Invoke-QboApi -Method Post -Path "item" -Body @{
        Name = $ItemName; Type = "Service"
        IncomeAccountRef = @{ value = $acctId }
        Taxable = $false
    }
    $itemId = $created.Item.Id
    Write-Output "Created service item '$ItemName' (Id $itemId)"
}

# --- invoice ----------------------------------------------------------------
$lines = @()
foreach ($li in $inv.line_items) {
    $lines += @{
        DetailType = "SalesItemLineDetail"
        Description = (Strip-Html $li[0])
        Amount = [decimal] $li[1]
        SalesItemLineDetail = @{
            ItemRef = @{ value = $itemId }
            Qty = 1
            UnitPrice = [decimal] $li[1]
        }
    }
}
$memo = ($inv.notes | ForEach-Object { Strip-Html $_ }) -join "  "
$body = @{
    DocNumber    = $docNumber
    TxnDate      = $txnDate
    CustomerRef  = @{ value = $customerId }
    Line         = $lines
    BillEmail    = @{ Address = $client.email }
    CustomerMemo = @{ value = $memo.Substring(0, [Math]::Min(995, $memo.Length)) }
    SalesTermRef = $null
}
if ($DryRun) {
    Write-Output "DryRun: would create invoice $docNumber for $($client.name):"
    Write-Output ($body | ConvertTo-Json -Depth 8)
    return
}
$created = Invoke-QboApi -Method Post -Path "invoice" -Body $body
$invoiceId = $created.Invoice.Id
Write-Output "Created invoice $docNumber (QBO Id $invoiceId, total $($created.Invoice.TotalAmt))"

if ($Send) {
    $sendTo = [uri]::EscapeDataString($client.email)
    Invoke-QboApi -Method Post -Path "invoice/$invoiceId/send?sendTo=$sendTo" | Out-Null
    Write-Output "Sent invoice $docNumber to $($client.email)"
} else {
    Write-Output "Invoice left in draft (no -Send)."
}
