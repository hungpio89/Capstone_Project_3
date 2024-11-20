module bit_counter_unit		// determine whether the bit is trans when we are done
(
	input logic				rst_n,
	input logic [ 3 : 0]	shift_bit,
	input logic [ 7 : 0] data_in,		// decide by number of data want to transfer, parity or not
	
	output logic			start_o,
	output logic			data_avail,
	output logic			data_on_trans,
	output logic			parity,
	output logic			stop,
	output logic			done
);

	logic [ 1 :  0] sel;
	logic [ 3 :  0] counter, w1;
	
	assign sel 		= {shift_bit, done};

mux4to1_4bit			mux_sel_start_done
(
							.sel 				(sel),		// arrange bit 0 ~ done, bit 1 ~ start
							.in				(counter),
		
							.out				(w1)
);

comparator_bit			check_done_flag
(
							.bit_used	 	(bit_used),
							.count_value_i	(counter),
	
							.done				(done)
);
endmodule
