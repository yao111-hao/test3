#==============================================================================
# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#
#==============================================================================
# HBM仿真专用的IP生成脚本
# 基于原来的gen_vivado_ip.tcl，添加了HBM系统相关的IP支持
#==============================================================================

array set build_options {
  -board_repo ""
}

# Expect arguments in the form of `-argument value`
for {set i 0} {$i < $argc} {incr i 2} {
    set arg [lindex $argv $i]
    set val [lindex $argv [expr $i+1]]
    if {[info exists build_options($arg)]} {
        set build_options($arg) $val
        puts "Set build option $arg to $val"
    } elseif {[info exists design_params($arg)]} {
        set design_params($arg) $val
        puts "Set design parameter $arg to $val"
    } else {
        puts "Skip unknown argument $arg and its value $val"
    }
}

# Settings based on defaults or passed in values
foreach {key value} [array get build_options] {
    set [string range $key 1 end] $value
}

if {[string equal $board_repo ""]} {
  puts "INFO: if showing board_part definition error, please provide \"board_repo\" in the command line to indicate Xilinx board repo path"
} else {
  set_param board.repoPaths $board_repo
}

# 改为u50板卡参数
set vivado_version 2021.2
set board au50
set part xcu50-fsvh2104-2-e
set board_part xilinx.com:au50:part0:1.3

set root_dir [file normalize ../..]
set ip_src_dir $root_dir/shell/plugs/rdma_onic_plugin
set hbm_ip_src_dir $root_dir/base_nics/open-nic-shell/src/hbm_subsystem
set sim_dir $root_dir/sim
set build_dir $sim_dir/build
set ip_build_dir $build_dir/ip
set build_managed_ip_dir $build_dir/managed_ip
set ip_src $root_dir/shell/plugs/rdma_onic_plugin
set p4_dir $root_dir/shell/packet_classification

file mkdir $ip_build_dir
file mkdir $build_managed_ip_dir

puts "INFO: Building required IPs for HBM simulation"
create_project -force managed_ip_project $build_managed_ip_dir -part $part
set_property BOARD_PART $board_part [current_project]

set ip_dict [dict create]

# 使用HBM仿真的IP列表
source ${sim_dir}/scripts/sim_vivado_ip_hbm.tcl

foreach ip $ips {
  set xci_file ${ip_build_dir}/$ip/$ip.xci
  
  # 检查IP是否存在于主IP目录
  if {[file exists ${ip_src_dir}/vivado_ip/${ip}.tcl]} {
    puts "INFO: Sourcing IP from main directory: ${ip}"
    source ${ip_src_dir}/vivado_ip/${ip}.tcl
  } elseif {[string match "axi_clock_converter*" $ip] || [string match "proc_sys_reset*" $ip] || 
            [string match "smartconnect*" $ip] || [string match "clk_wiz*" $ip] ||
            [string match "xlconstant*" $ip]} {
    # 这些是Xilinx内置IP，使用内置创建命令
    puts "INFO: Creating Xilinx built-in IP: ${ip}"
    create_hbm_builtin_ip $ip $xci_file
  } else {
    puts "WARNING: IP definition not found for $ip, skipping..."
    continue
  }

  if {[file exists $xci_file]} {
    generate_target all [get_files $xci_file]
    create_ip_run [get_files -of_objects [get_fileset sources_1] $xci_file]
    launch_runs ${ip}_synth_1 -jobs 8
    wait_on_run ${ip}_synth_1
    puts "INFO: $ip is generated"
  } else {
    puts "WARNING: XCI file not created for $ip"
  }
}

# 创建HBM系统的块设计
puts "INFO: Creating HBM system block design for simulation"
source ${hbm_ip_src_dir}/design_1.tcl

puts "INFO: All IPs required for HBM simulation are generated"

# 创建内置IP的过程
proc create_hbm_builtin_ip {ip_name xci_file} {
  switch $ip_name {
    "axi_clock_converter" {
      create_ip -name axi_clock_converter -vendor xilinx.com -library ip -version 2.1 -module_name $ip_name -dir [file dirname $xci_file]
      set_property -dict [list CONFIG.ADDR_WIDTH {64} CONFIG.DATA_WIDTH {512} CONFIG.ID_WIDTH {5}] [get_ips $ip_name]
    }
    "proc_sys_reset" {
      create_ip -name proc_sys_reset -vendor xilinx.com -library ip -version 5.0 -module_name $ip_name -dir [file dirname $xci_file]
    }
    "smartconnect" {
      create_ip -name smartconnect -vendor xilinx.com -library ip -version 1.0 -module_name $ip_name -dir [file dirname $xci_file]
      set_property -dict [list CONFIG.NUM_SI {3}] [get_ips $ip_name]
    }
    "clk_wiz" {
      create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name $ip_name -dir [file dirname $xci_file]
      set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {450.000}] [get_ips $ip_name]
    }
    "xlconstant" {
      create_ip -name xlconstant -vendor xilinx.com -library ip -version 1.1 -module_name $ip_name -dir [file dirname $xci_file]
      set_property -dict [list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {32}] [get_ips $ip_name]
    }
    default {
      puts "WARNING: Unknown built-in IP: $ip_name"
    }
  }
}
