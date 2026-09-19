# HDMI 1080p 时序教学工程

本工程只重点研究一个 RTL 文件：[`rtl/hdmi_timing_1080p.v`](rtl/hdmi_timing_1080p.v)。

Windows PowerShell运行：

```powershell
./run.ps1
```

也可以手动运行完整1080p检查：

```powershell
iverilog -g2012 -s tb_hdmi_timing_1080p -o hdmi_timing_1080p.vvp rtl/hdmi_timing_1080p.v sim/tb_hdmi_timing_1080p.sv
vvp hdmi_timing_1080p.vvp
```

预期结果：

```text
PASS: one complete 1920x1080 timing frame verified
      total periods = 2200 x 1125 = 2475000
      active pixels = 2073600
      HS = 44 clocks per line, VS = 5 lines per frame
```

`tb_hdmi_timing_small.sv`使用缩小后的`14×7`总时序生成`hdmi_timing_small.vcd`。用GTKWave打开它，可以在一页内观察完整一帧：

```powershell
gtkwave hdmi_timing_small.vcd
```

完整中文原理说明见[第02课](../../docs/02-hdmi-video-timing.md)。
