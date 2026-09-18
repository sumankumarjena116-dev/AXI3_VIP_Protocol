class slave_driver extends uvm_driver #(master_xtn);
		
	`uvm_component_utils(slave_driver)
	
	virtual axi_if.SLAVE_DRV_MP vif;
	slave_agt_config slave_agt_cfg;
	//master_xtn xtn;

	//declare 5 no of queues
	master_xtn q1[$];
	master_xtn q2[$];
	master_xtn q3[$];
	//master_xtn q4[$];	
	//master_xtn q5[$];	


	//declare objects for semaphore
	semaphore sem_awaddr=new(1);
	semaphore sem_wdata=new(1);
	semaphore sem_bresp=new(1);

	semaphore sem_araddr=new(1);
	semaphore sem_rresp=new(1);

	semaphore sem_wrdata=new();//wr data dependency
	semaphore sem_wrresp=new();//wr response dependency
	semaphore sem_rddata=new();//rd response dependency

	function new(string name="slave_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(slave_agt_config)::get(this,"","slave_agt_config",slave_agt_cfg))
			`uvm_fatal(get_type_name(),"can not get() have you set() it?")
	endfunction

	function void connect_phase(uvm_phase phase);
		vif=slave_agt_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever
			begin
				//xtn=master_xtn::type_id::create("xtn");
				//seq_item_port.get_next_item(req);
				//$display("befotre the slave driving");
				send_to_dut();

				//seq_item_port.item_done();
				//`uvm_info("SLAVE_DRIVER",$sformatf("string \n %s",.sprint()),UVM_LOW)
			
			end
	endtask


//\\//\\//\\//\\//\\write addr channel//\\//\\//\\//\\//\\//\\

	task wr_addr_drive();

		master_xtn xtn1;
		xtn1 = master_xtn::type_id::create("xtn1");

		        //`uvm_info("SLAVE","ENTER WR_ADDR_DRIVE",UVM_LOW)
		vif.slave_drv_cb.awready<=1'b1;
		    //`uvm_info("SLAVE","AWREADY ASSERTED",UVM_LOW)
	
		//$display("drive write address");
		@(vif.slave_drv_cb);		
		wait(vif.slave_drv_cb.awvalid)
	
		/*while(!(vif.slave_drv_cb.awvalid &&
        vif.slave_drv_cb.awready))
begin
    @(vif.slave_drv_cb);
end*/

		//`uvm_info("slave_driver","AW Handshake Detected",UVM_LOW);
		/*forever begin
    			@(vif.slave_drv_cb);
   			 $display(" awvalid=%0d awready=%0d",
             		 vif.slave_drv_cb.awvalid,
              		vif.slave_drv_cb.awready);
			end*/		
		//$display("after wait in slave wr address");
		xtn1.awid=vif.slave_drv_cb.awid;
		xtn1.awaddr=vif.slave_drv_cb.awaddr;
		xtn1.awlen=vif.slave_drv_cb.awlen;
		xtn1.awsize=vif.slave_drv_cb.awsize;
		xtn1.awburst=vif.slave_drv_cb.awburst;
		xtn1.awvalid=vif.slave_drv_cb.awvalid;
	
		//wait(vif.slave_drv_cb.awvalid);
		@(vif.slave_drv_cb);			
		vif.slave_drv_cb.awready<=1'b0;


		repeat($urandom_range(1,5))
		@(vif.slave_drv_cb);
		//$display("slave driver completed write address channel");
		q1.push_back(xtn1);
		q2.push_back(xtn1);
		//$display("Before slave sprint");
		`uvm_info("SLAVE_DRIVER",$sformatf("string \n %s",xtn1.sprint()),UVM_LOW)
		
		
	endtask

//\\//\\//\\//\\//\\write data channel//\\//\\//\\//\\//\\//\\

	task wr_data_drive(master_xtn xtn);
		//master_xtn xtn;
		xtn=master_xtn::type_id::create("xtn");
		
		xtn.wdata=new[xtn.awlen+1];
		xtn.wstrb=new[xtn.awlen+1];

		//foreach(xtn.wdata[i])
		for(int i=0;i<=(xtn.awlen+1);i++)
		begin

                	vif.slave_drv_cb.wready<=1'b1;
			@(vif.slave_drv_cb);
			wait(vif.slave_drv_cb.wvalid);
            		 //`uvm_info("slave_driver","W Handshake Detected",UVM_LOW);

			//vif.slave_drv_cb.wready<=1'b1;

			xtn.wid=vif.slave_drv_cb.wid;
			xtn.wdata[i]=vif.slave_drv_cb.wdata;
			xtn.wstrb[i]=vif.slave_drv_cb.wstrb;
			xtn.wlast=vif.slave_drv_cb.wlast;
		end	
		//wait(vif.slave_drv_cb.wvalid);
		@(vif.slave_drv_cb);	
		vif.slave_drv_cb.wready<=1'b0;
		repeat($urandom_range(1,5))
		@(vif.slave_drv_cb);
		//$display("slave driver completed write response channel");
		`uvm_info("SLAVE_DRIVER",$sformatf("string \n %s",xtn.sprint()),UVM_LOW)
			
		
	endtask

//\\//\\//\\//\\//\\write response channel//\\//\\//\\//\\//\\//\\

	task wr_resp_drive(master_xtn xtn);
	//	master_xtn xtn;
		//xtn=master_xtn::type_id::create("xtn");
	
		vif.slave_drv_cb.bvalid<=1'b1;

		vif.slave_drv_cb.bid<=xtn.bid;
		vif.slave_drv_cb.bresp<=1'b1;

		@(vif.slave_drv_cb);		
		wait(vif.slave_drv_cb.bready);
		vif.slave_drv_cb.bvalid<=1'b0;
		vif.slave_drv_cb.bresp<=1'b0;	
		
		repeat($urandom_range(1,5))
		@(vif.slave_drv_cb);
		//$display("slave driver has completed write response channel");
		`uvm_info("SLAVE_DRIVER",$sformatf("string \n %s",xtn.sprint()),UVM_LOW)		
	endtask

