#==============================================================================
# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#
#==============================================================================
# HBM仿真支持的IP列表
# 在原有IP基础上添加了HBM仿真相关的IP
#==============================================================================

set ips {
  axi_mm_bram
  axi_sys_mm
  axil_3to1_crossbar
  reconic_axil_crossbar
  axi_protocol_checker
  dev_mem_axi_crossbar
  dev_mem_3to1_axi_crossbar
  sys_mem_axi_crossbar
  sys_mem_5to2_axi_crossbar
  packet_parser
  rdma_core
  axi_clock_converter
  proc_sys_reset
  smartconnect
  clk_wiz
  xlconstant
}
