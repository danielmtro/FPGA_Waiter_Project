module i2c_master (
    input  clk,      // 20 kHz input clock. Assume this is the correct frequency for the I2C transfer.

    output i2c_scl,  // I2C clock
    inout  i2c_sda,  // I2C DATA

    input  [6:0] slav_addr,
    input  read_not_write,
    input  [7:0] reg_addr,

    input  [7:0] write_data,
    input  write_valid,
    output logic write_ready,

    output logic [7:0] read_data,
    output logic read_valid,
    input  read_ready,

    output logic error
);

    logic sda_set;  // sda_set=1 means use high impedance on the I2C data line, so the line is undriven by the master. sda_set=0 means pull-down the I2C data line to a 0 (master drives the line).
    logic scl_idle; // This indicates when the I2C clock should be idle (=1).
    
    enum logic [3:0] {INIT, START, SLAVE_ADDR, READ_OR_WRITE, ACK1, REG_ADDR, ACK2, DATA, ACK3, STOP0, STOP1, STOP2} state = INIT, next_state;
        
    assign i2c_scl = scl_idle | ~clk;     // The SCL is 1 if idle, else it is the inverted i2c clock (this is a trick so that the positive edge of SCL is always inbetween SDA transitions!).
    assign i2c_sda = sda_set ? 1'bz : 0 ; // I2C: set the data line to the high-impedance Z state when sending a `1`, else set to `0`.

    logic ack_1, ack_2, ack_3;            // Acknowledgement status bits for each separate ACK : 1.After slave address, 2.After register address and 3.After data.
    assign error = ack_1 | ack_2 | ack_3; // If any of the acknowledgements from the receiver are high (NACK), then an error has occured (acknowledge is active-low).
    
    logic [2:0] counter = 0; // Use this to count bits.
    
    localparam slave_address_length = 7;
    localparam slave_register_address = 8;
    localparam slave_data_length = 8;
    //TODO Complete the FSM next-state table. Most states automatically transistion to the next (these are listed in order):
    always_comb begin : fsm_next_state
        next_state = INIT;
        case(state)
            INIT:          next_state = (write_valid && write_ready) ? START : INIT; // Remember to check for a handshake (valid & ready). Move to the START state once a 'write_valid' signal has been received.
            START:         next_state = SLAVE_ADDR;
            SLAVE_ADDR:    next_state = (counter == slave_address_length - 1) ? READ_OR_WRITE : SLAVE_ADDR; // Send slave address to the device by incrementing the bit counter.
            READ_OR_WRITE: next_state = ACK1;
            ACK1:          next_state = REG_ADDR;
            REG_ADDR:      next_state = (counter == slave_register_address - 1) ? ACK2 : REG_ADDR;  // Send the register address to the device by incrementing the bit counter.
            ACK2:          next_state = DATA;
            DATA:          next_state = (counter == slave_data_length - 1) ? ACK3 : DATA;  // Send the data to the device by incrementing the bit counter.
            ACK3:          next_state = STOP0;
            STOP0:         next_state = STOP1;  // Here, we use 3 STOP states to deal with the SCL and SDA stop symbol timings.
            STOP1:         next_state = STOP2;
            STOP2:         next_state = INIT;
        endcase
    end    

    logic  [6:0] slav_addr_temp;
    logic  [7:0] write_data_temp;
    logic  [7:0] reg_addr_temp;
    logic        read_not_write_temp;

    always_ff @(posedge clk) begin : registers
        state <= next_state;
        // Register the acknowledgements (should all be zero):
        case (state)
            INIT:   begin ack_1 <= 0 ; ack_2 <= 0 ; ack_3 <= 0; end // Reset ACK registers.
            ACK1:         ack_1 <= i2c_sda;
            ACK2:         ack_2 <= i2c_sda;
            ACK3:         ack_3 <= i2c_sda;
        endcase
        // Bit counter (only counts in the sending states).
        if (state == SLAVE_ADDR || state == REG_ADDR || state == DATA) begin
            counter <= counter + 1; // Only count bits in these states (i.e. when we are actually sending information)
        end
        else counter <= 0;
        // Store the data transferred on the handshake:
        if (write_ready && write_valid) begin
            slav_addr_temp      <= slav_addr;
            write_data_temp     <= write_data;
            reg_addr_temp       <= reg_addr;
            read_not_write_temp <= read_not_write;
        end
    end

    //TODO Complete the following FSM output table:
    always_comb begin : fsm_output
        sda_set = 1;      // Default : SDA line is high (undriven).
        scl_idle = 0;     // Default : The clock is idle (high). You can change this if you think it's easier.
        write_ready = 0;  // Default : We are not ready to send a write transaction.
        case (state)
            INIT:          begin write_ready = 1'b1;
                                 scl_idle = 1'b1; end // Reset registers. Indicate that we are *ready* for a write transaction.
            START:         begin scl_idle = 1; sda_set = 0; end // Pull SDA down for start condition (sda_set).
            SLAVE_ADDR:    begin sda_set = slav_addr_temp[6 - counter]; end // SLAVE ADDR: The address of the slave we wish to write to. Set sda_set accordingly.
            READ_OR_WRITE: begin sda_set = read_not_write_temp; end
            ACK1:          begin sda_set = 1'b1; end
            REG_ADDR:      begin sda_set = reg_addr_temp[7 - counter]; end // REG ADDR: The address of the register we wish to write to. Set sda_set accordingly.
            ACK2:          begin sda_set = 1'b1; end
            DATA:          begin sda_set = write_data_temp[7 - counter]; end // DATA: The data we wish to write. Set sda_set accordingly.
            ACK3:          begin sda_set = 1'b1; end
            STOP0:         begin sda_set = 1'b0; end // Here, we use 3 STOP states to deal with the SCL and SDA stop symbol timings.
            STOP1:         begin scl_idle = 1'b1; sda_set = 1'b0; end //   For each of these 3 STOP states, set sda_set and scl_idle appropriately.
            STOP2:         begin sda_set = 1'b1; scl_idle = 1'b1; end
        endcase
    end


    always if (read_not_write) $error("I2C read transaction not implemented!");

endmodule
