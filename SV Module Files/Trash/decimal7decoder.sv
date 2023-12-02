// This module implements a 7-segment decoder that takes a 4-bit 2's complement input and outputs the corresponding 7-segment display output.
module decimal7decoder(
    input [3:0] SW, // 4-bit 2's complement input
    output logic [6:0] numHEX, // 7-segment display output
    output logic [6:0] signHEX // sign bit for negative numbers
);

logic [6:0] seg; // 7-segment display output
logic [6:0] sign; // sign bit for negative numbers

always @(*) begin
    case(SW)
    //Positive numbers
        4'b0000: seg = 7'b1000000; // Display 0
        4'b0001: seg = 7'b1111001; // Display 1
        4'b0010: seg = 7'b0100100; // Display 2
        4'b0011: seg = 7'b0110000; // Display 3
        4'b0100: seg = 7'b0011001; // Display 4
        4'b0101: seg = 7'b0010010; // Display 5
        4'b0110: seg = 7'b0000010; // Display 6
        4'b0111: seg = 7'b1111000; // Display 7
        4'b1000: seg = 7'b0000000; // Display 8
        4'b1001: seg = 7'b0011000; // Display 9
        //
        4'b1010: seg = 7'b0001000; // Display A
        4'b1011: seg = 7'b0000011; // Display B
        4'b1100: seg = 7'b1000110; // Display C
        4'b1101: seg = 7'b0100001; // Display D
        4'b1110: seg = 7'b0000110; // Display E
        4'b1111: seg = 7'b0001110; // Display F

    // Negative numbers
        4'b1111: seg = 7'b1111001; // Display -1
        4'b1110: seg = 7'b0100100; // Display -2
        4'b1101: seg = 7'b0110000; // Display -3
        4'b1100: seg = 7'b0011001; // Display -4
        4'b1011: seg = 7'b0010010; // Display -5
        4'b1010: seg = 7'b0000010; // Display -6
        4'b1001: seg = 7'b1111000; // Display -7
        4'b1000: seg = 7'b0000000; // Display -8
        default: seg = 7'b1111111; // Display nothing
    endcase
end

always @(*) begin
    case (SW)
        4'b1111: sign = 7'b0111111; // Display -1
        4'b1110: sign = 7'b0111111; // Display -2
        4'b1101: sign = 7'b0111111; // Display -3
        4'b1100: sign = 7'b0111111; // Display -4
        4'b1011: sign = 7'b0111111; // Display -5
        4'b1010: sign = 7'b0111111; // Display -6
        4'b1001: sign = 7'b0111111; // Display -7
        4'b1000: sign = 7'b0111111; // Display -8
        default: sign = 7'b1111111; // Display nothing
    endcase
end

assign numHEX = seg; // assign 7-segment display output to HEX0
assign signHEX = sign; // assign sign bit for negative numbers to HEX1

endmodule