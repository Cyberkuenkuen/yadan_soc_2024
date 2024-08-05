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
    input  wire            clk,
    input  wire            rst,
    input  wire [`INT_BUS] int_i,

    output wire         M0_HBUSREQ,     //主机0请求总线，1使能
    input  wire         M0_HGRANT,      //仲裁器返回的授权信号，1使能，一个周期
    output wire  [31:0] M0_HADDR,       //主机0地址
    output wire  [ 1:0] M0_HTRANS,      //主机0传输类型：NONSEQ, SEQ, IDLE, BUSY
    output wire  [ 2:0] M0_HSIZE,       //主机0的数据大小：000.8位，001.16位，010.32位
    output wire  [ 2:0] M0_HBURST,      //主机0批量传输，000单笔传输
    output wire  [ 3:0] M0_HPROT,       //保护控制
    output wire         M0_HLOCK,       //总线锁定
    output wire         M0_HWRITE,      //写，1使能，0读
    output wire  [31:0] M0_HWDATA,      //写数据
    output wire         M1_HBUSREQ,
    input  wire         M1_HGRANT,
    output wire  [31:0] M1_HADDR,
    output wire  [ 1:0] M1_HTRANS,
    output wire  [ 2:0] M1_HSIZE,
    output wire  [ 2:0] M1_HBURST,
    output wire  [ 3:0] M1_HPROT,
    output wire         M1_HLOCK,
    output wire         M1_HWRITE,
    output wire  [31:0] M1_HWDATA,
    input  wire  [31:0] M_HRDATA,       //总线读回数据
    input  wire  [ 1:0] M_HRESP,        //从机返回的总线传输状态 00 ok
    input  wire         M_HREADY        //1表示传输结束
);

    assign  M0_HPROT = 4'h0;
    assign  M1_HPROT = 4'h0;
    assign  M0_HLOCK = 1'b0;
    assign  M1_HLOCK = 1'b0;
    
    wire[`RegBus]   rom_data;
    wire[`RegBus]   rom_addr_o;
    wire            rom_ce;

    wire[`RegBus]   ram_rdata;
    wire[`RegBus]   ram_addr;
    wire[`RegBus]   ram_wdata;
    wire            ram_we;
    wire[2:0]       ram_sel;
    wire            ram_ce;

    // from pc_reg to if_id
    wire[`InstAddrBus]      if_pc;

    // from if_id to id
    wire[`InstAddrBus]      if_id_pc;
    wire[`InstBus]          if_id_inst;


    // from id to id_ex
    wire[`InstAddrBus]      id_pc;
    wire[`InstBus]          id_inst;
    wire[`AluOpBus]         id_aluop;
    wire[`AluSelBus]        id_alusel;
    wire[`RegBus]           id_reg1;
    wire[`RegBus]           id_reg2;
    wire                    id_wreg;
    wire[`RegAddrBus]       id_wd;
    wire                    id_wcsr_reg;
    wire[`RegBus]           id_csr_reg;
    wire[`DataAddrBus]      id_wd_csr_reg;

    // from id_ex to ex
    wire[`InstAddrBus]      id_ex_pc;
    wire[`InstBus]          id_ex_inst;
    wire[`AluOpBus]         id_ex_aluop;
    wire[`AluSelBus]        id_ex_alusel;
    wire[`RegBus]           id_ex_reg1;
    wire[`RegBus]           id_ex_reg2;
    wire                    id_ex_wreg;
    wire[`RegAddrBus]       id_ex_wd;
    wire                    id_ex_wcsr_reg;
    wire[`RegBus]           id_ex_csr_reg;
    wire[`DataAddrBus]      id_ex_wd_csr_reg;

    // from ex to ex_mem
    wire                    ex_wreg;
    wire[`RegAddrBus]       ex_wd;
    wire[`RegBus]           ex_wdata;

    wire[`AluOpBus]         ex_aluop;
    wire[`DataAddrBus]      ex_memaddr;
    wire[`RegBus]           ex_reg2;

    // from mul_div to ex
    wire[`DoubleRegBus]     muldiv_result;
    wire                    muldiv_done;

    // from ex to mul_div    
    wire   enable_in;
    wire   [31 : 0]  dividend;        
    wire   [31 : 0]  divisor;        
    wire   mul0_div1;
    wire   x_signed0_unsigned1;
    wire   y_signed0_unsigned1;

    // branch info from ex
    wire                    ex_branch_flag;
    wire[`RegBus]           ex_branch_addr;


    // csr_reg
    wire[`RegBus]           csr_reg_data;
    wire[`RegBus]           csr_interrupt_data;

    wire[`RegBus]           csr_mtvec;    
    wire[`RegBus]           csr_mepc;     
    wire[`RegBus]           csr_mstatus; 

    wire global_int_en;
    
    // id to csr
    wire[`DataAddrBus]      id_csr_reg_addr;
    // ex to csr 
    wire                    ex_wcsr_reg;
    wire[`DataAddrBus]      ex_wd_csr_reg;
    wire[`RegBus]           ex_wcsr_data;

    // from ex_mem to mem
    wire                    ex_mem_wreg;
    wire[`RegAddrBus]       ex_mem_wd;
    wire[`RegBus]           ex_mem_wdata;

    wire[`AluOpBus]         ex_mem_aluop;
    wire[`DataAddrBus]      ex_mem_memaddr;
    wire[`RegBus]           ex_mem_reg2;

    // from mem to mem_wb
    wire                    mem_wreg;
    wire[`RegAddrBus]       mem_wd;
    wire[`RegBus]           mem_wdata;


    // from mem_wb (wb) to regsfile
    wire                    wb_wreg;
    wire[`RegAddrBus]       wb_wd;
    wire[`RegBus]           wb_wdata;

    // from id to regsfile
    wire                    id_reg1_read;
    wire                    id_reg2_read;
    wire[`RegAddrBus]       id_reg1_addr;
    wire[`RegAddrBus]       id_reg2_addr;
    
    // from regsfile to id
    wire[`RegBus]           reg1_data;
    wire[`RegBus]           reg2_data;

    // ctrl
    wire[4:0]               stall;  
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


    pc_reg u_pc_reg(
        .clk                (clk),
        .rst                (rst),

        // from mem
        .PCchange_enable_i  (~ram_ce),

        // from ex
        .branch_flag_i      (ex_branch_flag),
        .branch_addr_i      (ex_branch_addr),

        // from ctrl
        .stalled            (stall),

        // to if_id
        .pc_o               (if_pc),

        // to cpu_ahb_if
        .ce_o               (rom_ce)
    );

    assign  rom_addr_o  =  if_pc;  // 指令存储器的输入地址就是 pc 的值


    if_id u_if_id(
        .clk                (clk),
        .rst                (rst),

        // from pc_reg
        .pc_i               (if_pc),

        // from cpu_ahb_if
        .inst_i             (rom_data),

        // from ex
        .ex_branch_flag_i   (ex_branch_flag),

        // from ctrl
        .stalled            (stall),

        // to id
        .pc_o               (if_id_pc),
        .inst_o             (if_id_inst)
    );


    id u_id(
        // from if_id
        .pc_i               (if_id_pc),
        .inst_i             (if_id_inst),
        
        // from regsfile
        .reg1_data_i        (reg1_data),
        .reg2_data_i        (reg2_data),

        // from ex
        .ex_wreg_i          (ex_wreg),
        .ex_wdata_i         (ex_wdata),
        .ex_wd_i            (ex_wd),
        .ex_branch_flag_i   (ex_branch_flag),
        .ex_aluop_i         (ex_aluop),

        // from mem
        .mem_wreg_i         (mem_wreg),
        .mem_wdata_i        (mem_wdata),
        .mem_wd_i           (mem_wd),

        // from csr_reg
        .csr_reg_data_i     (csr_reg_data),

        // to csr_reg
        .csr_reg_addr_o     (id_csr_reg_addr),

        // to regsfile
        .reg1_read_o        (id_reg1_read),
        .reg2_read_o        (id_reg2_read),
        .reg1_addr_o        (id_reg1_addr),
        .reg2_addr_o        (id_reg2_addr),

        // to ctrl
        .stallreq           (stallreq_from_id),

        // to id_ex
        .pc_o               (id_pc),
        .inst_o             (id_inst),
        .aluop_o            (id_aluop),
        .alusel_o           (id_alusel),
        .reg1_o             (id_reg1),
        .reg2_o             (id_reg2),
        .reg_wd_o           (id_wd),
        .wreg_o             (id_wreg),
        .wcsr_reg_o         (id_wcsr_reg),
        .csr_reg_o          (id_csr_reg),
        .wd_csr_reg_o       (id_wd_csr_reg)
    );


    regsfile u_regsfile(
        .clk                (clk),
        .rst                (rst),
        //
        .int_assert_i       (interrupt_int_assert_o),

        // from mem_wb (wb)
        .we_i               (wb_wreg),
        .waddr_i            (wb_wd),
        .wdata_i            (wb_wdata),

        // from id
        .re1_i              (id_reg1_read),
        .raddr1_i           (id_reg1_addr),
        .rdata1_o           (reg1_data),

        .re2_i              (id_reg2_read),
        .raddr2_i           (id_reg2_addr),
        .rdata2_o           (reg2_data)
    );


    id_ex u_id_ex(
        .clk                (clk),
        .rst                (rst),

        // from id
        .id_pc_i            (id_pc),
        .id_inst_i          (id_inst),
        .id_aluop           (id_aluop),
        .id_alusel          (id_alusel),
        .id_reg1            (id_reg1),
        .id_reg2            (id_reg2),
        .id_wd              (id_wd),
        .id_wreg            (id_wreg),
        .id_wcsr_reg        (id_wcsr_reg),
        .id_csr_reg         (id_csr_reg),
        .id_wd_csr_reg      (id_wd_csr_reg),

        // from ex
        .ex_branch_flag_i   (ex_branch_flag),
        
        // from ctrl
        .stalled            (stall),

        // to ex
        .ex_pc_o            (id_ex_pc),
        .ex_inst_o          (id_ex_inst),
        .ex_aluop           (id_ex_aluop),
        .ex_alusel          (id_ex_alusel),
        .ex_reg1            (id_ex_reg1),
        .ex_reg2            (id_ex_reg2),
        .ex_wd              (id_ex_wd),
        .ex_wreg            (id_ex_wreg),
        .ex_wcsr_reg        (id_ex_wcsr_reg),
        .ex_csr_reg         (id_ex_csr_reg),
        .ex_wd_csr_reg      (id_ex_wd_csr_reg)
    );


    ex u_ex(
        //
        .int_assert_i(interrupt_int_assert_o),
        .int_addr_i(interrupt_int_addr_o),

        // from id_ex
        .ex_pc              (id_ex_pc),
        .ex_inst            (id_ex_inst),
        .aluop_i            (id_ex_aluop),
        .alusel_i           (id_ex_alusel),
        .reg1_i             (id_ex_reg1),
        .reg2_i             (id_ex_reg2),
        .wd_i               (id_ex_wd),
        .wreg_i             (id_ex_wreg),
        .wcsr_reg_i         (id_ex_wcsr_reg),
        .csr_reg_i          (id_ex_csr_reg),
        .wd_csr_reg_i       (id_ex_wd_csr_reg),
        
        // from mul_div
        .muldiv_result_i    (muldiv_result),
        .muldiv_done_i      (muldiv_done),
        
        //to mul_div
        .muldiv_start_o     (enable_in),
        .muldiv_dividend_o  (dividend),
        .muldiv_divisor_o   (divisor),
        .mul_or_div_o       (mul0_div1),
        .muldiv_reg1_signed0_unsigned1(x_signed0_unsigned1),
        .muldiv_reg2_signed0_unsigned1(y_signed0_unsigned1),

        // to ex_mem
        .wd_o               (ex_wd),
        .wreg_o             (ex_wreg),
        .wdata_o            (ex_wdata),

        .ex_aluop_o         (ex_aluop),
        .ex_mem_addr_o      (ex_memaddr),
        .ex_reg2_o          (ex_reg2),

        // to csr reg
        .wcsr_reg_o         (ex_wcsr_reg),
        .wd_csr_reg_o       (ex_wd_csr_reg),
        .wcsr_data_o        (ex_wcsr_data),

        // branch info
        .branch_flag_o      (ex_branch_flag),
        .branch_addr_o      (ex_branch_addr)
    );

    mul_div_32 u_mul_div_32(
        .clk                    ( clk                   ),
        .reset_n                ( rst                  ),
        .enable_in              ( enable_in             ),
        .x                      ( dividend              ),
        .y                      ( divisor               ),
        .mul0_div1              ( mul0_div1             ),
        .x_signed0_unsigned1    ( x_signed0_unsigned1   ),
        .y_signed0_unsigned1    ( y_signed0_unsigned1   ),
        .enable_out             ( muldiv_done           ),
        .z                      ( muldiv_result         )
        // .ov                     ( ov                    )
    );



    ex_mem u_ex_mem(
        .clk                    (clk),
        .rst                    (rst),

        // from ex
        .ex_wd                  (ex_wd),
        .ex_wreg                (ex_wreg),
        .ex_wdata               (ex_wdata),

        .ex_aluop_i             (ex_aluop),
        .ex_mem_addr_i          (ex_memaddr),
        .ex_reg2_i              (ex_reg2),

        // from ctrl
        .stalled                (stall),

        // to mem
        .mem_wd                 (ex_mem_wd),
        .mem_wreg               (ex_mem_wreg),
        .mem_wdata              (ex_mem_wdata),

        .mem_aluop              (ex_mem_aluop),
        .mem_mem_addr           (ex_mem_memaddr),
        .mem_reg2               (ex_mem_reg2)
    );


    mem u_mem(
        // from ex_mem
        .wd_i                   (ex_mem_wd),
        .wreg_i                 (ex_mem_wreg),
        .wdata_i                (ex_mem_wdata),

        .mem_aluop_i            (ex_mem_aluop),
        .mem_mem_addr_i         (ex_mem_memaddr),
        .mem_reg2_i             (ex_mem_reg2),

        //
        .int_assert_i(interrupt_int_assert_o),
        
        // to mem_wd
        .wd_o                   (mem_wd),
        .wreg_o                 (mem_wreg),
        .wdata_o                (mem_wdata),

        // from ram
        .mem_data_i             (ram_rdata),
        
        // to ram
        .mem_addr_o             (ram_addr),
        .mem_we_o               (ram_we),
        .mem_data_o             (ram_wdata),
        .mem_sel_o              (ram_sel),
        .mem_ce_o               (ram_ce)
    );

    
    mem_wb u_mem_wb(
        .clk                    (clk),
        .rst                    (rst),

        // from mem
        .mem_wd                 (mem_wd),
        .mem_wreg               (mem_wreg),
        .mem_wdata              (mem_wdata),

        // from ctrl
        .stalled                (stall),

        // to regsfile (wb)
        .wb_wreg                (wb_wreg),
        .wb_wd                  (wb_wd),
        .wb_wdata               (wb_wdata)
    );

    
    csr_reg u_csr_reg(
        .clk                    (clk),
        .rst                    (rst),

        // from ex
        .we_i                   (ex_wcsr_reg),
        .waddr_i                (ex_wd_csr_reg),
        .wdata_i                (ex_wcsr_data),

        // from id
        .raddr_i                (id_csr_reg_addr),
        
        // to id
        .rdata_o                (csr_reg_data),

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
        .rst                        (rst),
        .stallreq_from_id_i         (stallreq_from_id),
        .stallreq_from_ex_i         (enable_in),
        .stallreq_from_mem_i        (stallreq_from_mem),
        .stallreq_from_if_i         (stallreq_from_if),
        .stallreq_from_interrupt_i  (stallreq_from_interrupt),

        // from ex
        .branch_flag_i              (ex_branch_flag),
        .stalled_o                  (stall)
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

    cpu_ahb_if u_cpu_ahb_if (
        .clk                     ( clk               ),
        .rst                     ( rst               ),
        .cpu_addr_i              ( rom_addr_o        ),
        .cpu_ce_i                ( rom_ce          ),
        .cpu_we_i                ( `WriteDisable      ),
        .cpu_writedata_i         ( `ZeroWord         ),
        .cpu_sel_i               ( 3'b010            ),
        .M_HGRANT                ( M1_HGRANT         ),
        .M_HRDATA                ( M_HRDATA          ),

        .cpu_readdata_o          ( rom_data           ),
        .M_HBUSREQ               ( M1_HBUSREQ         ),
        .M_HADDR                 ( M1_HADDR           ),
        .M_HTRANS                ( M1_HTRANS          ),
        .M_HSIZE                 ( M1_HSIZE           ),
        .M_HBURST                ( M1_HBURST          ),
        .M_HWRITE                ( M1_HWRITE          ),
        .M_HWDATA                ( M1_HWDATA          ),
        .stallreq                ( stallreq_from_if          )
);

    cpu_ahb_mem u_cpu_ahb_mem (
        .clk                     ( clk               ),
        .rst                     ( rst               ),
        .cpu_addr_i              ( ram_addr        ),
        .cpu_ce_i                ( ram_ce          ),
        .cpu_we_i                ( ram_we          ),
        .cpu_writedata_i         ( ram_wdata   ),
        .cpu_sel_i               ( ram_sel         ),
        .M_HGRANT                ( M0_HGRANT          ),
        .M_HRDATA                ( M_HRDATA          ),
        .M_HREADY                (M_HREADY           ),

        .cpu_readdata_o          ( ram_rdata    ),
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
