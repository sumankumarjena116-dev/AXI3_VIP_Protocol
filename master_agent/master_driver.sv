class master_driver extends uvm_driver #(master_xtn);
	`uvm_component_utils(master_driver)
	
	master_agt_config master_agt_cfg;
	virtual axi_if.MASTER_DRV_MP vif;


	//define 5 queues for 5 channels
	master_xtn q1[$],q2[$],q3[$],q4[$],q5[$];

	//declare semaphore as all the channels drives the signals and 
	//for proper synchonization use semaphore as it counts multiple permissions
	semaphore sem_awaddr=new(1);

	semaphore sem_wdata=new(1);
	
	semaphore sem_bresp=new(1);

	semaphore sem_araddr=new(1);

	semaphore sem_rdata=new(1);

	semaphore sem_wrdata=new();//write data dependency

	semaphore sem_wrresp=new();//write response dependency

	semaphore sem_rddata=new();//read response dependency

	function new(string name="master_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(master_agt_config)::get(this,"","master_agt_config",master_agt_cfg))
			`uvm_fatal(get_type_name(),"can not get() have you set() it?")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif=master_agt_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever
			begin
				seq_item_port.get_next_item(req);
				   // `uvm_info("DRV","GOT ITEM",UVM_LOW)
				send_to_dut(req);
			
				    //`uvm_info("DRV","BEFORE ITEM_DONE",UVM_LOW)
				seq_item_port.item_done();
				    //`uvm_info("DRV","AFTER ITEM_DONE",UVM_LOW)
				`uvm_info("MASTER_DRIVER",$sformatf("string \n %s",req.sprint()),UVM_LOW)
			end
	endtask 

//\\//\\//\\//\\/\\//\\write address channel//\\//\\//\\//\\//\\

	task wr_addr_drive(master_xtn xtn);
		   `uvm_info("WR_ADDR","ENTER WR_ADDR_DRIVE",UVM_LOW)
		@(vif.master_drv_cb);		
		
		vif.master_drv_cb.awvalid<=1'b1;
	
		vif.master_drv_cb.awid<=xtn.awid;
		vif.master_drv_cb.awaddr<=xtn.awaddr;
		vif.master_drv_cb.awlen<=xtn.awlen;
		vif.master_drv_cb.awsize<=xtn.awsize;
		vif.master_drv_cb.awburst<=xtn.awburst;
		
		 // `uvm_info("WR_ADDR","BEFORE CLOCK EVENT",UVM_LOW)
		//do begin
		@(vif.master_drv_cb);		
		  //`uvm_info("WR_ADDR","AFTER CLOCK EVENT",UVM_LOW)
		//end
		wait(vif.master_drv_cb.awready)
		//repeat(3)
		//@(vif.master_drv_cb);   // extra cycle
		  //`uvm_info("WR_ADDR","AFTER AWREADY WAIT",UVM_LOW)
		vif.master_drv_cb.awvalid<=1'b0;

		repeat($urandom_range(1,5))
		@(vif.master_drv_cb);
		//$display("master completed the write address channel");
	endtask

//\\//\\//\\//\\//\\write data channel//\\//\\//\\//\\//\\//\\//\\

	task wr_data_drive(master_xtn xtn);

		//xtn.wdata=new[xtn.awlen+1];
		//xtn.wstrb=new[xtn.awlen+1];
		foreach(xtn.wdata[i])
		//for(int i=0;i<(xtn.awlen+1);i++)
		begin
			//strb_calc();
			vif.master_drv_cb.wvalid<=1'b1;
			
			vif.master_drv_cb.wid<=xtn.wid;
			vif.master_drv_cb.wdata<=xtn.wdata[i];
			vif.master_drv_cb.wstrb<=xtn.wstrb[i];
			
			if(i==(xtn.awlen))
				vif.master_drv_cb.wlast<=1'b1;
			else
				vif.master_drv_cb.wlast<=1'b0;
			@(vif.master_drv_cb);		
			wait(vif.master_drv_cb.wready)
			vif.master_drv_cb.wvalid<=1'b0;
			vif.master_drv_cb.wlast<=1'b0;

		repeat($urandom_range(1,5))	
		@(vif.master_drv_cb);
		end
		//$display("master completed the write data channel");
		
	endtask

