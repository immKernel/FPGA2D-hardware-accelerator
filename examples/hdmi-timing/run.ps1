$ErrorActionPreference = "Stop"

iverilog -g2012 -s tb_hdmi_timing_1080p -o hdmi_timing_1080p.vvp `
  rtl/hdmi_timing_1080p.v sim/tb_hdmi_timing_1080p.sv
if ($LASTEXITCODE -ne 0) { throw "1080p testbench compilation failed" }
vvp hdmi_timing_1080p.vvp
if ($LASTEXITCODE -ne 0) { throw "1080p testbench failed" }

iverilog -g2012 -s tb_hdmi_timing_720p -o hdmi_timing_720p.vvp `
  rtl/hdmi_timing_1080p.v sim/tb_hdmi_timing_720p.sv
if ($LASTEXITCODE -ne 0) { throw "720p testbench compilation failed" }
vvp hdmi_timing_720p.vvp
if ($LASTEXITCODE -ne 0) { throw "720p testbench failed" }

iverilog -g2012 -s tb_hdmi_timing_small -o hdmi_timing_small.vvp `
  rtl/hdmi_timing_1080p.v sim/tb_hdmi_timing_small.sv
if ($LASTEXITCODE -ne 0) { throw "small timing testbench compilation failed" }
vvp hdmi_timing_small.vvp
if ($LASTEXITCODE -ne 0) { throw "small timing testbench failed" }

Write-Host "Open hdmi_timing_small.vcd in GTKWave to inspect the waveform."
