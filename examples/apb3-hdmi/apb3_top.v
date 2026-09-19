// Teaching copy of the APB3 HDMI display-control peripheral.
// CPU base address: 0xF8100000
//   +0x00 CONTROL : bit 0 = sig, bit 1 = HDMI enable
//   +0x04 FB_ADDR : framebuffer pixel address (0..57599)
//   +0x08 FB_DATA : RGB565 pixel data; address auto-increments
//   +0x0C STATUS  : bit 0 = HDMI enable, bits 31:16 = 57600

`timescale 1ns/1ps

module apb3_top (
  input      [31:0] apb_paddr,
  input       [0:0] apb_psel,
  input             apb_penable,
  output            apb_pready,
  input             apb_pwrite,
  input      [31:0] apb_pwdata,
  output reg [31:0] apb_prdata,
  output            apb_pslverror,
  output            sig,
  output            hdmi_enable,
  output reg         fb_wr_en,
  output reg [15:0] fb_wr_addr,
  output reg [15:0] fb_wr_data,
  input             clk,
  input             reset
);

  localparam [31:0] REG_CONTROL = 32'h0000_0000;
  localparam [31:0] REG_FB_ADDR = 32'h0000_0004;
  localparam [31:0] REG_FB_DATA = 32'h0000_0008;
  localparam [31:0] REG_STATUS  = 32'h0000_000C;
  localparam [15:0] LAST_PIXEL  = 16'd57599;

  wire do_write;
  reg  sig_reg;
  reg  hdmi_enable_reg;
  reg [15:0] fb_addr_ptr;

  // Continuous combinational connections.
  assign apb_pready    = 1'b1;
  assign apb_pslverror = 1'b0;
  assign do_write      = apb_psel[0] && apb_penable && apb_pwrite;
  assign sig           = sig_reg;
  assign hdmi_enable   = hdmi_enable_reg;

  // Read path: PADDR immediately selects the value returned to the CPU.
  always @(*) begin
    case (apb_paddr)
      REG_CONTROL: apb_prdata = {30'd0, hdmi_enable_reg, sig_reg};
      REG_FB_ADDR: apb_prdata = {16'd0, fb_addr_ptr};
      REG_STATUS:  apb_prdata = {16'd57600, 15'd0, hdmi_enable_reg};
      default:     apb_prdata = 32'd0;
    endcase
  end

  // Write path: registers change only on a rising edge of clk.
  always @(posedge clk) begin
    if (reset) begin
      sig_reg         <= 1'b0;
      hdmi_enable_reg <= 1'b0;
      fb_wr_en        <= 1'b0;
      fb_addr_ptr     <= 16'd0;
      fb_wr_addr      <= 16'd0;
      fb_wr_data      <= 16'd0;
    end else begin
      // A FB_DATA transaction raises this for exactly one clock period.
      fb_wr_en <= 1'b0;

      if (do_write) begin
        case (apb_paddr)
          REG_CONTROL: begin
            sig_reg         <= apb_pwdata[0];
            hdmi_enable_reg <= apb_pwdata[1];
          end

          REG_FB_ADDR: begin
            if (apb_pwdata[15:0] <= LAST_PIXEL)
              fb_addr_ptr <= apb_pwdata[15:0];
          end

          REG_FB_DATA: begin
            if (fb_addr_ptr <= LAST_PIXEL) begin
              fb_wr_en   <= 1'b1;
              fb_wr_addr <= fb_addr_ptr;
              fb_wr_data <= apb_pwdata[15:0];
              if (fb_addr_ptr == LAST_PIXEL)
                fb_addr_ptr <= 16'd0;
              else
                fb_addr_ptr <= fb_addr_ptr + 1'b1;
            end
          end

          default: begin
          end
        endcase
      end
    end
  end

endmodule
