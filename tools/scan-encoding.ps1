param(
  [string]$Root = ".",
  [string[]]$Extensions = @('.html', '.htm', '.css', '.js', '.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$enc1252    = [System.Text.Encoding]::GetEncoding(1252)

function Decode-Best([byte[]]$bytes) {
  try { return $utf8Strict.GetString($bytes) } catch { return $enc1252.GetString($bytes) }
}

$hasIssues = $false
$files = Get-ChildItem -Path $Root -Recurse -File | Where-Object { $Extensions -contains $_.Extension.ToLower() }

foreach ($f in $files) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)

  # Check for UTF-8 BOM
  $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

  $text = Decode-Best $bytes
  # Target known mojibake sequences and the replacement character
  $hits = @()
  if ($text.IndexOf([char]0xFFFD) -ge 0) { $hits += '[U+FFFD]' }
  $tokens = @(
    [string]([char]0x00C3),  # Ã
    [string]([char]0x00C2),  # Â
    [string]([char]0x00C5),  # Å
    "â€",                    # common prefix for mojibake punctuation (â€˜ â€œ â€� … — –)
    "â‚¬"                     # euro sign mojibake
  )
  foreach ($t in $tokens) { if ($text.Contains($t)) { $hits += $t } }

  # HTML meta charset at head top check (lightweight)
  $metaAtTop = $true
  if ($f.Extension.ToLower() -in @('.html','.htm')) {
    $head = [regex]::Match($text, '(?is)<head\b[^>]*>(.*?)</head>')
    if ($head.Success) {
      $inner = $head.Groups[1].Value.TrimStart()
      $metaAtTop = $inner -match '^(<meta\s+charset=\"?utf-8\"?[^>]*>)'
    }
  }

  if ($hasBom -or $hits.Count -gt 0 -or -not $metaAtTop) {
    $hasIssues = $true
    $parts = @()
    if ($hasBom) { $parts += 'BOM' }
    if ($hits.Count -gt 0) { $parts += ("suspicious:{0}" -f (($hits | Sort-Object -Unique) -join ' ')) }
    if (-not $metaAtTop -and $f.Extension -in '.html','.htm') { $parts += 'meta-missing-or-not-top' }
    Write-Host ("[issue] {0} -> {1}" -f $f.FullName, ($parts -join ', '))
  }
}

if (-not $hasIssues) { Write-Host 'No encoding issues detected (no BOM, no suspicious chars, meta ok).'}
