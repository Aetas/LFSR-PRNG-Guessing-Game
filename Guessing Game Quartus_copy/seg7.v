/*************************************
* Derek Prince                       *
* ECEN 2350: Digital Logic           *
* LFSR PRNG Generator Guessing Game  *
* Altera Cyclone 3 EP3C16F484        *
*                                    *
* Date:          November 30th, 2016 *
* Last Modified: December 2nd, 2016  *
*                                    *
**************************************
*
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
