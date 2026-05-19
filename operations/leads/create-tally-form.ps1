<#
.SYNOPSIS
    Creates the CWDB Deck Quote Request form in Tally via API.

.PARAMETER ApiKey
    Your Tally API key. Find it at: tally.so -> Account Settings -> API Keys

.PARAMETER WebhookUrl
    Optional. Make webhook URL to attach (run again after completing 3C).

.EXAMPLE
    .\create-tally-form.ps1 -ApiKey "YOUR_API_KEY"
    .\create-tally-form.ps1 -ApiKey "YOUR_API_KEY" -WebhookUrl "https://hook.make.com/..."
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ApiKey,

    [Parameter(Mandatory = $false)]
    [string]$WebhookUrl
)

function New-Uuid { return [System.Guid]::NewGuid().ToString() }

# ---------------------------------------------------------------------------
# Generate all block UUIDs up front
# ---------------------------------------------------------------------------
$tId  = New-Uuid   # form title

$g1   = New-Uuid;  $f1   = New-Uuid   # Full Name       (label uuid = group uuid)
$g2   = New-Uuid;  $f2   = New-Uuid   # Phone Number
$g3   = New-Uuid;  $f3   = New-Uuid   # Email Address
$g4   = New-Uuid;  $f4   = New-Uuid   # Property Address

$g5   = New-Uuid                       # Ownership (multiple choice)
$o5a  = New-Uuid;  $o5b  = New-Uuid

$g6   = New-Uuid                       # Project type
$o6a  = New-Uuid;  $o6b  = New-Uuid;  $o6c = New-Uuid;  $o6d = New-Uuid;  $o6e = New-Uuid

$g7   = New-Uuid                       # Budget
$o7a  = New-Uuid;  $o7b  = New-Uuid;  $o7c = New-Uuid;  $o7d = New-Uuid;  $o7e = New-Uuid

$g8   = New-Uuid                       # Timeline
$o8a  = New-Uuid;  $o8b  = New-Uuid;  $o8c = New-Uuid;  $o8d = New-Uuid

$g9   = New-Uuid;  $f9   = New-Uuid   # Additional notes

