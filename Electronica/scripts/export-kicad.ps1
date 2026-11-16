# Exports a tscircuit board to a KiCad project and checks it with KiCad's own tools.
#
#   powershell -File scripts\export-kicad.ps1 potencia
#
# Reads   <Electronica>\<board>.circuit.tsx
# Writes  <Electronica>\kicad\<board>\   (replaced on every run: edits made in KiCad are lost)
#
# After exporting it turns local labels into global labels in every schematic sheet.
# tscircuit exports nets shared between sheets as local labels, which KiCad does not
# connect across sheets; global labels make the schematic nets match the PCB nets.
param(
  [Parameter(Mandatory = $true)][string]$Board,
  [switch]$ConPcb   # also run the PCB checks (DRC and schematic parity); off while there are no footprints
)
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root "$Board.circuit.tsx"
$outRoot = Join-Path $root 'kicad'
$out = Join-Path $outRoot $Board
$kicadCli = 'C:\Program Files\KiCad\10.0\bin\kicad-cli.exe'

if (-not (Test-Path $src)) { throw "No existe $src" }
if (-not (Test-Path $kicadCli)) { throw "No se encontro kicad-cli en $kicadCli" }

# tsci and bun may be missing from PATH in shells opened before they were installed
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'Machine')

New-Item -ItemType Directory -Force $outRoot | Out-Null
$zip = Join-Path $outRoot "$Board.zip"

Push-Location $root
try {
  $ErrorActionPreference = 'Continue'
  & tsci export "$Board.circuit.tsx" -f kicad_zip -o $zip 2>&1 | ForEach-Object { "$_" }
  $ErrorActionPreference = 'Stop'
} finally { Pop-Location }
if (-not (Test-Path $zip)) { throw 'tsci export no genero el archivo' }

if (Test-Path $out) { Remove-Item $out -Recurse -Force -Confirm:$false }
Expand-Archive $zip $out -Force
Remove-Item $zip -Confirm:$false

# Local labels -> global labels, and junctions where a wire ends on the middle of another wire.
# tscircuit draws those T joins without a junction, and KiCad then treats the wires as separate.
$changed = 0
$junctions = 0
$inv = [Globalization.CultureInfo]::InvariantCulture
$wireRx = '\(wire\s*\(pts\s*\(xy\s+(-?[\d.]+)\s+(-?[\d.]+)\)\s*\(xy\s+(-?[\d.]+)\s+(-?[\d.]+)\)'
foreach ($sch in Get-ChildItem $out -Recurse -Filter *.kicad_sch) {
  $text = [IO.File]::ReadAllText($sch.FullName)
  $n = ([regex]::Matches($text, '\(label "')).Count
  $text = $text.Replace('(label "', '(global_label "')
  $changed += $n

  $wires = @(foreach ($m in [regex]::Matches($text, $wireRx)) {
    , @([double]::Parse($m.Groups[1].Value, $inv), [double]::Parse($m.Groups[2].Value, $inv),
        [double]::Parse($m.Groups[3].Value, $inv), [double]::Parse($m.Groups[4].Value, $inv))
  })
  $tol = 0.01
  $seen = @{}
  $add = New-Object System.Text.StringBuilder
  foreach ($w in $wires) {
    foreach ($pt in @(@($w[0], $w[1]), @($w[2], $w[3]))) {
      $px = $pt[0]; $py = $pt[1]
      foreach ($o in $wires) {
        if ([object]::ReferenceEquals($o, $w)) { continue }
        $dx = $o[2] - $o[0]; $dy = $o[3] - $o[1]
        $len2 = $dx * $dx + $dy * $dy
        if ($len2 -lt 1e-9) { continue }
        $t = (($px - $o[0]) * $dx + ($py - $o[1]) * $dy) / $len2
        if ($t -le 0.001 -or $t -ge 0.999) { continue }           # only strictly inside the other wire
        $cx = $o[0] + $t * $dx; $cy = $o[1] + $t * $dy
        if ([math]::Abs($cx - $px) -gt $tol -or [math]::Abs($cy - $py) -gt $tol) { continue }
        $key = '{0:F3},{1:F3}' -f $px, $py
        if ($seen.ContainsKey($key)) { continue }
        $seen[$key] = $true
        $id = [guid]::NewGuid().ToString()
        [void]$add.AppendLine(('  (junction (at {0} {1}) (diameter 0) (color 0 0 0 0) (uuid "{2}"))' -f
          $px.ToString($inv), $py.ToString($inv), $id))
        $junctions++
      }
    }
  }
  if ($add.Length -gt 0) {
    $i = $text.LastIndexOf(')')
    $text = $text.Substring(0, $i) + "`n" + $add.ToString() + ')' + $text.Substring($i + 1)
  }
  [IO.File]::WriteAllText($sch.FullName, $text)
}
"Etiquetas locales convertidas a globales: $changed"
"Uniones anadidas en cruces en T: $junctions"

