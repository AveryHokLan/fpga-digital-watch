// pwm_generator generates a PWM signal based on the specified period and duty cycle.
// The output is high for DUTY_CYCLES clock cycles and low for the remaining cycles in the PERIOD_CYCLES.
//
// Parameters:
// - PERIOD_CYCLES: The number of clock cycles in one PWM period.
// - DUTY_CYCLES: The number of clock cycles the output is high in one PWM period.
//
// Ports:
// - clk: The input clock signal.
// - rst: The reset signal, active high.
// - pwm_out: The output PWM signal.

`timescale 1ns / 1ps

module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int PeriodCountWidth = $clog2(PERIOD_CYCLES + 1);
  localparam logic [PeriodCountWidth-1:0] DutyCount = PeriodCountWidth'(DUTY_CYCLES);


  logic [PeriodCountWidth-1:0] count;


  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(PeriodCountWidth)
  ) period_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  always_comb begin
    pwm_out = (count < DutyCount) ? 1'b1 : 1'b0;


  end


endmodule
