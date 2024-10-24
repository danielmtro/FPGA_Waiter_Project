/*
This module integrates both the filter fsm and the lcd display.
It takes in the key, clock and relevant LCD outputs.

It creates the FSM and allows for visualisation of the current state
on the LCD.

We output the current state from this module.
*/

`timescale 1 ps / 1 ps
module state_machine_with_display(
    input       [3:0] KEY,
    input  wire       clk,         //                Clock to be used
    inout  wire [7:0] LCD_DATA,    // external_interface.DATA
    output wire       LCD_ON,      //                   .ON
    output wire       LCD_BLON,    //                   .BLON
    output wire       LCD_EN,      //                   .EN
    output wire       LCD_RS,      //                   .RS
    output wire       LCD_RW,      //                   .RW
    output [1:0]      filter_type  // output the current state
);

    filter_fsm(.clk(clk), 
               .key(KEY),
               .filter_type(filter_type));

    // iniate top level for the lcd control module
    lcd_top_level(.clk(clk),
                  .current_state(filter_type),
                  .LCD_DATA    (LCD_DATA),    // external_interface.export
                  .LCD_ON      (LCD_ON),      //                   .export
                  .LCD_BLON    (LCD_BLON),    //                   .export
                  .LCD_EN      (LCD_EN),      //                   .export
                  .LCD_RS      (LCD_RS),      //                   .export
                  .LCD_RW      (LCD_RW)       //                   .export)
    );

endmodule