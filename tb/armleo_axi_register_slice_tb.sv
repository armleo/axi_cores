////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2016-2021, Arman Avetisyan
// 
////////////////////////////////////////////////////////////////////////////////


`define TIMEOUT 1000000
`define SYNC_RST
`define CLK_HALF_PERIOD 10
`define TOP_TB armleo_axi_register_slice_tb
`define TOP armleo_axi_register_slice

`include "armleo_template.svh"


// TODO: Test vector definitions and multi configuration vector makefile

// Note: Test should not rely on this, but on localparams instead
`ifndef TEST_VECTOR_PASSTHROUGH
	`define TEST_VECTOR_PASSTHROUGH 0
`endif


localparam PASSTHROUGH = `TEST_VECTOR_PASSTHROUGH;

localparam ADDR_WIDTH = 40;
localparam DATA_WIDTH = 24;
localparam DATA_STROBES = DATA_WIDTH/8;
localparam ID_WIDTH = 6;

`AXI_FULL_SIGNALS(upstream_axi_, ADDR_WIDTH, DATA_WIDTH, ID_WIDTH)
`AXI_FULL_SIGNALS(downstream_axi_, ADDR_WIDTH, DATA_WIDTH, ID_WIDTH)

`TOP #(
	.ADDR_WIDTH(ADDR_WIDTH),
	.DATA_WIDTH(DATA_WIDTH),
	.ID_WIDTH(ID_WIDTH),
	.PASSTHROUGH(PASSTHROUGH)
) slice (
	.*
);

`define ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(signal) assert(upstream_axi_``signal`` === downstream_axi_``signal``);
generate if(PASSTHROUGH) begin : PASSTHROUGH_ASSERTS
	always @(posedge clk) begin
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awvalid);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awready);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awaddr);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awlen);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awsize);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awprot);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awburst);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awid);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(awlock);

		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(wvalid);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(wready);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(wdata);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(wstrb);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(wlast);

		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(bvalid);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(bready);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(bresp);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(bid);


		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(arvalid);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(arready);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(araddr);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(arlen);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(arsize);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(arprot);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(arburst);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(arid);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(arlock);

		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(rvalid);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(rready);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(rresp);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(rid);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(rlast);
		`ASSERT_EQUAL_UPSTREAM_DOWNSTREAM(rdata);
	end
end endgenerate

`define ASSERT_EQUAL_FOR_NON_PASSTHROUGH(a, b) if(`TEST_VECTOR_PASSTHROUGH==0) begin `assert_equal(a, b) end


`define TEST(data_bits, source_signals, source_valid, source_ready, destination_signals, destination_valid, destination_ready) \
	temp = {$urandom(), $urandom(), $urandom(), $urandom()}; \
	source_signals = temp[data_bits-1:0]; \
	source_valid = 1; \
	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(source_ready, 1) \
	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(destination_valid, 0) \
	@(negedge clk) \
	source_valid = 0; \
	source_signals = 0; \
	destination_ready = 1; \
	#1; \
	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(destination_valid, 1) \
	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(destination_signals, temp[data_bits-1:0]) \
	@(negedge clk) \
	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(destination_valid, 0) \
	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(source_ready, 1)


initial begin
	integer i;
	reg [127:0] temp;
	@(posedge rst_n)
	upstream_axi_awvalid = 0;
	downstream_axi_awready = 0;
	upstream_axi_wvalid = 0;
	downstream_axi_wready = 0;
	upstream_axi_bready = 0;
	downstream_axi_bvalid = 0;
	upstream_axi_arvalid = 0;
	downstream_axi_arready = 0;
	upstream_axi_rready = 0;
	downstream_axi_rvalid = 0;
	

	@(negedge clk)
	`TEST(ADDR_WIDTH + 8 + 3 + 2 + 1 + ID_WIDTH + 3, {
		upstream_axi_awaddr,
		upstream_axi_awlen,
		upstream_axi_awsize,
		upstream_axi_awburst,
		upstream_axi_awlock,
		upstream_axi_awid,
		upstream_axi_awprot
	}, upstream_axi_awvalid, upstream_axi_awready, {
		downstream_axi_awaddr,
		downstream_axi_awlen,
		downstream_axi_awsize,
		downstream_axi_awburst,
		downstream_axi_awlock,
		downstream_axi_awid,
		downstream_axi_awprot
	}, downstream_axi_awvalid, downstream_axi_awready)


	`TEST(DATA_WIDTH + DATA_STROBES + 1, {
		upstream_axi_wdata,
		upstream_axi_wstrb,
		upstream_axi_wlast
	}, upstream_axi_wvalid, upstream_axi_wready, {
		downstream_axi_wdata,
		downstream_axi_wstrb,
		downstream_axi_wlast
	}, downstream_axi_wvalid, downstream_axi_wready)


	`TEST(ID_WIDTH + 2, {
		downstream_axi_bid,
		downstream_axi_bresp
	}, downstream_axi_bvalid, downstream_axi_bready, {
		upstream_axi_bid,
		upstream_axi_bresp
	}, upstream_axi_bvalid, upstream_axi_bready)


	


	`TEST(ADDR_WIDTH + 8 + 3 + 2 + 1 + ID_WIDTH + 3, {
		upstream_axi_araddr,
		upstream_axi_arlen,
		upstream_axi_arsize,
		upstream_axi_arburst,
		upstream_axi_arlock,
		upstream_axi_arid,
		upstream_axi_arprot
	}, upstream_axi_arvalid, upstream_axi_arready, {
		downstream_axi_araddr,
		downstream_axi_arlen,
		downstream_axi_arsize,
		downstream_axi_arburst,
		downstream_axi_arlock,
		downstream_axi_arid,
		downstream_axi_arprot
	}, downstream_axi_arvalid, downstream_axi_arready)
	

	`TEST(ID_WIDTH + 2 + DATA_WIDTH + 1, {
		downstream_axi_rid,
        downstream_axi_rresp,
        downstream_axi_rdata,
        downstream_axi_rlast
	}, downstream_axi_rvalid, downstream_axi_rready, {
		upstream_axi_rid,
        upstream_axi_rresp,
        upstream_axi_rdata,
        upstream_axi_rlast
	}, upstream_axi_rvalid, upstream_axi_rready)
	
	/*
	upstream_axi_awvalid = 1;
	upstream_axi_awaddr = 100;
	#1;

	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(upstream_axi_awready, 1)
	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(downstream_axi_awvalid, 0)

	@(negedge clk)
	upstream_axi_awvalid = 0;
	upstream_axi_awaddr = 101;

	#1

	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(downstream_axi_awvalid, 1)
	`ASSERT_EQUAL_FOR_NON_PASSTHROUGH(downstream_axi_awaddr, 100)
	*/

	$finish;
end


endmodule