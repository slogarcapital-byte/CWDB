Add-Type -AssemblyName System.Drawing

$webDir = $PSScriptRoot

function Remap-Logo($srcPath, $outPath, $darkR, $darkG, $darkB, $accentR, $accentG, $accentB) {
    $src = [System.Drawing.Bitmap]::new($srcPath)
    $dst = [System.Drawing.Bitmap]::new($src.Width, $src.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dst)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.Dispose()

    for ($y = 0; $y -lt $src.Height; $y++) {
        for ($x = 0; $x -lt $src.Width; $x++) {
            $px = $src.GetPixel($x, $y)
            $r = $px.R; $g2 = $px.G; $b2 = $px.B; $a = $px.A

            if ($a -lt 30) { $dst.SetPixel($x, $y, [System.Drawing.Color]::Transparent); continue }

            # Near-white background → transparent
            if ($r -gt 210 -and $g2 -gt 210 -and $b2 -gt 210) {
                $dst.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
            }
            # Orange-ish pixel → accent color
            elseif ($r -gt 140 -and $g2 -lt 120 -and $b2 -lt 50 -and $r -gt $g2) {
                $alpha = [Math]::Min(255, [int]($a * 0.95))
                $dst.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $accentR, $accentG, $accentB))
            }
            # Dark pixel → remap with opacity based on darkness
            else {
                $lum = (0.299 * $r + 0.587 * $g2 + 0.114 * $b2) / 255.0
                $opacity = [Math]::Min(255, [int]((1 - $lum) * 280))
                if ($opacity -lt 15) { $dst.SetPixel($x, $y, [System.Drawing.Color]::Transparent); continue }
                $dst.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($opacity, $darkR, $darkG, $darkB))
            }
        }
    }

    $dst.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $dst.Dispose(); $src.Dispose()
    $kb = [math]::Round((Get-Item $outPath).Length / 1KB, 1)
    Write-Host "  $([IO.Path]::GetFileName($outPath))  ($kb KB)"
}

$sources = @(
    @{ Src = "logo-primary.png";      Stem = "logo-primary" },
    @{ Src = "logo-primary@2x.png";   Stem = "logo-primary@2x" },
    @{ Src = "logo-horizontal.png";   Stem = "logo-horizontal" },
    @{ Src = "logo-horizontal@2x.png"; Stem = "logo-horizontal@2x" }
)

Write-Host ""
Write-Host "Option A — Full Orange (dark→orange, grain→white)"
foreach ($s in $sources) {
    Remap-Logo (Join-Path $webDir $s.Src) (Join-Path $webDir "$($s.Stem)-orange.png") 229 76 0  255 255 255
}

Write-Host ""
Write-Host "Option C — White + Orange Accents (dark→white, grain→orange)"
foreach ($s in $sources) {
    Remap-Logo (Join-Path $webDir $s.Src) (Join-Path $webDir "$($s.Stem)-white.png") 255 255 255  229 76 0
}

Write-Host ""
Write-Host "Done. 8 files saved to: $webDir"
