`timescale 1ns / 1ps
// UART controller
module uart_tx_controller (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic bit_tick,
    input  logic last_bit,
    output logic load,
    output logic shift,
    output logic baud_en,
    output logic bit_clear,
    output logic bit_inc,
    output logic busy,
    output logic done
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        TRANSMIT,
        DONE
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
        // clear inputs
        load      = 1'b0;
        shift     = 1'b0;
        baud_en   = 1'b0;
        bit_clear = 1'b0;
        bit_inc   = 1'b0;
        busy      = 1'b0;
        done      = 1'b0;
        case (state)
            IDLE: begin
                // TODO 1: go to LOAD if start is asserted.
                if(start)
                    next_state = LOAD;
                    //TODO: timer clear
            end
            LOAD: begin
                // assert busy, load, bit_clear,
                // and baud_en. Start bit timing during LOAD.
                busy = 1'b1;
                load = 1'b1;
                baud_en = 1'b1;
                bit_clear = 1'b1;
                next_state = TRANSMIT; // move unconditionally to TRANSMIT.
            end
            TRANSMIT: begin
                // assert busy and baud_en.
                busy = 1;
                baud_en = 1;
                // If bit_tick && !last_bit: shift and bit_inc.
                if (bit_tick && !last_bit) begin
                    shift = 1'b1;
                    bit_inc = 1'b1;
                end
                    
                // move to DONE only after the STOP bit receives its full interval.
                if (bit_tick && last_bit)
                    next_state = DONE;
            end // end TRANSMIT case
            DONE: begin
                // return to IDLE for the next request.
                done = 1'b1;
                next_state =  IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
endmodule