//\\//\\//\\//\\//\\read address channel//\\//\\//\\//\\//\\//\\//\\
	
	task rd_addr_drive();
		master_xtn xtn2;
		xtn2 = master_xtn::type_id::create("xtn2");
		
		vif.slave_drv_cb.arready<=1'b1;

		@(vif.slave_drv_cb);
		wait(vif.slave_drv_cb.arvalid)
		`uvm_info("slave_driver","ar data handshake completed",UVM_LOW)
		xtn2.arid=vif.slave_drv_cb.arid;
		xtn2.araddr=vif.slave_drv_cb.araddr;
		xtn2.arlen=vif.slave_drv_cb.arlen;
		xtn2.arsize=vif.slave_drv_cb.arsize;
		xtn2.arburst=vif.slave_drv_cb.arburst;
		xtn2.arvalid=vif.slave_drv_cb.arvalid;

		@(vif.slave_drv_cb);
		vif.slave_drv_cb.arready<=1'b0;

		repeat($urandom_range(1,5))	
		@(vif.slave_drv_cb);
		`uvm_info("SLAVE_DRIVER",$sformatf("string \n %s",xtn2.sprint()),UVM_LOW)
               // $display("slave driver completed read address channel");

		q3.push_back(xtn2);

	endtask

//\\//\\//\\//\\//\\read data with response channel//\\//\\//\\//\\//\\

	task rd_data_resp_drive(master_xtn xtn);
	//xtn=master_xtn::type_id::create("xtn");
		
  	//if(xtn.rdata == null)
    	//`uvm_fatal("SLAVE_DRV","xtn handle is NULL")
		//xtn.rdata=new[xtn.arlen+1];

		//foreach(xtn.rdata[i])

		for(int i=0;i<xtn.arlen+1;i++)
		begin
			// @(vif.slave_drv_cb);
			vif.slave_drv_cb.rvalid<=1'b1;

			vif.slave_drv_cb.rid<=xtn.rid;
			vif.slave_drv_cb.rdata<=$urandom_range(1,2000);
			vif.slave_drv_cb.rresp<=1'b0;
		
			if(i==(xtn.arlen))
				vif.slave_drv_cb.rlast<=1'b1;
			else
				vif.slave_drv_cb.rlast<=1'b0;
		end
			@(vif.slave_drv_cb);
			wait(vif.slave_drv_cb.rready)
			vif.slave_drv_cb.rvalid<=1'b0;
			vif.slave_drv_cb.rlast<=1'b0;

			repeat($urandom_range(1,5))
			@(vif.slave_drv_cb);
			//$display("slave driver completed read response channel");
			`uvm_info("SLAVE_DRIVER",$sformatf("string \n %s",xtn.sprint()),UVM_LOW)
		//xtn.print();
	endtask

//\\//\\//\\//\\//\\////\\task send to dut//\\//\\//\\//\\//\\//\\\//\\

	task send_to_dut();
		/*q1.push_back(xtn);
		q2.push_back(xtn);
		q3.push_back(xtn);
		q4.push_back(xtn);
		q5.push_back(xtn);*/

		fork
			
			begin//wr addr thread
				//$display("Waiting for sem_awaddr");
				sem_awaddr.get(1);
			//	$display("before the drive channel1");
				wr_addr_drive();
			//	$display("after the drive channel1");								
				sem_wrdata.put(1);
				sem_awaddr.put(1);	
			end

			begin//wr data channel
				$display("before the drive ");
				
				sem_wrdata.get(1);
				sem_wdata.get(1);
				wr_data_drive(q1.pop_front());
				sem_wrresp.put(1);
				sem_wdata.put(1);
			end

			begin
				sem_wrresp.get(1);
				sem_bresp.get(1);
				wr_resp_drive(q2.pop_front());
				sem_bresp.put(1);
			end

			begin
				sem_araddr.get(1);
				rd_addr_drive();
				sem_rddata.put(1);
				sem_araddr.put(1);
			end

			begin
				sem_rddata.get(1);
				sem_rresp.get(1);
				rd_data_resp_drive(q3.pop_front());
				sem_rresp.put(1);
			end

		join_any
		
		//xtn.print();

	endtask
		
endclass
