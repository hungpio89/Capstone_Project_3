module  ctrl_interface_signal
(
	input 	logic						CLK,												// this is considered as the external custom clock by user
	input 	logic						RESETn,
	
	input 	logic	[	 7 :   0]	PADDR,
	input		logic						cfg_en,											// Enable config mode
	
	input 	logic	[  19 :   0] 	desired_baud_rate,
	
	input 	logic	[	 6 :   0]	ctrl_i,											// ctrl only write, only read, ..etc
	input 	logic	[	 3 :   0]	state_isr_i,
	
	output 	logic	[	 6 :   0]	ctrl_o,											// ctrl only write, only read, ..etc
	output 	logic	[	 3 :   0]	state_isr_o,
	output 	logic	[  12 :   0]	cd_o
	
);
	
	logic				[  12 :   0]	actual_cd;	
	
	// Register
	reg				[   7 :   0] 	base_offset; 
	
	// Local signal assignment for PADDR
	genvar i;
	generate 
		for (i = 0; i < 8; i = i + 1) begin: offset_assignment
			assign base_offset[i] = PADDR[i];
		end
	endgenerate
	
	// always loop for define cd for clock divisor counter
	always @(desired_baud_rate) begin	
		case(desired_baud_rate)
			20'd600   : actual_cd = 13'd5208;
			20'd4800	 : actual_cd = 13'd651;
			20'd9600	 : actual_cd = 13'd325;
			20'd19200 : actual_cd = 13'd162;
			20'd28800 : actual_cd = 13'd108;
			20'd38400 : actual_cd = 13'd81;
			20'd57600 : actual_cd = 13'd54;
			20'd115200: actual_cd = 13'd27;
			20'd230400: actual_cd = 13'd13;
			20'd460800: actual_cd = 13'd6;
			20'd921600: actual_cd = 13'd3;					// Maximum baudrate for normal UART
			default   :	actual_cd = 13'd27;					// default 115200
		endcase
	end
	
	
	always @(posedge CLK or negedge RESETn) begin
		if (!RESETn) begin
			ctrl_o 			<= 7'b000_0011;
			state_isr_o 	<= {2'b00, state_isr_i[1], state_isr_i[0]};
			cd_o				<= 13'd27;							// ~115200 baudrate
		end
		else begin
			if (cfg_en) begin
				case (base_offset)
					8'h0: begin
						for (int i = 0; i < 7; i = i + 1) begin
							ctrl_o[i]		<= ctrl_i[i];
						end
					end
					8'h4: begin
						for (int j = 2; j < 4; j = j + 1) begin
							state_isr_o[j]	<= state_isr_i[j];
						end
					end
					8'h8: begin
						for (int k = 0; k < 13; k = k + 1) begin
							cd_o[k]			<= actual_cd[k];
						end
					end
					default: begin
						ctrl_o 			<= 7'b000_0011;
						state_isr_o 	<= {2'b00, state_isr_i[1], state_isr_i[0]};
						cd_o				<= 13'd27;						// ~115200 baudrate
					end
				endcase
			end
			else
				ctrl_o 			<= ctrl_o;
				state_isr_o 	<= state_isr_o;
				cd_o				<= cd_o;
		end
	end

endmodule	