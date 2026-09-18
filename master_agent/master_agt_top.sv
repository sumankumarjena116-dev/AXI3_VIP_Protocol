class master_agt_top extends uvm_env;
	`uvm_component_utils(master_agt_top)

	master_agent master_agth[];
	axi_env_config axi_env_cfg;
	
	function new(string name="master_agt_top",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",axi_env_cfg))
	  		`uvm_fatal(get_type_name(),"not getting configuration")
	
		if(axi_env_cfg.has_master_agent)
		begin
			master_agth=new[axi_env_cfg.no_of_master_agent];
			foreach(master_agth[i])
			begin
				master_agth[i]=master_agent::type_id::create($sformatf("master_agth[%0d]",i),this);
				//uvm_config_db #(master_agt_config)::set(this,$sformatf("master_agth[%0d]*",i),"master_agt_config",axi_env_cfg.master_agt_cfg[i]);
				//master_agth[i]=master_agent::type_id::create($sformatf("master_agth[%0d]",i),this);

			end		
		end

	endfunction

endclass

