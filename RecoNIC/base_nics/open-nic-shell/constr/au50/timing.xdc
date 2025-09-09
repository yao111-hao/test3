# *************************************************************************
#
# Copyright 2020 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# *************************************************************************
# 定义了设计的“心跳”（时钟），处理了不需要分析的路径（时序例外），
# 并对性能最关键的模块进行了物理布局上的“圈地”（Pblock），以帮助时序收敛。
# --- 主时钟定义 ---
# 描述: 这是最重要的时序约束。它告诉Vivado，从 "pcie_refclk_p" 端口输入的是一个
#       周期为10.000ns (即100MHz) 的时钟。所有与此相关的逻辑都将以此为基准进行时序分析。
create_clock -period 10.000 -name pcie_refclk [get_ports pcie_refclk_p]

# hbm 时钟
create_clock -period 10.000 -name hbm_ref_clk [get_ports hbm_clk_clk_p]

# --- 时序例外 (Timing Exceptions) ---
# 描述: 告诉时序分析器忽略通过 "pcie_rstn" 端口的所有路径。
#       因为复位信号通常是异步的，不应按照同步时序逻辑进行分析。
set_false_path -through [get_ports pcie_rstn]

# --- 跨时钟域(CDC)路径约束 ---
# 描述: 这部分处理了数据在AXI-Stream时钟域 (axis_aclk) 和 CMAC以太网IP时钟域 (cmac_clk)
#       之间传递时的最大允许延迟。这是保证高速网络数据通路稳定工作的关键约束。
set axis_aclk [get_clocks -of_object [get_nets axis_aclk]]
foreach cmac_clk [get_clocks -of_object [get_nets cmac_clk*]] {
    set_max_delay -datapath_only -from $axis_aclk -to $cmac_clk 4.000
    set_max_delay -datapath_only -from $cmac_clk -to $axis_aclk 3.103
}

# 为CMAC创建接收与发送两个物理区块
# 1 创建一个名为 "pblock_packet_adapter_tx" 的物理区块。
create_pblock pblock_packet_adapter_tx
# 将CMAC的发送路径逻辑 (tx_inst) 添加到这个区块中。
add_cells_to_pblock [get_pblocks pblock_packet_adapter_tx] [get_cells -quiet {cmac_port*.packet_adapter_inst/tx_inst}]
# 定义这个区块的物理范围，这里指定了FPGA上的特定时钟区域(CLOCKREGION)。
resize_pblock [get_pblocks pblock_packet_adapter_tx] -add {CLOCKREGION_X1Y2:CLOCKREGION_X2Y3}

# 2 为CMAC的接收路径逻辑 (rx_inst) 创建并定义另一个物理区块。
create_pblock pblock_packet_adapter_rx
add_cells_to_pblock [get_pblocks pblock_packet_adapter_rx] [get_cells -quiet {cmac_port*.packet_adapter_inst/rx_inst}]
resize_pblock [get_pblocks pblock_packet_adapter_rx] -add {CLOCKREGION_X5Y2:CLOCKREGION_X6Y3}

