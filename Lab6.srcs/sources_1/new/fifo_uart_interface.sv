
`timescale 1ns / 1ps

module fifo_uart_interface #(
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

    // FIFO signals
    logic       rd_en;
    logic [7:0] rd_data;
    logic       empty;

    // UART signals
    logic uart_start;
    logic uart_busy;
    logic uart_done;

    fifo #(
        .WIDTH(8),
        .DEPTH(FIFO_DEPTH)
    ) u_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty),
        .full(full)
    );

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) u_uart (
        .clk(clk),
        .rst(rst),
        .start(uart_start),
        .data(rd_data),
        .tx(tx),
        .busy(uart_busy),
        .done(uart_done)
    );

    // Controller states
    typedef enum logic [2:0] {
        IDLE,
        READ_FIFO,
        WAIT_DATA,
        START_TX,
        WAIT_BUSY,
        WAIT_DONE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        rd_en = 1'b0;
        uart_start = 1'b0;

        case (state)

            IDLE: begin
                if (!empty && !uart_busy && !uart_done)
                    next_state = READ_FIFO;
            end

            READ_FIFO: begin
                rd_en = 1'b1;
                next_state = WAIT_DATA;
            end

            WAIT_DATA: begin
                next_state = START_TX;
            end

            START_TX: begin
                uart_start = 1'b1;
                next_state = WAIT_BUSY;
            end

            WAIT_BUSY: begin
                if (uart_busy)
                    next_state = WAIT_DONE;
            end

            WAIT_DONE: begin
                if (uart_done)
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
