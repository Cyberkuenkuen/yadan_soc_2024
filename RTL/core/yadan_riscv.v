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

module yadan_riscv(
        input   wire            clk
        ,input   wire            rst
        ,input   wire           set_mode
        ,input   wire       [`INT_BUS]   int_i


      , output wire         M0_HBUSREQ     //主机0请求总线，1使能
      , input  wire         M0_HGRANT      //仲裁器返回的授权信号，1使能，一个周期
      , output wire  [31:0] M0_HADDR       //主机0地址
      , output wire  [ 1:0] M0_HTRANS      //主机0传输类型：NONSEQ, SEQ, IDLE, BUSY
      , output wire  [ 2:0] M0_HSIZE       //主机0的数据大小：000.8位，001.16位，010.32位
      , output wire  [ 2:0] M0_HBURST      //主机0批量传输，000单笔传输
      , output wire  [ 3:0] M0_HPROT       //保护控制
      , output wire         M0_HLOCK       //总线锁定
      , output wire         M0_HWRITE      //写，1使能，0读
      , output wire  [31:0] M0_HWDATA      //写数据
      , output wire         M1_HBUSREQ
      , input  wire         M1_HGRANT
      , output wire  [31:0] M1_HADDR
      , output wire  [ 1:0] M1_HTRANS
      , output wire  [ 2:0] M1_HSIZE
      , output wire  [ 2:0] M1_HBURST
      , output wire  [ 3:0] M1_HPROT
      , output wire         M1_HLOCK
      , output wire         M1_HWRITE
      , output wire  [31:0] M1_HWDATA
      , input  wire  [31:0] M_HRDATA       //总线读回数据
      , input  wire  [ 1:0] M_HRESP        //从机返回的总线传输状态 00 ok
      , input  wire         M_HREADY       //1表示传输结束
    
);


    assign  M0_HLOCK = 1'b0;
    assign  M1_HLOCK = 1'b0;
    assign  M0_HPROT = 4'h0;
    assign  M1_HPROT = 4'h0;

    wire[`RegBus]   rom_data_i ;
    wire[`RegBus]   rom_addr_o ;
    wire            rom_ce_o   ;

    wire[`RegBus]   ram_data_i ;
    wire[`RegBus]   ram_addr_o ;
    wire[`RegBus]   ram_data_o ;
    wire            ram_we_o   ;
    wire[2:0]       ram_sel_o  ;
    wire            ram_ce_o   ;

    // 连接 IF/ID 模块与译码阶段 ID 模块的变量
    wire[`InstAddrBus]      pc_pc_o;
    wire[`InstAddrBus]      if_id_pc_o;
    wire[`InstBus]          if_id_inst_o;


    // 连接译码阶段 ID 模块输出与 ID/EX 模块的输入的变量
    wire[`InstAddrBus]      id_pc_o;
    wire[`InstBus]          id_inst_o;
    wire[`AluOpBus]         id_aluop_o;
    wire[`AluSelBus]        id_alusel_o;
    wire[`RegBus]           id_reg1_o;
    wire[`RegBus]           id_reg2_o;
    wire                    id_wreg_o;
    wire[`RegAddrBus]       id_wd_o;
    wire                    id_wcsr_reg_o;
    wire[`RegBus]           id_csr_reg_o;
    wire[`DataAddrBus]      id_wd_csr_reg_o;

    // 连接 ID/EX 模块输出与执行阶段 EX 模块的输入变量
    wire[`InstAddrBus]      ex_pc_i;
    wire[`InstBus]          ex_inst_i;
    wire[`AluOpBus]         ex_aluop_i;
    wire[`AluSelBus]        ex_alusel_i;
    wire[`RegBus]           ex_reg1_i;
    wire[`RegBus]           ex_reg2_i;
    wire                    ex_wreg_i;
    wire[`RegAddrBus]       ex_wd_i;
    wire                    ex_wcsr_reg_i;
    wire[`RegBus]           ex_csr_reg_i;
    wire[`DataAddrBus]      ex_wd_csr_reg_i;

    // 连接执行阶段 EX 模块的输出与 EX/MEM 模块的输入变量
    wire                    ex_wreg_o;
    wire[`RegAddrBus]       ex_wd_o;
    wire[`RegBus]           ex_wdata_o;

    wire[`AluOpBus]         ex_mem_aluop_o;
    wire[`DataAddrBus]      ex_addr_o;
    wire[`RegBus]           ex_mem_reg2_o;

    //from mul_div
    wire[`DoubleRegBus] muldiv_result_i;
    wire                muldiv_done;

    // mul_div_32 Inputs      
    wire   enable_in;
    wire   [31 : 0]  dividend;        
    wire   [31 : 0]  divisor;        
    wire   mul0_div1;
    wire   x_signed0_unsigned1;
    wire   y_signed0_unsigned1;

    // mul_div_32 Outputs
    wire  enable_out;    
    wire  ov;


    // ex to ctrl
    wire                    ex_branch_flag_o;
    wire[`RegBus]           ex_branch_addr_o;

    wire                    ctrl_branch_flag_o;
    wire[`RegBus]           ctrl_branch_addr_o;

    // csr_reg
    wire[`RegBus]           csr_reg_data_o;
    wire[`RegBus]           csr_interrupt_data_o;

    wire[`RegBus]         csr_mtvec;    
    wire[`RegBus]         csr_mepc;     
    wire[`RegBus]         csr_mstatus; 

    wire global_int_en;
    
    // id to csr
    wire[`DataAddrBus]      id_csr_reg_addr_o;
    // ex to csr 
    wire                    ex_wcsr_reg_o;
    wire[`DataAddrBus]      ex_wd_csr_reg_o;
    wire[`RegBus]           ex_wcsr_data_o;

    // 连接 EX/MEM 模块的输出与访存阶段 MEM 模块的输入的变量
    wire                    mem_wreg_i;
    wire[`RegAddrBus]       mem_wd_i;
    wire[`RegBus]           mem_wdata_i;

    wire[`AluOpBus]         mem_aluop_i;
    wire[`DataAddrBus]      mem_mem_addr_i;
    wire[`RegBus]           mem_reg2_i;

    // 连接访存阶段 MEM 模块的输出与 MEM/WB 模块的输入变量
    wire                    mem_wreg_o;
    wire[`RegAddrBus]       mem_wd_o;
    wire[`RegBus]           mem_wdata_o;


    // 连接 MEM/WB 模块的输出与回写阶段输入变量
    wire                    wb_wreg_i;
    wire[`RegAddrBus]       wb_wd_i;
    wire[`RegBus]           wb_wdata_i;

    // 连接译码阶段 ID 模块与通用寄存器 Regfile 模块的变量
    wire                    id_reg1_read_o;
    wire                    id_reg2_read_o;
    wire[`RegAddrBus]       id_reg1_addr_o;
    wire[`RegAddrBus]       id_reg2_addr_o;
    wire[`RegBus]           reg1_data_o;
    wire[`RegBus]           reg2_data_o;

    // ctrl
    wire[5:0]               stall;  
    wire[5:0]               flush;

    wire                    stallreq_from_id;
    wire                    stallreq_from_mem;
    wire                    stallreq_from_if;
    wire                    stallreq_from_interrupt;


    // interrupt模块输出信号
    wire interrupt_we_o;
    wire[`DataAddrBus] interrupt_waddr_o;
    wire[`DataAddrBus] interrupt_raddr_o;
    wire[`RegBus] interrupt_data_o;
    wire[`InstAddrBus] interrupt_int_addr_o;
    wire interrupt_int_assert_o;
    assign interrupt_int_assert_o = 0;

    //assign     stallreq_from_mem = ram_ce_o; 

    // pc_reg 例化
    pc_reg  u_pc_reg(
        .clk(clk),
        .rst(rst),
        .PCchange_enable(~ram_ce_o),
        .set_mode(set_mode),
        .branch_flag_i(ctrl_branch_flag_o),
        .branch_addr_i(ctrl_branch_addr_o),

        .stalled(stall),

        .pc_o(pc_pc_o),
        .ce_o(rom_ce_o)
    );

    assign  rom_addr_o  =  pc_pc_o;  // 指令存储器的输入地址就是 pc 的值

    // IF/ID 例化
    if_id   u_if_id(
        .clk(clk),
        .rst(rst),
        .pc_i(pc_pc_o),
        .inst_i(rom_data_i),
        .ex_branch_flag_i(ctrl_branch_flag_o),

        .flush(flush),
        .stalled(stall),

        .pc_o(if_id_pc_o),
        .inst_o(if_id_inst_o)
    );

    // ID 例化
    id  u_id(
        .rst(rst),
        .pc_i(if_id_pc_o),
        .inst_i(if_id_inst_o),
        
        // from regfile 模块的输入
        .reg1_data_i(reg1_data_o),
        .reg2_data_i(reg2_data_o),

        // from ex
        .ex_wreg_i(ex_wreg_o),
        .ex_wdata_i(ex_wdata_o),
        .ex_wd_i(ex_wd_o),
        .ex_branch_flag_i(ex_branch_flag_o),

        .ex_aluop_i(ex_mem_aluop_o),

        // from wd mem
        .mem_wreg_i     (mem_wreg_o),
        .mem_wdata_i    (mem_wdata_o),
        .mem_wd_i       (mem_wd_o),

        // from csr_reg
        .csr_reg_data_i(csr_reg_data_o),
        .csr_reg_addr_o(id_csr_reg_addr_o),

        // 送入 regfile 的信息
        .reg1_read_o(id_reg1_read_o),
        .reg2_read_o(id_reg2_read_o),
        .reg1_addr_o(id_reg1_addr_o),
        .reg2_addr_o(id_reg2_addr_o),

        .stallreq(stallreq_from_id),

        .pc_o(id_pc_o),
        .inst_o(id_inst_o),
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .reg_wd_o(id_wd_o),
        .wreg_o(id_wreg_o),

         // 送到 ID/EX 的信息
        .wcsr_reg_o(id_wcsr_reg_o),
        .csr_reg_o(id_csr_reg_o),
        .wd_csr_reg_o(id_wd_csr_reg_o)
    );

    // 通用寄存器 regfile 例化
    regsfile u_regsfile
    (
        .clk(clk),
        .rst(rst),
        .int_assert_i(interrupt_int_assert_o),
        .we_i(wb_wreg_i),
        .waddr_i(wb_wd_i),
        .wdata_i(wb_wdata_i),

        .re1_i(id_reg1_read_o),
        .raddr1_i(id_reg1_addr_o),
        .rdata1_o(reg1_data_o),

        .re2_i(id_reg2_read_o),
        .raddr2_i(id_reg2_addr_o),
        .rdata2_o(reg2_data_o)
    );

    // ID/EX 例化
    id_ex   u_id_ex(
        .clk(clk),
        .rst(rst),

        // 从译码阶段 ID 模块来的信息
        .id_pc_i(id_pc_o),
        .id_inst_i(id_inst_o),
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),
        .id_wcsr_reg(id_wcsr_reg_o),
        .id_csr_reg(id_csr_reg_o),
        .id_wd_csr_reg(id_wd_csr_reg_o),

        .ex_branch_flag_i(ctrl_branch_flag_o),

        .stalled(stall),
        .flush(flush),

        // 传递到执行阶段 EX 模块的信息
        .ex_pc_o(ex_pc_i),
        .ex_inst_o(ex_inst_i),
        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_wreg(ex_wreg_i),
        .ex_wcsr_reg(ex_wcsr_reg_i),
        .ex_csr_reg(ex_csr_reg_i),
        .ex_wd_csr_reg(ex_wd_csr_reg_i)
    );

    // EX 模块例化
    ex  u_ex(
        .rst(rst),

        // 从 ID/EX 模块来的信息
        .ex_pc(ex_pc_i),
        .ex_inst(ex_inst_i),
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),
        .wcsr_reg_i(ex_wcsr_reg_i),
        .csr_reg_i(ex_csr_reg_i),
        .wd_csr_reg_i(ex_wd_csr_reg_i),
        
        //from mul_div
        .muldiv_result_i(muldiv_result_i),
        .muldiv_done(muldiv_done),
        
        //中断
        .int_assert_i(interrupt_int_assert_o),
        .int_addr_i(interrupt_int_addr_o),

        //to mul_div

        .muldiv_start_o(enable_in),
        .muldiv_dividend_o(dividend),
        .muldiv_divisor_o(divisor),
        .mul_or_div(mul0_div1),
        .muldiv_reg1_signed0_unsigned1(x_signed0_unsigned1),
        .muldiv_reg2_signed0_unsigned1(y_signed0_unsigned1),

        // 输出到 ID/MEM 模块的信息
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o),

        .ex_aluop_o(ex_mem_aluop_o),
        .ex_mem_addr_o(ex_addr_o),
        .ex_reg2_o(ex_mem_reg2_o),

        // to csr reg
        .wcsr_reg_o(ex_wcsr_reg_o),
        .wd_csr_reg_o(ex_wd_csr_reg_o),
        .wcsr_data_o(ex_wcsr_data_o),

        // ex to ctrl
        .branch_flag_o(ex_branch_flag_o),
        .branch_addr_o(ex_branch_addr_o)
    );

    mul_div_32  u_mul_div_32 (
        .clk                     ( clk                   ),
        .reset_n                 ( rst                  ),
        .enable_in               ( enable_in             ),
        .x                       ( dividend              ),
        .y                       ( divisor               ),
        .mul0_div1               ( mul0_div1             ),
        .x_signed0_unsigned1     ( x_signed0_unsigned1   ),
        .y_signed0_unsigned1     ( y_signed0_unsigned1   ),

        .enable_out              ( muldiv_done           ),
        .z                       ( muldiv_result_i       ),
        .ov                      ( ov                    )
    );


    // EX/MEM 例化
    ex_mem  u_ex_mem(
        .clk(clk),
        .rst(rst),

        // 从执行阶段 EX 来的信息
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        .ex_aluop_i(ex_mem_aluop_o),
        .ex_mem_addr_i(ex_addr_o),
        .ex_reg2_i(ex_mem_reg2_o),

        .stalled(stall),
        .flush(flush),

        // 送到访存阶段的  MEM 信息
        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i),

        .mem_aluop(mem_aluop_i),
        .mem_mem_addr(mem_mem_addr_i),
        .mem_reg2(mem_reg2_i)
    );

    // MEM 例化
    mem u_mem(
        .rst(rst),

        // 来自 EX/MEM 模块的信息
        .wd_i(mem_wd_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        .mem_aluop_i(mem_aluop_i),
        .mem_mem_addr_i(mem_mem_addr_i),
        .mem_reg2_i(mem_reg2_i),

        .int_assert_i(interrupt_int_assert_o),
        // 送到 MEM/WB 的信息
        .wd_o(mem_wd_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o),

        // from ram
        .mem_data_i(ram_data_i),
        
        // to ram
        .mem_addr_o(ram_addr_o),
        .mem_we_o(ram_we_o),
        .mem_data_o(ram_data_o),
        .mem_sel_o(ram_sel_o),
        .mem_ce_o(ram_ce_o)
    );

    // MEM/WB 例化
    mem_wb  u_mem_wb(
        .clk(clk),
        .rst(rst),

        // 来自访存阶段 MEM 信息
        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),
        .mem_wdata(mem_wdata_o),

        .stalled(stall),
        .flush(flush),

        // 送到回写阶段的信息 to id/regsfile
        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),
        .wb_wdata(wb_wdata_i)
    );

    // csr_reg
    csr_reg     u_csr_reg(
        .clk(clk),
        .rst(rst),

        .we_i(ex_wcsr_reg_o),
        .waddr_i(ex_wd_csr_reg_o),
        .wdata_i(ex_wcsr_data_o),

        .raddr_i(id_csr_reg_addr_o),
        
        .rdata_o(csr_reg_data_o),

        .interrupt_csr_mtvec  (csr_mtvec),
        .interrupt_csr_mepc   (csr_mepc),
        .interrupt_csr_mstatus(csr_mstatus),

        .global_int_en_o(global_int_en),

        .interrupt_we_i(interrupt_we_o),
        .interrupt_raddr_i(interrupt_raddr_o),
        .interrupt_waddr_i(interrupt_waddr_o),
        .interrupt_data_i(interrupt_data_o),
        .interrupt_data_o(csr_interrupt_data_o)
    );


    // ctrl 
    ctrl    u_ctrl(
        .rst(rst),
        .stallreq_from_id(stallreq_from_id),
        .stallreq_from_ex(enable_in),
        .stallreq_from_mem(stallreq_from_mem),
        .stallreq_from_if(stallreq_from_if),
        .stallreq_from_interrupt(stallreq_from_interrupt),

        .branch_flag_i(ex_branch_flag_o),
        .branch_addr_i(ex_branch_addr_o),

        // ctrl to pc_reg
        .branch_flag_o(ctrl_branch_flag_o),
        .branch_addr_o(ctrl_branch_addr_o),
        .flush_o(flush),
        .stalled_o(stall)
    );

    // interrupt_ctrl模块例化
