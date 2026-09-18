class axi_test extends uvm_test;
	`uvm_component_utils(axi_test)
	

	master_agt_config master_agt_cfg[];
	slave_agt_config slave_agt_cfg[];
	axi_env_config axi_env_cfg;
	axi_env axi_envh;

	bit has_master_agent=1;
	bit has_slave_agent=1;
	bit has_scoreboard=1;

	int no_of_master_agent=1;
	int no_of_slave_agent=1;

	function new(string name="axi_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		axi_env_cfg=axi_env_config::type_id::create("axi_env_cfg");			
		
		if(has_master_agent)
		begin
			master_agt_cfg=new[no_of_master_agent];
			foreach(master_agt_cfg[i])
			begin
				master_agt_cfg[i]=master_agt_config::type_id::create($sformatf("master_agt_cfg[%0d]",i));
				master_agt_cfg[i].is_active=UVM_ACTIVE;
				if(!uvm_config_db #(virtual axi_if)::get(this,"","axi_if",master_agt_cfg[i].vif))
					`uvm_fatal(get_type_name(),"can not get have you set() it")
				uvm_config_db #(master_agt_config)::set(this,$sformatf("*master_agth[%0d]*",i),"master_agt_config",master_agt_cfg[i]);
				
				//axi_env_cfg.master_agt_cfg[i]=master_agt_cfg[i];	
				
				/*if(!uvm_config_db #(virtual axi_if)::get(this,"","axi_if",master_agt_cfg[i].vif))
					`uvm_fatal(get_type_name(),"can not get() vif from uvm_config_db, have you set() it?")*/
			end
		end
		
		if(has_slave_agent)
		begin
			slave_agt_cfg=new[no_of_slave_agent];
			foreach(slave_agt_cfg[i])
			begin
				slave_agt_cfg[i]=slave_agt_config::type_id::create($sformatf("slave_agt_cfg[%0d]",i));
				slave_agt_cfg[i].is_active=UVM_ACTIVE;
				if(!uvm_config_db #(virtual axi_if)::get(this,"","axi_if",slave_agt_cfg[i].vif))
					`uvm_fatal(get_type_name(),"can not get have you set() it")
				uvm_config_db #(slave_agt_config)::set(this,$sformatf("*slave_agth[%0d]*",i),"slave_agt_config",slave_agt_cfg[i]);
				
				/*if(!uvm_config_db #(virtual axi_if)::get(this,"","axi_if",slave_agt_cfg[i].vif))
					`uvm_fatal(get_type_name(),"can not get() vif from uvm_config_db, have you set() it?")*/
			end
		end

		axi_env_cfg.has_master_agent=has_master_agent;
                axi_env_cfg.has_slave_agent =has_slave_agent;
                axi_env_cfg.has_scoreboard =has_scoreboard;
		axi_env_cfg.no_of_master_agent = no_of_master_agent;
		axi_env_cfg.no_of_slave_agent  = no_of_slave_agent;
		
		axi_env_cfg.master_agt_cfg = new[axi_env_cfg.no_of_master_agent];
		foreach(master_agt_cfg[i])
		begin
			axi_env_cfg.master_agt_cfg[i]=master_agt_cfg[i];
		end
		axi_env_cfg.slave_agt_cfg  = new[axi_env_cfg.no_of_slave_agent];
		foreach(slave_agt_cfg[i])
		begin
			axi_env_cfg.slave_agt_cfg[i]=slave_agt_cfg[i];	
		end
		uvm_config_db #(axi_env_config)::set(this,"*","axi_env_config",axi_env_cfg);
	
		axi_envh=axi_env::type_id::create("axi_envh",this);
	
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
endclass

class fixed_test extends axi_test;
	`uvm_component_utils(fixed_test)

	fixed_seqs fixed_seqh;
	
	function new(string name="wrap_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void  build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		fixed_seqh=fixed_seqs::type_id::create("fixed_seqh");
		phase.raise_objection(this);
		 `uvm_info("TEST","Before sequence start",UVM_LOW)
		#500;		
		fixed_seqh.start(axi_envh.master_agt_toph.master_agth[0].master_seqrh);
		#500;		
		 `uvm_info("TEST","Before sequence start",UVM_LOW)

		phase.drop_objection(this);
	endtask
	
endclass
	
class incr_test extends axi_test;
	`uvm_component_utils(incr_test)

	incr_seqs incr_seqh;
	
	function new(string name="incr_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void  build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		incr_seqh=incr_seqs::type_id::create("incr_seqh");
		phase.raise_objection(this);
		incr_seqh.start(axi_envh.master_agt_toph.master_agth[0].master_seqrh);
		phase.drop_objection(this);
	endtask
	
endclass

class wrap_test extends axi_test;
	`uvm_component_utils(wrap_test)

	wrap_seqs wrap_seqh;
	
	function new(string name="wrap_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void  build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		wrap_seqh=wrap_seqs::type_id::create("wrap_seqh");
		phase.raise_objection(this);
		wrap_seqh.start(axi_envh.master_agt_toph.master_agth[0].master_seqrh);
		phase.drop_objection(this);
	endtask
	
endclass













































































































