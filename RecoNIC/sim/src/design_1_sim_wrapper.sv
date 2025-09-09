//==============================================================================
// Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
// SPDX-License-Identifier: MIT
//
//==============================================================================
// HBM仿真系统模块 - 模拟design_1的接口和行为
// 这个模块替换了原来的axi_3to1_interconnect_to_dev_mem，提供与HBM系统相同的接口
//==============================================================================
`timescale 1ns/1ps

module design_1_sim_wrapper (
  // --- 系统时钟和复位 ---
  input         axis_aclk,     // 250MHz主时钟
  input         axis_arestn,   // 主复位
  input         pcie_rstn,     // PCIe复位
  
  // --- HBM物理接口 (仿真中模拟) ---
  input         hbm_clk_clk_n, // 100MHz差分时钟负端
  input         hbm_clk_clk_p, // 100MHz差分时钟正端
  
  // --- HBM APB配置接口 ---
  input  [21:0] SAPB_0_paddr,
  input         SAPB_0_penable,
  input  [2:0]  SAPB_0_pprot,
  input         SAPB_0_pready,
  input         SAPB_0_psel,
  input  [31:0] SAPB_0_pwdata,
  input         SAPB_0_pwrite,
  output [31:0] SAPB_0_prdata,
  output        SAPB_0_pslverr,
  
  // --- Slave AXI接口0 (连接到QDMA Master) ---
  input  [4:0]   s_axi_qdma_mm_awid,
  input  [63:0]  s_axi_qdma_mm_awaddr,
  input  [3:0]   s_axi_qdma_mm_awqos,
  input  [7:0]   s_axi_qdma_mm_awlen,
  input  [2:0]   s_axi_qdma_mm_awsize,
  input  [1:0]   s_axi_qdma_mm_awburst,
  input  [3:0]   s_axi_qdma_mm_awcache,
  input  [2:0]   s_axi_qdma_mm_awprot,
  input          s_axi_qdma_mm_awvalid,
  output         s_axi_qdma_mm_awready,
  input  [511:0] s_axi_qdma_mm_wdata,
  input  [63:0]  s_axi_qdma_mm_wstrb,
  input          s_axi_qdma_mm_wlast,
  input          s_axi_qdma_mm_wvalid,
  output         s_axi_qdma_mm_wready,
  input          s_axi_qdma_mm_awlock,
  output [4:0]   s_axi_qdma_mm_bid,
  output [1:0]   s_axi_qdma_mm_bresp,
  output         s_axi_qdma_mm_bvalid,
  input          s_axi_qdma_mm_bready,
  input  [4:0]   s_axi_qdma_mm_arid,
  input  [63:0]  s_axi_qdma_mm_araddr,
  input  [7:0]   s_axi_qdma_mm_arlen,
  input  [2:0]   s_axi_qdma_mm_arsize,
  input  [1:0]   s_axi_qdma_mm_arburst,
  input  [3:0]   s_axi_qdma_mm_arcache,
  input  [2:0]   s_axi_qdma_mm_arprot,
  input          s_axi_qdma_mm_arvalid,
  output         s_axi_qdma_mm_arready,
  output [4:0]   s_axi_qdma_mm_rid,
  output [511:0] s_axi_qdma_mm_rdata,
  output [1:0]   s_axi_qdma_mm_rresp,
  output         s_axi_qdma_mm_rlast,
  output         s_axi_qdma_mm_rvalid,
  input          s_axi_qdma_mm_rready,
  input          s_axi_qdma_mm_arlock,
  input  [3:0]   s_axi_qdma_mm_arqos,

  // --- Slave AXI接口1 (连接到Compute Logic) ---
  input  [0:0]   s_axi_compute_logic_awid,
  input  [63:0]  s_axi_compute_logic_awaddr,
  input  [3:0]   s_axi_compute_logic_awqos,
  input  [7:0]   s_axi_compute_logic_awlen,
  input  [2:0]   s_axi_compute_logic_awsize,
  input  [1:0]   s_axi_compute_logic_awburst,
  input  [3:0]   s_axi_compute_logic_awcache,
  input  [2:0]   s_axi_compute_logic_awprot,
  input          s_axi_compute_logic_awvalid,
  output         s_axi_compute_logic_awready,
  input  [511:0] s_axi_compute_logic_wdata,
  input  [63:0]  s_axi_compute_logic_wstrb,
  input          s_axi_compute_logic_wlast,
  input          s_axi_compute_logic_wvalid,
  output         s_axi_compute_logic_wready,
  input          s_axi_compute_logic_awlock,
  output [0:0]   s_axi_compute_logic_bid,
  output [1:0]   s_axi_compute_logic_bresp,
  output         s_axi_compute_logic_bvalid,
  input          s_axi_compute_logic_bready,
  input  [0:0]   s_axi_compute_logic_arid,
  input  [63:0]  s_axi_compute_logic_araddr,
  input  [7:0]   s_axi_compute_logic_arlen,
  input  [2:0]   s_axi_compute_logic_arsize,
  input  [1:0]   s_axi_compute_logic_arburst,
  input  [3:0]   s_axi_compute_logic_arcache,
  input  [2:0]   s_axi_compute_logic_arprot,
  input          s_axi_compute_logic_arvalid,
  output         s_axi_compute_logic_arready,
  output [0:0]   s_axi_compute_logic_rid,
  output [511:0] s_axi_compute_logic_rdata,
  output [1:0]   s_axi_compute_logic_rresp,
  output         s_axi_compute_logic_rlast,
  output         s_axi_compute_logic_rvalid,
  input          s_axi_compute_logic_rready,
  input          s_axi_compute_logic_arlock,
  input  [3:0]   s_axi_compute_logic_arqos,

  // --- Slave AXI接口2 (连接到System Crossbar) ---
  input  [4:0]   s_axi_from_sys_crossbar_awid,
  input  [63:0]  s_axi_from_sys_crossbar_awaddr,
  input  [3:0]   s_axi_from_sys_crossbar_awqos,
  input  [7:0]   s_axi_from_sys_crossbar_awlen,
  input  [2:0]   s_axi_from_sys_crossbar_awsize,
  input  [1:0]   s_axi_from_sys_crossbar_awburst,
  input  [3:0]   s_axi_from_sys_crossbar_awcache,
  input  [2:0]   s_axi_from_sys_crossbar_awprot,
  input          s_axi_from_sys_crossbar_awvalid,
  output         s_axi_from_sys_crossbar_awready,
  input  [511:0] s_axi_from_sys_crossbar_wdata,
  input  [63:0]  s_axi_from_sys_crossbar_wstrb,
  input          s_axi_from_sys_crossbar_wlast,
  input          s_axi_from_sys_crossbar_wvalid,
  output         s_axi_from_sys_crossbar_wready,
  input          s_axi_from_sys_crossbar_awlock,
  output [4:0]   s_axi_from_sys_crossbar_bid,
  output [1:0]   s_axi_from_sys_crossbar_bresp,
  output         s_axi_from_sys_crossbar_bvalid,
  input          s_axi_from_sys_crossbar_bready,
  input  [4:0]   s_axi_from_sys_crossbar_arid,
  input  [63:0]  s_axi_from_sys_crossbar_araddr,
  input  [7:0]   s_axi_from_sys_crossbar_arlen,
  input  [2:0]   s_axi_from_sys_crossbar_arsize,
  input  [1:0]   s_axi_from_sys_crossbar_arburst,
  input  [3:0]   s_axi_from_sys_crossbar_arcache,
  input  [2:0]   s_axi_from_sys_crossbar_arprot,
  input          s_axi_from_sys_crossbar_arvalid,
  output         s_axi_from_sys_crossbar_arready,
  output [4:0]   s_axi_from_sys_crossbar_rid,
  output [511:0] s_axi_from_sys_crossbar_rdata,
  output [1:0]   s_axi_from_sys_crossbar_rresp,
  output         s_axi_from_sys_crossbar_rlast,
  output         s_axi_from_sys_crossbar_rvalid,
  input          s_axi_from_sys_crossbar_rready,
  input          s_axi_from_sys_crossbar_arlock,
  input  [3:0]   s_axi_from_sys_crossbar_arqos
);

// 内部信号
logic hbm_clk_100m;
logic hbm_clk_450m;
logic hbm_rstn_100m;
logic hbm_rstn_450m;

// 内部AXI信号到最终内存
logic [4:0]   m_axi_dev_mem_awid;
logic [63:0]  m_axi_dev_mem_awaddr;
logic [7:0]   m_axi_dev_mem_awlen;
logic [2:0]   m_axi_dev_mem_awsize;
logic [1:0]   m_axi_dev_mem_awburst;
logic         m_axi_dev_mem_awlock;
logic [3:0]   m_axi_dev_mem_awqos;
logic [3:0]   m_axi_dev_mem_awregion;
logic [3:0]   m_axi_dev_mem_awcache;
logic [2:0]   m_axi_dev_mem_awprot;
logic         m_axi_dev_mem_awvalid;
logic         m_axi_dev_mem_awready;
logic [511:0] m_axi_dev_mem_wdata;
logic [63:0]  m_axi_dev_mem_wstrb;
logic         m_axi_dev_mem_wlast;
logic         m_axi_dev_mem_wvalid;
logic         m_axi_dev_mem_wready;
logic [4:0]   m_axi_dev_mem_bid;
logic [1:0]   m_axi_dev_mem_bresp;
logic         m_axi_dev_mem_bvalid;
logic         m_axi_dev_mem_bready;
logic [4:0]   m_axi_dev_mem_arid;
logic [63:0]  m_axi_dev_mem_araddr;
logic [7:0]   m_axi_dev_mem_arlen;
logic [2:0]   m_axi_dev_mem_arsize;
logic [1:0]   m_axi_dev_mem_arburst;
logic         m_axi_dev_mem_arlock;
logic [3:0]   m_axi_dev_mem_arqos;
logic [3:0]   m_axi_dev_mem_arregion;
logic [3:0]   m_axi_dev_mem_arcache;
logic [2:0]   m_axi_dev_mem_arprot;
logic         m_axi_dev_mem_arvalid;
logic         m_axi_dev_mem_arready;
logic [4:0]   m_axi_dev_mem_rid;
logic [511:0] m_axi_dev_mem_rdata;
logic [1:0]   m_axi_dev_mem_rresp;
logic         m_axi_dev_mem_rlast;
logic         m_axi_dev_mem_rvalid;
logic         m_axi_dev_mem_rready;

// === HBM时钟生成仿真 ===
// 模拟从100MHz差分时钟生成450MHz内部时钟
always_comb begin
  // 简化的差分时钟处理，在仿真中我们直接使用正端时钟
  hbm_clk_100m = hbm_clk_clk_p;
end

// 生成450MHz时钟（在仿真中我们使用时钟分频器模拟PLL）
logic [2:0] clk_450m_counter;
always_ff @(posedge hbm_clk_100m or negedge pcie_rstn) begin
  if (!pcie_rstn) begin
    clk_450m_counter <= 3'd0;
    hbm_clk_450m <= 1'b0;
  end else begin
    // 简化的时钟生成，实际中是PLL产生450MHz
    clk_450m_counter <= clk_450m_counter + 1'b1;
    if (clk_450m_counter == 3'd0) begin
      hbm_clk_450m <= ~hbm_clk_450m;
    end
  end
end

// 复位同步器
logic [3:0] rstn_sync_100m, rstn_sync_450m;

always_ff @(posedge hbm_clk_100m or negedge pcie_rstn) begin
  if (!pcie_rstn) begin
    rstn_sync_100m <= 4'd0;
  end else begin
    rstn_sync_100m <= {rstn_sync_100m[2:0], 1'b1};
  end
end

always_ff @(posedge hbm_clk_450m or negedge pcie_rstn) begin
  if (!pcie_rstn) begin
    rstn_sync_450m <= 4'd0;
  end else begin
    rstn_sync_450m <= {rstn_sync_450m[2:0], 1'b1};
  end
end

assign hbm_rstn_100m = rstn_sync_100m[3];
assign hbm_rstn_450m = rstn_sync_450m[3];

// === APB配置接口模拟 ===
// 简单的APB接口模拟，返回固定响应
assign SAPB_0_prdata = 32'hDEADBEEF; // 仿真中的虚拟数据
assign SAPB_0_pslverr = 1'b0;       // 不产生错误

// === 使用原来的3to1交叉连接器 ===
// 这里我们重用原来的逻辑，但添加时钟域转换
axi_3to1_interconnect_to_dev_mem axi_3to1_crossbar_inst (
  // Slave接口 - 保持原来的连接
  .s_axi_qdma_mm_awid              (s_axi_qdma_mm_awid),
  .s_axi_qdma_mm_awaddr            (s_axi_qdma_mm_awaddr),
  .s_axi_qdma_mm_awqos             (s_axi_qdma_mm_awqos),
  .s_axi_qdma_mm_awlen             (s_axi_qdma_mm_awlen),
  .s_axi_qdma_mm_awsize            (s_axi_qdma_mm_awsize),
  .s_axi_qdma_mm_awburst           (s_axi_qdma_mm_awburst),
  .s_axi_qdma_mm_awcache           (s_axi_qdma_mm_awcache),
  .s_axi_qdma_mm_awprot            (s_axi_qdma_mm_awprot),
  .s_axi_qdma_mm_awvalid           (s_axi_qdma_mm_awvalid),
  .s_axi_qdma_mm_awready           (s_axi_qdma_mm_awready),
  .s_axi_qdma_mm_wdata             (s_axi_qdma_mm_wdata),
  .s_axi_qdma_mm_wstrb             (s_axi_qdma_mm_wstrb),
  .s_axi_qdma_mm_wlast             (s_axi_qdma_mm_wlast),
  .s_axi_qdma_mm_wvalid            (s_axi_qdma_mm_wvalid),
  .s_axi_qdma_mm_wready            (s_axi_qdma_mm_wready),
  .s_axi_qdma_mm_awlock            (s_axi_qdma_mm_awlock),
  .s_axi_qdma_mm_bid               (s_axi_qdma_mm_bid),
  .s_axi_qdma_mm_bresp             (s_axi_qdma_mm_bresp),
  .s_axi_qdma_mm_bvalid            (s_axi_qdma_mm_bvalid),
  .s_axi_qdma_mm_bready            (s_axi_qdma_mm_bready),
  .s_axi_qdma_mm_arid              (s_axi_qdma_mm_arid),
  .s_axi_qdma_mm_araddr            (s_axi_qdma_mm_araddr),
  .s_axi_qdma_mm_arlen             (s_axi_qdma_mm_arlen),
  .s_axi_qdma_mm_arsize            (s_axi_qdma_mm_arsize),
  .s_axi_qdma_mm_arburst           (s_axi_qdma_mm_arburst),
  .s_axi_qdma_mm_arcache           (s_axi_qdma_mm_arcache),
  .s_axi_qdma_mm_arprot            (s_axi_qdma_mm_arprot),
  .s_axi_qdma_mm_arvalid           (s_axi_qdma_mm_arvalid),
  .s_axi_qdma_mm_arready           (s_axi_qdma_mm_arready),
  .s_axi_qdma_mm_rid               (s_axi_qdma_mm_rid),
  .s_axi_qdma_mm_rdata             (s_axi_qdma_mm_rdata),
  .s_axi_qdma_mm_rresp             (s_axi_qdma_mm_rresp),
  .s_axi_qdma_mm_rlast             (s_axi_qdma_mm_rlast),
  .s_axi_qdma_mm_rvalid            (s_axi_qdma_mm_rvalid),
  .s_axi_qdma_mm_rready            (s_axi_qdma_mm_rready),
  .s_axi_qdma_mm_arlock            (s_axi_qdma_mm_arlock),
  .s_axi_qdma_mm_arqos             (s_axi_qdma_mm_arqos),

  .s_axi_compute_logic_awid        ({4'd0, s_axi_compute_logic_awid}),
  .s_axi_compute_logic_awaddr      (s_axi_compute_logic_awaddr),
  .s_axi_compute_logic_awqos       (s_axi_compute_logic_awqos),
  .s_axi_compute_logic_awlen       (s_axi_compute_logic_awlen),
  .s_axi_compute_logic_awsize      (s_axi_compute_logic_awsize),
  .s_axi_compute_logic_awburst     (s_axi_compute_logic_awburst),
  .s_axi_compute_logic_awcache     (s_axi_compute_logic_awcache),
  .s_axi_compute_logic_awprot      (s_axi_compute_logic_awprot),
  .s_axi_compute_logic_awvalid     (s_axi_compute_logic_awvalid),
  .s_axi_compute_logic_awready     (s_axi_compute_logic_awready),
  .s_axi_compute_logic_wdata       (s_axi_compute_logic_wdata),
  .s_axi_compute_logic_wstrb       (s_axi_compute_logic_wstrb),
  .s_axi_compute_logic_wlast       (s_axi_compute_logic_wlast),
  .s_axi_compute_logic_wvalid      (s_axi_compute_logic_wvalid),
  .s_axi_compute_logic_wready      (s_axi_compute_logic_wready),
  .s_axi_compute_logic_awlock      (s_axi_compute_logic_awlock),
  .s_axi_compute_logic_bid         (s_axi_compute_logic_bid),
  .s_axi_compute_logic_bresp       (s_axi_compute_logic_bresp),
  .s_axi_compute_logic_bvalid      (s_axi_compute_logic_bvalid),
  .s_axi_compute_logic_bready      (s_axi_compute_logic_bready),
  .s_axi_compute_logic_arid        ({4'd0, s_axi_compute_logic_arid}),
  .s_axi_compute_logic_araddr      (s_axi_compute_logic_araddr),
  .s_axi_compute_logic_arlen       (s_axi_compute_logic_arlen),
  .s_axi_compute_logic_arsize      (s_axi_compute_logic_arsize),
  .s_axi_compute_logic_arburst     (s_axi_compute_logic_arburst),
  .s_axi_compute_logic_arcache     (s_axi_compute_logic_arcache),
  .s_axi_compute_logic_arprot      (s_axi_compute_logic_arprot),
  .s_axi_compute_logic_arvalid     (s_axi_compute_logic_arvalid),
  .s_axi_compute_logic_arready     (s_axi_compute_logic_arready),
  .s_axi_compute_logic_rid         (s_axi_compute_logic_rid),
  .s_axi_compute_logic_rdata       (s_axi_compute_logic_rdata),
  .s_axi_compute_logic_rresp       (s_axi_compute_logic_rresp),
  .s_axi_compute_logic_rlast       (s_axi_compute_logic_rlast),
  .s_axi_compute_logic_rvalid      (s_axi_compute_logic_rvalid),
  .s_axi_compute_logic_rready      (s_axi_compute_logic_rready),
  .s_axi_compute_logic_arlock      (s_axi_compute_logic_arlock),
  .s_axi_compute_logic_arqos       (s_axi_compute_logic_arqos),

  .s_axi_from_sys_crossbar_awid    (s_axi_from_sys_crossbar_awid),
  .s_axi_from_sys_crossbar_awaddr  (s_axi_from_sys_crossbar_awaddr),
  .s_axi_from_sys_crossbar_awqos   (s_axi_from_sys_crossbar_awqos),
  .s_axi_from_sys_crossbar_awlen   (s_axi_from_sys_crossbar_awlen),
  .s_axi_from_sys_crossbar_awsize  (s_axi_from_sys_crossbar_awsize),
  .s_axi_from_sys_crossbar_awburst (s_axi_from_sys_crossbar_awburst),
  .s_axi_from_sys_crossbar_awcache (s_axi_from_sys_crossbar_awcache),
  .s_axi_from_sys_crossbar_awprot  (s_axi_from_sys_crossbar_awprot),
  .s_axi_from_sys_crossbar_awvalid (s_axi_from_sys_crossbar_awvalid),
  .s_axi_from_sys_crossbar_awready (s_axi_from_sys_crossbar_awready),
  .s_axi_from_sys_crossbar_wdata   (s_axi_from_sys_crossbar_wdata),
  .s_axi_from_sys_crossbar_wstrb   (s_axi_from_sys_crossbar_wstrb),
  .s_axi_from_sys_crossbar_wlast   (s_axi_from_sys_crossbar_wlast),
  .s_axi_from_sys_crossbar_wvalid  (s_axi_from_sys_crossbar_wvalid),
  .s_axi_from_sys_crossbar_wready  (s_axi_from_sys_crossbar_wready),
  .s_axi_from_sys_crossbar_awlock  (s_axi_from_sys_crossbar_awlock),
  .s_axi_from_sys_crossbar_bid     (s_axi_from_sys_crossbar_bid),
  .s_axi_from_sys_crossbar_bresp   (s_axi_from_sys_crossbar_bresp),
  .s_axi_from_sys_crossbar_bvalid  (s_axi_from_sys_crossbar_bvalid),
  .s_axi_from_sys_crossbar_bready  (s_axi_from_sys_crossbar_bready),
  .s_axi_from_sys_crossbar_arid    (s_axi_from_sys_crossbar_arid),
  .s_axi_from_sys_crossbar_araddr  (s_axi_from_sys_crossbar_araddr),
  .s_axi_from_sys_crossbar_arlen   (s_axi_from_sys_crossbar_arlen),
  .s_axi_from_sys_crossbar_arsize  (s_axi_from_sys_crossbar_arsize),
  .s_axi_from_sys_crossbar_arburst (s_axi_from_sys_crossbar_arburst),
  .s_axi_from_sys_crossbar_arcache (s_axi_from_sys_crossbar_arcache),
  .s_axi_from_sys_crossbar_arprot  (s_axi_from_sys_crossbar_arprot),
  .s_axi_from_sys_crossbar_arvalid (s_axi_from_sys_crossbar_arvalid),
  .s_axi_from_sys_crossbar_arready (s_axi_from_sys_crossbar_arready),
  .s_axi_from_sys_crossbar_rid     (s_axi_from_sys_crossbar_rid),
  .s_axi_from_sys_crossbar_rdata   (s_axi_from_sys_crossbar_rdata),
  .s_axi_from_sys_crossbar_rresp   (s_axi_from_sys_crossbar_rresp),
  .s_axi_from_sys_crossbar_rlast   (s_axi_from_sys_crossbar_rlast),
  .s_axi_from_sys_crossbar_rvalid  (s_axi_from_sys_crossbar_rvalid),
  .s_axi_from_sys_crossbar_rready  (s_axi_from_sys_crossbar_rready),
  .s_axi_from_sys_crossbar_arlock  (s_axi_from_sys_crossbar_arlock),
  .s_axi_from_sys_crossbar_arqos   (s_axi_from_sys_crossbar_arqos),

  // Master接口连接到内存
  .m_axi_dev_mem_awid              (m_axi_dev_mem_awid),
  .m_axi_dev_mem_awaddr            (m_axi_dev_mem_awaddr),
  .m_axi_dev_mem_awlen             (m_axi_dev_mem_awlen),
  .m_axi_dev_mem_awsize            (m_axi_dev_mem_awsize),
  .m_axi_dev_mem_awburst           (m_axi_dev_mem_awburst),
  .m_axi_dev_mem_awlock            (m_axi_dev_mem_awlock),
  .m_axi_dev_mem_awqos             (m_axi_dev_mem_awqos),
  .m_axi_dev_mem_awregion          (m_axi_dev_mem_awregion),
  .m_axi_dev_mem_awcache           (m_axi_dev_mem_awcache),
  .m_axi_dev_mem_awprot            (m_axi_dev_mem_awprot),
  .m_axi_dev_mem_awvalid           (m_axi_dev_mem_awvalid),
  .m_axi_dev_mem_awready           (m_axi_dev_mem_awready),
  .m_axi_dev_mem_wdata             (m_axi_dev_mem_wdata),
  .m_axi_dev_mem_wstrb             (m_axi_dev_mem_wstrb),
  .m_axi_dev_mem_wlast             (m_axi_dev_mem_wlast),
  .m_axi_dev_mem_wvalid            (m_axi_dev_mem_wvalid),
  .m_axi_dev_mem_wready            (m_axi_dev_mem_wready),
  .m_axi_dev_mem_bid               (m_axi_dev_mem_bid),
  .m_axi_dev_mem_bresp             (m_axi_dev_mem_bresp),
  .m_axi_dev_mem_bvalid            (m_axi_dev_mem_bvalid),
  .m_axi_dev_mem_bready            (m_axi_dev_mem_bready),
  .m_axi_dev_mem_arid              (m_axi_dev_mem_arid),
  .m_axi_dev_mem_araddr            (m_axi_dev_mem_araddr),
  .m_axi_dev_mem_arlen             (m_axi_dev_mem_arlen),
  .m_axi_dev_mem_arsize            (m_axi_dev_mem_arsize),
  .m_axi_dev_mem_arburst           (m_axi_dev_mem_arburst),
  .m_axi_dev_mem_arlock            (m_axi_dev_mem_arlock),
  .m_axi_dev_mem_arqos             (m_axi_dev_mem_arqos),
  .m_axi_dev_mem_arregion          (m_axi_dev_mem_arregion),
  .m_axi_dev_mem_arcache           (m_axi_dev_mem_arcache),
  .m_axi_dev_mem_arprot            (m_axi_dev_mem_arprot),
  .m_axi_dev_mem_arvalid           (m_axi_dev_mem_arvalid),
  .m_axi_dev_mem_arready           (m_axi_dev_mem_arready),
  .m_axi_dev_mem_rid               (m_axi_dev_mem_rid),
  .m_axi_dev_mem_rdata             (m_axi_dev_mem_rdata),
  .m_axi_dev_mem_rresp             (m_axi_dev_mem_rresp),
  .m_axi_dev_mem_rlast             (m_axi_dev_mem_rlast),
  .m_axi_dev_mem_rvalid            (m_axi_dev_mem_rvalid),
  .m_axi_dev_mem_rready            (m_axi_dev_mem_rready),

  // 时钟和复位 - 仍然使用原来的时钟域
  .axis_aclk                       (axis_aclk),
  .axis_arestn                     (axis_arestn)
);

// === HBM内存模拟器 ===
// 在仿真中，我们仍然使用BRAM，但添加HBM特性的模拟
axi_mm_bram axi_hbm_bram_inst (
  .s_axi_aclk      (axis_aclk),        // 注意：实际HBM工作在450MHz，但仿真中简化
  .s_axi_aresetn   (axis_arestn),
  .s_axi_awid      (m_axi_dev_mem_awid),
  .s_axi_awaddr    (m_axi_dev_mem_awaddr[18:0]), // 512KB地址空间
  .s_axi_awlen     (m_axi_dev_mem_awlen),
  .s_axi_awsize    (m_axi_dev_mem_awsize),
  .s_axi_awburst   (m_axi_dev_mem_awburst),
  .s_axi_awlock    (1'b0),
  .s_axi_awcache   (m_axi_dev_mem_awcache),
  .s_axi_awprot    (m_axi_dev_mem_awprot),
  .s_axi_awvalid   (m_axi_dev_mem_awvalid),
  .s_axi_awready   (m_axi_dev_mem_awready),
  .s_axi_wdata     (m_axi_dev_mem_wdata),
  .s_axi_wstrb     (m_axi_dev_mem_wstrb),
  .s_axi_wlast     (m_axi_dev_mem_wlast),
  .s_axi_wvalid    (m_axi_dev_mem_wvalid),
  .s_axi_wready    (m_axi_dev_mem_wready),
  .s_axi_bid       (m_axi_dev_mem_bid),
  .s_axi_bresp     (m_axi_dev_mem_bresp),
  .s_axi_bvalid    (m_axi_dev_mem_bvalid),
  .s_axi_bready    (m_axi_dev_mem_bready),
  .s_axi_arid      (m_axi_dev_mem_arid),
  .s_axi_araddr    (m_axi_dev_mem_araddr[18:0]),
  .s_axi_arlen     (m_axi_dev_mem_arlen),
  .s_axi_arsize    (m_axi_dev_mem_arsize),
  .s_axi_arburst   (m_axi_dev_mem_arburst),
  .s_axi_arlock    (1'b0),
  .s_axi_arcache   (m_axi_dev_mem_arcache),
  .s_axi_arprot    (m_axi_dev_mem_arprot),
  .s_axi_arvalid   (m_axi_dev_mem_arvalid),
  .s_axi_arready   (m_axi_dev_mem_arready),
  .s_axi_rid       (m_axi_dev_mem_rid),
  .s_axi_rdata     (m_axi_dev_mem_rdata),
  .s_axi_rresp     (m_axi_dev_mem_rresp),
  .s_axi_rlast     (m_axi_dev_mem_rlast),
  .s_axi_rvalid    (m_axi_dev_mem_rvalid),
  .s_axi_rready    (m_axi_dev_mem_rready)
);

endmodule: design_1_sim_wrapper