$ErrorActionPreference = "Stop"

iverilog -g2012 -s tb_basic_fifo -o basic_fifo.vvp `
  rtl/basic_fifo.v sim/tb_basic_fifo.sv
if ($LASTEXITCODE -ne 0) { throw "basic_fifo compilation failed" }

vvp basic_fifo.vvp
if ($LASTEXITCODE -ne 0) { throw "basic_fifo testbench failed" }

Write-Host "Waveform: gtkwave basic_fifo.vcd"
