`timescale 1ns / 1ps

// Interface for the FIFO to the UART controller for 581 graduate extended version

module ext_write_interface #(
    parameter int CLK_FREQ = 100_000_000,
parameter int BAUD = 115_200,
parameter int FIFO_DEPTH = 8
)(
input  logic       clk,
input  logic       rst,
input  logic       wr_en,
input  logic [7:0] wr_data,
output logic       full,
output logic       tx
);

fifo_uart_interface #(
.CLK_FREQ(CLK_FREQ),
.BAUD(BAUD),
.FIFO_DEPTH(FIFO_DEPTH)
) u_interface (
.clk(clk),
.rst(rst),
.wr_en(wr_en),
.wr_data(wr_data),
.full(full),
.tx(tx)
);

endmodule
