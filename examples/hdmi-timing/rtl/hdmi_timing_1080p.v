// 1920x1080 progressive video timing generator.
//
// One rising edge of pixel_clk represents one pixel period. The module counts
// 2200 pixel periods per line and 1125 lines per frame, then derives DE, HS and
// VS from the current horizontal and vertical positions.

`timescale 1ns/1ps

module hdmi_timing_1080p #(
  parameter integer H_ACTIVE = 1920,
  parameter integer H_FRONT  = 88,
  parameter integer H_SYNC   = 44,
  parameter integer H_BACK   = 148,
  parameter integer V_ACTIVE = 1080,
  parameter integer V_FRONT  = 4,
  parameter integer V_SYNC   = 5,
  parameter integer V_BACK   = 36
) (
  input  wire        pixel_clk,
  input  wire        reset_n,
  output wire        hsync,
  output wire        vsync,
  output wire        data_enable,
  output wire [11:0] pixel_x,
  output wire [11:0] pixel_y
);

  localparam integer H_TOTAL = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;
  localparam integer V_TOTAL = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;

  reg [11:0] h_count;
  reg [11:0] v_count;

  // Raster counters: h_count advances every pixel clock. v_count advances
  // only when the final pixel period of a line has completed.
  always @(posedge pixel_clk or negedge reset_n) begin
    if (!reset_n) begin
      h_count <= 12'd0;
      v_count <= 12'd0;
    end else if (h_count == H_TOTAL - 1) begin
      h_count <= 12'd0;
      if (v_count == V_TOTAL - 1)
        v_count <= 12'd0;
      else
        v_count <= v_count + 1'b1;
    end else begin
      h_count <= h_count + 1'b1;
    end
  end

  // Pixels are meaningful only while both counters are inside the active area.
  assign data_enable = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

  // 1080p uses positive-polarity synchronization pulses. The pulse begins
  // after the active region and front porch, then lasts H_SYNC/V_SYNC periods.
  assign hsync = (h_count >= H_ACTIVE + H_FRONT) &&
                 (h_count <  H_ACTIVE + H_FRONT + H_SYNC);

  assign vsync = (v_count >= V_ACTIVE + V_FRONT) &&
                 (v_count <  V_ACTIVE + V_FRONT + V_SYNC);

  // Coordinates are valid only while data_enable is high.
  assign pixel_x = h_count;
  assign pixel_y = v_count;

endmodule
