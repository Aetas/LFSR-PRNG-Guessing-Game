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


// Testbench to ensure prng bit string is long enough/what it should be.
module LFSR_tb1();
  reg clk, load, reset, enable;
  reg unsigned [31:0] set, count;
  //reg [7:0] out;   //I would normally do this as 1-bit outputs to shift into place but
  wire [7:0] prn;
  reg unsigned [5:0] staten;       //state location. 2^5 goes to 32, which is what is needed.
  wire [3:0] testones, testtens;
  bcd bdcTest(.in(prn), .ones(testones), .tens(testtens));
  
  initial begin
    clk = 1'b1;
    set = 32'b0;    //all 0
    load = 1'b1;    //load is active-high
    reset = 1'b0;   //reset is active-high
    enable = 1'b1;  //enable is active-high
    staten = 6'b0;
    count = 32'b0;
    #6 load = 1'b0;
  end
  always #5 clk = ~clk;
  
  // "Oh God What Have I Done" 32-State Bit Train Detection Express!
  // Just kidding, fuck that.
  
  //I can just look at the final bit and say if it's 0, reset counter. If it's 1, increment counter and state location.
  LFSRprng lfsr(.clk(clk), .reset(reset), .load(load), .enable(enable), .set(set), .prn(prn));
  always @(negedge clk) begin //negedge because the LFSR triggers on posedge clk and I don't want them shifting at the same time.
    staten = ~prn[7] ? (staten + 1) : 6'b0;
    
    count = count + 1;
    if (staten == 32) begin
      $display("Full sequence encountered after %d comparisons", count);
      count = 0;
    end
  end
  
endmodule //LFSR_tb1