# KiCad checks
$rootSch = Get-ChildItem $out -Filter "$Board.circuit.kicad_sch" | Select-Object -First 1
$pcb = Get-ChildItem $out -Filter *.kicad_pcb | Select-Object -First 1
$erc = Join-Path $out 'erc.rpt'
$drc = Join-Path $out 'drc.rpt'
& $kicadCli sch erc -o $erc $rootSch.FullName | Out-Null

# KiCad only connects a pin that sits on the END of a wire. tscircuit sometimes runs a wire
# straight through a pin, so split wires at every pin that ERC reports as unconnected.
$wireBlockRx = '\(wire\s*\(pts\s*\(xy\s+(-?[\d.]+)\s+(-?[\d.]+)\)\s*\(xy\s+(-?[\d.]+)\s+(-?[\d.]+)\)\s*\)\s*(\(stroke\s*\(width [^)]*\)\s*\(type [^)]*\)\s*\))\s*\(uuid\s+[^)]+\)\s*\)'
$splits = 0
for ($pass = 0; $pass -lt 3; $pass++) {
  $pts = @(Select-String -Path $erc -Pattern '^\s*@\(([\d.-]+) mm, ([\d.-]+) mm\): Symbol .* Pin ' | ForEach-Object {
    , @([double]::Parse($_.Matches[0].Groups[1].Value, $inv), [double]::Parse($_.Matches[0].Groups[2].Value, $inv))
  })
  if ($pts.Count -eq 0) { break }
  $before = $splits
  foreach ($sch in Get-ChildItem $out -Recurse -Filter *.kicad_sch) {
    $text = [IO.File]::ReadAllText($sch.FullName)
    $new = [regex]::Replace($text, $wireBlockRx, {
      param($m)
      $x1 = [double]::Parse($m.Groups[1].Value, $inv); $y1 = [double]::Parse($m.Groups[2].Value, $inv)
      $x2 = [double]::Parse($m.Groups[3].Value, $inv); $y2 = [double]::Parse($m.Groups[4].Value, $inv)
      $dx = $x2 - $x1; $dy = $y2 - $y1; $len2 = $dx * $dx + $dy * $dy
      if ($len2 -lt 1e-9) { return $m.Value }
      foreach ($p in $pts) {
        $t = (($p[0] - $x1) * $dx + ($p[1] - $y1) * $dy) / $len2
        if ($t -le 0.001 -or $t -ge 0.999) { continue }
        if ([math]::Abs($x1 + $t * $dx - $p[0]) -gt 0.01 -or [math]::Abs($y1 + $t * $dy - $p[1]) -gt 0.01) { continue }
        $script:splits++
        $px = $p[0].ToString($inv); $py = $p[1].ToString($inv)
        $a = '(wire (pts (xy {0} {1}) (xy {2} {3})) {4} (uuid "{5}"))' -f $m.Groups[1].Value, $m.Groups[2].Value, $px, $py, $m.Groups[5].Value, [guid]::NewGuid()
        $b = '(wire (pts (xy {0} {1}) (xy {2} {3})) {4} (uuid "{5}"))' -f $px, $py, $m.Groups[3].Value, $m.Groups[4].Value, $m.Groups[5].Value, [guid]::NewGuid()
        return "$a`n  $b"
      }
      return $m.Value
    })
    if ($new -ne $text) { [IO.File]::WriteAllText($sch.FullName, $new) }
  }
  if ($splits -eq $before) { break }
  & $kicadCli sch erc -o $erc $rootSch.FullName | Out-Null
}
"Cables divididos en pines intermedios: $splits"

