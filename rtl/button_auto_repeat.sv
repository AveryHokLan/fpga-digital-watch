// button auto repeat module. generates a single immediate pulse on a button press, then produces repeated pulses at a fixed rate if the button is held down.
//
// parameters:
// HOLD_CYCLES: number of clock cycles the button must be held before auto repeat starts
// REPEAT_CYCLES: number of clock cycles between auto repeat pulses (must be smaller than HOLD_CYCLES)
//
// ports:
// clk: input clock signal
// button: input button signal (active high)
// pulse: output pulse signal (active high)
//

`timescale 1ns / 1ps

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;

  assign pulse = rise | (button & pulse_train);

  rising_edge_detector u_rise (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold (
      .clk(clk),
      .button(button),
      .held(held)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_repeat (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );


endmodule
