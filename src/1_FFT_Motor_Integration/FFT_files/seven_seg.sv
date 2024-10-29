module seven_seg(
    input      [3:0]  bcd,
    output reg [6:0]  segments // Must be reg to set in always block!!
);
  
  always @(*) begin
    case(bcd)
        0:       segments = 7'b1000000;
        1:       segments = 7'b1111001;
        2:       segments = 7'b0100100;
        3:       segments = 7'b0110000;
        4:       segments = 7'b0011001;
        5:       segments = 7'b0010010;
        6:       segments = 7'b0000010;
        7:       segments = 7'b1111000;
        8:       segments = 7'b0000000;
        9:       segments = 7'b0010000;
        default: segments = 7'b1111111;  // Default: All segments turned off.
    endcase
  end

endmodule
