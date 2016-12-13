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

module seg7(bnum, led);
input [4:0] bnum;			//input number
output reg [0:6] led;	//output
				//I did this in reverse originally so the vector declaration is reversed instead of redoing it
always @(bnum)
	case(bnum)
		0: led = 7'b0000001;		//0
		1: led = 7'b1001111;		//1
		2: led = 7'b0010010;		//2
		3: led = 7'b0000110;		//3
		4: led = 7'b1001100;		//4
		5: led = 7'b0100100;		//5
		6: led = 7'b0100000;		//6
		7: led = 7'b0001111;		//7
		8: led = 7'b0000000;		//8
		9: led = 7'b0000100;		//9
		10: led = 7'b0001000;	//A
		11: led = 7'b1100000;	//B
		12: led = 7'b0110001;	//C
		13: led = 7'b1000010;	//D
		14: led = 7'b0110000;	//E
		15: led = 7'b0111000;	//F

		20: led = 7'b1001000;	//H
		21: led = 7'b1001111;	//I
		22: led = 7'b1110001;	//L
		23: led = 7'b0000001;	//O
		30: led = 7'b1111110;	//negative sign
		31: led = 7'b1111111;	//all off

		default: led = 7'b1111111;	//default off
	endcase
endmodule //seg7
