`timescale 1ns/1ps

module tb_hdmi_timing_1080p;
  localparam integer H_ACTIVE = 1920;
  localparam integer H_FRONT  = 88;
  localparam integer H_SYNC   = 44;
  localparam integer H_BACK   = 148;
  localparam integer H_TOTAL  = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;
  localparam integer V_ACTIVE = 1080;
  localparam integer V_FRONT  = 4;
  localparam integer V_SYNC   = 5;
  localparam integer V_BACK   = 36;
  localparam integer V_TOTAL  = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;

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
  integer hsync_pixels;
  integer vsync_lines;
  reg expected_de;
  reg expected_hs;
  reg expected_vs;

  // 148.5 MHz nominal pixel clock: period is approximately 6.734 ns.
  always #3.367 pixel_clk = ~pixel_clk;

  hdmi_timing_1080p dut (
    .pixel_clk   (pixel_clk),
    .reset_n     (reset_n),
    .hsync       (hsync),
    .vsync       (vsync),
    .data_enable (data_enable),
    .pixel_x     (pixel_x),
    .pixel_y     (pixel_y)
  );

  initial begin
    repeat (3) @(negedge pixel_clk);
    reset_n = 1'b1;

    active_pixels = 0;
    hsync_pixels = 0;
    vsync_lines = 0;

    // Check every pixel period of one complete 2200 x 1125 frame.
    for (y = 0; y < V_TOTAL; y = y + 1) begin
      for (x = 0; x < H_TOTAL; x = x + 1) begin
        expected_de = (x < H_ACTIVE) && (y < V_ACTIVE);
        expected_hs = (x >= H_ACTIVE + H_FRONT) &&
                      (x <  H_ACTIVE + H_FRONT + H_SYNC);
        expected_vs = (y >= V_ACTIVE + V_FRONT) &&
                      (y <  V_ACTIVE + V_FRONT + V_SYNC);

        if (pixel_x !== x || pixel_y !== y)
          $fatal(1, "coordinate mismatch: expected (%0d,%0d), got (%0d,%0d)",
                 x, y, pixel_x, pixel_y);
        if (data_enable !== expected_de)
          $fatal(1, "DE mismatch at (%0d,%0d)", x, y);
        if (hsync !== expected_hs)
          $fatal(1, "HS mismatch at (%0d,%0d)", x, y);
        if (vsync !== expected_vs)
          $fatal(1, "VS mismatch at (%0d,%0d)", x, y);

        if (data_enable)
          active_pixels = active_pixels + 1;
        if (hsync)
          hsync_pixels = hsync_pixels + 1;
        if (x == 0 && vsync)
          vsync_lines = vsync_lines + 1;

        // Print one representative horizontal line and every vertical boundary.
        if (y == 0 && x == 0)
          $display("TRACE frame start:       x=%0d y=%0d DE=%0b HS=%0b VS=%0b", x, y, data_enable, hsync, vsync);
        if (y == 0 && x == H_ACTIVE)
          $display("TRACE horizontal active end / front porch start: x=%0d", x);
        if (y == 0 && x == H_ACTIVE + H_FRONT)
          $display("TRACE HS rising edge:     x=%0d", x);
        if (y == 0 && x == H_ACTIVE + H_FRONT + H_SYNC)
          $display("TRACE HS falling edge:    x=%0d", x);
        if (x == 0 && y == V_ACTIVE)
          $display("TRACE vertical active end / front porch start: y=%0d", y);
        if (x == 0 && y == V_ACTIVE + V_FRONT)
          $display("TRACE VS rising edge:     y=%0d", y);
        if (x == 0 && y == V_ACTIVE + V_FRONT + V_SYNC)
          $display("TRACE VS falling edge:    y=%0d", y);

        @(negedge pixel_clk);
      end
    end

    if (active_pixels != H_ACTIVE * V_ACTIVE)
      $fatal(1, "active pixel count mismatch: %0d", active_pixels);
    if (hsync_pixels != H_SYNC * V_TOTAL)
      $fatal(1, "HS width/count mismatch: %0d", hsync_pixels);
    if (vsync_lines != V_SYNC)
      $fatal(1, "VS line count mismatch: %0d", vsync_lines);
    if (pixel_x !== 0 || pixel_y !== 0)
      $fatal(1, "counters did not wrap at frame boundary");

    $display("TRACE frame wrap:        x=%0d y=%0d", pixel_x, pixel_y);
    $display("PASS: one complete 1920x1080 timing frame verified");
    $display("      total periods = %0d x %0d = %0d", H_TOTAL, V_TOTAL,
             H_TOTAL * V_TOTAL);
    $display("      active pixels = %0d", active_pixels);
    $display("      HS = %0d clocks per line, VS = %0d lines per frame",
             H_SYNC, V_SYNC);
    $finish;
  end

endmodule
