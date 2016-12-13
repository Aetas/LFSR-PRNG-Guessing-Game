/*************************************
* Derek Prince                       *
* ECEN 2350: Digital Logic           *
* LFSR PRNG Generator Guessing Game  *
* Altera Cyclone 3 EP3C16F484        *
*                                    *
* Date:          November 30th, 2016 *
* Last Modified: December 1st, 2016  *
*                                    *
**************************************
*
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