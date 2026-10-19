`timescale 1ns / 1ps
// Day 12 mini-lab: UART Tx controller
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
        case (state)
            IDLE: begin
                // TODO 1: go to LOAD if start is asserted.
                if(start)
                    next_state = LOAD;
            end
            LOAD: begin
                // TODO 2: move unconditionally to TRANSMIT.
                next_state = TRANSMIT;
            end
            TRANSMIT: begin
                // TODO 3: move to DONE only after the STOP
                // bit receives its full interval.
                if (bit_tick && last_bit)
                    next_state = DONE;
            end // end TRANSMIT case
            DONE: begin
                // TODO 4: return to IDLE for the next request.
                //done = 1; // NOT dealing with the output signals yet
                next_state =  IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

// NEXT Combinational block, normally they're combined
    always_comb begin
        // Defaults are already supplied.
        load      = 1'b0;
        shift     = 1'b0;
        baud_en   = 1'b0;
        bit_clear = 1'b0;
        bit_inc   = 1'b0;
        busy      = 1'b0;
        done      = 1'b0;

        case (state)
            IDLE: begin
                // assume timer clear goes here
            end
            LOAD: begin
                // TODO 5: assert busy, load, bit_clear,
                // and baud_en. Start bit timing during LOAD.
                busy = 1'b1;
                load = 1'b1;
                bit_clear = 1'b1;
                baud_en = 1'b1;
                
            end
            TRANSMIT: begin
                // TODO 6: assert busy and baud_en.
                // If bit_tick && !last_bit: shift and bit_inc.
                busy = 1;
                baud_en = 1;
                if (bit_tick && !last_bit) begin
                    
                    bit_inc++;
                end
                    
            end
            DONE: begin
                // TODO 7: assert done for this one state cycle.
                done =  1;
            end
            default: begin
            end
        endcase
    end
endmodule