# ---------------------------------------------------------------------------
# Build JSON body as a here-string
# Numeric literals (0,1,2...) and booleans (true/false) written directly —
# no ConvertTo-Json involved, so PS5 integer-zero serialization is not an issue.
# Backtick-dollar (`$) escapes literal $ in budget option text.
# ---------------------------------------------------------------------------
$body = @"
{
  "status": "PUBLISHED",
  "blocks": [
    {
      "uuid": "$tId",
      "type": "FORM_TITLE",
      "groupUuid": "$tId",
      "groupType": "FORM_TITLE",
      "payload": { "html": "CWDB Deck Quote Request" }
    },
    { "uuid": "$g1", "type": "LABEL",            "groupUuid": "$g1", "groupType": "QUESTION", "payload": { "html": "Full Name" } },
    { "uuid": "$f1", "type": "INPUT_TEXT",        "groupUuid": "$g1", "groupType": "QUESTION", "payload": { "placeholder": "Your full name", "isRequired": true, "name": "full_name" } },

    { "uuid": "$g2", "type": "LABEL",             "groupUuid": "$g2", "groupType": "QUESTION", "payload": { "html": "Phone Number" } },
    { "uuid": "$f2", "type": "INPUT_PHONE_NUMBER","groupUuid": "$g2", "groupType": "QUESTION", "payload": { "placeholder": "(715) 555-0000", "isRequired": true, "defaultCountryCode": "US", "name": "phone_number" } },

    { "uuid": "$g3", "type": "LABEL",             "groupUuid": "$g3", "groupType": "QUESTION", "payload": { "html": "Email Address" } },
    { "uuid": "$f3", "type": "INPUT_EMAIL",        "groupUuid": "$g3", "groupType": "QUESTION", "payload": { "placeholder": "you@email.com", "isRequired": true, "name": "email_address" } },

    { "uuid": "$g4", "type": "LABEL",             "groupUuid": "$g4", "groupType": "QUESTION", "payload": { "html": "Property Address" } },
    { "uuid": "$f4", "type": "INPUT_TEXT",        "groupUuid": "$g4", "groupType": "QUESTION", "payload": { "placeholder": "Street address, City, WI ZIP", "isRequired": true, "name": "property_address" } },

    { "uuid": "$g5",  "type": "MULTIPLE_CHOICE",         "groupUuid": "$g5", "groupType": "QUESTION",        "payload": { "html": "Do you own this property?", "isRequired": false } },
    { "uuid": "$o5a", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g5", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "Yes, I own this home", "index": 0 } },
    { "uuid": "$o5b", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g5", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "No, I rent",            "index": 1 } },

    { "uuid": "$g6",  "type": "MULTIPLE_CHOICE",         "groupUuid": "$g6", "groupType": "QUESTION",        "payload": { "html": "What type of project is this?", "isRequired": false } },
    { "uuid": "$o6a", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g6", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "New deck build",            "index": 0 } },
    { "uuid": "$o6b", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g6", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "Deck replacement",          "index": 1 } },
    { "uuid": "$o6c", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g6", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "Deck repair",               "index": 2 } },
    { "uuid": "$o6d", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g6", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "Deck addition / expansion", "index": 3 } },
    { "uuid": "$o6e", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g6", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "Not sure yet",              "index": 4 } },

    { "uuid": "$g7",  "type": "MULTIPLE_CHOICE",         "groupUuid": "$g7", "groupType": "QUESTION",        "payload": { "html": "What is your estimated budget?", "isRequired": false } },
    { "uuid": "$o7a", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g7", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "Under `$5,000",        "index": 0 } },
    { "uuid": "$o7b", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g7", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "`$5,000 - `$10,000",   "index": 1 } },
    { "uuid": "$o7c", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g7", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "`$10,000 - `$20,000",  "index": 2 } },
    { "uuid": "$o7d", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g7", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "`$20,000 - `$40,000",  "index": 3 } },
    { "uuid": "$o7e", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g7", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "`$40,000+",             "index": 4 } },

    { "uuid": "$g8",  "type": "MULTIPLE_CHOICE",         "groupUuid": "$g8", "groupType": "QUESTION",        "payload": { "html": "When are you looking to start?", "isRequired": false } },
    { "uuid": "$o8a", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g8", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "As soon as possible", "index": 0 } },
    { "uuid": "$o8b", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g8", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "Within 1-3 months",   "index": 1 } },
    { "uuid": "$o8c", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g8", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "3-6 months",           "index": 2 } },
    { "uuid": "$o8d", "type": "MULTIPLE_CHOICE_OPTION",  "groupUuid": "$g8", "groupType": "MULTIPLE_CHOICE", "payload": { "text": "Just planning ahead", "index": 3 } },

    { "uuid": "$g9", "type": "LABEL",    "groupUuid": "$g9", "groupType": "QUESTION", "payload": { "html": "Anything else we should know about your project?" } },
    { "uuid": "$f9", "type": "TEXTAREA", "groupUuid": "$g9", "groupType": "QUESTION", "payload": { "placeholder": "Deck size, materials, special features, etc.", "isRequired": false, "name": "additional_notes" } }
  ]
}
"@

# ---------------------------------------------------------------------------
# API call — create form
# ---------------------------------------------------------------------------

$headers = @{
    'Authorization' = "Bearer $ApiKey"
    'Content-Type'  = 'application/json'
}

Write-Host ''
Write-Host 'Creating Tally form...'

try {
    $response = Invoke-RestMethod `
        -Uri     'https://api.tally.so/forms' `
        -Method  POST `
        -Headers $headers `
        -Body    $body

    $formId    = $response.id
    $shareUrl  = "https://tally.so/r/$formId"
    $embedCode = "<iframe src=`"https://tally.so/embed/$formId`" width=`"100%`" height=`"500`" frameborder=`"0`" marginheight=`"0`" marginwidth=`"0`" title=`"CWDB Deck Quote Request`"></iframe>"

    Write-Host ''
    Write-Host 'Form created successfully.' -ForegroundColor Green
    Write-Host ''
    Write-Host "Form ID:   $formId"
    Write-Host "Share URL: $shareUrl"
    Write-Host ''
    Write-Host 'Embed code (paste into Webflow):'
    Write-Host $embedCode

    $formId | Out-File -FilePath "$PSScriptRoot\tally-form-id.txt" -Encoding UTF8 -NoNewline
    Write-Host ''
    Write-Host 'Form ID saved to tally-form-id.txt'

    # ---------------------------------------------------------------------------
    # Optional — attach Make webhook
    # ---------------------------------------------------------------------------
    if ($WebhookUrl) {
        Write-Host ''
        Write-Host 'Adding Make webhook...'

        $webhookBody = '{ "url": "' + $WebhookUrl + '", "enabled": true }'

        Invoke-RestMethod `
            -Uri     "https://api.tally.so/forms/$formId/webhooks" `
            -Method  POST `
            -Headers $headers `
            -Body    $webhookBody | Out-Null

        Write-Host 'Webhook added.' -ForegroundColor Green
    } else {
        Write-Host ''
        Write-Host 'Tip: re-run with -WebhookUrl after completing 3C (Make setup).' -ForegroundColor Yellow
    }

} catch {
    Write-Host ''
    Write-Host 'API call failed.' -ForegroundColor Red
    Write-Host "Error:    $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    exit 1
}
