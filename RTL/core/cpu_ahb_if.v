/******************************************************************************
MIT License

Copyright (c) 2020 BH6BAO

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

******************************************************************************/

`include "yadan_defs.v"

module cpu_ahb_if (
    input   wire            clk,
    input   wire            rst_n,

    // cpu侧接口
    input   wire [31:0]     cpu_addr_i,
    input   wire            cpu_ce_i,
    input   wire            cpu_we_i,
    input   wire [31:0]     cpu_writedata_i,
    input   wire [2:0]      cpu_sel_i,

    output  reg  [31:0]     cpu_readdata_o,

    // AHB总线端接口
    input   wire            M_HGRANT,
    input   wire [31:0]     M_HRDATA,

    output  reg             M_HBUSREQ,
    output  reg  [31:0]     M_HADDR,
    output  reg  [ 1:0]     M_HTRANS,
    output  reg  [ 2:0]     M_HSIZE,
    output  reg  [ 2:0]     M_HBURST,
    output  reg             M_HWRITE,
    output  reg  [31:0]     M_HWDATA,
    
    // to ctrl
    output  reg             stallreq
);

    localparam  IDLE    = 3'b000, 
                WAIT    = 3'b001, 
                CONTROL = 3'b010, 
                ENDS    = 3'b100;
    
    reg [2:0] state;
    reg [2:0] nxt_state;
    
    always @(posedge clk or negedge rst_n) begin 
        if (rst_n == `RstEnable)
            state <= IDLE ;
        else 
            state <= nxt_state;
    end

    // 状态转移的逻辑
    always @(*) begin   
        case(state)
            IDLE:       nxt_state = cpu_ce_i ? WAIT : IDLE;
            WAIT:       nxt_state = cpu_ce_i ? (M_HGRANT ? CONTROL : WAIT) : IDLE;
            CONTROL:    nxt_state = cpu_ce_i ? ENDS : IDLE;
            ENDS:       nxt_state = cpu_ce_i ? ENDS : IDLE;
        endcase
    end

    // 输出逻辑
    always @(*) begin
        M_HADDR         = cpu_addr_i;     // 数据地址
        M_HSIZE         = cpu_sel_i;      // 每次传输的数据大小
        M_HTRANS        = 2'b10;          // 传输状态：只传输一个数据
        M_HBURST        = 3'b000;         // 传输策略：只传一个数据
        M_HWRITE        = cpu_we_i;       // 读写选择

        cpu_readdata_o  = `ZeroWord;      // cpu读到的数据，默认0
        M_HWDATA        = `ZeroWord;      // cpu写入总线的数据，默认0
        
        case (state) 
            IDLE, WAIT, CONTROL: begin
                stallreq    = 1'b1;
                M_HBUSREQ   = cpu_ce_i ? 1'b1 : 1'b0;
            end 
            ENDS: begin
                if (cpu_ce_i) begin
                    stallreq    =   1'b0;
                    M_HBUSREQ   =   1'b1; 
                    if (cpu_we_i == `WriteEnable) begin     // cpu写总线
                        M_HWDATA    =   cpu_writedata_i;    
                    end else begin                          // cpu读总线
                        cpu_readdata_o  =  M_HRDATA;
                    end
                end else begin
                    stallreq    =   1'b1;
                    M_HBUSREQ   =   1'b0;
                end 
            end 
        endcase
    end

endmodule