module APB_MASTER	// APB BRIDGE
(
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input logic 				PCLK,						// input clk_i from CPU (interface with rising-edge)
	input logic 				PRESETn,					// input rst_ni from CPU
	input logic 				READ_WRITE,				// indicate APB in read or write mode
	input logic [ 31 :  0]	apb_write_data,		// data sequence send to slave
	input logic [ 31 :  0]	apb_write_paddr,		// address sequence send to slave
	input logic [ 31 :  0]	apb_read_paddr,		// address sequence receive from slave
	//---------------------------------------------------//
	
	//---------------REQUESTER IN(MASTER)----------------//
	
	//--------------------OPTIONAL-----------------------//
	input logic [	2 :  0]	PPROT,					// protection type (normal, priviledged or secure protection level)
	//---------------------------------------------------//
	
	//-----------------INPUT FROM COMPLETER--------------//
	input logic 				PREADY,					// indicates an APB write access when HIGH (1) and an APB read access when LOW (0)
	input logic	[  7 :  0]	PRDATA,					// read data bus is driven by the selected Completer during read cycles when PWRITE is LOW.
	//---------------------------------------------------//
	
	
	
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------REQUESTER OUT------------------//
	output logic 				PSELx,	// indicates that the completer is selected and that a data transfer is require
	output logic 				PENABLE,					// indicates second and subsequent cycles of an APB transfer
	output logic [ 31 :  0] PADDR,					// address bus APB
	output logic [ 31 :  0] PWDATA,					// driven by the APB bridge Requester during write cycles when PWRITE is HIGH.
	
	output logic [  3 :	0] PSTRB,					// indicates which byte lanes to updateduring a write transfer. 
																// There is one write strobe for each 8 bits of the write data bus. 
																// PSTRB[n]corresponds to PWDATA[(8n + 7):(8n)].
																// PSTRB must not be active during a read transfer
	output logic 				PWRITE,					// indicates an APB write access when HIGH (1) and an APB read access when LOW (0)
	//---------------------------------------------------//
	
	//--------------------CPU FEEDBACK-------------------//
	output logic [ 31 :  0] apb_read_data_out		// address bus APB
	//---------------------------------------------------//
);

//	Local logic declaration
	logic 						transfer;				// indicate start transfer process assert by transfer cycle (maybe based on ADDR, READ_WRITE, PWRITE, CLK, RESETn, PWDATA, PRDATA)

	
FSM_APB	APB_PULSE_GENERATOR	(
									// INPUT
									.PCLK(PCLK),
									.PRESETn(PRESETn),
									.transfer(transfer),
									
									// OUTPUT
									.PREADY(PREADY),
									.PENABLE(PENABLE),
									.PSELx(PSELx)
);

endmodule
