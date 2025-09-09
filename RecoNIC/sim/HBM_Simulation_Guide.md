# RecoNIC HBM仿真系统改进指南

## 概述

由于硬件设计从DDR内存迁移到HBM内存，仿真环境也需要相应更新以匹配新的架构。本指南详细说明了如何更新RecoNIC的仿真环境以支持HBM系统。

## 核心变化

### 硬件层面的变化
1. **内存子系统**: 从DDR控制器链条更换为HBM系统(`design_1`)
2. **时钟要求**: 新增100MHz差分时钟输入，内部PLL生成450MHz工作时钟
3. **接口转换**: 从512-bit AXI接口转换为HBM的256-bit接口
4. **配置接口**: 新增APB配置接口用于HBM控制

### 仿真环境变化
1. **测试台更新**: 添加HBM时钟生成和信号接口
2. **模块替换**: 用HBM系统仿真模块替换原有的AXI交叉连接器
3. **IP生成**: 添加HBM相关的Vivado IP生成支持
4. **时钟域**: 处理多时钟域同步问题

## 文件修改清单

### 新增文件

#### 1. HBM系统仿真模块
**文件**: `/workspace/RecoNIC/sim/src/design_1_sim_wrapper.sv`
- **作用**: 模拟hardware中的design_1 HBM系统
- **功能**: 
  - 提供与硬件design_1相同的接口
  - 内部集成时钟转换逻辑
  - 包含HBM内存BRAM模拟器
  - 支持APB配置接口

#### 2. HBM时钟生成器
**文件**: `/workspace/RecoNIC/sim/src/hbm_clk_gen.sv`
- **作用**: 为仿真环境提供100MHz差分时钟
- **功能**:
  - 生成精确的100MHz差分时钟对
  - 支持复位同步
  - 仿真专用的时钟生成逻辑

#### 3. HBM IP生成脚本
**文件**: `/workspace/RecoNIC/sim/scripts/gen_vivado_ip_hbm.tcl`
- **作用**: 生成HBM仿真所需的Vivado IP
- **功能**:
  - 创建时钟转换IP (axi_clock_converter)
  - 创建复位同步IP (proc_sys_reset) 
  - 创建智能连接IP (smartconnect)
  - 创建时钟向导IP (clk_wiz)
  - 创建常量IP (xlconstant)

#### 4. HBM IP配置文件
**文件**: `/workspace/RecoNIC/sim/scripts/sim_vivado_ip_hbm.tcl`
- **作用**: 定义HBM仿真需要的IP列表
- **功能**: 在原有IP基础上添加HBM相关IP

### 修改文件

#### 1. 主测试台文件
**文件**: `/workspace/RecoNIC/sim/src/rn_tb_2rdma_top.sv`
- **修改**:
  - 添加HBM时钟信号定义
  - 实例化HBM时钟生成器
  - 添加APB控制接口信号
  - 替换axi_3to1_interconnect_to_dev_mem为design_1_sim_wrapper
  - 移除独立的设备内存BRAM实例
  - 调整AXI ID宽度匹配

#### 2. 单RDMA测试台文件
**文件**: `/workspace/RecoNIC/sim/src/rn_tb_top.sv`
- **修改**:
  - 类似rn_tb_2rdma_top.sv的修改
  - 替换axi_interconnect_to_dev_mem为HBM系统
  - 更新时钟和复位连接

## 详细实施步骤

### 步骤1: 生成HBM仿真IP
```bash
cd /workspace/RecoNIC/sim/scripts
vivado -mode batch -source gen_vivado_ip_hbm.tcl
```

### 步骤2: 编译仿真文件
确保所有新添加的SystemVerilog文件被包含在编译列表中：

**更新 `/workspace/RecoNIC/sim/scripts/kernel.f`**:
```
# HBM仿真支持文件
src/design_1_sim_wrapper.sv
src/hbm_clk_gen.sv
```

### 步骤3: 更新测试用例
现有的测试用例JSON配置文件不需要修改，因为接口保持兼容。

### 步骤4: 运行仿真
使用标准的仿真命令：
```bash
cd /workspace/RecoNIC/sim
python run_testcase.py -roce -tc read_2rdma -gui
```

## 接口兼容性

### AXI接口映射
- **QDMA MM接口**: 5-bit ID，直接映射
- **Compute Logic接口**: 1-bit ID，扩展为5-bit
- **System Crossbar接口**: 5-bit ID，直接映射

### 时钟域处理
- **输入时钟**: 250MHz (axis_aclk) 
- **HBM时钟**: 100MHz差分时钟 → 内部450MHz
- **仿真简化**: 在design_1_sim_wrapper中使用axis_aclk作为工作时钟

### 复位策略
- **主复位**: axis_arstn (250MHz域)
- **PCIe复位**: pcie_rstn
- **HBM复位**: 从pcie_rstn派生，同步到HBM时钟域

## 调试和验证

### 仿真检查点
1. **时钟生成**: 确认100MHz差分时钟正确生成
2. **复位同步**: 验证各时钟域复位时序
3. **AXI传输**: 检查AXI接口数据传输正确性
4. **内存访问**: 验证通过HBM系统的内存读写

### 常见问题
1. **时钟不同步**: 检查hbm_clk_gen模块的复位逻辑
2. **AXI ID冲突**: 确认ID宽度转换正确
3. **内存初始化**: 检查init_mem模块与新HBM系统的兼容性

## 性能考虑

### 仿真性能
- HBM系统模块增加了仿真复杂度，可能影响仿真速度
- 可以通过减少内存大小来提高仿真速度
- 考虑在快速功能验证中禁用详细的HBM时序模拟

### 内存容量
- 当前配置为512KB BRAM模拟HBM
- 可根据测试需要调整内存大小
- 注意地址映射的正确性

## 未来扩展

### 完整HBM模型
如果需要更精确的HBM行为模拟，可以考虑：
1. 集成Xilinx HBM IP的BFM (Bus Functional Model)
2. 添加HBM特定的时序和性能特性
3. 实现真实的450MHz时钟域逻辑

### 多HBM通道
当前实现只使用单个HBM通道，将来可以扩展到：
1. 多通道HBM访问
2. 通道间负载均衡
3. 通道故障模拟

## 总结

通过上述修改，RecoNIC的仿真环境能够正确模拟新的HBM内存系统，同时保持与现有测试用例的兼容性。主要的改进包括：

1. **架构匹配**: 仿真架构与硬件设计保持一致
2. **接口兼容**: 保持向后兼容性，现有测试可以直接运行
3. **可扩展性**: 提供了未来进一步增强HBM仿真的基础
4. **调试友好**: 保留了详细的调试接口和信号

这些修改确保了从DDR到HBM的平滑过渡，同时为后续的硬件验证提供了可靠的仿真平台。