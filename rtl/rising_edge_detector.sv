// Rising Edge Detector Module ：detects when an input signal changes from 0 to 1 and generates a one-clock-cycle high pulse.
//
// Parameters:
// - None
//
// Ports:
// - clk: The input clock signal.
// - sig_in: The input signal to be monitored for rising edges.
// - rise: The output signal that goes high for one clock cycle when a rising edge is detected on sig_in.
//

`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  logic sig_in_prev;  // Register to hold the previous state of sig_in
  initial sig_in_prev = 1'b0;  // Initialize to 0

  always_ff @(posedge clk) begin
    sig_in_prev <= sig_in;
  end

  always_comb begin
    rise = (sig_in == 1'b1) && (sig_in_prev == 1'b0);
  end


endmodule
