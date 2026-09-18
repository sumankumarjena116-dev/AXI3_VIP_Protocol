class axi_sb extends uvm_scoreboard;
	`uvm_component_utils(axi_sb)

	uvm_tlm_analysis_fifo #(master_xtn)fifo_mstrh[];
	uvm_tlm_analysis_fifo #(master_xtn)fifo_slvh[];

	axi_env_config axi_env_cfg;
	master_xtn wr_xtn;
	master_xtn rd_xtn;
	
	master_xtn mst_xtn,slv_xtn;

	static int pkt_rcvd,pkt_compared;


	covergroup write_cg;
		option.per_instance=1;
		
		awaddr_cp:	coverpoint wr_xtn.awaddr{bins awaddr_bin1={['h0000:'h00ff]};
							bins awaddr_bin2={['h0100:'h0fff]};
							}
		awburst_cp:	coverpoint wr_xtn.awburst{bins awburst_bin0={0};
							bins awburst_bin1={1};
							bins awburst_bin2={2};
						/*	bins awsize_bin3={3};
							bins awsize_bin4={4};
							bins awsize_bin5={5};
							bins awsize_bin6={6};
							bins awsize_bin7={7};*/}
		awlen_cp :	coverpoint wr_xtn.awlen{bins awlen_bin1={0};
							bins awlen_bin2={[1:5]};
							bins awlen_bin3={[6:10]};
							bins awlen_bin4={[11:15]};
						}							
		awsize_cp:	coverpoint wr_xtn.awsize{bins awsize_bin1={0};
							bins awsize_bin2={1};
							bins awsize_bin3={2};
							/*bins awsize_bin4={3};*/}
		bresp_cp:	coverpoint wr_xtn.bresp{bins bresp_bin={0};}
	
		WR_ADDR_CROSS:	cross awburst_cp,awsize_cp,awlen_cp;
	endgroup

	covergroup write_cg1 with function sample(int i);
		option.per_instance=1;
		
		wdata_cp:coverpoint wr_xtn.wdata[i]{bins wdata_bin={[0:'hffff_ffff]};}
		wstrb_cp:coverpoint wr_xtn.wstrb[i]{bins wstrb_bin0={4'b1111};
						bins wstrb_bin1={4'b1100};
						bins wstrb_bin2={4'b0011};	
						bins wstrb_bin3={4'b1000};
						bins wstrb_bin4={4'b0100};
						bins wstrb_bin5={4'b0010};
						bins wstrb_bin6={4'b0001};}
						//bins wstrb_bin7={4'b1110};}	
	endgroup

	covergroup read_cg;
		option.per_instance=1;
		
		araddr_cp:coverpoint rd_xtn.araddr{bins araddr_bin0={['h0000:'h00ff]};
						bins araddr_bin1={['h0100:'h0fff]};}
		arburst_cp:coverpoint rd_xtn.arburst{bins arburst_bin={0};
							bins arburst_bin2={1};
							bins arburst_bin3={2};	
							/*bins arburst_bin4={3};*/}
		arlen_cp:coverpoint rd_xtn.arlen{bins arlen_bin={0};
							bins arlen_bin2={[1:5]};
							bins arlen_bin3={[6:10]};
							bins arlen_bin4={[11:15]};
							}
					
		arsize_cp:coverpoint rd_xtn.arsize{bins arsize_bin={0};
							bins arsize_bin1={1};
							bins arsize_bin2={2};
							/*bins arsize_bin3={3};
							bins arsize_bin4={4};
							bins arsize_bin5={5};
							bins arsize_bin6={6};
							bins arsize_bin7={7};*/}
	
		READ_ADDR_CROSS:cross arburst_cp,arlen_cp,arsize_cp;
	endgroup


	covergroup read_cg1 with function sample(int i);
		option.per_instance=1;
		
		rdata_cp:coverpoint rd_xtn.rdata[i]{bins rdata_bin={['h0000_0000:'hffff_ffff]};}
		rresp_cp:coverpoint rd_xtn.rresp[i]{bins rresp_bin={0};}
	endgroup

	function new(string name="axi_sb",uvm_component parent);
		super.new(name,parent);
		wr_xtn=new();
		rd_xtn=new();

		 mst_xtn = master_xtn::type_id::create("mst_xtn");
   		 slv_xtn = master_xtn::type_id::create("slv_xtn");
		write_cg=new();
		write_cg1=new();
		read_cg=new();
		read_cg1=new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",axi_env_cfg))	
			`uvm_fatal(get_type_name(),"can not get(),have you set() it?")	
		 //`uvm_info("SB","BUILD PHASE",UVM_NONE)	
		fifo_mstrh=new[axi_env_cfg.no_of_master_agent];
		foreach(fifo_mstrh[i])
		begin
			fifo_mstrh[i]=new($sformatf("fifo_mstrh[%0d]",i),this);
		end

		fifo_slvh=new[axi_env_cfg.no_of_slave_agent];
		foreach(fifo_slvh[i])
		begin
			fifo_slvh[i]=new($sformatf("fifo_slvh[%0d]",i),this);
		end
	endfunction


	task run_phase(uvm_phase phase);
	
		forever
			begin
				  `uvm_info("SB","RUN PHASE ENTERED",UVM_NONE)
					
				fifo_mstrh[0].get(mst_xtn);
				`uvm_info("SB","MASTER PACKET RECEIVED by fifo",UVM_LOW)
				fifo_slvh[0].get(slv_xtn);
				`uvm_info("SB","SLAVE PACKET RECEIVED",UVM_LOW)
				pkt_rcvd++;
				
				//mst_xtn.print();
				//slv_xtn.print();
				/*forever begin
  #100;
  $display("MASTER FIFO USED=%0d", fifo_mstrh[0].used());
  $display("SLAVE FIFO USED=%0d", fifo_slvh[0].used());
end*/
				if(mst_xtn.compare(slv_xtn))
				begin
					wr_xtn=mst_xtn;
					rd_xtn=slv_xtn;
					pkt_compared++;
						
					write_cg.sample();
					read_cg.sample();
					if(mst_xtn.wvalid)
					begin
						foreach(mst_xtn.wdata[i])
						begin
							write_cg1.sample(i);
						/* $display("================scoreboard report=====================");
		                                $display("functional coverage= %0.2f",write_cg.get_coverage());
						 $display("functional coverage= %0.2f",write_cg1.get_coverage());
                	      		          `uvm_info(get_type_name(),$sformatf("scoreboard apb_xtn =\n %s",mst_xtn.sprint()),UVM_LOW)
						$display("================================================================");*/

						end
					end
						
					if(slv_xtn.rvalid)
					$display("RVALID=%0b", slv_xtn.rvalid);
					begin
						foreach(slv_xtn.rdata[i])
						begin
							read_cg1.sample(i);
						end	
					
					`uvm_info("scoreboard","comparison successful",UVM_LOW)
					end

					//$display("=====================scoreboard report==============================");
					 //$display("functional coverage= %0.2f",write_cg.get_coverage());
					 //$display("functional coverage= %0.2f",read_cg.get_coverage());
					//`uvm_info(get_full_name(),$sformatf("master_xtn \n %s",mst_xtn.sprint()),UVM_LOW)
					//`uvm_info(get_full_name(),$sformatf("slave_xtn \n %s",slv_xtn.sprint()),UVM_LOW)
					//$display("====================================================================");
					end
				else
				`uvm_error("scoreboard","master and slave packet mismatch")
			end
	endtask		
		function void report_phase(uvm_phase phase);
			`uvm_info("scoreboard",$sformatf("no. of packet received=%0d",pkt_rcvd),UVM_LOW)
			`uvm_info("scoreboard",$sformatf("no of packet compared=%0d",pkt_compared),UVM_LOW)

			
					$display("=====================scoreboard report==============================");
					 $display("functional coverage= %0.2f",write_cg.get_coverage());
					 $display("functional coverage= %0.2f",read_cg.get_coverage());
					`uvm_info(get_full_name(),$sformatf("master_xtn \n %s",mst_xtn.sprint()),UVM_LOW)
					`uvm_info(get_full_name(),$sformatf("slave_xtn \n %s",slv_xtn.sprint()),UVM_LOW)
					$display("====================================================================");

		endfunction

endclass















