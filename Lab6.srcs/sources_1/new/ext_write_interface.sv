`timescale 1ns / 1ps

// Interface for the FIFO to the UART controller for 581 graduate extended version

module ext_write_interface(
    input logic wr_en,
    input logic wr_data [7:0],
    output logic full,
    output logic tx
    );
    
    fifo my_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en,
        .rd_data,
        .empty(empty),
        .full(full)
    );
endmodule
