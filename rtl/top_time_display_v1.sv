`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  // restartable_rate_generator
  logic selected_tick;

  logic tick_1hz;
  logic tick_25hz;
  logic tick_1khz;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)  // 1 Hz
  ) u_rate_1hz (
      .clk (CLOCK_50),
      .run (SW[1:0] == 2'b00),
      .tick(tick_1hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)  // 25 Hz
  ) u_rate_25hz (
      .clk (CLOCK_50),
      .run (SW[1:0] == 2'b01),
      .tick(tick_25hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)  // 1 kHz
  ) u_rate_1khz (
      .clk (CLOCK_50),
      .run (SW[1:0] == 2'b10),
      .tick(tick_1khz)
  );

  always_comb
    unique case (SW[1:0])
      2'b00:   selected_tick = tick_1hz;
      2'b01:   selected_tick = tick_25hz;
      2'b10:   selected_tick = tick_1khz;
      2'b11:   selected_tick = 1'b1;  // 50 MHz，不分频
      default: selected_tick = tick_1hz;
    endcase

  // hms_counter
  localparam int HourWidth = 5;
  localparam int MinuteWidth = 6;
  localparam int SecondWidth = 6;

  logic [  HourWidth-1:0] binary_hours;  // 5 bits to represent hours (0-23)
  logic [MinuteWidth-1:0] binary_minutes;  // 6 bits to represent minutes (0-59)
  logic [SecondWidth-1:0] binary_seconds;  // 6 bits to represent seconds (0-59)

  hms_counter hms_counter_inst (
      .clk(CLOCK_50),
      .enable(selected_tick),
      .hours(binary_hours),
      .minutes(binary_minutes),
      .seconds(binary_seconds)
  );

  // Binary to BCD convert for display

  logic [3:0] ones_seconds;
  logic [3:0] tens_seconds;
  logic [3:0] ones_minutes;
  logic [3:0] tens_minutes;
  logic [3:0] ones_hours;
  logic [3:0] tens_hours;


  binary_to_bcd binary_to_bcd_seconds (
      .bin ({1'b0, binary_seconds}),
      .tens(tens_seconds),
      .ones(ones_seconds)
  );

  binary_to_bcd binary_to_bcd_minutes (
      .bin ({1'b0, binary_minutes}),
      .tens(tens_minutes),
      .ones(ones_minutes)
  );

  binary_to_bcd binary_to_bcd_hours (
      .bin ({2'b0, binary_hours}),
      .tens(tens_hours),
      .ones(ones_hours)
  );

  //seven segment displays

  seven_segment #(
      .ACTIVE_LOW(1)
  ) digit_seconds_ones (
      .digit(ones_seconds),
      .blank(1'b0),
      .segments(HEX0)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) digit_seconds_tens (
      .digit(tens_seconds),
      .blank(1'b0),
      .segments(HEX1)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) digit_minute_ones (
      .digit(ones_minutes),
      .blank(1'b0),
      .segments(HEX2)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) digit_minute_tens (
      .digit(tens_minutes),
      .blank(1'b0),
      .segments(HEX3)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) digit_hour_ones (
      .digit(ones_hours),
      .blank(1'b0),
      .segments(HEX4)
  );

  seven_segment #(
      .ACTIVE_LOW(1)
  ) digit_hour_tens (
      .digit(tens_hours),
      .blank(1'b0),
      .segments(HEX5)
  );

endmodule