//\\//\\//\\//\\//\\write response channel//\\//\\//\\//\\//\\//\\

	task wr_resp_drive(master_xtn xtn);
		//enterin
	//	@(vif.master_drv_cb);
		vif.master_drv_cb.bready<=1'b1;
		
		//vif.master_drv_cb.bid<=xtn.bid;
		//vif.master_drv_cb.bresp<=xtn.bresp;
		//$display("before bvalid asserted");

		@(vif.master_drv_cb);					
		wait(vif.master_drv_cb.bvalid)
		vif.master_drv_cb.bready<=1'b0;

		repeat($urandom_range(1,5))
		@(vif.master_drv_cb);
	
		$display("master completed write response channel");
	endtask


//\\//\\//\\//\\//\\//read address channel//\\//\\//\\//\\//\\//\\//\\

	task rd_addr_drive(master_xtn xtn);
		repeat($urandom_range(1,5))
		@(vif.master_drv_cb);

		vif.master_drv_cb.arvalid<=1'b1;

		vif.master_drv_cb.arid<=xtn.arid;
		vif.master_drv_cb.araddr<=xtn.araddr;
		vif.master_drv_cb.arlen<=xtn.arlen;
		vif.master_drv_cb.arsize<=xtn.arsize;
		vif.master_drv_cb.arburst<=xtn.arburst;
		
		@(vif.master_drv_cb); 		
		wait(vif.master_drv_cb.arready)
		vif.master_drv_cb.arvalid<=1'b0;
		
		repeat($urandom_range(1,5))
		@(vif.master_drv_cb);
		//$display("master completed read address channel");
	endtask

//\\//\\//\\//\\//\\read data with response channel//\\//\\//\\//\\//\\

	task rd_data_resp_drive(master_xtn xtn);
		
		foreach(xtn.rdata[i])
		begin
			vif.master_drv_cb.rready<=1'b1;
			//vif.master_drv_cb.rid<=xtn.rid;
			//vif..master_drv_cb.rdata<=xtn.rdata[i];

			//if(i==(xtn.arlen))
				//vif.master_drv_cb.rlast<=1'b1;
			//else
				//vif.master_drv_cb.rlast<=1'b0;
				
			@(vif.master_drv_cb);			
			wait(vif.master_drv_cb.rvalid)
			vif.master_drv_cb.rready<=1'b0;
			//vif.master_drv_cb.rlast<=1'b0;

			repeat($urandom_range(1,5))
			@(vif.master_drv_cb);
		end
		//$display("master completed read response channel");
		
	endtask

//\\//\\//\\//\\//\\//\\send to dut task//\\//\\//\\//\\//\\//\\

	task send_to_dut(master_xtn xtn);	
		q1.push_back(xtn);
		q2.push_back(xtn);
		q3.push_back(xtn);
		q4.push_back(xtn);
		q5.push_back(xtn);

	fork	
		begin//write address thread
			sem_awaddr.get(1);
			//`uvm_info("DRV","AFTER SEM_AWADDR_GET",UVM_LOW)
			 //`uvm_info("DRV","ENTER SEND_TO_DUT",UVM_LOW)
			//$display("q1 size=%0d", q1.size());
			wr_addr_drive(q1.pop_front());
			 //`uvm_info("DRV","ENTER SEND_TO_DUT",UVM_LOW)
			
			sem_wrdata.put(1);
			sem_awaddr.put(1);
		end
		
		begin//write data thread
                        sem_wrdata.get(1);
			sem_wdata.get(1);
                        wr_data_drive(q2.pop_front());
                        sem_wrresp.put(1);
                        sem_wdata.put(1);
		end

		begin//write response thread
			sem_wrresp.get(1);
			sem_bresp.get(1);
			 //`uvm_info("DRV","ENTER SEND_TO_DUT",UVM_LOW)
			wr_resp_drive(q3.pop_front());
			 //`uvm_info("DRV","ENTER SEND_TO_DUT",UVM_LOW)
			sem_bresp.put(1);	
		end

		begin//read address thread
			sem_araddr.get(1);
			//sem_bresp.get(1);
			rd_addr_drive(q4.pop_front());
			sem_rddata.put(1);
			sem_araddr.put(1);
		end

		begin//rd data eith response thread
			sem_rddata.get(1);
			sem_rdata.get(1);
			rd_data_resp_drive(q5.pop_front());
			sem_rdata.put(1);
		end
		
	join_any
		//xtn.print();

	endtask
endclass
