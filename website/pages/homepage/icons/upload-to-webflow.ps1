<#
.SYNOPSIS
    Uploads all SVG icon files in this folder to Webflow as site assets.

.PARAMETER ApiToken
    Your Webflow API token (found in Webflow Account Settings → API Access).

.EXAMPLE
    .\upload-to-webflow.ps1 -ApiToken "your_token_here"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiToken
)

$SiteId    = "69c846db9eee02fddb1e2367"
$IconsPath = $PSScriptRoot
$ApiBase   = "https://api.webflow.com/v2"

$headers = @{
    "Authorization" = "Bearer $ApiToken"
    "Content-Type"  = "application/json"
    "Accept"        = "application/json"
}

$svgFiles = Get-ChildItem -Path $IconsPath -Filter "*.svg"

if ($svgFiles.Count -eq 0) {
    Write-Host "No SVG files found in $IconsPath" -ForegroundColor Yellow
    exit
}

Write-Host "`nUploading $($svgFiles.Count) SVG icons to Webflow (site: $SiteId)`n"

$success = 0
$failed  = 0

foreach ($file in $svgFiles) {
    Write-Host "  $($file.Name)..." -NoNewline

    try {
        # --- Step 1: Compute MD5 hash (base64) required by Webflow ---
        $md5     = [System.Security.Cryptography.MD5]::Create()
        $bytes   = [System.IO.File]::ReadAllBytes($file.FullName)
        $hashB64 = [System.Convert]::ToBase64String($md5.ComputeHash($bytes))

        # --- Step 2: Request a presigned S3 upload URL from Webflow ---
        $body = @{ fileName = $file.Name; fileHash = $hashB64 } | ConvertTo-Json

        $wfResponse = Invoke-RestMethod `
            -Uri     "$ApiBase/sites/$SiteId/assets" `
            -Method  POST `
            -Headers $headers `
            -Body    $body

        $uploadUrl     = $wfResponse.uploadUrl
        $uploadDetails = $wfResponse.uploadDetails

        # --- Step 3: POST file to S3 as multipart/form-data ---
        # S3 presigned POST requires all fields BEFORE the file content
        $multipart = [System.Net.Http.MultipartFormDataContent]::new()

        foreach ($prop in $uploadDetails.PSObject.Properties) {
            $multipart.Add(
                [System.Net.Http.StringContent]::new($prop.Value),
                $prop.Name
            )
        }

        $fileStream  = [System.IO.File]::OpenRead($file.FullName)
        $fileContent = [System.Net.Http.StreamContent]::new($fileStream)
        $fileContent.Headers.ContentType =
            [System.Net.Http.Headers.MediaTypeHeaderValue]::new("image/svg+xml")
        $multipart.Add($fileContent, "file", $file.Name)

        $httpClient = [System.Net.Http.HttpClient]::new()
        $s3Response = $httpClient.PostAsync($uploadUrl, $multipart).GetAwaiter().GetResult()

        $fileStream.Dispose()
        $httpClient.Dispose()

        if ($s3Response.IsSuccessStatusCode) {
            Write-Host " ✓" -ForegroundColor Green
            $success++
        } else {
            $errBody = $s3Response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
            Write-Host " ✗  S3 error $($s3Response.StatusCode): $errBody" -ForegroundColor Red
            $failed++
        }

    } catch {
        Write-Host " ✗  $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n--- $success uploaded, $failed failed ---`n"
