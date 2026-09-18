class slave_monitor extends uvm_monitor;
	`uvm_component_utils(slave_monitor)

	virtual axi_if.SLAVE_MON_MP vif;
	slave_agt_config slave_agt_cfg;

		int slv_pkg_sent;

	uvm_analysis_port #(master_xtn)slv_monport;

	function new(string name="slave_monitor",uvm_component parent);
		super.new(name,parent);
		slv_monport=new("slv_monport",this);		
	endfunction
	
	master_xtn xtn,xtn1,xtn2,xtn3,xtn4;
		
	//declare queues
	master_xtn q1[$],q2[$],q3[$];

	//declare semaphore
	semaphore sem_awaddr=new(1);

	semaphore sem_wdata=new(1);

	semaphore sem_bresp=new(1);
	
	semaphore sem_araddr=new(1);

	semaphore sem_rresp=new(1);

	semaphore sem_wrdata=new();//wr data dependency

	semaphore sem_wrresp=new();//wr response dependency
	
	semaphore sem_rdresp=new();//rd response dependency


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(slave_agt_config)::get(this,"","slave_agt_config",slave_agt_cfg))
			`uvm_fatal(get_type_name(),"can not get() have you set() it?")
	endfunction
	
	function void connect_phase(uvm_phase phase);
		vif=slave_agt_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		//xtn=master_xtn::type_id::create("xtn");
		forever 
			//xtn=master_xtn::type_id::create("xtn");		
			collect_data();
			
		//`uvm_info("MASTER_MONITOR",$sformatf("string \n %s",xtn.sprint()),UVM_LOW)
	endtask



	task wr_addr_collect();
		
		master_xtn xtn;
		xtn=master_xtn::type_id::create("xtn");
		//@(vif.slave_mon_cb);
		
		wait(vif.slave_mon_cb.awvalid && vif.slave_mon_cb.awready)
		xtn.awvalid=vif.slave_mon_cb.awvalid;
		xtn.awid=vif.slave_mon_cb.awid;
		xtn.awaddr=vif.slave_mon_cb.awaddr;
		xtn.awlen=vif.slave_mon_cb.awlen;
		xtn.awsize=vif.slave_mon_cb.awsize;
		xtn.awburst=vif.slave_mon_cb.awburst;
		xtn.awready=vif.slave_mon_cb.awready;		

		//@(vif.slave_mon_cb);
		q1.push_back(xtn);
		q2.push_back(xtn);

		  `uvm_info("SLAVE_MON","BEFORE WRITE address",UVM_NONE)	

		   $display("SLAVE PORT SIZE=%0d",slv_monport.size());
		slv_monport.write(xtn);
		  `uvm_info("SLAVE_MON","AFTER WRITE address",UVM_NONE)	
		slv_pkg_sent++;		
		
		@(vif.slave_mon_cb);
		`uvm_info("slave_monitor","aw has completed sampling",UVM_LOW)	
		`uvm_info("SLAVE_MONITOR",$sformatf("printing form slave monitor collect_awaddr \n %s",xtn.sprint()),UVM_LOW)			
		//$display("slave monitor collect the write address");
	endtask


	task wr_data_collect(master_xtn xtn);

		xtn1=master_xtn::type_id::create("xtn1");		
		xtn1=xtn;
		xtn1.wdata=new[xtn.awlen+1];
		xtn1.wstrb=new[xtn.wdata.size()];
		
		//xtn.wr_addr_calc();
		//xtn.strb_calc();

		foreach(xtn1.wdata[i])
		begin
			 //@(vif.slave_mon_cb);
			/*forever begin
   @(vif.slave_mon_cb);
   $display("TIME=%0t WVALID=%0b WREADY=%0b WDATA=%h WSTRB=%h",
             $time,
             vif.slave_mon_cb.wvalid,
             vif.slave_mon_cb.wready,
             vif.slave_mon_cb.wdata,
             vif.slave_mon_cb.wstrb);
end*/
			wait(vif.slave_mon_cb.wvalid && vif.slave_mon_cb.wready);
			xtn1.wid=vif.slave_mon_cb.wid;
			xtn1.wstrb[i]=vif.slave_mon_cb.wstrb;
			//$display("wstrb=%0d",vif.slave_mon_cb.wstrb);
			if(vif.slave_mon_cb.wstrb==15)
				xtn1.wdata[i]=vif.slave_mon_cb.wdata;
			if(vif.slave_mon_cb.wstrb==8)
				xtn1.wdata[i]=vif.slave_mon_cb.wdata[31:24];
			if(vif.slave_mon_cb.wstrb==4)
				xtn1.wdata[i]=vif.slave_mon_cb.wdata[23:16];
			if(vif.slave_mon_cb.wstrb==2)
				xtn1.wdata[i]=vif.slave_mon_cb.wdata[15:8];
			if(vif.slave_mon_cb.wstrb==1)
				xtn1.wdata[i]=vif.slave_mon_cb.wdata[7:0];
			if(vif.slave_mon_cb.wstrb==12)
				xtn1.wdata[i]=vif.slave_mon_cb.wdata[31:16];	
			if(vif.slave_mon_cb.wstrb==14)
				xtn1.wdata[i]=vif.slave_mon_cb.wdata[31:8];	
			if(vif.slave_mon_cb.wstrb==3)
				xtn1.wdata[i]=vif.slave_mon_cb.wdata[15:0];
			//if(vif.slave_mon_cb.wstrb==7)
				//xtn1.wdata[i]=vif.slave_mon_cb.wdata[23:0];	
			//$display("wstrb =%h,wdata=%h",vif.slave_mon_cb.wstrb,vif.slave_mon_cb.wdata);
			if(i==(xtn1.awlen))
				xtn1.wlast=vif.slave_mon_cb.wlast;
			/*else
				xtn1.wlast=vif.master_mon_cb.wlast=1'b0;*/
				
				xtn1.wvalid=vif.slave_mon_cb.wvalid;

				xtn1.wready=vif.slave_mon_cb.wready;				
		
			@(vif.slave_mon_cb);
		end
			//$display("slave monitor collect write data");
		 	 `uvm_info("SLAVE_MON","BEFORE WRITE data",UVM_NONE)		
			slv_monport.write(xtn1);
		 	 `uvm_info("SLAVE_MON","after WRITE data",UVM_NONE)
			slv_pkg_sent++;
				
			
			//`uvm_info("slave_monitor","w has completed sampling",UVM_LOW)
			`uvm_info("slave_MONITOR",$sformatf("printing from slave collect_wdata \n %s",xtn1.sprint()),UVM_LOW)
						
			//@(vif.slave_mon_cb);
			
	endtask

	task wr_resp_collect(master_xtn xtn2);
		//@(vif.slave_mon_cb);
		xtn2 = master_xtn::type_id::create("xtn2");
		$display("before wait in bresp");		
		wait(vif.slave_mon_cb.bready && vif.slave_mon_cb.bvalid);
		$display("after wait in bresp");
		//xtn.bid=vif.slave_mon_cb.bid;
		xtn2.bresp=vif.slave_mon_cb.bresp;
		//xtn2.bvalid=vif.slave_mon_cb.bvalid;
		//xtn2.bready=vif.slave_mon_cb.bready;

		//@(vif.slave_mon_cb);
                //$display("master monitor collects the write response");

		slv_monport.write(xtn2);
		`uvm_info("slave_monitor","bresp has completed sampling",UVM_LOW)
		slv_pkg_sent++;		
		`uvm_info("SLAVE_MONITOR",$sformatf("printing from collect b_resp \n %s",xtn2.sprint()),UVM_LOW)
		@(vif.slave_mon_cb);
		
	endtask

	task rd_addr_collect();
		//@(vif.master_mon_cb);
		master_xtn xtn3;
		xtn3 = master_xtn::type_id::create("xtn3");
		
		wait(vif.slave_mon_cb.arvalid && vif.slave_mon_cb.arready)

		xtn3.arid=vif.slave_mon_cb.arid;
		xtn3.araddr=vif.slave_mon_cb.araddr;
		xtn3.arlen=vif.slave_mon_cb.arlen;
		xtn3.arsize=vif.slave_mon_cb.arsize;
		xtn3.arburst=vif.slave_mon_cb.arburst;
		xtn3.arvalid=vif.slave_mon_cb.arvalid;	
		xtn3.arready=vif.slave_mon_cb.arready;					

		//@(vif.slave_mon_cb);
		q3.push_back(xtn3);
		//$display("slave monitor collects read address");
		  `uvm_info("SLAVE_MON","BEFORE READ ADDRESS",UVM_NONE)                              				
		slv_monport.write(xtn3);
		  `uvm_info("SLAVE_MON","AFTER READ ADDRESS",UVM_NONE)
		slv_pkg_sent++;
		                              				
		@(vif.slave_mon_cb);
	endtask

	task rd_data_collect(master_xtn xtn);
		//@(vif.slave_mon_cb);
		xtn4 = master_xtn::type_id::create("xtn4");
		xtn4=xtn;		
		xtn4.rdata=new[xtn4.arlen+1];

		foreach(xtn4.rdata[i])
		begin
			wait(vif.slave_mon_cb.rvalid && vif.slave_mon_cb.rready)
			xtn4.rid=vif.slave_mon_cb.rid;
			xtn4.rdata[i]=vif.slave_mon_cb.rdata;
			xtn4.rresp=vif.slave_mon_cb.rresp;
	
			if(i==(xtn4.arlen))
				xtn4.rlast=vif.slave_mon_cb.rlast;
			//else 
				//xtn.rlast=1'b0;
			xtn4.rvalid=vif.slave_mon_cb.rvalid;
			xtn4.rready=vif.slave_mon_cb.rready;
			@(vif.slave_mon_cb);
		end

			//$display("slave monitor collected read respose");
			slv_monport.write(xtn4);
			slv_pkg_sent++;
			
			//@(vif.slave_mon_cb);
			
	endtask


	task collect_data();
		
		fork
			begin//write address thread
				sem_awaddr.get(1);
				wr_addr_collect();
				sem_wrdata.put(1);
				sem_awaddr.put(1);
			end

			begin//write data thread
				sem_wrdata.get(1);
				sem_wdata.get(1);
				wr_data_collect(q1.pop_front());
				sem_wrresp.put(1);
				sem_wdata.put(1);
			end

			begin//write response thread
				sem_wrresp.get(1);
				sem_bresp.get(1);
				wr_resp_collect(q2.pop_front());
				sem_bresp.put(1);
			end

			begin//read address thread
				sem_araddr.get(1);
				rd_addr_collect();
				sem_rdresp.put(1);
				sem_araddr.put(1);
			end

			begin//read response thresd
				sem_rdresp.get(1);
				sem_rresp.get(1);
				rd_data_collect(q3.pop_front());
				sem_rresp.put(1);
			end

		join_any

	endtask
		
	function void report_phase(uvm_phase phase);
		//`uvm_info("MSTR_MONITOR",$formatf("total packets sent form master slave = %d",this.mstr_pkt_sent),UVM_LOW)
		$display("slave sent packets = %d",slv_pkg_sent);
	endfunction


endclass
