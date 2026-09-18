class master_monitor extends uvm_monitor;
	`uvm_component_utils(master_monitor)
	
	master_agt_config master_agt_cfg;
	virtual axi_if.MASTER_MON_MP vif;
	uvm_analysis_port #(master_xtn)mstr_monport;
	master_xtn xtn,xtn1,xtn2,xtn3,xtn4;

	//declare queues
	master_xtn q1[$],q2[$],q3[$];

	int mstr_pkt_sent;
	
	//declare semaphore
	semaphore sem_awaddr=new(1);

	semaphore sem_wdata=new(1);

	semaphore sem_bresp=new(1);
	
	semaphore sem_araddr=new(1);

	semaphore sem_rresp=new(1);

	semaphore sem_wrdata=new();//wr data dependency

	semaphore sem_wrresp=new();//wr response dependency
	
	semaphore sem_rdresp=new();//rd response dependency
	
	function new(string name="master_monitor",uvm_component parent);
		super.new(name,parent);
		mstr_monport=new("master_monport",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(master_agt_config)::get(this,"","master_agt_config",master_agt_cfg))
			`uvm_fatal(get_type_name(),"can not get(),have you() set() it?")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif=master_agt_cfg.vif;
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
		//@(vif.master_mon_cb);
		
		wait(vif.master_mon_cb.awvalid && vif.master_mon_cb.awready)
		xtn.awvalid=vif.master_mon_cb.awvalid;
		xtn.awid=vif.master_mon_cb.awid;
		xtn.awaddr=vif.master_mon_cb.awaddr;
		xtn.awlen=vif.master_mon_cb.awlen;
		xtn.awsize=vif.master_mon_cb.awsize;
		xtn.awburst=vif.master_mon_cb.awburst;
		xtn.awready=vif.master_mon_cb.awready;		

		//@(vif.master_mon_cb);
		q1.push_back(xtn);
		q2.push_back(xtn);
		 `uvm_info("MASTER_MON","BEFORE WRITE address",UVM_NONE)


		   $display("MASTER PORT SIZE=%0d",mstr_monport.size());
		mstr_monport.write(xtn);
		 `uvm_info("MASTER_MON","after WRITE address",UVM_NONE)
		mstr_pkt_sent++;		
		@(vif.master_mon_cb);
		//`uvm_info("master_monitor","aw has completed sampling",UVM_LOW)	
		`uvm_info("MASTER_MONITOR",$sformatf("printing form master monitor collect_awaddr \n %s",xtn.sprint()),UVM_LOW)			
		//$display("master monitor collect the write address");
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
			 //@(vif.master_mon_cb);
			wait(vif.master_mon_cb.wvalid && vif.master_mon_cb.wready)
			xtn1.wid=vif.master_mon_cb.wid;
			xtn1.wstrb[i]=vif.master_mon_cb.wstrb;
			$display("wstrb=%0d",vif.master_mon_cb.wstrb);
			if(vif.master_mon_cb.wstrb==15)
				xtn1.wdata[i]=vif.master_mon_cb.wdata;
			if(vif.master_mon_cb.wstrb==8)
				xtn1.wdata[i]=vif.master_mon_cb.wdata[31:24];
			if(vif.master_mon_cb.wstrb==4)
				xtn1.wdata[i]=vif.master_mon_cb.wdata[23:16];
			if(vif.master_mon_cb.wstrb==2)
				xtn1.wdata[i]=vif.master_mon_cb.wdata[15:8];
			if(vif.master_mon_cb.wstrb==1)
				xtn1.wdata[i]=vif.master_mon_cb.wdata[7:0];
			if(vif.master_mon_cb.wstrb==12)
				xtn1.wdata[i]=vif.master_mon_cb.wdata[31:16];	
			if(vif.master_mon_cb.wstrb==14)
				xtn1.wdata[i]=vif.master_mon_cb.wdata[31:8];	
			if(vif.master_mon_cb.wstrb==3)
				xtn1.wdata[i]=vif.master_mon_cb.wdata[15:0];
			//if(vif.master_mon_cb.wstrb==7)
			//	xtn1.wdata[i]=vif.master_mon_cb.wdata[23:0];	
			//$display("wstrb =%h,wdata=%h",vif.master_mon_cb.wstrb,vif.master_mon_cb.wdata);
			//if(i==(xtn1.awlen))
				xtn1.wlast=vif.master_mon_cb.wlast;
			/*else
				xtn1.wlast=vif.master_mon_cb.wlast=1'b0;*/
				
				xtn1.wvalid=vif.master_mon_cb.wvalid;
				xtn1.wready=vif.master_mon_cb.wready;
					
		
			@(vif.master_mon_cb);
		end
			//$display("master monitor collect write data");
			 `uvm_info("MASTER_MON","BEFORE WRITE data",UVM_NONE)	
			mstr_monport.write(xtn1);
			 `uvm_info("MASTER_MON","after WRITE data",UVM_NONE)
			mstr_pkt_sent++;
			
			//`uvm_info("master_monitor","w has completed sampling",UVM_LOW)
			`uvm_info("MASTER_MONITOR",$sformatf("printing from master collect_wdata \n %s",xtn1.sprint()),UVM_LOW)
						
			//@(vif.master_mon_cb);
			
	endtask

	task wr_resp_collect(master_xtn xtn2);
		//@(vif.master_mon_cb);
		xtn2 = master_xtn::type_id::create("xtn2");
		$display("before wait in bresp");		
		wait(vif.master_mon_cb.bready && vif.master_mon_cb.bvalid)
		$display("after wait in bresp");
		//xtn.bid=vif.master_mon_cb.bid;
		xtn2.bresp=vif.master_mon_cb.bresp;
		xtn2.bvalid=vif.master_mon_cb.bvalid;
		xtn2.bready=vif.master_mon_cb.bready;		

		//@(vif.master_mon_cb);
                //$display("master monitor collects the write response");
	
		  `uvm_info("MASTER_MON","BEFORE WRITE response",UVM_NONE)                              
		mstr_monport.write(xtn2);
		`uvm_info("master_mon","after write response",UVM_LOW)
		mstr_pkt_sent++;		
		`uvm_info("MASTER_MONITOR",$sformatf("printing from collect b_resp \n %s",xtn2.sprint()),UVM_LOW)
		@(vif.master_mon_cb);
		
	endtask

	task rd_addr_collect();
		//@(vif.master_mon_cb);
		master_xtn xtn3;
		xtn3 = master_xtn::type_id::create("xtn3");
		
		wait(vif.master_mon_cb.arvalid && vif.master_mon_cb.arready)

		xtn3.arid=vif.master_mon_cb.arid;
		xtn3.araddr=vif.master_mon_cb.araddr;
		xtn3.arlen=vif.master_mon_cb.arlen;
		xtn3.arsize=vif.master_mon_cb.arsize;
		xtn3.arburst=vif.master_mon_cb.arburst;
		xtn3.arvalid=vif.master_mon_cb.arvalid;	
		xtn3.arready=vif.master_mon_cb.arready;	

		//@(vif.master_mon_cb);
		q3.push_back(xtn3);
		//$display("master monitor collects read address");
		  `uvm_info("MASTER_MON","BEFORE READ ADDRESS",UVM_NONE)                              		
		mstr_monport.write(xtn3);
		  `uvm_info("MASTER_MON","AFTER READ ADDRESS",UVM_NONE) 
		mstr_pkt_sent++;		                             		
		`uvm_info("MASTER_MONITOR",$sformatf("printing from collect rd_addr \n %s",xtn3.sprint()),UVM_LOW)		
		@(vif.master_mon_cb);
	endtask

	task rd_data_collect(master_xtn xtn);
		//@(vif.master_mon_cb);
		xtn4 = master_xtn::type_id::create("xtn4");		
		xtn4=xtn;
		xtn4.rdata=new[xtn4.arlen+1];

		foreach(xtn4.rdata[i])
		begin
			wait(vif.master_mon_cb.rvalid && vif.master_mon_cb.rready)
			xtn4.rid=vif.master_mon_cb.rid;
			xtn4.rvalid=vif.master_mon_cb.rvalid;
			xtn4.rready=vif.master_mon_cb.rready;
			xtn4.rdata[i]=vif.master_mon_cb.rdata;
			xtn4.rresp[i]=vif.master_mon_cb.rresp;
	
			if(i==(xtn4.arlen))
			begin
				xtn4.rlast=vif.master_mon_cb.rlast;
			end
			@(vif.master_mon_cb);
		end

			//$display("master monitor collected read respose");
		  	`uvm_info("MASTER_MON","BEFORE READ DATA",UVM_NONE)                              		
			mstr_monport.write(xtn4);
		 	 `uvm_info("MASTER_MON","AFTER READ DATA",UVM_NONE)
			mstr_pkt_sent++;
			                              		
			//@(vif.master_mon_cb);
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
		//`uvm_info("MSTR_MONITOR",$formatf("total packets sent form master monitor = %d",this.mstr_pkt_sent),UVM_LOW)
		$display("master sent packets = %d",mstr_pkt_sent);
	endfunction


		
endclass
