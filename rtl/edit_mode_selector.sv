//When count is zero, button must be held long enough to assert long_press, which arms the
//latch and allows count to advance to one. Thereafter, each brief press of button advances
//count by one until it wraps back to zero and the cycle repeats.
//
// Parameters:
// HOLD_CYCLES: The number of clock cycles the button must be held down to assert
//
// Ports:
// clk: The input clock signal.
// button: The input signal representing the button state (1 when pressed, 0 when released
// mode_enable: A 3-bit output where only one bit is high at a time to indicate the current mode.
//

`timescale 1ns / 1ps

module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable
);
  logic long_press;
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)
  );

  logic press;
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );
  logic armed;
  logic disarm;
  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarm),
      .armed(armed)
  );

  logic reset_counter;
  logic enable_counter;
  logic [1:0] count;
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );

  // Counter runs only while armed; resets when disarmed
  assign enable_counter = armed && press;
  assign reset_counter = disarm;

  // Disarm on the press that steps past the last mode
  assign disarm = armed && press && count == 2;
  // Output logic
  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
