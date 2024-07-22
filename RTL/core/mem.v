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

module mem(
    input   wire            rst,

    // 来自执行阶段的信息 from ex
    input   wire[`RegAddrBus]   wd_i,
    input   wire                wreg_i,
    input   wire[`RegBus]       wdata_i,

    input   wire[`AluOpBus]     mem_aluop_i,
    input   wire[`DataAddrBus]  mem_mem_addr_i,
    input   wire[`RegBus]       mem_reg2_i,

    input wire int_assert_i,                // 中断发生标志
    // input wire[`InstAddrBus] int_addr_i,    // 中断跳转地址

    // from ram 
    input   wire[`DataBus]      mem_data_i,

    // to ram 
    output  reg[`DataAddrBus]   mem_addr_o,
    output  wire                mem_we_o,
    output  reg[2:0]            mem_sel_o,
    output  reg[`DataBus]       mem_data_o,
    output  wire                 mem_ce_o,

    // 访存阶段的结果
    output  reg[`RegAddrBus]    wd_o,
    output  reg                 wreg_o,
    output  reg[`RegBus]        wdata_o
);

    reg         mem_we;
    reg         mem_ce;

    assign  mem_we_o = mem_we;//(int_assert_i == `INT_ASSERT)?`WriteDisable : mem_we;
    assign  mem_ce_o = mem_ce;//(int_assert_i == `INT_ASSERT)?`Disable : mem_ce;

    always  @ (*)   begin
        if (rst == `RstEnable) begin
            wd_o        = `NOPRegAddr;
            wreg_o      = `WriteDisable;
            wdata_o     = `ZeroWord;
            mem_addr_o  = `ZeroWord;
            mem_we      = `WriteDisable;
            mem_sel_o   = 3'b010;
            mem_data_o  = `ZeroWord;
            mem_ce    = `Disable;
        end else begin
            wd_o        = wd_i;
            wreg_o      = wreg_i;
            wdata_o     = wdata_i;
            mem_addr_o  = mem_mem_addr_i;
            mem_we      = `WriteDisable;
            mem_sel_o   = 3'b010;
            mem_data_o  = `ZeroWord;
            mem_ce    = `Disable;
            case (mem_aluop_i)
                `EXE_LB: begin          // lb

                    mem_we      = `WriteDisable;
                    mem_ce    = `Enable;
                    mem_sel_o   = 3'b000;

                    case (mem_mem_addr_i[1:0])
                        2'b00: begin
                            wdata_o = {{24{mem_data_i[7]}}, mem_data_i[7:0]};
                        end 
                        2'b01: begin
                            wdata_o = {{24{mem_data_i[15]}}, mem_data_i[15:8]};
                        end
                        2'b10: begin
                            wdata_o = {{24{mem_data_i[23]}}, mem_data_i[23:16]};
                        end
                        2'b11: begin
                            wdata_o = {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                        end
                        default: begin
                            wdata_o = `ZeroWord;
                        end
                    endcase                   
                end
                `EXE_LH: begin          // lh

                    mem_we      = `WriteDisable;
                    mem_ce    = `Enable;
                    mem_sel_o   = 3'b001;

                    case (mem_mem_addr_i[1:0])
                        2'b00: begin
                            wdata_o = {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                        end 
                        2'b10: begin
                            wdata_o = {{16{mem_data_i[31]}}, mem_data_i[31:16]};
                        end
                        default: begin
                            wdata_o = `ZeroWord;
                        end
                    endcase
                end
                `EXE_LW: begin          // lw

                    mem_we      = `WriteDisable;
                    mem_ce    = `Enable;
                    wdata_o     = mem_data_i;

                end
                `EXE_LBU: begin         // lbu

                    mem_we      = `WriteDisable;
                    mem_ce    = `Enable;
                    mem_sel_o   = 3'b000;

                    case (mem_mem_addr_i[1:0])
                        2'b00: begin
                            wdata_o = {24'h0, mem_data_i[7:0]};
                        end 
                        2'b01: begin
                            wdata_o = {24'h0, mem_data_i[15:8]};
                        end
                        2'b10: begin
                            wdata_o = {24'h0, mem_data_i[23:16]};
                        end
                        2'b11: begin
                            wdata_o = {24'h0, mem_data_i[31:24]};
                        end
                        default: begin
                            wdata_o = `ZeroWord;
                        end
                    endcase
                end
                `EXE_LHU: begin         // lhu

                    mem_we      = `WriteDisable;
                    mem_ce    = `Enable;
                    mem_sel_o   = 3'b001;

                    case (mem_mem_addr_i[1:0])
                        2'b00: begin
                            wdata_o = {16'h0, mem_data_i[15:0]};
                        end 
                        2'b10: begin
                            wdata_o = {16'h0, mem_data_i[31:16]};
                        end
                        default: begin
                            wdata_o = `ZeroWord;
                        end
                    endcase   
                end
                `EXE_SB : begin         // sb

                    mem_we      = `WriteEnable;
                    mem_ce    =  `Enable;
                    mem_data_o  = {24'h000000, mem_reg2_i[7:0]};
                    mem_sel_o   = 3'b000;
                    wdata_o     = wdata_i;
                   
                end
                `EXE_SH: begin          // sh

                    mem_we      = `WriteEnable;
                    mem_ce    =  `Enable; 
                    mem_data_o  = {mem_reg2_i[15:0], mem_reg2_i[15:0]};
                    mem_sel_o   = 3'b001;
                    wdata_o     = wdata_i;
                    
                end
                `EXE_SW: begin          // sw

                    mem_we      = `WriteEnable;
                    mem_ce    = `Enable;
                    mem_data_o  = mem_reg2_i;
                    mem_sel_o   = 3'b010;
                    wdata_o     = wdata_i;
                end

                default: begin
                    mem_we      = `WriteDisable;
                    mem_ce    = `Disable;
                    mem_sel_o   = 3'b000;
                end
            endcase

        end
    end

endmodule // mem
