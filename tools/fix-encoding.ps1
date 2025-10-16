param(
  [string]$Root = ".",
  [string[]]$Extensions = @('.html', '.htm', '.css', '.js', '.json'),
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Encodings
$utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)   # no BOM, throw on invalid
$utf8NoBom  = New-Object System.Text.UTF8Encoding($false)           # no BOM
$enc1252    = [System.Text.Encoding]::GetEncoding(1252)

function Decode-Best([byte[]]$bytes) {
  try { return $utf8Strict.GetString($bytes) } catch { return $enc1252.GetString($bytes) }
}

function Has-SuspiciousChars([string]$text) {
  # common mojibake lead chars: Ã (C3), Â (C2), â (E2), Å (C5), plus U+FFFD
  return ($text.IndexOf([char]0x00C3) -ge 0 -or $text.IndexOf([char]0x00C2) -ge 0 -or 
          $text.IndexOf([char]0x00E2) -ge 0 -or $text.IndexOf([char]0x00C5) -ge 0 -or 
          $text.IndexOf([char]0xFFFD) -ge 0)
}

function Fix-DoubleDecoded([string]$text) {
  # Try to recover mojibake like Ã©, â€™, etc. by treating text as cp1252 bytes -> UTF-8
  $bytes = $enc1252.GetBytes($text)
  return $utf8NoBom.GetString($bytes)
}

function Fix-HtmlMeta([string]$text) {
  # Remove existing charset/meta content-type and insert <meta charset="utf-8"> at top of <head>
  $t = [regex]::Replace($text, '(?is)<meta\s+[^>]*charset\s*=\s*(["'']).*?\1[^>]*>\s*', '')
  $t = [regex]::Replace($t, '(?is)<meta\s+http-equiv\s*=\s*(["''])Content-Type\1[^>]*>\s*', '')
  $m = [regex]::Match($t, '(?is)<head\b[^>]*>')
  if ($m.Success) {
    $insertion = "{0}`r`n    <meta charset=""utf-8"">" -f $m.Value
    return $t.Substring(0, $m.Index) + $insertion + $t.Substring($m.Index + $m.Length)
  }
  return $t
}

function Fix-GoogleFonts([string]$text) {
  # Add latin-ext subset only for legacy css endpoint (not css2)
  return [regex]::Replace($text, '(?i)(https?://fonts\.googleapis\.com/css\?[^"''\s>]*)', {
    param($m)
    $url = $m.Groups[1].Value
    if ($url -match '/css2') { return $url } # css2 auto-handles subsets
    if ($url -match '([?&])subset=([^&"'']*)') {
      $cur = $matches[2]
      if ($cur -notmatch '(?i)latin-ext') { return $url -replace 'subset=([^&"'']*)', "subset=$cur,latin-ext" }
      return $url
    } else {
      return ($url + '&subset=latin-ext')
    }
  })
}

function Write-Utf8NoBom([string]$path, [string]$text) {
  if ($DryRun) { return }
  [System.IO.File]::WriteAllText($path, $text, $utf8NoBom)
}

function Process-TextFile([System.IO.FileInfo]$file) {
  $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
  $origText = Decode-Best $bytes
  $text = $origText

  $didDouble = $false
  if (Has-SuspiciousChars $text) {
    $text = Fix-DoubleDecoded $text
    $didDouble = $true
  }

  # Remove explicit replacement characters
  $beforeLen = $text.Length
  $text = $text.Replace([string]([char]0xFFFD), '')
  $removedFFFD = ($beforeLen - $text.Length)

  # HTML-specific fixes
  $metaFixed = $false; $fontsFixed = $false
  switch ($file.Extension.ToLower()) {
    '.html' { 
      $new = Fix-HtmlMeta $text
      if ($new -ne $text) { $text = $new; $metaFixed = $true }
      $new2 = Fix-GoogleFonts $text
      if ($new2 -ne $text) { $text = $new2; $fontsFixed = $true }
    }
    '.htm'  { 
      $new = Fix-HtmlMeta $text
      if ($new -ne $text) { $text = $new; $metaFixed = $true }
      $new2 = Fix-GoogleFonts $text
      if ($new2 -ne $text) { $text = $new2; $fontsFixed = $true }
    }
  }

  # Only write if something changed or to ensure utf8-no-bom
  $changed = $didDouble -or $removedFFFD -gt 0 -or $metaFixed -or $fontsFixed -or $true
  if ($changed) { Write-Utf8NoBom $file.FullName $text }

  $summary = @()
  if ($didDouble) { $summary += 'mojibake' }
  if ($removedFFFD -gt 0) { $summary += "removed-FFFD:$removedFFFD" }
  if ($metaFixed) { $summary += 'meta-utf8' }
  if ($fontsFixed) { $summary += 'latin-ext' }
  if ($summary.Count -gt 0) {
    Write-Host ("[fixed] {0} -> {1}" -f $file.FullName, ($summary -join ','))
  } else {
    Write-Host ("[rewrote] {0}" -f $file.FullName)
  }
}

# Collect all target files
$all = Get-ChildItem -Path $Root -Recurse -File | Where-Object { $Extensions -contains $_.Extension.ToLower() }
if (-not $all) { Write-Host "No target files found."; exit 0 }

foreach ($f in $all) { Process-TextFile $f }

Write-Host "Done. All files rewritten as UTF-8 (no BOM)."
