`timescale 1ns / 1ps
// "What happens out there, the mistakes, even the victories, you can't bring it home."
//              - Nolan Grayson, Invincible


module uart_frame_shift (
    input  logic       clk,
    input  logic       rst,
    input  logic       load,
    input  logic       shift,
    input  logic [7:0] data,
    output logic       tx
);

    logic [9:0] tx_shift;

    always_ff @(posedge clk) begin
        if (rst)
            tx_shift <= '1;
        else if (load)
            tx_shift <= {1'b1, data, 1'b0};
        else if (shift)
            tx_shift <= {1'b1, tx_shift[9:1]};
    end

    assign tx = tx_shift[0];

endmodule
