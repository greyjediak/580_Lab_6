`timescale 1ns / 1ps

// Datapath for UART Transmitter
module uart_tx #(
    parameter int CLK_FREQ = 100_000_000,
    parameter int BAUD     = 115_200
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       start,
    input  logic [7:0] data,
    output logic       tx,
    output logic       busy,
    output logic       done
);
    logic load, shift, baud_en, bit_clear, bit_inc;
    logic bit_tick, last_bit;
    logic [3:0] bit_count;
    logic [7:0] data_latched;

    // Capture the external byte on the clock that accepts start.
    // The frame register loads this captured byte in the LOAD state
    // one cycle later; external data need not remain stable.
    always_ff @(posedge clk) begin
        if (rst)
            data_latched <= '0;
        else if (start && !busy && !done)
            data_latched <= data; //clock domain crossing
    end

    always_ff @(posedge clk) begin
        if (rst)
            bit_count <= '0;
        else if (bit_clear)
            bit_count <= '0;
        else if (bit_inc)
            // increment the frame-bit counter on bit_inc.
            bit_count <= bit_count + 1'b1; // Replace with your logic - done
    end

    // assert last_bit only when the STOP bit is active.
    // assign last_bit = 1'b0;
    assign last_bit = (bit_count === 4'd9); // 4 bits, with the value decimal 9
    
    // Instantiate the baud generator
    baud_tick #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) u_baud (
        .clk(clk),
        .rst(rst),
        .en(baud_en),
        .tick(bit_tick)
    );

    // Instantiate UART U Frame
    uart_frame_shift u_frame (
        .clk(clk),
        .rst(rst),
        .load(load),
        .shift(shift),
        .data(data_latched),
        .tx(tx)
    );

    // Instantiate UART controller
    uart_tx_controller u_ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .bit_tick(bit_tick),
        .last_bit(last_bit),
        .load(load),
        .shift(shift),
        .baud_en(baud_en),
        .bit_clear(bit_clear),
        .bit_inc(bit_inc),
        .busy(busy),
        .done(done)
    );
endmodule
