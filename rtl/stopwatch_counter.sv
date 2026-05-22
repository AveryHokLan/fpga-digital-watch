`timescale 1ns / 1ps

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // Takes priority over enable
    input logic enable,
    output logic [6:0] minutes,  // 0-99 minutes
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundredths of a second
);

  logic centisecond_tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 100)  // Number of clock cycles in one centisecond
  ) u_rate_gen (
      .clk (clk),
      .run (enable && !rst),   // Run when enabled and not in reset
      .tick(centisecond_tick)
  );

  cascade_counter #(
      .N2(100),  // 0-99 minutes
      .N1(60),  // 0-59 seconds
      .N0(100),  // 0-99 centiseconds
      // Output port widths
      .W2(7),  // 7 bits for minutes (0-99)
      .W1(6),  // 6 bits for seconds (0-59)
      .W0(7)  // 7 bits for centiseconds (0-99)
  ) centiseconds_counter (
      .clk(clk),
      .rst(rst),
      .enable(enable && !rst && centisecond_tick),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );

endmodule
