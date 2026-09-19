`timescale 1ns/1ps

// Reuse the exact same RTL with standard 1280x720p60 timing parameters.
module tb_hdmi_timing_720p;
  localparam integer H_ACTIVE = 1280;
  localparam integer H_FRONT  = 110;
  localparam integer H_SYNC   = 40;
  localparam integer H_BACK   = 220;
  localparam integer H_TOTAL  = 1650;
  localparam integer V_ACTIVE = 720;
  localparam integer V_FRONT  = 5;
  localparam integer V_SYNC   = 5;
  localparam integer V_BACK   = 20;
  localparam integer V_TOTAL  = 750;

  reg pixel_clk = 1'b0;
  reg reset_n = 1'b0;
  wire hsync;
  wire vsync;
  wire data_enable;
  wire [11:0] pixel_x;
  wire [11:0] pixel_y;
  integer x;
  integer y;
  integer active_pixels;

  // 74.25 MHz nominal clock, approximately 13.468 ns per pixel period.
  always #6.734 pixel_clk = ~pixel_clk;

  hdmi_timing_1080p #(
    .H_ACTIVE(H_ACTIVE), .H_FRONT(H_FRONT),
    .H_SYNC(H_SYNC),     .H_BACK(H_BACK),
    .V_ACTIVE(V_ACTIVE), .V_FRONT(V_FRONT),
    .V_SYNC(V_SYNC),     .V_BACK(V_BACK)
  ) dut (
    .pixel_clk(pixel_clk), .reset_n(reset_n),
    .hsync(hsync), .vsync(vsync), .data_enable(data_enable),
    .pixel_x(pixel_x), .pixel_y(pixel_y)
  );

  initial begin
    repeat (2) @(negedge pixel_clk);
    reset_n = 1'b1;
    #0.001;
    active_pixels = 0;

    for (y = 0; y < V_TOTAL; y = y + 1) begin
      for (x = 0; x < H_TOTAL; x = x + 1) begin
        if (pixel_x !== x || pixel_y !== y)
          $fatal(1, "720p coordinate mismatch at (%0d,%0d)", x, y);
        if (data_enable !== ((x < H_ACTIVE) && (y < V_ACTIVE)))
          $fatal(1, "720p DE mismatch at (%0d,%0d)", x, y);
        if (hsync !== ((x >= H_ACTIVE + H_FRONT) &&
                       (x < H_ACTIVE + H_FRONT + H_SYNC)))
          $fatal(1, "720p HS mismatch at (%0d,%0d)", x, y);
        if (vsync !== ((y >= V_ACTIVE + V_FRONT) &&
                       (y < V_ACTIVE + V_FRONT + V_SYNC)))
          $fatal(1, "720p VS mismatch at (%0d,%0d)", x, y);
        if (data_enable)
          active_pixels = active_pixels + 1;
        @(negedge pixel_clk);
      end
    end

    if (active_pixels != H_ACTIVE * V_ACTIVE)
      $fatal(1, "720p active pixel count mismatch: %0d", active_pixels);
    if (pixel_x !== 0 || pixel_y !== 0)
      $fatal(1, "720p frame did not wrap to (0,0)");

    $display("PASS: same RTL verified with 1280x720 timing parameters");
    $display("      total periods = 1650 x 750 = 1237500");
    $display("      active pixels = %0d", active_pixels);
    $display("      74.25 MHz / 1237500 = 60 Hz");
    $finish;
  end
endmodule
