//==============================================================================
// Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
// SPDX-License-Identifier: MIT
//
//==============================================================================
// HBM时钟生成器 - 仿真专用
// 为HBM系统提供100MHz差分时钟
//==============================================================================
`timescale 1ns/1ps

module hbm_clk_gen (
  input  logic rst_n,        // 复位信号 (低电平有效)
  output logic hbm_clk_p,    // 100MHz差分时钟正端
  output logic hbm_clk_n     // 100MHz差分时钟负端
);

// 生成100MHz时钟 (周期 = 10ns)
parameter real CLK_PERIOD = 10.0; // 10ns = 100MHz

initial begin
  hbm_clk_p = 1'b0;
  hbm_clk_n = 1'b1;
end

// 100MHz时钟生成
always begin
  if (rst_n) begin
    #(CLK_PERIOD/2);
    hbm_clk_p = ~hbm_clk_p;
    hbm_clk_n = ~hbm_clk_n;
  end else begin
    // 复位期间时钟停止
    hbm_clk_p = 1'b0;
    hbm_clk_n = 1'b1;
    @(posedge rst_n);
  end
end

endmodule: hbm_clk_gen