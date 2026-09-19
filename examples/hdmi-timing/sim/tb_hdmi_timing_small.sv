`timescale 1ns/1ps

// A deliberately tiny mode for viewing the complete waveform without a huge
// VCD file. The RTL is unchanged; only its timing parameters are overridden.
module tb_hdmi_timing_small;
  reg pixel_clk = 1'b0;
  reg reset_n = 1'b0;
  wire hsync;
  wire vsync;
  wire data_enable;
  wire [11:0] pixel_x;
  wire [11:0] pixel_y;

  always #5 pixel_clk = ~pixel_clk;

  hdmi_timing_1080p #(
    .H_ACTIVE(8), .H_FRONT(2), .H_SYNC(2), .H_BACK(2),
    .V_ACTIVE(4), .V_FRONT(1), .V_SYNC(1), .V_BACK(1)
  ) dut (
    .pixel_clk(pixel_clk), .reset_n(reset_n),
    .hsync(hsync), .vsync(vsync), .data_enable(data_enable),
    .pixel_x(pixel_x), .pixel_y(pixel_y)
  );

  initial begin
    $dumpfile("hdmi_timing_small.vcd");
    $dumpvars(0, tb_hdmi_timing_small);
    repeat (2) @(negedge pixel_clk);
    reset_n = 1'b1;
    repeat (14 * 7 + 2) @(negedge pixel_clk);
    $display("PASS: tiny waveform generated in hdmi_timing_small.vcd");
    $finish;
  end
endmodule
