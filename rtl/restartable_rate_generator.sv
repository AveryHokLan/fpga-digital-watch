//resettable_rate_generator - A module that generates a tick signal at a specified rate when enabled. The rate is determined by the CYCLE_COUNT parameter, which specifies how many clock cycles must pass before a tick is generated. The generator can be restarted by toggling the run signal.
//
// Parameters:
// CYCLE_COUNT - The number of clock cycles in one period of the tick signal.
//
// Ports:
// clk - The clock signal for synchronizing the generator.
// run - When high, the generator runs and produces ticks at the specified rate.
// tick - The output signal that goes high for one clock cycle at the end of each period defined by CYCLE_COUNT when run is high.
//
// Note:
// If CYCLE_COUNT is set to 1, the tick will be high on every clock cycle when run is high.


`timescale 1ns / 1ps

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);

  // Becomes high at the end of each cycle
  logic tick_qualifier;

  logic running = 1'b0;
  always_ff @(posedge clk) running <= run;

  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      localparam int CountWidth = $clog2(CYCLE_COUNT);

      logic rst_count;
      logic enable_count;
      logic [CountWidth -1:0] count;

      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      assign rst_count = ~run;  // When run is low, reset. when run is high, count normally
      assign enable_count = run;  // when run is low, don't count. when run is high, count normally
      assign tick_qualifier = (count == CountWidth'(CYCLE_COUNT - 1));  // tick when count reaches CYCLE_COUNT - 1

    end else begin : g_special
      assign tick_qualifier = 1'b1;
    end
  endgenerate

endmodule
