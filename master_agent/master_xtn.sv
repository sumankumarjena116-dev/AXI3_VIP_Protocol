class master_xtn extends uvm_sequence_item;
	`uvm_object_utils(master_xtn)

	rand bit ARESET;	
	//wr address channel
	rand bit [3:0]awid;
	rand bit [31:0]awaddr;
	rand bit [3:0]awlen;
	rand bit [2:0]awsize;
	rand bit [1:0]awburst;
	bit awvalid;
	bit awready;
	
	//wr data channel
	rand bit [3:0]wid;
	rand bit [31:0]wdata[];
	bit [3:0]wstrb[];
	rand bit wlast;
	bit wvalid;
	bit wready;

	//wr response channel
	bit [3:0]bid;
	bit [1:0]bresp;
	bit bvalid;
	bit bready;

	//rd address channel
	rand bit [3:0]arid;
	rand bit [31:0]araddr;
	rand bit [3:0]arlen;
	rand bit [2:0]arsize;
	rand bit [1:0]arburst;
	bit arvalid;
	bit arready;

	//rd response channel
	bit [3:0]rid;
	bit [31:0]rdata[];

	bit [1:0]rresp;
	bit rlast;
	bit rvalid;
	bit rready;

	function new(string name="master_xtn");
		super.new(name);
	endfunction

	constraint wr_data {wdata.size()==(awlen+1);}
	//constraint rd_data {rdata.size()==(arlen+1);}

	//constraint wstrb_calc{wstrb.size()==(awlen+1);}

	constraint write_id{(awid==wid);(wid==bid);}//write addr id should be wqual with write data and write response id
	constraint read_id{(arid==rid);}//read addr id should be equal with rd response

	constraint burst1{awburst dist{0:=10,1:=10,2:=10};}//burst 0 means fixed,1 means increment,2 means wrap,3 means reserved
	constraint burst2{arburst dist{0:=10,1:=10,2:=10};}

	constraint aw_size_lim{awsize dist{0:=10,1:=10,2:=10};}//2^0=1,2^1=2,2^2=4 we can take upto 4 byte
	constraint ar_size_lim{arsize dist{0:=10,1:=10,2:=10};}

	constraint awaddr_c{awaddr<4096;}
	constraint araddr_c{araddr<4096;}

	//constraint for awsize and awlen
	constraint wrapping_len{if (awburst==2'b10) (awlen+1) inside {2,4,8,16};}
	constraint rrapping_len{if (arburst==2'b10) (arlen+1) inside {2,4,8,16};}

	//allignment for write channel
		constraint awaddr_a1 { if ((awburst == 2'b00 || awburst == 2'b10) && (awsize == 2'b01)) awaddr%2 == 0;}
		constraint awaddr_a2 { if ((awburst == 2'b00 || awburst == 2'b10) && (awsize == 2'b10))awaddr%4 == 0;}

	
	//allignment for read channel
		constraint araddr_a1 { if ((arburst == 2'b00 || arburst == 2'b10) && (arsize == 2'b01)) araddr%2 == 0;}
		constraint araddr_a2 { if ((arburst == 2'b00 || arburst == 2'b10) && (arsize == 2'b10)) araddr%4 == 0;}

	constraint max_boundary{(2**awsize)*(awlen+1) < 4096;}//4kb boundary
	constraint max_boundary_c{(2**arsize)*(arlen+1) < 4096;}

	//internal signals for burst description
	bit [31:0]waddr[];
	int no_of_wbytes;
	bit[31:0] aligned_waddr;
	bit[31:0] start_waddr;

	bit [31:0]raddr[];
	int no_of_rbytes;
	bit[31:0] aligned_raddr;
	bit[31:0] start_raddr;


//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\/\\//\\//\\//\\
//**************************write address calculation**************************************

	function void wr_addr_calc();

		bit wb;//to track the burst was wrapped or not
		bit[3:0] burst_length=awlen+1;
		int no_of_wbytes=2**awsize;
		bit N=burst_length;
		bit start_waddr=awaddr;

		bit[31:0] wrap_boundary=(int'(start_waddr/(no_of_wbytes*burst_length)))*(no_of_wbytes*burst_length);
		
		bit[31:0] addr_n=(wrap_boundary+(no_of_wbytes*burst_length));

		waddr=new[awlen+1];
		waddr[0]=awaddr;

		aligned_waddr=(int'(start_waddr/no_of_wbytes))*(no_of_wbytes);

		for(int i=2;i<(burst_length+1);i++)
		begin
			if(awburst==2'b00)
				waddr[i-1]=awaddr;
			else if(awburst==2'b01)
				waddr[i-1]=aligned_waddr+(i-1)*no_of_wbytes;
			else if(awburst==2'b10)
			begin
				if(wb==0)
					begin
						waddr[i-1]=aligned_waddr+(i-1)*no_of_wbytes;
					if(waddr[i-1]==(wrap_boundary+(no_of_wbytes*burst_length)))
						begin
							waddr[i-1]=wrap_boundary;
							wb++;
						end
					end
				else
						waddr[i-1]=start_waddr+((i-1)*no_of_wbytes)-(no_of_wbytes*burst_length);
			end
		end
	endfunction

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\/\\//\\//\\//\\
//***********************read address calculation******************************************

	function void rd_addr_calc();

                bit wb;//to track the burst was wrapped or not
               	int burst_length=arlen+1;
                int no_of_rbytes=2**arsize;
                bit N=burst_length;
                bit[31:0] start_raddr=araddr;

                bit[31:0] wrap_boundary=(int'(start_raddr/(no_of_rbytes*burst_length)))*(no_of_rbytes*burst_length);

                bit[31:0] addr_n=(wrap_boundary+(no_of_rbytes*burst_length));

                raddr=new[arlen+1];
                raddr[0]=araddr;

                aligned_raddr=(int'(start_raddr/no_of_rbytes))*(no_of_rbytes);

                for(int i=2;i<(burst_length+1);i++)
		begin
                        if(arburst==2'b00)
                                raddr[i-1]=araddr;
                        else if(arburst==2'b01)
                                raddr[i-1]=aligned_raddr+(i-1)*no_of_rbytes;
                        else if(arburst==2'b10)
                        begin
                                if(wb==0)
                                        begin
                                                raddr[i-1]=aligned_raddr+(i-1)*no_of_rbytes;
                                        if(raddr[i-1]==(wrap_boundary+(no_of_rbytes*burst_length)))
                                                begin
                                                        raddr[i-1]=wrap_boundary;
                                                        wb++;
                                                end
                                        end
                                else
                                                raddr[i-1]=start_raddr+((i-1)*no_of_rbytes)-(no_of_rbytes*burst_length);
                        end
		end
        endfunction
	

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\/\\//\\//\\//\\
//***********************strobe calculation******************************************

	function void strb_calc();
		int no_of_wbytes=2**awsize;
		int data_bus_bytes=4;
		
		int lower_byte_lane,upper_byte_lane;
		
		int  lower_byte_lane_0=start_waddr-(int'(start_raddr/data_bus_bytes))*data_bus_bytes;
		int upper_byte_lane_0=aligned_waddr+(no_of_wbytes-1)-(int'(start_waddr/data_bus_bytes))*data_bus_bytes;

		foreach(wstrb[i])
			wstrb[i]=0;
	
		for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
		begin
			wstrb[0][j]=1;
		end

		for(int i=1;i<(awlen+1);i++)
		begin
			lower_byte_lane=waddr[i]-(int'(waddr[i]/data_bus_bytes))*data_bus_bytes;
			upper_byte_lane=lower_byte_lane + (no_of_wbytes-1);
	
			for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
			begin
				wstrb[i][j]=1;
			end
		end

		$display("lbl=%0d",lower_byte_lane);
		$display("ubl=%0d",upper_byte_lane);

		$display("lbl0=%0d",lower_byte_lane_0);
		$display("ubl0=%0d",upper_byte_lane_0);
	endfunction

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\/\\//\\//\\//\\
//***********************post randomize method******************************************

	function void post_randomize();
		    $display("POST_RANDOMIZE START");
		wstrb=new[awlen+1];
		wr_addr_calc();
		
		strb_calc();

		rd_addr_calc();

		foreach(wstrb[i])
		$display("value of wstrb=%0d",wstrb[i]);

		$display("/////////write_addr////////\n wr_addr=%0p",waddr);
		$display("////////write_addr_awaddr/////\n AWADDR=%0p",awaddr);
		$display("///////read_addr///////// \n rd_addr=%0p",raddr);
		$display("//////read_addr_araddr///// \n ARADDR=%0p",araddr);
		
		this.print();
	endfunction

	function void do_print(uvm_printer printer);
		super.do_print(printer);
		//WR ADDR SIGNALS 
		printer.print_field("awid",this.awid,4,UVM_DEC);
		printer.print_field("awaddr",this.awaddr,32,UVM_DEC);
		printer.print_field("awlen",this.awlen,4,UVM_DEC);
		printer.print_field("awsize",this.awsize,3,UVM_DEC);
		printer.print_field("awburst",this.awburst,2,UVM_DEC);
		printer.print_field("awvalid",this.awvalid,1,UVM_DEC);
		printer.print_field("awready",this.awready,1,UVM_DEC);

		//WR DATA SIGNALS
		printer.print_field("wid",this.wid,4,UVM_DEC);

		foreach(wdata[i])
		begin
		printer.print_field($sformatf("wdata[%0d]",i),this.wdata[i],32,UVM_DEC);
		printer.print_field($sformatf("wstrb[%0d]",i),this.wstrb[i],4,UVM_BIN);
		end
		printer.print_field("wlast",this.wlast,1,UVM_BIN);
		printer.print_field("wvalid",this.wvalid,1,UVM_BIN);
		printer.print_field("wready",this.wready,1,UVM_BIN);
	
		//WR RESPONSE CHANNEL
		printer.print_field("bid",this.bid,4,UVM_DEC);
		printer.print_field("bresp",this.bresp,2,UVM_DEC);
		printer.print_field("bvalid",this.bvalid,1,UVM_DEC);
		printer.print_field("bready",this.bready,1,UVM_DEC);
	
		//RD address channel
		printer.print_field("arid",this.arid,4,UVM_DEC);
		printer.print_field("araddr",this.araddr,32,UVM_DEC);
		printer.print_field("arelen",this.arlen,4,UVM_DEC);
		printer.print_field("arsize",this.arsize,3,UVM_DEC);
		printer.print_field("arburst",this.arburst,2,UVM_DEC);
		printer.print_field("awvalid",this.awvalid,1,UVM_DEC);
		printer.print_field("awready",this.awready,1,UVM_DEC);

		//RD DATA CHANNEL
		printer.print_field("rid",this.rid,4,UVM_DEC);
		//printer.print_field("rdata",this.rdata,32,UVM_DEC);
		foreach(wdata[i])
	        begin
                	printer.print_field($sformatf("rdata[%0d]",i),this.rdata[i],32,UVM_DEC);
		end
		printer.print_field("rresp",this.rresp,2,UVM_DEC);
		printer.print_field("rlast",this.rlast,2,UVM_DEC);
		printer.print_field("bvalid",this.bvalid,1,UVM_DEC);
		printer.print_field("rready",this.rready,1,UVM_DEC);
	endfunction

	virtual function bit do_comparer(uvm_object rhs,uvm_comparer comparer);
		master_xtn rhs_;
		if(!$cast(rhs_,rhs))
			begin
				`uvm_error("do_compare","casting of rhs object failed")
			end
		return
			super.do_compare(rhs,comparer) &&
			this.awid==rhs_.awid &&
			this.awaddr==rhs_.awaddr &&
			this.awlen==rhs_.awlen &&
			this.awsize==rhs_.awsize &&
			this.awburst==rhs_.awburst &&
			this.awvalid==rhs_.awvalid &&
			this.awready==rhs_.awready &&

			this.wid==rhs_.wid &&
			this.wdata==rhs_.wdata &&
			this.wstrb==rhs_.wstrb &&
			this.wlast==rhs_.wlast &&
			this.wvalid==rhs_.wvalid &&
			this.wready==rhs_.wready &&

			this.bid==rhs_.bid &&
			this.bresp==rhs_.bresp &&
			this.bvalid==rhs_.bvalid &&
			this.bready==rhs_.bready &&

			this.arid==rhs_.arid &&
			this.araddr==rhs_.araddr &&
			this.arlen==rhs_.arlen &&
			this.arsize==rhs_.arlen &&
			this.arburst==rhs_.arburst &&
			this.arvalid==rhs_.arvalid &&
			this.arready==rhs_.arready &&

			this.rid==rhs_.rid &&
			this.rdata==rhs_.rdata &&
			this.rresp==rhs_.rresp &&
			this.rlast==rhs_.rlast &&
			this.rvalid==rhs_.rvalid &&
			this.rready==rhs_.rready;
	endfunction

endclass
