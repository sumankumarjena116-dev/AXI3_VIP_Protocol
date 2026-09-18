class axi_env extends uvm_env;
	`uvm_component_utils(axi_env)
	
	master_agt_top master_agt_toph;
	slave_agt_top slave_agt_toph;
	axi_sb sbh;

	axi_env_config axi_env_cfg;

	function new(string name="axi_env",uvm_component parent);
		super.new(name,parent);

		$display("AXI_ENV CONDTRUCTOR");
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		   $display("AXI_ENV BUILD PHASE ENTERED");

		if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",axi_env_cfg))
			`uvm_fatal(get_type_name(),"can not get(),have you set() it?")
                
		//$display(axi_env_cfg.has_master_agent);

		master_agt_toph=master_agt_top::type_id::create("master_agt_toph",this);
		slave_agt_toph=slave_agt_top::type_id::create("slave_agt_toph",this);
	
		
		/*if(axi_env_cfg.has_master_agent)
		begin
			master_agt_toph=new[axi_env_cfg.no_of_master_agent];
			foreach(master_agt_toph[i])
			begin
				master_agt_toph[i]=master_agt_top::type_id::create($sformatf("master_agt_toph[%0d]",i),this);
				uvm_config_db #(master_agt_config)::set(this,"*","master_agt_config",axi_env_cfg.master_agt_cfg[i]);
			end		
		end

		if(axi_env_cfg.has_slave_agent)
		begin
			slave_agt_toph=new[axi_env_cfg.no_of_slave_agent];
			foreach(slave_agt_toph[i])
			begin
				slave_agt_toph[i]=slave_agt_top::type_id::create($sformatf("slave_agt_toph[%0d]",i),this);
				uvm_config_db #(slave_agt_config)::set(this,"*","slave_agt_config",axi_env_cfg.slave_agt_cfg[i]);
			end
		end*/
		
		if(axi_env_cfg.has_scoreboard)
			sbh=axi_sb::type_id::create("sbh",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		  `uvm_info("ENV","ENV CONNECT PHASE",UVM_LOW)
		if(axi_env_cfg.has_scoreboard)
		begin
			foreach(axi_env_cfg.master_agt_cfg[i])
			begin
				         $display("CONNECTING MASTER[%0d]",i);
				master_agt_toph.master_agth[i].master_monh.mstr_monport.connect(sbh.fifo_mstrh[i].analysis_export);
				         $display("CONNECTED MASTER[%0d]",i);
			end
			foreach(axi_env_cfg.slave_agt_cfg[i])
			begin
				$display("CONNECTING SLAVE[%0d]",i);
				slave_agt_toph.slave_agth[i].slave_monh.slv_monport.connect(sbh.fifo_slvh[i].analysis_export);
                               $display("CONNECTED SLAVE[%0d]",i);

			end
		end
	endfunction

endclass
