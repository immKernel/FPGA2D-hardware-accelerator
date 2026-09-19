$ErrorActionPreference = "Stop"

$efinityRunner = "D:\efin\efinity\2026.1\bin\efx_run.bat"
if (-not (Test-Path -LiteralPath $efinityRunner)) {
  throw "Efinity runner not found: $efinityRunner"
}

& $efinityRunner hdmi_timing_1080p `
  -f map `
  --family Titanium `
  -d Ti60F225 `
  --timing_model I3 `
  -v rtl\hdmi_timing_1080p.v `
  --output_dir efinity_out `
  --work_dir efinity_work `
  --map_opts root=hdmi_timing_1080p

if ($LASTEXITCODE -ne 0) {
  throw "Efinity map failed with exit code $LASTEXITCODE"
}

Write-Host "Resource summary:"
Select-String -Path efinity_out\hdmi_timing_1080p.map.rpt `
  -Pattern '^EFX_(ADD|LUT4|FF|RAM10)' | ForEach-Object { $_.Line }
