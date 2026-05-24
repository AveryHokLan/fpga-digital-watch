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
  logic app_blank_hours;
  logic app_blank_minutes;
  logic app_blank_seconds;

  user_top #(
      .CYCLES_PER_SECOND(50_000_000)
  ) u_user_top (
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (app_blank_hours),
      .blank_minutes(app_blank_minutes),
      .blank_seconds(app_blank_seconds)
  );

  localparam int PWMPeriod = CYCLES_PER_SECOND / 1000; // small engough so human cannot see flashing.
  localparam int PWMWidth = $clog2(PWMPeriod);

  logic [PWMWidth-1:0] pwm_count;
  logic [PWMWidth:0] brightness_threshold;

  logic pwm_on;
  logic pwm_blank;

  mod_n_counter #(
      .N(PWMPeriod),
      .WIDTH(PWMWidth)
  ) u_brightness_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );

  logic [1:0] brightness_selection;
  assign brightness_selection = sw[9:8];

  always_comb begin
    case (brightness_selection)
      2'b00:   brightness_threshold = (PWMWidth + 1)'(PWMPeriod / 8);
      2'b01:   brightness_threshold = (PWMWidth + 1)'(PWMPeriod / 4);
      2'b11:   brightness_threshold = (PWMWidth + 1)'(PWMPeriod / 2);
      2'b10:   brightness_threshold = (PWMWidth + 1)'(PWMPeriod);
      default: brightness_threshold = (PWMWidth + 1)'(PWMPeriod);
    endcase
  end

  assign pwm_on = (sw[9:8] == 2'b10) || ({1'b0, pwm_count} < brightness_threshold);
  assign pwm_blank = ~pwm_on;


  assign blank_hours = app_blank_hours | pwm_blank;
  assign blank_minutes = app_blank_minutes | pwm_blank;
  assign blank_seconds = app_blank_seconds | pwm_blank;


endmodule




