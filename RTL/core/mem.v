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
    // from ex_mem
    input   wire[`RegAddrBus]   wreg_addr_i,
    input   wire                wreg_i,
    input   wire[`RegBus]       wreg_data_i,

    input   wire[`AluOpBus]     aluop_i,
    input   wire[`DataAddrBus]  memaddr_i,
    input   wire[`RegBus]       operand2_i,

    //
    input wire int_assert_i,                // 中断发生标志
    // input wire[`InstAddrBus] int_addr_i,    // 中断跳转地址

    // from cpu_ahb_mem
    input   wire[`DataBus]      ram_data_i,

    // to cpu_ahb_mem 
    output  reg[`DataAddrBus]   ram_addr_o,
    output  wire                ram_we_o,
    output  reg[2:0]            ram_sel_o,
    output  reg[`DataBus]       ram_data_o,
    output  wire                ram_ce_o,

    // to mem_wb
    output  reg                 wreg_o,
    output  reg[`RegAddrBus]    wreg_addr_o,
    output  reg[`RegBus]        wreg_data_o
);

    reg         ram_we;
    reg         ram_ce;

    assign  ram_we_o = ram_we;//(int_assert_i == `INT_ASSERT)?`WriteDisable : ram_we;
    assign  ram_ce_o = ram_ce;//(int_assert_i == `INT_ASSERT)?`Disable : ram_ce;

    always @(*) begin
        wreg_addr_o = wreg_addr_i;
        wreg_o      = wreg_i;
        wreg_data_o = wreg_data_i;
        ram_addr_o  = memaddr_i;
        ram_we      = `WriteDisable;
        ram_sel_o   = 3'b010;
        ram_data_o  = `ZeroWord;
        ram_ce      = `Disable;
        case (aluop_i)
            `EXE_LB: begin          // lb

                ram_we      = `WriteDisable;
                ram_ce      = `Enable;
                ram_sel_o   = 3'b000;

                case (memaddr_i[1:0])
                    2'b00: begin
                        wreg_data_o = {{24{ram_data_i[7]}}, ram_data_i[7:0]};
                    end 
                    2'b01: begin
                        wreg_data_o = {{24{ram_data_i[15]}}, ram_data_i[15:8]};
                    end
                    2'b10: begin
                        wreg_data_o = {{24{ram_data_i[23]}}, ram_data_i[23:16]};
                    end
                    2'b11: begin
                        wreg_data_o = {{24{ram_data_i[31]}}, ram_data_i[31:24]};
                    end
                    default: begin
                        wreg_data_o = `ZeroWord;
                    end
                endcase                   
            end
            `EXE_LH: begin          // lh

                ram_we      = `WriteDisable;
                ram_ce      = `Enable;
                ram_sel_o   = 3'b001;

                case (memaddr_i[1:0])
                    2'b00: begin
                        wreg_data_o = {{16{ram_data_i[15]}}, ram_data_i[15:0]};
                    end 
                    2'b10: begin
                        wreg_data_o = {{16{ram_data_i[31]}}, ram_data_i[31:16]};
                    end
                    default: begin
                        wreg_data_o = `ZeroWord;
                    end
                endcase
            end
            `EXE_LW: begin          // lw

                ram_we      = `WriteDisable;
                ram_ce      = `Enable;
                wreg_data_o = ram_data_i;

            end
            `EXE_LBU: begin         // lbu

                ram_we      = `WriteDisable;
                ram_ce      = `Enable;
                ram_sel_o   = 3'b000;

                case (memaddr_i[1:0])
                    2'b00: begin
                        wreg_data_o = {24'h0, ram_data_i[7:0]};
                    end 
                    2'b01: begin
                        wreg_data_o = {24'h0, ram_data_i[15:8]};
                    end
                    2'b10: begin
                        wreg_data_o = {24'h0, ram_data_i[23:16]};
                    end
                    2'b11: begin
                        wreg_data_o = {24'h0, ram_data_i[31:24]};
                    end
                    default: begin
                        wreg_data_o = `ZeroWord;
                    end
                endcase
            end
            `EXE_LHU: begin         // lhu

                ram_we      = `WriteDisable;
                ram_ce      = `Enable;
                ram_sel_o   = 3'b001;

                case (memaddr_i[1:0])
                    2'b00: begin
                        wreg_data_o = {16'h0, ram_data_i[15:0]};
                    end 
                    2'b10: begin
                        wreg_data_o = {16'h0, ram_data_i[31:16]};
                    end
                    default: begin
                        wreg_data_o = `ZeroWord;
                    end
                endcase   
            end
            `EXE_SB : begin         // sb

                ram_we      = `WriteEnable;
                ram_ce      =  `Enable;
                ram_data_o  = {24'h000000, operand2_i[7:0]};
                ram_sel_o   = 3'b000;
                wreg_data_o = wreg_data_i;
                
            end
            `EXE_SH: begin          // sh

                ram_we      = `WriteEnable;
                ram_ce      =  `Enable; 
                ram_data_o  = {operand2_i[15:0], operand2_i[15:0]};
                ram_sel_o   = 3'b001;
                wreg_data_o = wreg_data_i;
                
            end
            `EXE_SW: begin          // sw

                ram_we      = `WriteEnable;
                ram_ce      = `Enable;
                ram_data_o  = operand2_i;
                ram_sel_o   = 3'b010;
                wreg_data_o = wreg_data_i;
            end

            default: begin
                ram_we      = `WriteDisable;
                ram_ce      = `Disable;
                ram_sel_o   = 3'b000;
            end
        endcase
    end

endmodule // mem
