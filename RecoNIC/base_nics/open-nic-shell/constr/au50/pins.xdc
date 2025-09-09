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

# This file should be read in as unmanaged Tcl constraints to enable the usage
# of if statement
# 在Verilog/VHDL代码或块设计中声明的顶层端口（ports），
# 精确地映射到Alveo U50板卡上FPGA芯片的物理引脚（PACKAGE_PIN），并定义这些引脚的电气标准（IOSTANDARD）。
# Gen3 x16 or Dual x8 Bifrucation on Lane 8-15: AB8(N)/AB9(P)
#	Note: This pair fails timing for PCIe QDMA x16 in this design.
#		[Place 30-739] the GT ref clock should be within 2 quads from all txvrs.
# Dual x8 Bifrucation on Lane 0-7 AF8(N)/AF9(P)
#	Note: The AU50 Vitis shell uses this pair, thus used here.
# --- PCIe 接口引脚 ---
# 描述: 将PCIe的差分参考时钟输入端口(pcie_refclk_p/n)绑定到FPGA的AF9和AF8引脚。
set_property PACKAGE_PIN AF8 [get_ports pcie_refclk_n]
set_property PACKAGE_PIN AF9 [get_ports pcie_refclk_p]

# 描述: 将PCIe的复位输入端口(pcie_rstn)绑定到AW27引脚，并设置其电平标准为1.8V LVCMOS。
set_property PACKAGE_PIN AW27 [get_ports pcie_rstn]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_rstn]

# 添加的hbm 驱动时钟
set_property PACKAGE_PIN BB18 [get_ports hbm_clk_clk_p]
set_property PACKAGE_PIN BC18 [get_ports hbm_clk_clk_n]

# --- QSFP 网络接口引脚 (使用了Tcl脚本逻辑) ---
# 描述: 这是一个更高级的约束写法，增加了设计的灵活性和健壮性。
#       它首先检查设计中是否存在名为 "qsfp_refclk_p" 的端口。
set num_ports [llength [get_ports qsfp_refclk_p]]
# 如果存在至少1个QSFP时钟端口，则将其绑定到N36/N37引脚。
# 这样做可以避免在不使用QSFP接口的设计中，因找不到端口而导致约束报错。
if {$num_ports >= 1} {
    set_property PACKAGE_PIN N37 [get_ports qsfp_refclk_n[0]]
    set_property PACKAGE_PIN N36 [get_ports qsfp_refclk_p[0]]
}
# 这是一个设计规则检查。如果设计中出现了2个或更多的QSFP时钟端口，
# 脚本会打印错误信息并退出，因为U50板卡只有一个物理QSFP接口。
if {$num_ports >= 2} {
    puts "Alveo U50 has only one QSFP28 port, got $num_ports . Quitting"
	exit
}

# Fix the CATTRIP issue for custom flow
# --- HBM 关键信号引脚 ---
# 描述: "hbm_cattrip" 是HBM的灾难性过热跳闸信号，是一个重要的保护信号。
#       在非Vitis的标准FPGA开发流程(custom flow)中，需要手动约束此引脚。
#       这里将其绑定到J18引脚，并设置为1.8V LVCMOS电平。
set_property PACKAGE_PIN J18 [get_ports hbm_cattrip]
set_property IOSTANDARD LVCMOS18 [get_ports hbm_cattrip]


#********************************************************************************************
# --- HBM 子系统时钟引脚 ---
# 描述: 根据Alveo U50官方XDC和board.xml，为HBM的100MHz差分参考时钟分配物理引脚。
#       这里的端口名 "hbm_diff_clk_p/n" 需要与您顶层设计中的端口名完全一致。
# 注意，需要在顶层设计中加入这两个端口
set_property PACKAGE_PIN BB18 [get_ports hbm_diff_clk_p]
set_property PACKAGE_PIN BC18 [get_ports hbm_diff_clk_n]