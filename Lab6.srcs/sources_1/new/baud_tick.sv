`timescale 1ns / 1ps
// "One nation, under God, indivisible, with liberty and justice for all.
//                          - Francis Bellany, newest version with amendment by Dwight D. Eisenhower

module baud_tick #(
    parameter int CLK_FREQ = 100_000_000, 
    parameter int BAUD = 115_200
    )(
        input logic clk,
        input logic rst,
        input logic en,
        output logic tick
    );
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD;
    localparam int COUNTER_W = $clog2(CLKS_PER_BIT);
    logic [COUNTER_W-1:0] r_reg;
    logic [COUNTER_W-1:0] r_next;
    
    always_ff @(posedge clk) begin
        if(rst)
            r_reg <= 0;
        else
            r_reg <= r_next;
    end
    //next-state logic
    assign r_next = !en ? 0 : (r_reg == CLKS_PER_BIT - 1) ? 0 : r_reg + 1;
    //output logic
    assign tick = (r_reg == 1);
endmodule
