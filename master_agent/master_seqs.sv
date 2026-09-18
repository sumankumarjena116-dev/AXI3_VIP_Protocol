class master_seqs extends uvm_sequence #(master_xtn);
	`uvm_object_utils(master_seqs)

	function new(string name="master_seqs");
		super.new(name);
	endfunction

	/*task body();
		repeat(1)
		begin
			req=master_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
	endtask*/

endclass


//for wrap
class fixed_seqs extends master_seqs;
	`uvm_object_utils(fixed_seqs)

	function new(string name="fixed_seqs");
		super.new(name);
	endfunction

	task body();
		repeat(50)
		begin
			// `uvm_info("SEQ","BODY STARTED",UVM_LOW)			
			req=master_xtn::type_id::create("req");
			 //`uvm_info("SEQ","BODY STARTED",UVM_LOW)
			start_item(req);
			 `uvm_info("SEQ","BODY STARTED",UVM_LOW)
			
			assert(req.randomize() with {awburst==2'b00;arburst==2'b00;});
			/*if(req.randomize() with {
  				awburst == 2'b00;
 				 arburst == 2'b00;
				})
			begin
			  $display("Randomization passed");
			end
			else begin
			  $display("Randomization failed");				
			end*/
			  `uvm_info("SEQ","AFTER RANDOMIZE",UVM_LOW)
			finish_item(req);
			 	 `uvm_info("SEQ","AFTER FINISH_ITEM",UVM_LOW)
		end
	endtask

	
endclass

class incr_seqs extends master_seqs;
	`uvm_object_utils(incr_seqs)

	function new(string name="incr_seqs");
		super.new(name);
	endfunction

	task body();
		repeat(50)
		begin
			req=master_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst==2'b01;arburst==2'b01;});
			finish_item(req);
		end
	endtask	
endclass

class wrap_seqs extends master_seqs;
	`uvm_object_utils(wrap_seqs)
	
	function new(string name="wrap_seqs");
		super.new(name);
	endfunction

	task body();
		repeat(50)
		begin
			req=master_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst==2'b10;arburst==2'b10;});
			finish_item(req);
		end
	endtask	
endclass






