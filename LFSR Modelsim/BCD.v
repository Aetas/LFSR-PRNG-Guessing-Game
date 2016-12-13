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

// Doubble Dabble
// Also known as shift-and-add 3. But that's stupid.
module bcd(in, ones, tens);

  input [7:0] in;

  output reg [3:0] ones, tens;  //I only care about -99 through 99.
  reg [3:0] hundreds;           // not defined as i/o to avoid compiler bitching about ports.

  integer i;
  always@ (in) begin
    ones = 4'b0;
    tens = 4'b0;
    hundreds = 4'b0;

    //do for loops work in hardware? I thought this was a system Verilog thing.
    for (i=7; i>=0; i=i-1) begin
      if (hundreds >= 5)
        hundreds = hundreds + 3;
      if (tens >= 5)
        tens = tens + 3;
      if (ones >= 5)
        ones = ones + 3;

        //shifting bits in
        hundreds = {hundreds[2:0], tens[3]};
        tens = {tens[2:0], ones[3]};
        ones = {ones[2:0], in[i]};
    end
  end

endmodule
