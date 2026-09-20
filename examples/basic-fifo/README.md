# Basic FIFO example

本目录配套 [`docs/05-fifo-foundations-to-advanced.md`](../../docs/05-fifo-foundations-to-advanced.md)。

内容：

- `rtl/basic_fifo.v`：固定 `8-bit × 8 entries` 的单时钟同步 FIFO。
- `sim/tb_basic_fifo.sv`：验证 Reset、FIFO 顺序、full、empty、overflow、underflow 和同时读写。
- `run.ps1`：使用 Icarus Verilog 编译并运行 testbench。

运行：

```powershell
cd examples/basic-fifo
./run.ps1
```

预期结果：

```text
PASS: basic_fifo completed all tests
```

生成的 `basic_fifo.vcd` 可使用 GTKWave 打开。
