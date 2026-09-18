
package axi_test_pkg;

//import uvm_pkg.sv
	import uvm_pkg::*;
//include uvm_macros.sv

	`include "uvm_macros.svh"

	`include "master_agt_config.sv"
	`include "slave_agt_config.sv"
	`include "axi_env_config.sv"

	`include "master_xtn.sv"
	`include "master_driver.sv"
	`include "master_monitor.sv"
	`include "master_sequencer.sv"
	`include "master_agent.sv"
	`include "master_agt_top.sv"
	`include "master_seqs.sv"

	//`include "spi_xtn.sv"
	`include "slave_driver.sv"
	`include "slave_monitor.sv"
	`include "slave_sequencer.sv"
	`include "slave_agent.sv"
	`include "slave_agt_top.sv"
	//`include "slave_seqs.sv"
	
	`include "axi_sb.sv"
	`include "axi_env.sv"
	`include "axi_test.sv"
	
endpackage
