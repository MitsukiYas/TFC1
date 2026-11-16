# Compares the nets tscircuit defines with the nets KiCad reads from the exported schematic.
#   powershell -File scripts\compare-netlist.ps1 control
# Run after export-kicad.ps1. Reports every pin whose net differs.
param([Parameter(Mandatory = $true)][string]$Board)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root "kicad\$Board"
$kicadCli = 'C:\Program Files\KiCad\10.0\bin\kicad-cli.exe'
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'Machine')

# --- tscircuit side: pin -> net, from circuit json ---
$json = Join-Path $out 'circuit.json'
Push-Location $root
try {
  $ErrorActionPreference = 'Continue'
  & tsci export "$Board.circuit.tsx" -f circuit-json -o $json 2>&1 | Out-Null
  $ErrorActionPreference = 'Stop'
} finally { Pop-Location }
$cj = Get-Content $json -Raw | ConvertFrom-Json
$comp = @{}; foreach ($c in $cj | Where-Object type -eq 'source_component') { $comp[$c.source_component_id] = $c.name }
$netName = @{}; foreach ($n in $cj | Where-Object type -eq 'source_net') { $netName[$n.source_net_id] = $n.name }
$ports = @{}; foreach ($p in $cj | Where-Object type -eq 'source_port') { $ports[$p.source_port_id] = $p }
$ts = @{}
foreach ($t in $cj | Where-Object type -eq 'source_trace') {
  $nets = @($t.connected_source_net_ids | ForEach-Object { $netName[$_] })
  foreach ($pid_ in $t.connected_source_port_ids) {
    $p = $ports[$pid_]
    $key = "$($comp[$p.source_component_id]).$($p.pin_number)"
    if ($nets.Count -gt 0) { $ts[$key] = $nets[0] }
  }
}

# --- KiCad side: pin -> net, from the schematic netlist ---
$net = Join-Path $out 'sch.net'
$rootSch = Join-Path $out "$Board.circuit.kicad_sch"
& $kicadCli sch export netlist --format kicadsexpr -o $net $rootSch | Out-Null
$text = Get-Content $net -Raw
$ki = @{}
$cur = ''; $ref = ''
foreach ($line in ($text.Substring($text.IndexOf('(nets')) -split "`n")) {
  if ($line -match '\(name "([^"]*)"\)') { $cur = $matches[1] }
  elseif ($line -match '\(ref "([^"]+)"\)') { $ref = $matches[1] }
  elseif ($line -match '\(pin "([^"]+)"\)') { $ki["$ref.$($matches[1])"] = $cur }
}

$bad = 0
foreach ($k in ($ts.Keys | Sort-Object)) {
  $kn = if ($ki.ContainsKey($k)) { $ki[$k] } else { '(sin conexion)' }
  if ($kn.TrimStart('/') -ne $ts[$k]) { "DIFERENTE  $k  tscircuit=$($ts[$k])  KiCad=$kn"; $bad++ }
}
# Pins KiCad connects to a net although tscircuit leaves them unconnected
foreach ($k in ($ki.Keys | Sort-Object)) {
  if ($k -like '#*' -or $ts.ContainsKey($k)) { continue }
  if ($ki[$k] -notlike 'unconnected-*') { "SOBRANTE   $k  KiCad=$($ki[$k])  (sin conexion en tscircuit)"; $bad++ }
}
"Pines comparados: $($ts.Count)   diferencias: $bad"
