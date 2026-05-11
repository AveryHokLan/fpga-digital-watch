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

















  //1. State encoding

  //2. State registers

  //3. Next state logic

  //4. Output logic







  // logic [31:0] count;
  // logic ;



  //   always_comb begin
  //     if (run == 0) begin
  //         tick = 0;
  //     end
  //     else begin
  //         tick = 1;
  //     end
  //   end





  //       if (run == 0) tick = 0;
  //   //  else if (run == 1)
  //   //         tick = 1;
  //   end








  //     parameter int MAX   = 2,
  //     parameter int WIDTH = 2
  // ) (
  //     input logic clk,
  //     input logic rst,
  //     input logic enable,
  //     output logic [WIDTH-1:0] count
  // );
  //   logic [WIDTH-1:0] next_count;
  //   localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);
  //   localparam logic [WIDTH-1:0] One = WIDTH'(1);

  //   initial count = WIDTH'(0);

  //   always_comb
  //     if (count == Max) next_count = 0;
  //     else next_count = count + One;

  //   always_ff @(posedge clk) begin
  //     if (rst) count <= 0;
  //     else if (enable) count <= next_count;
  //   end
endmodule