//    interrupt_ctrl u_interrupt_ctrl(
//        .clk(clk),
//        .rst(rst),
//        .global_int_en_i(global_int_en),  //
//        .int_flag_i(int_i),
//        .inst_i(id_inst_o),//
//        .inst_addr_i(id_pc_o), //
//        .inst_ex_i(id_inst_o), //
//        .branch_flag_i(ctrl_branch_flag_o),
//        .branch_addr_i(ctrl_branch_addr_o),
//        .div_done_i(enable_in),//
        
//        .data_i(csr_interrupt_data_o),
//        .csr_mtvec  (csr_mtvec),
//        .csr_mepc   (csr_mepc),
//        .csr_mstatus(csr_mstatus),

//        // .stallreq_interrupt_o(stallreq_from_interrupt),

//        .we_o(interrupt_we_o),
//        .waddr_o(interrupt_waddr_o),
//        .raddr_o(interrupt_raddr_o),
//        .data_o(interrupt_data_o),
//        .int_addr_o(interrupt_int_addr_o),
//        .int_assert_o(interrupt_int_assert_o)
//    );

    cpu_ahb_if  u_if_cpu_ahb (
        .clk                     ( clk               ),
        .rst                     ( rst               ),
        .cpu_addr_i              ( rom_addr_o        ),
        .cpu_ce_i                ( rom_ce_o          ),
        .cpu_we_i                ( 1'b0              ),
        .cpu_writedate_i         ( `ZeroWord         ),
        .cpu_sel_i               ( 3'b010            ),
        .M_HGRANT                ( M1_HGRANT         ),
        .M_HRDATA                ( M_HRDATA          ),

        .cpu_readdate_o          ( rom_data_i        ),
        .M_HBUSREQ               ( M1_HBUSREQ         ),
        .M_HADDR                 ( M1_HADDR           ),
        .M_HTRANS                ( M1_HTRANS          ),
        .M_HSIZE                 ( M1_HSIZE           ),
        .M_HBURST                ( M1_HBURST          ),
        .M_HWRITE                ( M1_HWRITE          ),
        .M_HWDATA                ( M1_HWDATA          ),
        .stallreq                ( stallreq_from_if          )
);

    cpu_ahb_mem  u_mem_cpu_ahb (
        .clk                     ( clk               ),
        .rst                     ( rst               ),
        .cpu_addr_i              ( ram_addr_o        ),
        .cpu_ce_i                ( ram_ce_o          ),
        .cpu_we_i                ( ram_we_o          ),
        .cpu_writedate_i         ( ram_data_o   ),
        .cpu_sel_i               ( ram_sel_o         ),
        .M_HGRANT                ( M0_HGRANT          ),
        .M_HRDATA                ( M_HRDATA          ),
        .M_HREADY                (M_HREADY           ),

        .cpu_readdate_o          ( ram_data_i    ),
        .M_HBUSREQ               ( M0_HBUSREQ         ),
        .M_HADDR                 ( M0_HADDR           ),
        .M_HTRANS                ( M0_HTRANS          ),
        .M_HSIZE                 ( M0_HSIZE           ),
        .M_HBURST                ( M0_HBURST          ),
        .M_HWRITE                ( M0_HWRITE          ),
        .M_HWDATA                ( M0_HWDATA          ),
        .stallreq                ( stallreq_from_mem          )
);


endmodule // bitty_riscv
