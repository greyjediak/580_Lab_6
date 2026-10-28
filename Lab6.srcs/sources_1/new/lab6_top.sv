`timescale 1ns / 1ps

module lab6_top(
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] sw,
    output logic [7:0] led,
    output logic       tx
);

    localparam int CLKS_PER_BIT = 100_000_000 / 115_200;  // 868
//    localparam int GAP          = 10 * CLKS_PER_BIT;       // one idle frame
//    localparam int GAP_W        = $clog2(GAP + 1);

    logic start, busy, done;
//    logic [GAP_W-1:0] gap_cnt;

//    always_ff @(posedge clk) begin
//        if (rst || busy)
//            gap_cnt <= '0;
//        else if (gap_cnt != GAP)
//            gap_cnt <= gap_cnt + 1'b1;
//    end

    assign start = !busy && !done;

    uart_tx #(
        .CLK_FREQ(100_000_000),
        .BAUD(115_200)
    ) uart_test (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data(sw),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

endmodule