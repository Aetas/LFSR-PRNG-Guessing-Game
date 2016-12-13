/*************************************
* Derek Prince                       *
* ECEN 2350: Digital Logic           *
* LFSR PRNG Generator Guessing Game  *
* Altera Cyclone 3 EP3C16F484        *
*                                    *
* Date:          November 30th, 2016 *
* Last Modified: December 5th, 2016  *
*                                    *
**************************************
*
*/

// -99 to 99 range is 199 values, so the closest power of 2 is 2^8, or 8 bits.
// This will be the output, though a 255 bit string is long enough to do the job.
// 1st bit is sign bit.

//I'll use 32 bits because that's a nice multiple of 8 and it doesn't really matter.
// at a length of 32, the sequence will be ~4 billion which can be checked in ~4 seconds at a GHz clock. an hour at 1MHz
module LFSRprng(clk, reset, prn);
  input clk, reset;  	//Sould probably make these things the same? Maybe not.
  reg [31:0] mondobits;             //FF memory         
  output [7:0] prn;                 //pseudo-random number output (8-bit)
  wire tap;
  assign tap = ~(mondobits[0] ^ mondobits[1] ^ mondobits[21] ^ mondobits[31]);	//feedback. Taps at 1, 2, 22, 32.
  //Shift Register Start
  always@ (posedge clk) begin // 
      mondobits = reset ? {mondobits[30:0], tap} : 32'b10011011001101000110101000110111; // assign a less boring reset state
  end
  assign prn = mondobits[31:24];  //grab the most significant 8 bits for the output.
    
endmodule //LFSRprng