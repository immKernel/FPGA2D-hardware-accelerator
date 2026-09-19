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
TRACE frame start:       x=0 y=0 DE=1 HS=0 VS=0
TRACE horizontal active end / front porch start: x=1920
TRACE HS rising edge:     x=2008
TRACE HS falling edge:    x=2052
TRACE vertical active end / front porch start: y=1080
TRACE VS rising edge:     y=1084
TRACE VS falling edge:    y=1089
TRACE frame wrap:         x=0 y=0
PASS: one complete 1920x1080 timing frame verified
      total periods = 2200 x 1125 = 2475000
      active pixels = 2073600
      HS = 44 clocks per line, VS = 5 lines per frame
PASS: asynchronous reset immediately clears counters and outputs
```

同一个`hdmi_timing_1080p.v`还会被第二个测试平台用标准720p参数重新例化：

```text
PASS: same RTL verified with 1280x720 timing parameters
      total periods = 1650 x 750 = 1237500
      active pixels = 921600
      74.25 MHz / 1237500 = 60 Hz
```

`tb_hdmi_timing_small.sv`使用缩小后的`14×7`总时序生成`hdmi_timing_small.vcd`。用GTKWave打开它，可以在一页内观察完整一帧：

```powershell
gtkwave hdmi_timing_small.vcd sim/hdmi_timing_small.gtkw
```

布局文件会自动加入`pixel_clk`、`reset_n`、`pixel_x`、`pixel_y`、`data_enable`、`hsync`和`vsync`。

完整中文原理说明见[第03课](../../docs/03-hdmi-video-timing.md)。

## Efinity综合检查

安装Efinity 2026.1后，在PowerShell运行：

```powershell
./synthesize.ps1
```

脚本只执行Map，不需要创建引脚工程。Ti60F225实测结果：

```text
map : PASS
EFX_ADD  : 22
EFX_LUT4 : 30
EFX_FF   : 24
```

这说明教学RTL不仅能仿真，也能被Efinity综合成实际FPGA计数器、比较器和触发器。
