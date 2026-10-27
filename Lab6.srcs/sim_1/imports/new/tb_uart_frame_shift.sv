`timescale 1ns/1ps

module tb_uart_frame_shift;

    logic clk, rst, load, shift;
    logic [7:0] data;
    logic tx;
    int errors = 0;

    uart_frame_shift dut (
        .clk(clk), .rst(rst), .load(load), .shift(shift),
        .data(data), .tx(tx)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic check_tx(input logic expected, input string message);
        if (tx !== expected) begin
            $error("%s: expected tx=%0b actual tx=%0b", message, expected, tx);
            errors++;
        end
    endtask

    task automatic do_shift;
        begin
            @(negedge clk);
            shift = 1'b1;
            @(posedge clk);
            #1;
            shift = 1'b0;
        end
    endtask

    initial begin
        rst = 1'b1;
        load = 1'b0;
        shift = 1'b0;
        data = 8'h00;

        repeat (2) @(posedge clk);
        #1;
        check_tx(1'b1, "idle-high after reset");

        @(negedge clk);
        rst = 1'b0;

        // 8'h53 = 0101_0011
        // UART order: start, d0..d7, stop
        // Expected: 0,1,1,0,0,1,0,1,0,1
        data = 8'h53;

        @(negedge clk);
        load = 1'b1;
        @(posedge clk);
        #1;
        load = 1'b0;

        check_tx(1'b0, "start bit");
        do_shift(); check_tx(1'b1, "data bit 0");
        do_shift(); check_tx(1'b1, "data bit 1");
        do_shift(); check_tx(1'b0, "data bit 2");
        do_shift(); check_tx(1'b0, "data bit 3");
        do_shift(); check_tx(1'b1, "data bit 4");
        do_shift(); check_tx(1'b0, "data bit 5");
        do_shift(); check_tx(1'b1, "data bit 6");
        do_shift(); check_tx(1'b0, "data bit 7");
        do_shift(); check_tx(1'b1, "stop bit");
        do_shift(); check_tx(1'b1, "idle after frame");

        // Verify data is captured on load.
        data = 8'hA6;
        @(negedge clk);
        load = 1'b1;
        @(posedge clk);
        #1;
        load = 1'b0;
        data = 8'h00;

        check_tx(1'b0, "second frame start");
        do_shift(); check_tx(1'b0, "captured A6 data bit 0");
        do_shift(); check_tx(1'b1, "captured A6 data bit 1");

        if (errors == 0)
            $display("PASS: uart_frame_shift");
        else
            $display("FAIL: uart_frame_shift detected %0d error(s)", errors);

        $finish;
    end

endmodule
