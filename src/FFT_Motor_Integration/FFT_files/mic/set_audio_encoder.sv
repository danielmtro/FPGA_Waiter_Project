module set_audio_encoder (
    input      i2c_clk, // Assuming a 20 kHz clock is input (for testbench)
    output     I2C_SCLK,
    inout      I2C_SDAT
);
    logic [23:0] data;       
    logic valid, ready;
    logic error;

    // Instantiate I2C master module
    i2c_master u1 (.clk(i2c_clk), .i2c_scl(I2C_SCLK), .i2c_sda(I2C_SDAT), .slav_addr(data[23-:7]), .read_not_write(data[16]), .reg_addr(data[15-:8]), .write_data(data[7:0]), .write_ready(ready), .write_valid(valid), .error(error));

    // Now, let's use a FSM to control the I2C master module.
    // We will feed the I2C module a set of instructions that determine the registers to set and values to set them to (see always_comb block at the bottom).
    enum logic [1:0] {LOAD, WAIT, NEXT} state = LOAD, next_state;            

    localparam INIT_CMDS_N = 11;
    logic [3:0] initialise_index = 0;
    
    always_comb begin : fsm_next_state
        next_state = LOAD;
        case (state)
            LOAD : next_state = initialise_index < INIT_CMDS_N ? WAIT : LOAD; // Stop sending to the audio encoder chip after we step through all initialisation commands.
            WAIT : next_state = ready ? (error === 1 ? LOAD : NEXT) : WAIT;  // Wait until the I2C module is finished sending bits. If it finished but there was an error, try again by restarting from the LOAD state.
            NEXT : next_state = LOAD; 
        endcase
    end
                                                        
    logic [15:0]    reg_and_data;
    logic done;
    assign done = (initialise_index >= INIT_CMDS_N && ready);
                            
    always_ff @(posedge i2c_clk) begin : fsm_ff
        state <= next_state;
        case(state)
            LOAD: data <= {7'h1A,1'b0,reg_and_data};      // 0x1A is the 7-bit address of the Audio Encoder chip. The 1-bit is R/W=0 for writing. Now, reg_and_data is 7bits reg address and 9bits data to write into that register.
            NEXT: initialise_index <= initialise_index+1; // Increment the initialise index to read the next initialisation command from the sequence.
        endcase
    end
    assign valid = (state == WAIT); // Assert valid to get the I2C module to start sending.

    // The following is a ROM that contains all initialisation commands to setup the audio codec, in order.
    always_comb begin : config_data_cmds
        case(initialise_index)
            //    Audio Config Data  // Format: {7 bits for reg, 9 bits for value}
            1:        reg_and_data    <=    {7'h00, 9'hFF}; // Set SET_LIN_L:     +12dB left channel line input volume, enable mute to ADC, disable simultaneous load.
            2:        reg_and_data    <=    {7'h01, 9'hFF}; // Set SET_LIN_R:     +12dB right channel line input volume, enable mute to ADC, disable simultaneous load.
            3:        reg_and_data    <=    {7'h02, 9'hFD}; // Set SET_HEAD_L:    +4dB left channel headphone output volume, zero cross detect enabled, disable simultaneous load.
            4:        reg_and_data    <=    {7'h03, 9'hFD}; // Set SET_HEAD_R:    +4dB right channel headphone output volume, zero cross detect enabled, disable simultaneous load.
            5:        reg_and_data    <=    {7'h04, 9'h3D}; // Set A_PATH_CTRL:   Microphone boost enabled, disable mic mute to ADC, mic line select to ADC, enable bypass, select DAC, enable side tone, -6dB side tone attenuation
            6:        reg_and_data    <=    {7'h05, 9'h00}; // Set D_PATH_CTRL:   Enable high pass filter, disable de-emphasis, disable soft-mute, clear DC offset when high pass filter disabled.
            7:        reg_and_data    <=    {7'h06, 9'h00}; // POWER_DOWN_CTRL:   Disable all power down options.       
            8:        reg_and_data    <=    {7'h07, 9'h41}; // SET_FORMAT:        MSB-first Left-Justified audio data format, 16 bit audio data length, right-channel DAC data when DACLRC is low, right channel DAC data right, enable MASTER mode, don't invert BCLK.
            9:        reg_and_data    <=    {7'h08, 9'h02}; // SAMPLE_CTRL:       Normal mode (256/384fs), Base Over-Sampling Ratio = 384fs, ADC and DAC sample rate control = 0, core clock is MCLK, CLOCKOUT is core clock.
            10:       reg_and_data    <=    {7'h09, 9'h01}; // SET_ACTIVE:        Bit-0: Set interface to Active.
            default : reg_and_data    <=    16'd0 ;
        endcase
    end
endmodule
