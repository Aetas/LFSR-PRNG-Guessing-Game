/*********************************************
* Derek Prince                               *
* ECEN 2350: Digital Logic                   *
* LFSR PRNG Generator Guessing Game          *
* Altera Cyclone 3 EP3C16F484                *
*                                            *
* Date:          November 30th, 2016         *
* Last Modified: December 5th, 2016          *
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

module GuessingGame(seg7_0, seg7_1, seg7_2, seg7_3, SW, status_leds, CLOCK_50, reset, start, check);

	//states. Implemented this way to avoid constant driver conflicts
	parameter resetState = 3'b0, startState = 3'b001, checkState = 3'b010, correctState = 3'b011, cheatState = 3'b100, waitForInput = 3'b101;

	output wire [9:0] status_leds;							//DE0 status LEDS
	output wire [0:6] seg7_0, seg7_1, seg7_2, seg7_3;	//DE0 7 segment displays

	input wire [9:0] SW;											//DE0 switches
	input wire CLOCK_50;											//DE0 50MHz internal clock frequency
	input wire reset, start, check;							//DE0 pushbuttons

	wire [7:0] prn;												//LFSRprng output number. 8-bit
	wire [3:0] secretOne, secretTen;							//converted BCD numbers from random number
	wire [3:0] guessOne, guessTen;							//number of guesses converted to BCD

	reg [26:0] clk_divider_count_halfHz;					//It needs to count to 100 million, what can I say. At least this program is small and everything is parallel, right?
	reg [7:0] guessCount;										//keeps track of number of guesses made
	reg [7:0] genNumStorage;									//stores generated number in undone 2's complement.
	reg [4:0] dispNum[3:0];										//display numbers. Have to be resigsters to change the displays between states. 5 bits to support some letters
	reg [24:0] clk_divider_count;								//counter to divide frequency
	reg [3:0] onesInput, tensInput;							//DE0 board inputs
	reg [3:0] hiddenOnes, hiddenTens;						//generated numbers in BCD format
	reg [2:0] currentState, nextState;						//stores the states
	reg clk, negative, higher, correct;						//negative is for generated number. higher is if the hidden num is higher or lower (T:1/F:0)
	reg inputIsNegative;
	reg halfHztoggle;	//this is for the final screen display.
							//assignment says to display the number and the guesses.
							//if there were 10+ guesses and a negative number, that's 5 displays.
							//I have 4.

	//modules
	LFSRprng lfsr(.clk(clk), .reset(reset), .prn(prn));
	bcd generateConversion(.in({1'b0, genNumStorage[6:0]}), .ones(secretOne), .tens(secretTen));
	bcd guessConversion(.in(guessCount), .ones(guessOne), .tens(guessTen));
	seg7 display0(.bnum(dispNum[0]), .led(seg7_0));
	seg7 display1(.bnum(dispNum[1]), .led(seg7_1));
	seg7 display2(.bnum(dispNum[2]), .led(seg7_2));
	seg7 display3(.bnum(dispNum[3]), .led(seg7_3));

	//initials
	initial begin
		clk = 0;
		halfHztoggle = 0;
		guessCount = 0;
		genNumStorage = 8'b0;
		dispNum[0] = ~5'b0;	//0 is left-most display
		dispNum[1] = ~5'b0;
		dispNum[2] = ~5'b0;
		dispNum[3] = ~5'b0;
		hiddenOnes = 0;
		hiddenTens = 0;
		onesInput = 0;
		tensInput = 0;
		currentState = 0;	//initially 0
	end

	//statusLEDs
	assign status_leds[9] = (currentState == resetState);		//leds 9-4 are the states
	assign status_leds[8] = (currentState == startState);
	assign status_leds[7] = (currentState == waitForInput);
	assign status_leds[6] = (currentState == checkState);
	assign status_leds[5] = (currentState == correctState);
	assign status_leds[4] = (currentState == cheatState);
	assign status_leds[3] = reset;									//3-1 follow the pushbutton logic levels
	assign status_leds[2] = start;
	assign status_leds[1] = check;
	assign status_leds[0] = clk;										//follows clk

	//input vs generated number comparison (debugging)
	//assign status_leds[9:2] = halfHztoggle ? {hiddenTens, hiddenOnes} : {tensInput, onesInput};

	//keep track of checks
	always @(negedge check) begin
		guessCount =  reset ? (guessCount + 1) : 0;
	end

	//FSM00122
	always @(posedge clk) begin

	currentState = nextState;
		case (currentState)
			//RESET STATE
			resetState: begin
				correct = 0;
				genNumStorage = 0;
				//set 7-segments blank
				dispNum[0] <= ~5'b0;
				dispNum[1] <= ~5'b0;
				dispNum[2] <= ~5'b0;
				dispNum[3] <= ~5'b0;
				nextState <= waitForInput;
			end

			//START STATE
			startState: begin
				//intermediate 2's complement conversion.
				//not a fan, but user input being in BCD makes it a requirement. At least without a reverse BCD dealio.
				genNumStorage = prn;
				negative = genNumStorage[7];

				//non blocking assignment to let genNumStorage convert.
				hiddenOnes <= secretOne;		//at start, grab the current p-rand number.
				hiddenTens <= secretTen;		// User inputs are in BCD, so I'm just doing comparisons
													// in BCD. Not my fave but that's what the project requests.

				dispNum[0] <= ~5'b0;
				dispNum[1] <= ~5'b0;
				dispNum[2] <= ~5'b0;
				dispNum[3] <= ~5'b0;
				nextState = waitForInput;
			end

			//CHECK STATE
			checkState: begin
				if (negative == inputIsNegative) begin
					//signs agree, compare magnitudes
					if ({hiddenTens, hiddenOnes} == {tensInput, onesInput}) begin
						//next state
						correct = 1;
					end
					else
						higher = negative ? ~({hiddenTens, hiddenOnes} > {tensInput, onesInput}) : ({hiddenTens, hiddenOnes} > {tensInput, onesInput});
				end
				else if (negative != inputIsNegative) begin
					higher = (~negative & inputIsNegative) ? 1'b1 : 1'b0;		//
				end
				//state interpretation
				//non-blocking so it evaluates after the if's
				dispNum[0] <= higher ? 20 : 22;	//H = 20, L = 22
				dispNum[1] <= higher ? 21 : 23;	//I = 21, O = 23
				dispNum[2] <= ~5'b0;
				dispNum[3] <= ~5'b0;
				if (correct)
					nextState = correctState;
				else
					nextState = waitForInput;
			end

			//CORRECT STATE
			correctState: begin
				//low clock is the secret number. (right)
				//high clock is number of guesses (left)
				dispNum[0] = halfHztoggle ? guessTen : ~5'b0;
				dispNum[1] = halfHztoggle ? guessOne : {~4'b0, ~negative};
				dispNum[2] = halfHztoggle ? ~5'b0 : hiddenTens;
				dispNum[3] = halfHztoggle ? ~5'b0 : hiddenOnes;
				//nextState = correctState;
				if (~reset)
					nextState = resetState;
			end

			//CHEATING HOBBITSIES
			cheatState: begin
				//when this switch is flipped, the display shows the secret number.
				//Obviously this is cheating but I only have 10 minutes to do the video.

				dispNum[0] <= ~5'b0;	//off
				dispNum[1] <= negative ? 30 : 31;		//negative sign - will send 31 for all off or 30 for negative sign
				dispNum[2] <= {1'b0, hiddenTens};		//concatenated with 0 because the 7-segment module takes
				dispNum[3] <= {1'b0, hiddenOnes};		//5-bit inputs (expanded to handle HI and LO)
				if (~start)
					nextState = startState;
				else if (SW[0]) begin
					nextState = cheatState;
				end
				else begin
					//clear cheat screen and set back to previous state
					dispNum[0] <= higher ? 20 : 22;	//H = 20, L = 22
					dispNum[1] <= higher ? 21 : 23;	//I = 21, O = 23
					dispNum[2] <= ~5'b0;
					dispNum[3] <= ~5'b0;
					nextState = waitForInput;
				end
			end

			//IDLE STATE
			waitForInput: begin
				//gather inputs
				inputIsNegative = SW[9];
				tensInput = SW[8:5];
				onesInput = SW[4:1];


				if (~reset)
					nextState <= resetState;
				else if (~start)
					nextState <= startState;
				else if (~check)
					nextState <= checkState;
				else if (SW[0])
					nextState <= cheatState;
			end
		endcase

	end

	//hardware clock division
	always @(posedge CLOCK_50) begin
		clk_divider_count = clk_divider_count + 1;

		if (clk_divider_count == 5000000) begin	//divides clk by 5M. 10Hz clk. Watching the states is fun. That's why/
			clk_divider_count = 5'b0;					//reset count
			clk = ~clk;
		end

		clk_divider_count_halfHz = clk_divider_count_halfHz + 1;

		if (clk_divider_count_halfHz == 100000000) begin
			halfHztoggle = ~halfHztoggle;	//it's actually a quarter Hz clock but I use the low period and the high period. So whatever.
			clk_divider_count_halfHz = 0;
		end
	end

endmodule
