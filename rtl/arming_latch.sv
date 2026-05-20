// One instance of this module will track whether the watch is in edit mode.
// When the user enters edit mode, the arm signal will be pulsed high for one.
//
// port:
//   clk: clock signal
//   arm: pulse high for one cycle to enter edit mode
//   disarm: pulse high for one cycle to exit edit mode
//   armed: high when in edit mode, low otherwise
//

`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);

  initial armed = 1'b0;

  always_ff @(posedge clk) begin
    if (disarm) armed <= 1'b0;
    else if (arm) armed <= 1'b1;
  end

endmodule
