class axi_env_config extends uvm_object;

	`uvm_object_utils(axi_env_config);

	bit has_functional_coverage;
	bit has_scoreboard=1;
	bit has_master_agent=1;
	bit has_slave_agent=1;
	int no_of_master_agent=1;
	int no_of_slave_agent=1;

	master_agt_config master_agt_cfg[];
	slave_agt_config slave_agt_cfg[];
	

	function new(string name="axi_env_config");
		super.new(name);
	endfunction

endclass
