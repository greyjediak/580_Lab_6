`timescale 1ns / 1ps
// "One nation, under God, indivisible, with liberty and justice for all.
//                          - Francis Bellany, newest version with amendment by Dwight D. Eisenhower

module baud_tick #(
    parameter int CLK_FREQ = 100_000_000,
    parameter int BAUD     = 115_200
)(
    input  logic clk,
    input  logic rst,
    input  logic en,
    output logic tick
);

    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD;
    localparam int COUNT_W =
        (CLKS_PER_BIT <= 1) ? 1 : $clog2(CLKS_PER_BIT); //error correction allowance added 

    logic [COUNT_W-1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= '0;
            tick  <= 1'b0;
        end
        else if (!en) begin
            count <= '0;
            tick  <= 1'b0;
        end
        else if (count == CLKS_PER_BIT-1) begin
            count <= '0;
            tick  <= 1'b1;
        end
        else begin
            count <= count + 1'b1;
            tick  <= 1'b0;
        end
    end

endmodule

