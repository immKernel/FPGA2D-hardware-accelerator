$ErrorActionPreference = "Stop"

iverilog -g2012 -s tb_hdmi_timing_1080p -o hdmi_timing_1080p.vvp `
  rtl/hdmi_timing_1080p.v sim/tb_hdmi_timing_1080p.sv
vvp hdmi_timing_1080p.vvp

iverilog -g2012 -s tb_hdmi_timing_small -o hdmi_timing_small.vvp `
  rtl/hdmi_timing_1080p.v sim/tb_hdmi_timing_small.sv
vvp hdmi_timing_small.vvp

Write-Host "Open hdmi_timing_small.vcd in GTKWave to inspect the waveform."
