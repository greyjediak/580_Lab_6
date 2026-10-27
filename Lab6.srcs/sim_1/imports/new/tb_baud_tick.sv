`timescale 1ns/1ps

module tb_baud_tick;

    localparam int CLK_FREQ = 100;
    localparam int BAUD     = 10;
    localparam int EXPECTED = CLK_FREQ / BAUD;

    logic clk, rst, en, tick;
    int errors = 0;
    int cycle_num;

    baud_tick #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) dut (
        .clk(clk), .rst(rst), .en(en), .tick(tick)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic check(input logic condition, input string message);
        if (condition !== 1'b1) begin
            $error("%s", message);
            errors++;
        end
    endtask

    initial begin
        rst = 1'b1;
        en  = 1'b0;

        repeat (2) @(posedge clk);
        #1;
        check(tick === 1'b0, "tick low after reset");

        @(negedge clk);
        rst = 1'b0;

        // --------------------------------------------------------
        // Disabled: no ticks.
        // --------------------------------------------------------
        repeat (5) begin
            @(posedge clk);
            #1;
            check(tick === 1'b0, "tick asserted while disabled");
        end

        // --------------------------------------------------------
        // Enable.
        //
        // With CLK_FREQ=100 and BAUD=10:
        //
        //   CLKS_PER_BIT = 10
        //
        // Therefore tick must be high after enabled clock numbers
        // 10, 20, and 30, and low on every other clock.
        // --------------------------------------------------------
        @(negedge clk);
        en = 1'b1;

        for (cycle_num = 1; cycle_num <= 30; cycle_num++) begin
            @(posedge clk);
            #1;

            if ((cycle_num % EXPECTED) == 0)
                check(tick === 1'b1,
                      $sformatf("tick missing on enabled clock %0d", cycle_num));
            else
                check(tick === 1'b0,
                      $sformatf("unexpected tick on enabled clock %0d", cycle_num));
        end

        // --------------------------------------------------------
        // Disable partway through timing. The counter should clear.
        // --------------------------------------------------------
        @(negedge clk);
        en = 1'b0;

        repeat (4) begin
            @(posedge clk);
            #1;
            check(tick === 1'b0, "tick asserted while disabled");
        end

        // --------------------------------------------------------
        // Re-enable. The next tick must again occur only after a
        // complete 10-clock interval.
        // --------------------------------------------------------
        @(negedge clk);
        en = 1'b1;

        for (cycle_num = 1; cycle_num <= EXPECTED; cycle_num++) begin
            @(posedge clk);
            #1;

            if (cycle_num == EXPECTED)
                check(tick === 1'b1,
                      "tick did not occur after a full restarted interval");
            else
                check(tick === 1'b0,
                      "tick occurred too early after re-enable");
        end

        if (errors == 0)
            $display("PASS: baud_tick");
        else
            $display("FAIL: baud_tick detected %0d error(s)", errors);

        $finish;
    end

endmodule
