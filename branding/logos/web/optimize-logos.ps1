Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$sourceDir   = Join-Path $projectRoot "logos"
$outputDir   = $PSScriptRoot

$jobs = @(
    @{ Source = "1.1-primary-logo-high-res.png"; Output = "logo-primary.png";       Width = 400 },
    @{ Source = "1.1-primary-logo-high-res.png"; Output = "logo-primary@2x.png";    Width = 800 },
    @{ Source = "1.2-horizontal-logo-high-res.png"; Output = "logo-horizontal.png"; Width = 600 },
    @{ Source = "1.2-horizontal-logo-high-res.png"; Output = "logo-horizontal@2x.png"; Width = 1200 }
)

foreach ($job in $jobs) {
    $srcPath = Join-Path $sourceDir $job.Source
    $outPath = Join-Path $outputDir $job.Output

    $src = [System.Drawing.Bitmap]::new($srcPath)

    $ratio  = $job.Width / $src.Width
    $height = [int]($src.Height * $ratio)
    $dst    = [System.Drawing.Bitmap]::new($job.Width, $height)

    $g = [System.Drawing.Graphics]::FromImage($dst)
    $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.DrawImage($src, 0, 0, $job.Width, $height)
    $g.Dispose()

    $dst.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $dst.Dispose()
    $src.Dispose()

    $kb = [math]::Round((Get-Item $outPath).Length / 1KB, 1)
    Write-Host "  $($job.Output)  →  $($job.Width)x$height px  ($kb KB)"
}

Write-Host ""
Write-Host "Done. Web-optimized logos saved to: $outputDir"
