Add-Type -AssemblyName System.Drawing

$contentDir = 'C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB\.superpowers\brainstorm\1000-1774828463\content'

function B64($name) {
    $path = Join-Path $contentDir "$name.png"
    $bytes = [IO.File]::ReadAllBytes($path)
    return [Convert]::ToBase64String($bytes)
}

Write-Host "Encoding images..."
$pa = B64 'logo-primary-a'
$pb = B64 'logo-primary-b'
$pc = B64 'logo-primary-c'
$ha = B64 'logo-horizontal-a'
$hb = B64 'logo-horizontal-b'
$hc = B64 'logo-horizontal-c'
Write-Host "Done encoding. Building HTML..."

$html = @"
<h2>Inverse Logo Options — Dark Header</h2>
<p class="subtitle">All three versions shown on the actual Timber Slate background (#323434). Click a card to select your preferred direction.</p>

<style>
  .logo-cards { display:flex; gap:20px; flex-wrap:wrap; margin-top:8px; }
  .logo-card { flex:1; min-width:260px; border:2px solid #3a3a4a; border-radius:10px; overflow:hidden; cursor:pointer; transition:border-color 0.2s,transform 0.15s; background:#1e1e2e; }
  .logo-card:hover { border-color:#6060aa; transform:translateY(-2px); }
  .logo-card.selected { border-color:#e54c00 !important; box-shadow:0 0 0 3px rgba(229,76,0,0.3); }
  .header-sim { background:#323434; padding:20px 24px; display:flex; flex-direction:column; align-items:center; gap:16px; border-bottom:3px solid #2a2a2a; }
  .header-sim img { max-height:68px; width:auto; display:block; }
  .horiz-logo { max-width:100%; max-height:42px !important; }
  .card-footer { padding:14px 16px; }
  .card-footer h3 { margin:0 0 4px; font-size:15px; color:#eee; }
  .card-footer p { margin:0; font-size:13px; color:#999; line-height:1.4; }
  .option-label { display:inline-block; background:#e54c00; color:white; font-weight:700; font-size:11px; letter-spacing:0.08em; padding:2px 8px; border-radius:4px; margin-bottom:6px; text-transform:uppercase; }
  .section-label { font-size:10px; letter-spacing:0.1em; text-transform:uppercase; color:#555; margin:0 0 3px; font-weight:600; text-align:center; }
</style>

<div class="logo-cards">
  <div class="logo-card" data-choice="a" onclick="toggleSelect(this)">
    <div class="header-sim">
      <div><p class="section-label">Stacked</p><img src="data:image/png;base64,$pa" /></div>
      <div><p class="section-label">Horizontal</p><img src="data:image/png;base64,$ha" class="horiz-logo" /></div>
    </div>
    <div class="card-footer">
      <span class="option-label">A</span>
      <h3>Full Orange</h3>
      <p>Everything in Crafted Orange — state, text, icon unified. Grain lines become white. Bold and high-contrast.</p>
    </div>
  </div>
  <div class="logo-card" data-choice="b" onclick="toggleSelect(this)">
    <div class="header-sim">
      <div><p class="section-label">Stacked</p><img src="data:image/png;base64,$pb" /></div>
      <div><p class="section-label">Horizontal</p><img src="data:image/png;base64,$hb" class="horiz-logo" /></div>
    </div>
    <div class="card-footer">
      <span class="option-label">B</span>
      <h3>Sky Blue + Orange</h3>
      <p>State shape and text in Wisconsin Sky Blue. Grain lines and outline stay Crafted Orange. Two-tone outdoor feel.</p>
    </div>
  </div>
  <div class="logo-card" data-choice="c" onclick="toggleSelect(this)">
    <div class="header-sim">
      <div><p class="section-label">Stacked</p><img src="data:image/png;base64,$pc" /></div>
      <div><p class="section-label">Horizontal</p><img src="data:image/png;base64,$hc" class="horiz-logo" /></div>
    </div>
    <div class="card-footer">
      <span class="option-label">C</span>
      <h3>White + Orange Accents</h3>
      <p>State shape and text in white. Grain lines and outline in Crafted Orange. Clean, classic light-on-dark look.</p>
    </div>
  </div>
</div>

<p style="margin-top:16px;font-size:12px;color:#666;"><strong style="color:#888">Note:</strong> The raster PNG uses the same color for both text and state shape, so they remap together. To independently color text vs. icon, we can recreate in SVG.</p>
"@

$outPath = Join-Path $contentDir 'logo-options-v2.html'
[IO.File]::WriteAllText($outPath, $html, [Text.Encoding]::UTF8)
Write-Host "Written to: $outPath"
