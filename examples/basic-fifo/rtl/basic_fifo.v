`timescale 1ns/1ps
`default_nettype none

// Minimal single-clock FIFO for learning.
// Fixed configuration: 8-bit data, 8 entries, synchronous read output.
module basic_fifo (
    input  wire       clk,
    input  wire       rst_n,

    input  wire       wr_en,
    input  wire [7:0] din,

    input  wire       rd_en,
    output reg  [7:0] dout,

    output wire       full,
    output wire       empty,
    output reg  [3:0] count
);

    reg [7:0] mem [0:7];
    reg [2:0] wr_ptr;
    reg [2:0] rd_ptr;

    wire do_write;
    wire do_read;

    assign full  = (count == 4'd8);
    assign empty = (count == 4'd0);

    assign do_write = wr_en && !full;
    assign do_read  = rd_en && !empty;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 3'd0;
            rd_ptr <= 3'd0;
            dout   <= 8'd0;
            count  <= 4'd0;
        end else begin
            if (do_write) begin
                mem[wr_ptr] <= din;
                wr_ptr      <= wr_ptr + 1'b1;
            end

            if (do_read) begin
                dout   <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end

            case ({do_write, do_read})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

endmodule

`default_nettype wire
