//


`timescale 1ns / 1ps

module key_synchroniser (
 input logic clk ,
 input logic [3:0] key_n , // active -low , asynchronous
 output logic [3:0] key_sync // active -high , synchronised
);

 logic [3:0] key_pressed;
    logic [3:0] sync_stage1;

    // Invert active-low keys to active-high pressed signals
    assign key_pressed = ~key_n;

    // Two-stage synchroniser
    initial begin
        sync_stage1 = 4'b0000;
        key_sync    = 4'b0000;
    end

    always_ff @(posedge clk) begin
        sync_stage1 <= key_pressed;
        key_sync    <= sync_stage1;
    end

endmodule
