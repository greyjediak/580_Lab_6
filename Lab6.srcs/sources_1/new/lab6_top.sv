`timescale 1ns / 1ps

module lab6_top(
    input logic clk,
    input logic rst,
    input logic [7:0] sw,
    output logic tx
    );
    
    logic start;
    logic busy;
    logic done;
    
    uart_tx #(
        .CLK_FREQ(100_000_000),
        .BAUD(115_200)
    )(
        .clk(clk),
        .rst(rst),
        .start(start),
        .data(sw),
        .tx(tx),
        .busy(busy),
        .done(done)
    );
    
    assign start = !rst && !busy && !done;
    
    
endmodule
