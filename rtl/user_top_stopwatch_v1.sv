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

module user_top_stopwatch_v1 #(
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
  assign led = clk ? sw : ~sw;

  assign blank_hours = button[0];
  assign blank_minutes = button[1];
  assign blank_seconds = button[2];

  //   assign hours_disp = button[3] ? 7'd16 : 7'd7;
  //   assign minutes_disp = button[3] ? 7'd38 : 7'd23;
  //   assign seconds_disp = button[3] ? 7'd59 : 7'd45;

  logic start_stop_pulse;

  rising_edge_detector start_stop_detector (
      .clk(clk),
      .sig_in(button[0]),  // Start/Stop button
      .rise(start_stop_pulse)
  );

  logic lap_pulse;

  rising_edge_detector lap_detector (
      .clk(clk),
      .sig_in(button[1]),  // Lap button
      .rise(lap_pulse)
  );

  logic counter_rst;
  logic counter_enable;
  logic lap_hold;


  stopwatch_control stopwatch_control_inst (
      .clk(clk),
      .rise_start_stop(start_stop_pulse),
      .rise_lap(lap_pulse),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  logic [6:0] counter_minutes;
  logic [5:0] counter_seconds;
  logic [6:0] counter_centiseconds;

  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) stopwatch_counter_inst (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(counter_minutes),
      .seconds(counter_seconds),
      .centiseconds(counter_centiseconds)
  );

  logic [6:0] snapshot_minutes;
  logic [5:0] snapshot_seconds;
  logic [6:0] snapshot_centiseconds;

  snapshot_mux #(
      .WIDTH(7)
  ) snapshot_mux_minutes (
      .clk(clk),
      .hold(lap_hold),
      .d(counter_minutes),  // Current minutes
      .q(snapshot_minutes)  // Output to minutes display
  );
  snapshot_mux #(
      .WIDTH(6)
  ) snapshot_mux_seconds (
      .clk(clk),
      .hold(lap_hold),
      .d(counter_seconds),  // Current seconds
      .q(snapshot_seconds)  // Output to seconds display
  );

  snapshot_mux #(
      .WIDTH(7)
  ) snapshot_mux_centiseconds (
      .clk(clk),
      .hold(lap_hold),
      .d(counter_centiseconds),  // Current centiseconds
      .q(snapshot_centiseconds)  // Output to centiseconds display
  );



  assign hours_disp   = snapshot_minutes;
  assign minutes_disp = {1'b0, snapshot_seconds};
  assign seconds_disp = snapshot_centiseconds;


  /* verilator lint_off UNUSEDSIGNAL */
  logic [1:0] unused_buttons;
  logic [9:0] unused_sw;

  assign unused_buttons = button[3:2];
  assign unused_sw = sw;
  /* verilator lint_on UNUSEDSIGNAL */



endmodule
