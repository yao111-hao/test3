#!/bin/bash
#==============================================================================
# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: MIT
#
#==============================================================================
# RecoNIC HBM仿真环境自动化设置脚本
# 这个脚本将自动配置仿真环境以支持HBM系统
#==============================================================================

set -e  # 出错时退出

echo "========================================="
echo "RecoNIC HBM仿真环境设置"
echo "========================================="

# 检查环境变量
if [ -z "$VIVADO_DIR" ]; then
    echo "错误: VIVADO_DIR环境变量未设置"
    echo "请设置: export VIVADO_DIR=/your/vivado/installation/path/Vivado/2021.2"
    exit 1
fi

echo "✓ VIVADO_DIR: $VIVADO_DIR"

# 检查当前目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM_DIR="$(dirname "$SCRIPT_DIR")"
ROOT_DIR="$(dirname "$SIM_DIR")"

echo "✓ 项目根目录: $ROOT_DIR"
echo "✓ 仿真目录: $SIM_DIR"

# 步骤1: 生成HBM相关的Vivado IP
echo ""
echo "步骤1: 生成HBM仿真相关的Vivado IP..."
cd "$SCRIPT_DIR"

if [ -f "gen_vivado_ip_hbm.tcl" ]; then
    echo "正在生成HBM仿真IP..."
    $VIVADO_DIR/bin/vivado -mode batch -source gen_vivado_ip_hbm.tcl
    if [ $? -eq 0 ]; then
        echo "✓ HBM仿真IP生成完成"
    else
        echo "✗ HBM仿真IP生成失败"
        exit 1
    fi
else
    echo "✗ gen_vivado_ip_hbm.tcl 文件未找到"
    exit 1
fi

# 步骤2: 更新编译文件列表
echo ""
echo "步骤2: 更新编译文件列表..."

KERNEL_FILE="$SCRIPT_DIR/kernel.f"
if [ -f "$KERNEL_FILE" ]; then
    # 检查是否已经添加了HBM相关文件
    if ! grep -q "design_1_sim_wrapper.sv" "$KERNEL_FILE"; then
        echo "添加HBM仿真文件到kernel.f..."
        cat >> "$KERNEL_FILE" << EOF

# HBM仿真支持文件
src/design_1_sim_wrapper.sv
src/hbm_clk_gen.sv
EOF
        echo "✓ kernel.f 更新完成"
    else
        echo "✓ kernel.f 已包含HBM仿真文件"
    fi
else
    echo "✗ kernel.f 文件未找到"
    exit 1
fi

# 步骤3: 验证关键文件存在
echo ""
echo "步骤3: 验证HBM仿真文件..."

REQUIRED_FILES=(
    "$SIM_DIR/src/design_1_sim_wrapper.sv"
    "$SIM_DIR/src/hbm_clk_gen.sv"
    "$SIM_DIR/HBM_Simulation_Guide.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $(basename "$file") 存在"
    else
        echo "✗ $(basename "$file") 缺失"
        echo "  预期路径: $file"
        exit 1
    fi
done

# 步骤4: 检查测试台修改
echo ""
echo "步骤4: 检查测试台文件修改..."

TB_FILES=(
    "$SIM_DIR/src/rn_tb_2rdma_top.sv"
    "$SIM_DIR/src/rn_tb_top.sv"
)

for tb_file in "${TB_FILES[@]}"; do
    if [ -f "$tb_file" ]; then
        if grep -q "design_1_sim_wrapper" "$tb_file"; then
            echo "✓ $(basename "$tb_file") 已更新为HBM系统"
        else
            echo "⚠ $(basename "$tb_file") 可能未完全更新"
            echo "  请检查是否包含HBM系统模块的实例化"
        fi
    else
        echo "✗ $(basename "$tb_file") 文件不存在"
    fi
done

# 步骤5: 提供使用指导
echo ""
echo "========================================="
echo "设置完成！"
echo "========================================="
echo ""
echo "现在您可以运行HBM仿真了："
echo ""
echo "1. 进入仿真目录:"
echo "   cd $SIM_DIR"
echo ""
echo "2. 运行测试用例:"
echo "   python run_testcase.py -roce -tc read_2rdma -gui"
echo ""
echo "3. 查看详细指导:"
echo "   cat HBM_Simulation_Guide.md"
echo ""
echo "注意事项:"
echo "- 确保所有Python依赖已安装 (scapy, numpy)"
echo "- 如果使用questasim，确保COMPILED_LIB_DIR已设置"
echo "- 首次运行可能需要一些时间来生成必要的文件"
echo ""
echo "如有问题，请参考 HBM_Simulation_Guide.md 中的调试部分。"
echo ""