// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_brightness_wrapper #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    input logic [3:0] button,
    input logic [9:0] sw,
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  localparam int PWMPeriod = CYCLES_PER_SECOND / 1000;
  localparam int PWMWidth = $clog2(PWMPeriod);

  logic app_blank_hours;
  logic app_blank_minutes;
  logic app_blank_seconds;

  logic [PWMWidth-1:0] pwm_count;
  logic [PWMWidth:0] duty_threshold;
  logic pwm_on;
  logic pwm_blank;

  user_top #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(app_blank_hours),
      .blank_minutes(app_blank_minutes),
      .blank_seconds(app_blank_seconds)
  );

  mod_n_counter #(
      .N(PWMPeriod),
      .WIDTH(PWMWidth)
  ) u_brightness_counter (
      .clk(clk),
      .rst(button[0]),
      .enable(1'b1),
      .count(pwm_count)
  );

  always_comb begin
    case (sw[9:8])
      2'b00:   duty_threshold = PWMPeriod / 8;
      2'b01:   duty_threshold = PWMPeriod / 4;
      2'b11:   duty_threshold = PWMPeriod / 2;
      2'b10:   duty_threshold = PWMPeriod;
      default: duty_threshold = PWMPeriod;
    endcase
  end

  assign pwm_on = pwm_count < duty_threshold;
  assign pwm_blank = ~pwm_on;

  assign blank_hours = app_blank_hours | pwm_blank;
  assign blank_minutes = app_blank_minutes | pwm_blank;
  assign blank_seconds = app_blank_seconds | pwm_blank;



endmodule
