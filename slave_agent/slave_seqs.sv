class slave_seqs extends uvm_sequence;
	`uvm_object_utils(slave_seqs)

	function new(string name="slave_seqs");
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