# Some exported symbols have their pins a fraction of a grid step away from where the wire ends.
# Where ERC reports an unconnected pin and a dangling wire end within 1.3 mm on the same sheet,
# join them with a short wire. compare-netlist.ps1 verifies the result against tscircuit.
$sheetFile = @{ '/' = $rootSch.FullName }
$rootText = [IO.File]::ReadAllText($rootSch.FullName)
foreach ($m in [regex]::Matches($rootText, '\(property "Sheetname" "([^"]+)"[\s\S]*?\(property "Sheetfile" "([^"]+)"')) {
  $sheetFile["/$($m.Groups[1].Value)/"] = Join-Path $out $m.Groups[2].Value
}
$bridges = 0
$sheet = '/'; $kind = ''
$pins = @(); $ends = @()
foreach ($line in Get-Content $erc) {
  if ($line -match '^\*+ Sheet (.+)$') { $sheet = $matches[1].Trim(); continue }
  if ($line -match '^\[(\w+)\]') { $kind = $matches[1]; continue }
  if ($line -match '^\s*@\(([\d.-]+) mm, ([\d.-]+) mm\)') {
    $pt = [pscustomobject]@{ sheet = $sheet; x = [double]::Parse($matches[1], $inv); y = [double]::Parse($matches[2], $inv) }
    if ($kind -eq 'pin_not_connected') { $pins += $pt }
    elseif ($kind -eq 'unconnected_wire_endpoint') { $ends += $pt }
  }
}
foreach ($p in $pins) {
  $near = $ends | Where-Object { $_.sheet -eq $p.sheet } |
    ForEach-Object { $_ | Add-Member -NotePropertyName d -NotePropertyValue ([math]::Sqrt(($_.x - $p.x) * ($_.x - $p.x) + ($_.y - $p.y) * ($_.y - $p.y))) -Force -PassThru } |
    Where-Object { $_.d -gt 0.001 -and $_.d -le 1.3 } | Sort-Object d | Select-Object -First 1
  if (-not $near -or -not $sheetFile.ContainsKey($p.sheet)) { continue }
  $file = $sheetFile[$p.sheet]
  $text = [IO.File]::ReadAllText($file)
  $w = '  (wire (pts (xy {0} {1}) (xy {2} {3})) (stroke (width 0) (type default)) (uuid "{4}"))' -f
    $p.x.ToString($inv), $p.y.ToString($inv), $near.x.ToString($inv), $near.y.ToString($inv), [guid]::NewGuid()
  $i = $text.LastIndexOf(')')
  [IO.File]::WriteAllText($file, $text.Substring(0, $i) + $w + "`n)" + $text.Substring($i + 1))
  $bridges++
}
if ($bridges -gt 0) { & $kicadCli sch erc -o $erc $rootSch.FullName | Out-Null }
"Pines unidos a cables cercanos: $bridges"
if ($ConPcb) { & $kicadCli pcb drc --schematic-parity -o $drc $pcb.FullName | Out-Null }

# Library warnings are expected: tscircuit embeds its own symbols and footprints
$expected = 'lib_symbol_issues|lib_footprint_issues|footprint_symbol_mismatch|footprint_symbol_field_mismatch'
function Show-Report($title, $path) {
  $items = Get-Content $path | Where-Object { $_ -match '^\[' }
  $real = @($items | Where-Object { $_ -notmatch $expected })
  "{0}: {1} avisos ({2} esperados de biblioteca, {3} por revisar)" -f $title, @($items).Count, (@($items).Count - $real.Count), $real.Count
  $real | Group-Object | ForEach-Object { "   x{0}  {1}" -f $_.Count, $_.Name }
}
Show-Report 'ERC' $erc
if ($ConPcb) { Show-Report 'DRC' $drc }
& $kicadCli sch export pdf -o (Join-Path $out "$Board.pdf") $rootSch.FullName | Out-Null
& (Join-Path $PSScriptRoot 'compare-netlist.ps1') $Board
"Proyecto KiCad: $out"
