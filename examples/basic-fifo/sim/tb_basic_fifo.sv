`timescale 1ns/1ps
`default_nettype none

module tb_basic_fifo;

    logic       clk = 1'b0;
    logic       rst_n = 1'b0;
    logic       wr_en = 1'b0;
    logic [7:0] din = 8'h00;
    logic       rd_en = 1'b0;
    wire  [7:0] dout;
    wire        full;
    wire        empty;
    wire  [3:0] count;

    basic_fifo dut (
        .clk   (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .din   (din),
        .rd_en (rd_en),
        .dout  (dout),
        .full  (full),
        .empty (empty),
        .count (count)
    );

    always #5 clk = ~clk;

    task automatic tick;
        @(posedge clk);
        #1;
    endtask

    task automatic write_byte(input logic [7:0] value);
        begin
            din   = value;
            wr_en = 1'b1;
            tick();
            wr_en = 1'b0;
        end
    endtask

    task automatic read_and_expect(input logic [7:0] expected);
        begin
            rd_en = 1'b1;
            tick();
            rd_en = 1'b0;
            if (dout !== expected)
                $fatal(1, "FIFO mismatch: expected %02h, got %02h", expected, dout);
        end
    endtask

    integer i;

    initial begin
        $dumpfile("basic_fifo.vcd");
        $dumpvars(0, tb_basic_fifo);

        repeat (2) tick();
        rst_n = 1'b1;
        tick();

        if (!empty || full || count != 0)
            $fatal(1, "Reset state is incorrect");

        // Basic FIFO order.
        write_byte(8'h11);
        write_byte(8'h22);
        write_byte(8'h33);
        if (count != 3)
            $fatal(1, "Count should be 3 after three writes");

        read_and_expect(8'h11);
        read_and_expect(8'h22);
        read_and_expect(8'h33);
        if (!empty || count != 0)
            $fatal(1, "FIFO should be empty after draining");

        // Fill the FIFO and prove an overflow request is ignored.
        for (i = 0; i < 8; i = i + 1)
            write_byte(8'h40 + i[7:0]);

        if (!full || count != 8)
            $fatal(1, "FIFO should be full after eight writes");

        write_byte(8'hee);
        if (!full || count != 8)
            $fatal(1, "Write while full changed FIFO state");

        for (i = 0; i < 8; i = i + 1)
            read_and_expect(8'h40 + i[7:0]);

        // Simultaneous read and write keeps count unchanged.
        write_byte(8'ha1);
        write_byte(8'hb2);
        din   = 8'hc3;
        wr_en = 1'b1;
        rd_en = 1'b1;
        tick();
        wr_en = 1'b0;
        rd_en = 1'b0;

        if (dout !== 8'ha1 || count != 2)
            $fatal(1, "Simultaneous read/write test failed");

        read_and_expect(8'hb2);
        read_and_expect(8'hc3);

        // An underflow request must not move state.
        rd_en = 1'b1;
        tick();
        rd_en = 1'b0;
        if (!empty || count != 0)
            $fatal(1, "Read while empty changed FIFO state");

        $display("PASS: basic_fifo completed all tests");
        $finish;
    end

endmodule

`default_nettype wire
