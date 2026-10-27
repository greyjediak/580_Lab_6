`timescale 1ns / 1ps

module ext_write_interface (
    input  logic       clk,
    input  logic       rst,
    input  logic       wr_en,
    input  logic [7:0] wr_data,
    output logic       full,
    output logic       tx
);

    logic       rd_en;
    logic [7:0] rd_data;
    logic       empty;

    logic uart_start;
    logic uart_busy;
    logic uart_done;
    
endmodule