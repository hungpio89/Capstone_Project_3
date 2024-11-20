module AHB_BusMatrix
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input logic 					HCLK,							// input clk_i from CPU (interface with rising-edge)
	input logic 					HRESETn,						// input rst_ni from CPU
	input logic		[  3 :  0]	REMAP,						// System address remap control
	//---------------------------------------------------//
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic						HSELM,						// from CPU mostly (in this case)
	input logic		[  1 :  0]	HTRANSM,						// indicate VALID when the AHB contains a valid APB read transfer
	input logic 					HWRITEM,						// indicates an AHB write ACCESS when HIGH (1) and an AHB read ACCESS when LOW (0)\
	input logic 	[  2 :  0]	HSIZEM,
	input logic 	[  2 :  0]	HBURSTM,
	input logic 	[  3 :  0]	HPROTM,
	input logic 					HREADYinM,					
	input logic		[ 63 :  0]	HWDATAM,				
	input logic		[ 31 :  0]	HADDRM,						// address for read slave register address
	//---------------------------------------------------//

	//-----------------RETURN FROM SLAVE-----------------//
	input logic		[ 63 :  0]	HRDATAS,
	input logic 					HRESPS,
	input logic 					HREADYoutS,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------REQUESTER OUT------------------//
	// SEND TO SLAVE
	output logic 					HREADYMUXS,
	output logic 	[  3 :  0]	HPROTS,
	output logic 	[  2 :  0]	HBURSTS,
	output logic 	[  2 :  0]	HSIZES,
	output logic	[  1 :  0]	HTRANSS,
	output logic	[ 63 :  0]	HWDATA,
	output logic	[ 31 :  0]	HADDRS,
	output logic 					PENABLE,						// indicates second and subsequent cycles of an APB transfer
	output logic 					HWRITES,						// indicates an APB write ACCESS when HIGH (1) and an APB read ACCESS when LOW (0)
	output logic					HSELS,						// currently use HSEL for select slave AHB (AHB-APB Bridge)
	
	// SEND BACK TO MASTER
	output logic	[ 63 :  0]	HRDATAM,
	output logic 					HRESPM,
	output logic 					HREADYoutM
	//---------------------------------------------------//
);

D_FF_1bit		Input_stage_HSEL
(	
	//------------------CPU INPUT------------------------//
				.clk					(HCLK), 
				.rst_ni				(HRESETn),
	//---------------------------------------------------//
	
	//-------------D-FF-INPUT <-> OUTPUT-----------------//
				.D						(HSELM),
				.Q						(HSELS)
	//---------------------------------------------------//
);
endmodule


