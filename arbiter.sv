module arbiter 
#(
	parameter NUM_MASTERS = 4
) (
	input  logic                  	hclk,        	// AHB Clock
	input  logic                  	hresetn,     	// AHB Reset, active low
	input  logic [NUM_MASTERS-1:0] 	hreq,       	// AHB Request signals from masters
	input  logic                  	hready,      	// AHB Ready from APB bridge
	
	output logic [NUM_MASTERS-1:0] 	hgrant      	// Grant signals for each master
);

    // Internal signal for priority encoding
    logic [$clog2(NUM_MASTERS)-1:0] grant_index;
    logic grant_valid;

    // Priority Encoder: Find the highest-priority requesting master
    always_comb begin
        grant_index = '0;
        grant_valid = 1'b0;
        for (int i = NUM_MASTERS-1; i >= 0; i--) begin
            if (hreq[i]) begin
                grant_index = i;
                grant_valid = 1'b1;
                break;
            end
        end
    end

    // Generate grant signals
	always_ff @(posedge hclk or negedge hresetn) begin
		if (!hresetn) begin
			hgrant <= {NUM_MASTERS{1'b0}};
		end 
		else begin 
			if (hready && grant_valid) begin
				hgrant <= {NUM_MASTERS{1'b0}};
				hgrant[grant_index] <= 1'b1;
			end 
			else
				hgrant <= {NUM_MASTERS{1'b0}};
		end
	end

endmodule
