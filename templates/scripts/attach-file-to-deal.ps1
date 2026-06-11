<#
.SYNOPSIS
    Attach a file (estimate / invoice PDF) to a HubSpot deal as a note attachment.

.DESCRIPTION
    1. Uploads the file to HubSpot Files (hidden from public indexing).
    2. Creates a note engagement on the deal with the file attached, so the
       PDF shows on the deal timeline in the HubSpot UI.

    Part of the bids-to-deals flow: every estimate or invoice PDF generated
    under sales/estimates/ or finance/invoices/ should be attached to the
    matching deal so HubSpot is the single place to see a job's paper trail.

.NOTES
    Required env var (read from .env.local at repo root):
      HUBSPOT_PRIVATE_APP_TOKEN with scopes: files, crm.objects.deals.read.
      (Note creation rides on the deals object grant.)

.EXAMPLE
    pwsh templates/scripts/attach-file-to-deal.ps1 `
        -FilePath sales/estimates/2026-06-03-overbeck-stain.pdf `
        -DealId 324817992387 `
        -NoteBody "Estimate #2026-06-03-001 (stain, $2,800)"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $FilePath,
    [Parameter(Mandatory)] [string] $DealId,
    [string] $NoteBody = "",
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"

# --- token ---------------------------------------------------------------
$envFile = Join-Path $RepoRoot ".env.local"
if (Test-Path $envFile) {
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
$token = $env:HUBSPOT_PRIVATE_APP_TOKEN
if (-not $token) { throw "Missing HUBSPOT_PRIVATE_APP_TOKEN (see .env.local)" }

$file = Resolve-Path $FilePath
if (-not (Test-Path $file)) { throw "File not found: $FilePath" }

# --- 1. upload to HubSpot Files -------------------------------------------
$uploadHeaders = @{ Authorization = "Bearer $token" }
$form = @{
    file       = Get-Item $file
    # PRIVATE = signed-URL access only. The HIDDEN_* values need the extra
    # files.ui_hidden.write scope and fail with a misleading "Invalid JSON
    # for options input" error without it.
    options    = '{"access":"PRIVATE"}'
    folderPath = '/cwdb-deal-attachments'
}
$uploaded = Invoke-RestMethod -Method Post -Uri 'https://api.hubapi.com/files/v3/files' `
    -Headers $uploadHeaders -Form $form
Write-Output "Uploaded file id $($uploaded.id): $($uploaded.name)"

# --- 2. note on the deal with the attachment ------------------------------
if (-not $NoteBody) { $NoteBody = "Attached: $(Split-Path $file -Leaf)" }
$noteHeaders = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
$body = @{
    properties = @{
        hs_note_body       = $NoteBody
        hs_timestamp       = (Get-Date).ToUniversalTime().ToString("o")
        hs_attachment_ids  = "$($uploaded.id)"
    }
    associations = @(
        @{
            to    = @{ id = $DealId }
            types = @(@{ associationCategory = 'HUBSPOT_DEFINED'; associationTypeId = 214 })
        }
    )
} | ConvertTo-Json -Depth 6
$note = Invoke-RestMethod -Method Post -Uri 'https://api.hubapi.com/crm/v3/objects/notes' `
    -Headers $noteHeaders -Body $body
Write-Output "Note $($note.id) created on deal $DealId with attachment"
