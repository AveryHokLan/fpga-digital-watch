// button hold detect
// Detects when a button is held down for a certain duration and generates a signal accordingly.
//
// Parameters:
// HOLD_CYCLES: The number of clock cycles the button must be held down to consider
//
// Ports:
// clk: The input clock signal.
// button: The input signal representing the button state (1 when pressed, 0 when released
// held: The output signal that goes high when the button has been held down for the specified duration.
//

`timescale 1ns / 1ps

module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);

  localparam int CountMax = HOLD_CYCLES;
  localparam int CountWidth = $clog2(CountMax + 1);

  logic count_rst;
  logic count_enable;
  logic [CountWidth -1:0] count;

  always_comb begin
    if (button) begin
      count_rst = 1'b0;
      count_enable = 1'b1;
    end else begin
      count_rst = 1'b1;
      count_enable = 1'b0;
    end
  end

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  logic held_latched;
  logic held_rise;

  initial held_latched = 1'b0;

  always_comb begin
    held_rise = button && (count == CountWidth'(CountMax));
  end

  always_ff @(posedge clk) begin
    if (!button) begin
      held_latched <= 1'b0;
    end else if (held_rise) begin
      held_latched <= 1'b1;
    end
  end

  always_comb begin
    held = (held_latched || held_rise) && button;
  end

endmodule

