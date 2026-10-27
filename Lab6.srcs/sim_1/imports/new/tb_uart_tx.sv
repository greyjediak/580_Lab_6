`timescale 1ns/1ps

module tb_uart_tx;
    localparam int CLK_FREQ     = 100;
    localparam int BAUD         = 10;
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD;

    logic clk = 1'b0;
    logic rst = 1'b1;
    logic start = 1'b0;
    logic [7:0] data = '0;
    logic tx, busy, done;
    int errors = 0;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) dut (
        .clk(clk), .rst(rst), .start(start), .data(data),
        .tx(tx), .busy(busy), .done(done)
    );

    always #5 clk = ~clk;

`ifdef DUMP_VCD
    initial begin
        $dumpfile("uart_tx_day12.vcd");
        $dumpvars(0, tb_uart_tx);
    end
`endif

    task automatic check(input logic condition, input string msg);
        if (condition !== 1'b1) begin
            $error("%s", msg);
            errors++;
        end
    endtask

    function automatic logic frame_bit(input logic [7:0] byte_in,
                                       input int frame_idx);
        if (frame_idx == 0)       frame_bit = 1'b0; // start
        else if (frame_idx == 9)  frame_bit = 1'b1; // stop
        else                      frame_bit = byte_in[frame_idx-1];
    endfunction

    task automatic transmit_and_check(input logic [7:0] byte_in,
                                      input logic inject_busy_start);
        logic expected;
        begin
            // Request transaction on a clean rising edge.
            @(negedge clk);
            start = 1'b1;
            data  = byte_in;
            @(posedge clk);
            #1;
            check(busy === 1'b1, "busy should assert in LOAD");
            check(tx   === 1'b1, "line should still be idle during LOAD");
            check(done === 1'b0, "done asserted early");

            // The wrapper captures data at the start-acceptance edge.
            // Changing the input now must not change the frame.
            @(negedge clk);
            start = 1'b0;
            data  = ~byte_in;
            @(posedge clk);
            #1;
            check(tx === 1'b0, "start bit must begin on LOAD->TRANSMIT edge");
            check(busy === 1'b1, "busy must remain asserted");

            // Verify each bit at EVERY system-clock interval. This
            // catches early/late shifts, including stop-bit truncation.
            for (int bit_idx = 0; bit_idx < 10; bit_idx++) begin
                expected = frame_bit(byte_in, bit_idx);

                for (int cyc = 0; cyc < CLKS_PER_BIT; cyc++) begin
                    @(negedge clk);
                    // Try an extra start while transmitting data bit 2;
                    // it must be ignored.
                    if (inject_busy_start && bit_idx == 3 && cyc == 2) begin
                        start = 1'b1;
                        data = 8'h00;
                    end
                    if (inject_busy_start && bit_idx == 3 && cyc == 3)
                        start = 1'b0;

                    check(tx === expected,
                          $sformatf("byte=%02h frame_bit=%0d cycle=%0d: tx wrong",
                                    byte_in, bit_idx, cyc));
                    check(busy === 1'b1,
                          $sformatf("byte=%02h bit=%0d cycle=%0d: busy dropped",
                                    byte_in, bit_idx, cyc));
                    check(done === 1'b0,
                          $sformatf("byte=%02h bit=%0d cycle=%0d: done early",
                                    byte_in, bit_idx, cyc));
                    @(posedge clk);
                    #1;
                end
            end

            // After exactly 10 * CLKS_PER_BIT system-clock cycles:
            check(tx === 1'b1, "tx must remain idle-high after frame");
            check(busy === 1'b0, "busy must deassert when stop completes");
            check(done === 1'b1, "done must pulse after complete stop bit");

            @(posedge clk);
            #1;
            check(done === 1'b0, "done must last exactly one clock");
            check(busy === 1'b0, "must be idle after done");
            check(tx === 1'b1, "tx must remain idle-high");
            $display("Checked frame 0x%02h", byte_in);
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        #1;
        check(tx === 1'b1, "reset should produce idle-high tx");
        check(busy === 1'b0, "reset should clear busy");
        check(done === 1'b0, "reset should clear done");
        @(negedge clk);
        rst = 1'b0;

        transmit_and_check(8'h55, 1'b1);
        transmit_and_check(8'hA3, 1'b0);
        // A couple of edge patterns help catch bit-order errors:
        transmit_and_check(8'h00, 1'b0);
        transmit_and_check(8'hFF, 1'b0);

        if (errors == 0) begin
            $display("PASS: Day 12 UART FSMD mini-lab");
        end else begin
            $display("FAIL: Day 12 UART FSMD mini-lab: %0d errors", errors);
            $fatal(1, "UART verification failed");
        end
        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "TIMEOUT: UART testbench did not complete");
    end
endmodule
