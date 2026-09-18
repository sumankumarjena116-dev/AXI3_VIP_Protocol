interface axi_if(input bit clock);
	
	//wr address channel
	logic [3:0]awid;
	logic [31:0]awaddr;
	logic [3:0]awlen;
	logic [2:0]awsize;
	logic [1:0]awburst;
	logic awvalid;
	logic awready;
	bit ACLK;
	bit ARESETn;
	assign ACLK=clock;

	//wr data channel
	logic [3:0]wid;
	logic [31:0]wdata;
	logic [3:0]wstrb;
	logic wlast;
	logic wvalid;
	logic wready;

	//wr response channel
	logic [3:0]bid;
	logic [1:0]bresp;
	logic bvalid;
	logic bready;

	//rd address channel
	logic [3:0]arid;
	logic [31:0]araddr;
	logic [3:0]arlen;
	logic [2:0]arsize;
	logic [1:0]arburst;
	logic arvalid;
	logic arready;

	//rd response channel
	logic [3:0]rid;
	logic [31:0]rdata;
	logic [1:0]rresp;
	logic rlast;
	logic rvalid;
	logic rready;



	clocking master_drv_cb @(posedge clock);
		default input #1 output #1;

		//wr addr channel
		output awid;//wr addr ch
		output awaddr;
		output awlen;
		output awsize;
		output awburst;
		output awvalid;
		input awready;//wr addr
		
		//wr data channel	
		output wid;
		output wdata;
		output wstrb;
		output wlast;
		output wvalid;
		input wready;
		
		//wr resp channel
		input bid;
		input bresp;
		input bvalid;
		output bready;
	
		//read addr channel
		output arid;
		output araddr;
		output arlen;
		output arsize;
		output arburst;
		output arvalid;
		input arready;	

		//read resp channel
		input rid;
		input rdata;
		input rresp;
		input rlast;
		input rvalid;
		output rready;
		
	endclocking

	clocking master_mon_cb @(posedge clock);
		default input #1 output #1;

		input awid;//wr addr ch
                input awaddr;
                input awlen;
                input awsize;
                input awburst;
                input awvalid;

                input arid;//rd addr ch
                input araddr;
                input arlen;
                input arsize;
                input arburst;
                input arvalid;


                input wid;//wr data ch
                input wdata;
                input wstrb;
                input wlast;
                input wvalid;
                input bready;//wr resp ch
                input rready;//rd resp ch

                input awready;//wr addr
                input wready;//wr data ch
                input bid;//wr resp ch
                input bresp;
                input bvalid;
                input arready;
                input rid;//rd resp ch
                input rdata;
                input rresp;
                input rlast;
                input rvalid;
	endclocking

	clocking slave_drv_cb @(posedge clock);
		default input #1 output #1;
		
		//wr addr channel
                input awid;
                input awaddr;
                input awlen;
                input awsize;
                input awburst;
                input awvalid;
                output awready;

		//wr data channel
		input wid;
                input wdata;
                input wstrb;
                input wlast;
                input wvalid;
                output wready;//wr data ch

		
		//write response channel
        	output bid;
		output bresp;
		output bvalid;
		input bready;       
	
		//rd addr channel
		input arid;
                input araddr;
                input arlen;
                input arsize;
                input arburst;
                input arvalid;
		output arready;

               		
		//rd data channel
                output rid;
		output rdata;
                output rresp;
		output rlast;
                output rvalid;
                input rready;
               
  	endclocking

	clocking slave_mon_cb @(posedge clock);
		default input #1 output #1;
		
		input awid;//wr addr ch
                input awaddr;
                input awlen;
                input awsize;
                input awburst;
                input awvalid;

                input arid;//rd addr ch
                input araddr;
                input arlen;
                input arsize;
                input arburst;
                input arvalid;


                input wid;//wr data ch
                input wdata;
                input wstrb;
                input wlast;
                input wvalid;
                input bready;//wr resp ch
                input rready;//rd resp ch

                input awready;//wr addr
                input wready;//wr data ch
                input bid;//wr resp ch
                input bresp;
                input bvalid;
                input arready;
                input rid;//rd resp ch
                input rdata;
                input rresp;
                input rlast;
                input rvalid;

	endclocking
		
	modport MASTER_DRV_MP(clocking master_drv_cb);
	modport MASTER_MON_MP(clocking master_mon_cb);

	modport SLAVE_DRV_MP(clocking slave_drv_cb);
	modport SLAVE_MON_MP(clocking slave_mon_cb);

	property p_awvalid;
		@(posedge clock) $rose(awvalid) |-> $stable(awburst) && $stable(awsize) && $stable(awaddr) until awready[->1];
	endproperty

	property p_wvalid;
		@(posedge clock) $rose(wvalid) |-> $stable(wid) && $stable(wdata) && $stable(wstrb) until wready[->1];
	endproperty

	property p_arvalid;
		@(posedge clock) $rose(arvalid) |-> $stable(arid) && $stable(arlen) && $stable(arburst) && $stable(arsize) && $stable(araddr) until arready[->1];
	endproperty

	property p_bvalid;
		@(posedge clock) $rose(bvalid) |-> $stable(bid) && $stable(bresp) until bready[->1];
	endproperty

	
 	property p_rvalid;
		@(posedge clock) $rose(rvalid) |-> $stable(rid) && $stable(rdata) && $stable(rlast) && $stable(rresp) until rready[->1];
	endproperty

	awvalid_ap: assert property(p_awvalid)
			$display("awvalid passed");
		else
			$display("awvalid failed");

	wvalid_ap: assert property(p_wvalid)
			$display("wvalid passed");
		else
			$display("wvalid failed");

	arvalid_ap: assert property(p_arvalid)
			$display("arvalid passed");
		else
			$display("arvalid failed");

	bvalid_ap: assert property(p_bvalid)
			$display("bvalid passed");
		else
			$display("bvalid failed");

	rvalid_ap: assert property(p_rvalid)
			$display("rvalid passed");
		else
			$display("rvalid failed");

	

	//handshake mechanism
	property awvalid_awready;
		@(posedge clock) awvalid && (!awready) |=> awvalid;
	endproperty

	property wvalid_wready;
		@(posedge clock) wvalid && (!wready) |=> wvalid;
	endproperty


	property arvalid_arready;
		@(posedge clock) arvalid && (!arready) |=> arvalid;
	endproperty

	property bvalid_bready;
		@(posedge clock) bvalid && (!bready) |=> bvalid;
	endproperty

	property rvalid_rready;
		@(posedge clock) rvalid && (!rready) |=> rvalid;
	endproperty

	awvalid_awready_ap:assert property(awvalid_awready)
			$display("awvalid awready passed");
		else
			$display("awvalid awready failed");

	
	wvalid_wready_ap:assert property(wvalid_wready)
			$display("awvalid awready passed");
		else
			$display("awvalid awready failed");

	arvalid_arready_ap:assert property(arvalid_arready)
			$display("arvalid arready passed");
		else
			$display("arvalid arready failed");

	bvalid_bready_ap:assert property(bvalid_bready)
			$display("bvalid bready passed");
		else
			$display("bvalid bready failed");

	rvalid_rready_ap:assert property(rvalid_rready)
			$display("rvalid rready passed");
		else
			$display("rvalid rready failed");


	
endinterface
























	
		
