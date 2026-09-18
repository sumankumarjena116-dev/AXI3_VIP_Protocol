class slave_agt_top extends uvm_env;
	`uvm_component_utils(slave_agt_top)

	slave_agent slave_agth[];
	axi_env_config axi_env_cfg;
	
	function new(string name="slave_agt_top",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",axi_env_cfg))
	  		`uvm_fatal("SPI_AGT_TOP","not getting configuration")

			if(axi_env_cfg.has_slave_agent)
		begin
			slave_agth=new[axi_env_cfg.no_of_slave_agent];
			foreach(slave_agth[i])
			begin
				slave_agth[i]=slave_agent::type_id::create($sformatf("slave_agth[%0d]",i),this);
				//uvm_config_db #(slave_agt_config)::set(this,$sformatf("slave_agth[%0d]*",i),"slave_agt_config",axi_env_cfg.slave_agt_cfg[i]);
				//slave_agth[i]=slave_agent::type_id::create($sformatf("slave_agth[%0d]",i),this);

			end
		end

	endfunction

endclass
