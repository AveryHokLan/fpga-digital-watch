// binary_to_bcd - A module to convert a 7-bit binary number (0-99) to its BCD representation.
//
// Parameters:
// None
//
// Ports:
// bin - The 7-bit binary input representing a number from 0 to 99.
// tens - The 4-bit BCD output for the tens digit.
// ones - The 4-bit BCD output for the ones digit.

`timescale 1ns / 1ps

module binary_to_bcd (
    input  logic [6:0] bin,   //binary input, 0-99
    output logic [3:0] tens,  //decimal tens digit (BCD)
    output logic [3:0] ones   //decimal ones digit (BCD)
);

  assign tens = 4'(bin / 7'd10);
  assign ones = 4'(bin % 7'd10);

endmodule
