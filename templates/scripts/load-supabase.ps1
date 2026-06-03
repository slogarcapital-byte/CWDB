<#
.SYNOPSIS
    Shared helper for UPSERTing records into Supabase via the REST API.

.DESCRIPTION
    Dot-source this file from any pull-*.ps1 script that needs to push rows into the
    CWDB data warehouse. Exposes Invoke-SupabaseUpsert, which batches records and uses
    the Prefer: resolution=merge-duplicates header so re-runs are idempotent.

    Authentication uses SUPABASE_SERVICE_ROLE_KEY which BYPASSES RLS. This key must
    NEVER reach the browser; it is server-side only.

.NOTES
    Required env vars (read from .env.local at repo root or process env):
      SUPABASE_URL                - https://<project>.supabase.co
      SUPABASE_SERVICE_ROLE_KEY   - service_role JWT (Project Settings -> API -> "service_role")

    Usage example:
        . "$PSScriptRoot\load-supabase.ps1"
        Initialize-SupabaseClient
        $rows = @( @{ city_name = "Wausau"; state = "WI"; zip_codes = @("54401") } )
        Invoke-SupabaseUpsert -Table "dim_city" -Records $rows -ConflictColumns "city_name"
#>

Set-StrictMode -Version Latest

$Script:SupabaseUrl     = $null
$Script:SupabaseKey     = $null
$Script:SupabaseHeaders = $null

function Initialize-SupabaseClient {
    <#
    .SYNOPSIS
        Read SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY from env and prep request headers.
    #>
    [CmdletBinding()]
    param()

    $Script:SupabaseUrl = $env:SUPABASE_URL
    $Script:SupabaseKey = $env:SUPABASE_SERVICE_ROLE_KEY

    if (-not $Script:SupabaseUrl) {
        throw "Missing required env var: SUPABASE_URL. See operations/data-warehouse/README.md"
    }
    if (-not $Script:SupabaseKey) {
        throw "Missing required env var: SUPABASE_SERVICE_ROLE_KEY. See operations/data-warehouse/README.md"
    }

    # Tolerate Supabase dashboard URLs copied from different fields:
    # - Project URL:    https://<id>.supabase.co            (correct)
    # - REST API base:  https://<id>.supabase.co/rest/v1/   (common mistake)
    # - With trailing /
    # We always want the bare origin so we can append our own /rest/v1/<table>.
    if ($Script:SupabaseUrl -match '^(https?://[^/]+)') {
        $Script:SupabaseUrl = $matches[1]
    } else {
        throw "SUPABASE_URL does not look like a valid URL: '$($Script:SupabaseUrl)'"
    }

    $Script:SupabaseHeaders = @{
        "apikey"        = $Script:SupabaseKey
        "Authorization" = "Bearer $($Script:SupabaseKey)"
        "Content-Type"  = "application/json"
        "Prefer"        = "resolution=merge-duplicates,return=minimal"
    }
}

function Invoke-SupabaseUpsert {
    <#
    .SYNOPSIS
        Batched UPSERT into a Supabase table via PostgREST.
    .PARAMETER Table
        Unqualified table name in the public schema (e.g., "dim_contractor").
    .PARAMETER Records
        Array of hashtables. Each element becomes one row.
    .PARAMETER ConflictColumns
        Comma-separated list of columns that form the natural-key UNIQUE constraint.
        Used as ?on_conflict=... so PostgREST does an UPSERT instead of INSERT.
    .PARAMETER BatchSize
        Rows per HTTP request. Default 500. Supabase free tier comfortably handles 500-1000.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]   $Table,
        [Parameter(Mandatory)] [object[]] $Records,
        [Parameter(Mandatory)] [string]   $ConflictColumns,
        [int] $BatchSize = 500
    )

    if (-not $Script:SupabaseUrl) {
        throw "Supabase client not initialized. Call Initialize-SupabaseClient first."
    }
    if (-not $Records -or $Records.Count -eq 0) {
        Write-Verbose "Invoke-SupabaseUpsert: no records for table $Table; skipping."
        return 0
    }

    $endpoint = "$($Script:SupabaseUrl)/rest/v1/$Table" + "?on_conflict=$ConflictColumns"
    $written  = 0
    $batchNum = 0
    for ($i = 0; $i -lt $Records.Count; $i += $BatchSize) {
        $end   = [Math]::Min($i + $BatchSize, $Records.Count) - 1
        $batch = $Records[$i..$end]
        $batchNum++

        # ConvertTo-Json wraps single-item arrays into the object itself — force array form.
        if ($batch.Count -eq 1) {
            $body = "[" + ($batch[0] | ConvertTo-Json -Depth 32 -Compress) + "]"
        } else {
            $body = $batch | ConvertTo-Json -Depth 32 -Compress
        }

        try {
            Invoke-RestMethod -Method Post -Uri $endpoint -Headers $Script:SupabaseHeaders -Body $body -ErrorAction Stop | Out-Null
            $written += $batch.Count
            Write-Verbose "UPSERT $Table batch $batchNum ($($batch.Count) rows) ok"
        } catch {
            $errBody = ""
            try {
                if ($_.Exception.Response) {
                    $stream = $_.Exception.Response.GetResponseStream()
                    $reader = New-Object System.IO.StreamReader($stream)
                    $errBody = $reader.ReadToEnd()
                }
            } catch { }
            throw "UPSERT to $Table failed (batch $batchNum, $($batch.Count) rows): $($_.Exception.Message)`n$errBody"
        }
    }
    return $written
}

function Invoke-SupabaseSelect {
    <#
    .SYNOPSIS
        Read rows from a Supabase table via PostgREST. Convenience for ingest scripts
        that need to resolve FKs (e.g., look up dim_city.city_id by city_name).
    .PARAMETER Table
        Unqualified table name.
    .PARAMETER Select
        Columns to return (PostgREST select syntax). Default "*".
    .PARAMETER Filter
        PostgREST filter string, e.g. "city_name=eq.Wausau".
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Table,
        [string] $Select = "*",
        [string] $Filter = $null
    )

    if (-not $Script:SupabaseUrl) {
        throw "Supabase client not initialized. Call Initialize-SupabaseClient first."
    }

    $url = "$($Script:SupabaseUrl)/rest/v1/$Table" + "?select=$Select"
    if ($Filter) { $url += "&$Filter" }

    $headers = @{
        "apikey"        = $Script:SupabaseKey
        "Authorization" = "Bearer $($Script:SupabaseKey)"
        "Accept"        = "application/json"
    }
    return Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ErrorAction Stop
}

function Load-DotEnvIfNeeded {
    <#
    .SYNOPSIS
        Load .env.local from the repo root if SUPABASE_URL isn't already in the environment.
        Mirrors the Load-DotEnv pattern from the existing pull-*.ps1 scripts.
    .PARAMETER RepoRoot
        Absolute path to the repo root. Defaults to two levels up from this script.
    #>
    [CmdletBinding()]
    param(
        [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
    )

    if ($env:SUPABASE_URL -and $env:SUPABASE_SERVICE_ROLE_KEY) { return }

    $envFile = Join-Path $RepoRoot ".env.local"
    if (-not (Test-Path $envFile)) { return }

    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $idx  = $line.IndexOf("=")
            $name = $line.Substring(0, $idx).Trim()
            $val  = $line.Substring($idx + 1).Trim().Trim("'`"")
            if ($name -and -not [Environment]::GetEnvironmentVariable($name, "Process")) {
                [Environment]::SetEnvironmentVariable($name, $val, "Process")
            }
        }
    }
}
