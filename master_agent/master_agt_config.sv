
class master_agt_config extends uvm_object;
	`uvm_object_utils(master_agt_config)

	uvm_active_passive_enum is_active=UVM_ACTIVE;
	virtual axi_if vif;
	
	function new(string name="master_agt_config");
		super.new(name);
	endfunction

endclass
