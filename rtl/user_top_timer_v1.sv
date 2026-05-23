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

module user_top_timer_v1 #(
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

  //   assign led = clk ? sw : ~sw;

  //   assign blank_hours = button[0];
  //   assign blank_minutes = button[1];
  //   assign blank_seconds = button[2];

  //   assign hours_disp = button[3] ? 7'd16 : 7'd7;
  //   assign minutes_disp = button[3] ? 7'd38 : 7'd23;
  //   assign seconds_disp = button[3] ? 7'd59 : 7'd45;

  // ------------------
  // Core Functionality : countdown
  // ------------------

  logic counter_clr;
  logic hours_borrow;

  // Seconds
  logic seconds_borrow;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic seconds_tick;
  logic [5:0] seconds;

  editable_countdown #(
      .MAX  (60),  // 0-60 seconds
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(counter_clr),
      .tick(seconds_tick),  // In stopped mode, start_stop_pulse acts as tick to decrement time
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );


  //Minutes
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic minutes_borrow;
  logic minutes_tick;
  logic [5:0] minutes;

  assign minutes_tick = seconds_tick && seconds_borrow;

  editable_countdown #(
      .MAX  (60),  // 0-59 minutes
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(counter_clr),
      .tick(minutes_tick),  // Borrow from seconds
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );


  //Hours
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic hours_tick;
  logic [4:0] hours;
  assign hours_tick = minutes_tick && minutes_borrow;

  editable_countdown #(
      .MAX  (24),  // 0-23 hours
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .clr(counter_clr),
      .tick(hours_tick),  // Borrow from minutes
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .borrow_out(hours_borrow)
  );

  // Zero-extend counter values to display outputs
  assign hours_disp   = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // --------------
  // Mode Selection
  // --------------
  // 3 modes: Stopped, Running, Edit.
  // 000: normal mode
  // 001: edit seconds
  // 010: edit minutes
  // 100: edit hours

  logic [2:0] mode_enable;

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)  // Hold for 1 second to enter edit mode
  ) u_edit_mode_selector_timer (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  logic pwm_out;

  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),  // 2 Hz
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 10)  // 80% duty cycle
  ) u_pwm_generator (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  assign seconds_edit = mode_enable[0] ? 1'b1 : 1'b0;
  assign minutes_edit = mode_enable[1] ? 1'b1 : 1'b0;
  assign hours_edit = mode_enable[2] ? 1'b1 : 1'b0;

  // blank the display of the unit being edited by using the PWM output to blank the digits when in edit mode
  assign blank_seconds = mode_enable[0] ? pwm_out : 1'b0;
  assign blank_minutes = mode_enable[1] ? pwm_out : 1'b0;
  assign blank_hours = mode_enable[2] ? pwm_out : 1'b0;

  // --------------
  // edit mode
  // --------------
  // button[1]: increment
  // button[0]: decrement

  logic inc_pulse;
  logic dec_pulse;

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // 0.5 second hold before auto repeat
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // Repeat 10 Hz while held
  ) u_inc_button (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // 0.5 second hold before auto repeat
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // Repeat 10 Hz while held
  ) u_dec_button (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  assign seconds_inc = mode_enable[0] && inc_pulse;
  assign seconds_dec = mode_enable[0] && dec_pulse;

  assign minutes_inc = mode_enable[1] && inc_pulse;
  assign minutes_dec = mode_enable[1] && dec_pulse;

  assign hours_inc   = mode_enable[2] && inc_pulse;
  assign hours_dec   = mode_enable[2] && dec_pulse;


  // --------------
  // 000: normal mode
  // --------------

  logic running;

  logic count_not_zero;

  assign count_not_zero = (hours != 0) || (minutes != 0) || (seconds != 0);


  always_ff @(posedge clk) begin
    if (counter_clr || !count_not_zero) begin
      running <= 1'b0;
    end else if ((mode_enable == 3'b000) && start_stop_pulse) begin
      running <= ~running;
    end
  end
  // Derive 1 Hz tick from system clock
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk(clk),
      .run((mode_enable == 3'b000) && running),  // Run the timer when not in edit mode and not paused
      .tick(seconds_tick)
  );

  logic start_stop_pulse;

  rising_edge_detector start_stop_detector (
      .clk(clk),
      .sig_in(button[0]),  // Start/Stop button
      .rise(start_stop_pulse)
  );



  //unused
  assign counter_clr = button[2];

  assign led[5:0] = sw[5:0];
  assign led[6] = running;
  assign led[9] = hours_borrow;
  assign led[8] = counter_clr;
  assign led[7] = button[2];

  /* verilator lint_off UNUSEDSIGNAL */
  logic [3:0] unused_sw;
  assign unused_sw = sw[9:6];
  /* verilator lint_on UNUSEDSIGNAL */


endmodule
