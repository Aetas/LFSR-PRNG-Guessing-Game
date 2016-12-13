/*********************************************
* Derek Prince                               *
* ECEN 2350: Digital Logic                   *
* LFSR PRNG Generator Guessing Game          *
* Altera Cyclone 3 EP3C16F484                *
*                                            *
* Date:          November 30th, 2016         *
* Last Modified: December 1st, 2016          *
*                                            *
**********************************************

Copyright (c) 2016 Derek Prince

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

// -99 to 99 range is 199 values, so the closest power of 2 is 2^8, or 8 bits.
// This will be the output, though a 255 bit string is long enough to do the job.
// 1st bit is sign bit.

//I'll use 32 bits because that's a nice multiple of 8 and it doesn't really matter.
// at a length of 32, the sequence will be ~4 billion which can be checked in ~4 seconds at a GHz clock. an hour at 1MHz
module LFSRprng(clk, reset, load, enable, set, prn);
  input wire reset, load, enable, clk;  //Sould probably make these things the same? Maybe not.
  input wire [31:0] set;                //set an initial state. Can be specified.
  reg [31:0] mondobits;                 //FF memory
  output [7:0] prn;                     //pseudo-random number output (8-bit)
  wire tap;
  assign tap = ~(mondobits[0] ^ mondobits[1] ^ mondobits[21] ^ mondobits[31]);    //feedback
  //Shift Register Start
  always@ (posedge clk) begin //
    if (load)
      mondobits = set;
    else if (reset && !load)   //I don't want it to reset if it just loaded a state. Technically that state would be a user error though.
      mondobits = ~32'b0;     //set all to 1. 0 freezes LFSR's (XOR)
    else if (enable)
      mondobits <= {mondobits[30:0], tap};  //feedback. Taps at 1, 2, 22
  end
  assign prn = mondobits[31:23];  //grab the most significant 8 bits for the output.
      // The prn is not a non-blocking assignment simply because I want to have
      // the output match the load for the first clock cycle. Bit string length will still be the same

endmodule //LFSRprng
