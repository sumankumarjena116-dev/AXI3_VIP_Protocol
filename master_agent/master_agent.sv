class master_agent extends uvm_agent;
	`uvm_component_utils(master_agent)

	master_sequencer master_seqrh;
	master_driver master_drvh;
	master_monitor master_monh;

	master_agt_config master_agt_cfg;
	
	function new(string name="master_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(master_agt_config)::get(this,"","master_agt_config",master_agt_cfg))
			`uvm_fatal(get_type_name(),"can not get(),have you set() it?")
		master_monh=master_monitor::type_id::create("master_monh",this);
		if(master_agt_cfg.is_active==UVM_ACTIVE)
		begin
			master_drvh=master_driver::type_id::create("master_drvh",this);
			master_seqrh=master_sequencer::type_id::create("master_seqrh",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		if(master_agt_cfg.is_active==UVM_ACTIVE)
		begin
			master_drvh.seq_item_port.connect(master_seqrh.seq_item_export);
		end
	endfunction

endclass
