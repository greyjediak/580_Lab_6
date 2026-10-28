
`timescale 1ns / 1ps

module tb_fifo_uart_interface;

    localparam int CLK_FREQ = 100;
    localparam int BAUD = 10;
    localparam int CPB = CLK_FREQ / BAUD;
    localparam int FIFO_DEPTH = 8;

    logic clk = 1'b0;
    logic rst;
    logic wr_en;
    logic [7:0] wr_data;
    logic full;
    logic tx;

    int errors = 0;

    always #5 clk = ~clk;

    ext_write_interface #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .tx(tx)
    );

    task automatic check(
        input logic condition,
        input string message
    );
        if (condition !== 1'b1) begin
            $error("%s", message);
            errors++;
        end
    endtask

    // Write one byte on a rising clock edge.
    task automatic write_byte(input logic [7:0] value);
        @(negedge clk);

        check(!full, "FIFO full before write");

        wr_data = value;
        wr_en = 1'b1;

        @(posedge clk);
        #1;

        @(negedge clk);
        wr_en = 1'b0;
    endtask

    // Check one complete 8-N-1 UART frame.
    task automatic receive_byte(input logic [7:0] expected);
        logic [7:0] received;

        // Detect start bit.
        @(negedge tx);

        // Sample near the center of the start bit.
        repeat (CPB / 2) @(posedge clk);
        #1;
        check(tx === 1'b0, "Invalid start bit");

        // Sample eight data bits, LSB first.
        for (int i = 0; i < 8; i++) begin
            repeat (CPB) @(posedge clk);
            #1;
            received[i] = tx;
        end

        // Check stop bit.
        repeat (CPB) @(posedge clk);
        #1;
        check(tx === 1'b1, "Invalid stop bit");

        check(received === expected,
            $sformatf(
                "Expected %02h (%c), received %02h (%c)",
                expected, expected, received, received
            )
        );

        $display("UART received: %c (0x%02h)",
                 received, received);
    endtask

    initial begin
        rst = 1'b1;
        wr_en = 1'b0;
        wr_data = 8'h00;

        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // The receiver must run concurrently with
        // the writer so it cannot miss the first start bit.
        fork
            begin : writer
                write_byte("H");
                write_byte("E");
                write_byte("L");
                write_byte("L");
                write_byte("O");
            end

            begin : receiver
                receive_byte("H");
                receive_byte("E");
                receive_byte("L");
                receive_byte("L");
                receive_byte("O");
            end
        join

        repeat (20) @(posedge clk);
        #1;

        check(tx === 1'b1,
              "UART did not return to idle high");

        if (errors == 0)
            $display("PASS: FIFO UART transmitted HELLO");
        else
            $display("FAIL: %0d errors", errors);

        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "Timeout: FIFO UART test did not finish");
    end

endmodule
