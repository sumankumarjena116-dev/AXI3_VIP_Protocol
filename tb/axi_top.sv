
module axi_top;
          
         `include "uvm_macros.svh"
	import uvm_pkg::*;
	import axi_test_pkg::*;

	bit clock;
	parameter cycle=10;

	axi_if in0(clock);

	initial begin

		/*`ifdef VCS
                        $fsdbDumpvars(0, axi_top);
                        `endif*/


		uvm_config_db #(virtual axi_if)::set(null,"*","axi_if",in0);
		run_test( );
	end

	initial begin
		clock=1'b1;
		forever #(cycle/2) clock=~clock;
	end	
endmodule
