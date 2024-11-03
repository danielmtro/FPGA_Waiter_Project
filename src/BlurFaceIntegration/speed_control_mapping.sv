/*
Module maps logic integers up to 7 to their corresponding 
ascii characters
*/

import lcd_inst_pkg::*;

module speed_control_mapping
(
    input logic [3:0] speed,
    output logic [7:0] ascii_speed
);

    always_comb begin
        ascii_speed = {8'd53};
        case(speed)

            3'b000 : ascii_speed = _0;
            3'b001 : ascii_speed = _1;
            3'b010 : ascii_speed = _2;
            3'b011 : ascii_speed = _3;
            3'b100 : ascii_speed = _4;
            3'b101 : ascii_speed = _5;
            default ascii_speed = _5;
        endcase
    end
endmodule