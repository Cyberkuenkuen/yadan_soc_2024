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
    input  wire             clk,
    input  wire             rst_n,
    input  wire [`INT_BUS]  int_flag_i,

    output wire             M0_HBUSREQ,     //主机0请求总线，1使能
    input  wire             M0_HGRANT,      //仲裁器返回的授权信号，1使能，一个周期
    output wire  [31:0]     M0_HADDR,       //主机0地址
    output wire  [ 1:0]     M0_HTRANS,      //主机0传输类型：NONSEQ, SEQ, IDLE, BUSY
    output wire  [ 2:0]     M0_HSIZE,       //主机0的数据大小：000.8位，001.16位，010.32位
    output wire  [ 2:0]     M0_HBURST,      //主机0批量传输，000单笔传输
    output wire  [ 3:0]     M0_HPROT,       //保护控制
    output wire             M0_HLOCK,       //总线锁定
    output wire             M0_HWRITE,      //写，1使能，0读
    output wire  [31:0]     M0_HWDATA,      //写数据

    output wire             M1_HBUSREQ,
    input  wire             M1_HGRANT,
    output wire  [31:0]     M1_HADDR,
    output wire  [ 1:0]     M1_HTRANS,
    output wire  [ 2:0]     M1_HSIZE,
    output wire  [ 2:0]     M1_HBURST,
    output wire  [ 3:0]     M1_HPROT,
    output wire             M1_HLOCK,
    output wire             M1_HWRITE,
    output wire  [31:0]     M1_HWDATA,

    input  wire  [31:0]     M_HRDATA,       //总线读回数据
    input  wire  [ 1:0]     M_HRESP,        //从机返回的总线传输状态 00 ok
    input  wire             M_HREADY        //1表示传输结束
);

    assign  M0_HPROT = 4'h0;            //保护控制
    assign  M1_HPROT = 4'h0;
    assign  M0_HLOCK = 1'b0;            //主机锁定总线
    assign  M1_HLOCK = 1'b0;
    
    // inst rom and data ram
    wire[`RegBus]           rom_addr;   // from pc_reg(pc_o) to cpu_ahb_if
    wire                    rom_ce;     // from pc_reg(ce_o) to cpu_ahb_if
    wire[`RegBus]           rom_data;   // from cpu_ahb_if to if_id(inst_i)

    wire[`RegBus]           ram_addr;   // from mem to cpu_ahb_mem
    wire                    ram_ce;
    wire                    ram_we;
    wire[2:0]               ram_sel;
    wire[`RegBus]           ram_wdata;
    wire[`RegBus]           ram_rdata;  // from cpu_ahb_mem to mem

    // from pc_reg to if_id
    wire[`InstAddrBus]      if_pc;

    // from if_id to id
    wire[`InstAddrBus]      if_id_pc;
    wire[`InstBus]          if_id_inst;
    
    // from id to regsfile
    wire                    id_reg1_read;
    wire                    id_reg2_read;
    wire[`RegAddrBus]       id_reg1_addr;
    wire[`RegAddrBus]       id_reg2_addr;
    
    // from regsfile to id
    wire[`RegBus]           reg1_data;
    wire[`RegBus]           reg2_data;
    
    // from id to id_ex
    wire[`InstAddrBus]      id_pc;
    wire[`InstBus]          id_inst;
    wire[`AluOpBus]         id_aluop;
    wire[`AluSelBus]        id_alusel;
    wire[`RegBus]           id_operand1;
    wire[`RegBus]           id_operand2;
    wire                    id_wreg;
    wire[`RegAddrBus]       id_wreg_addr;
    wire                    id_wcsr;
    wire[`RegBus]           id_csr_data;
    wire[`DataAddrBus]      id_wcsr_addr;

    // from id_ex to ex
    wire[`InstAddrBus]      id_ex_pc;
    wire[`InstBus]          id_ex_inst;
    wire[`AluOpBus]         id_ex_aluop;
    wire[`AluSelBus]        id_ex_alusel;
    wire[`RegBus]           id_ex_operand1;
    wire[`RegBus]           id_ex_operand2;
    wire                    id_ex_wreg;
    wire[`RegAddrBus]       id_ex_wreg_addr;
    wire                    id_ex_wcsr;
    wire[`RegBus]           id_ex_csr_data;
    wire[`DataAddrBus]      id_ex_wcsr_addr;

    // from ex to mul_div    
    wire                    muldiv_start;
    wire[`RegBus]           dividend;        
    wire[`RegBus]           divisor;        
    wire                    mul0_div1;
    wire                    x_signed0_unsigned1;
    wire                    y_signed0_unsigned1;

    // from mul_div to ex
    wire[`DoubleRegBus]     muldiv_result;
    wire                    muldiv_done;

    // branch info from ex
    wire                    ex_branch_flag;
    wire[`RegBus]           ex_branch_addr;

    // from ex to ex_mem
    wire                    ex_wreg;
    wire[`RegAddrBus]       ex_wreg_addr;
    wire[`RegBus]           ex_wreg_data;

    wire[`AluOpBus]         ex_aluop;
    wire[`DataAddrBus]      ex_memaddr;
    wire[`RegBus]           ex_operand2;

    // from ex_mem to mem
    wire                    ex_mem_wreg;
    wire[`RegAddrBus]       ex_mem_wreg_addr;
    wire[`RegBus]           ex_mem_wreg_data;

    wire[`AluOpBus]         ex_mem_aluop;
    wire[`DataAddrBus]      ex_mem_memaddr;
    wire[`RegBus]           ex_mem_operand2;

    // from mem to mem_wb
    wire                    mem_wreg;
    wire[`RegAddrBus]       mem_wreg_addr;
    wire[`RegBus]           mem_wreg_data;

    // from mem_wb (wb) to regsfile
    wire                    wb_wreg;
    wire[`RegAddrBus]       wb_wreg_addr;
    wire[`RegBus]           wb_wreg_data;

    // ctrl
    wire[4:0]               stall;  
    wire[4:0]               flush;
    wire                    stallreq_from_id;
    wire                    stallreq_from_mem;
    wire                    stallreq_from_if;
    wire                    stallreq_from_interrupt;

    // csr_reg
    wire[`RegBus]           csr_data;
    wire[`RegBus]           csr_interrupt_data;

    wire[`RegBus]           csr_mtvec;    
    wire[`RegBus]           csr_mepc;     
    wire[`RegBus]           csr_mstatus; 

    wire global_int_en;
    
    // id to csr
    wire[`DataAddrBus]      id_rcsr_addr;
    
    // ex to csr 
    wire                    ex_wcsr;
    wire[`DataAddrBus]      ex_wcsr_addr;
    wire[`RegBus]           ex_wcsr_data;

    // interrupt 模块输出
    wire interrupt_we_o;
    wire[`DataAddrBus] interrupt_waddr_o;
    wire[`RegBus] interrupt_data_o;
    wire[`InstAddrBus] interrupt_int_addr_o;
    wire interrupt_int_assert_o;


    pc_reg u_pc_reg(
        .clk                (clk),
        .rst_n              (rst_n),

        // from mem
        .PCchange_enable_i  (~ram_ce),

        // from ex
        .ex_branch_flag_i   (ex_branch_flag),
        .ex_branch_addr_i   (ex_branch_addr),

        // from ctrl
        .stalled_i          (stall[0]),
        .flush_i            (flush[0]),

        // to if_id
        .pc_o               (if_pc),

        // to cpu_ahb_if
        .ce_o               (rom_ce)
    );

    assign  rom_addr  =  if_pc;  // 指令存储器的输入地址就是 pc 的值

    if_id u_if_id(
        .clk                (clk),
        .rst_n              (rst_n),

        // from pc_reg
        .pc_i               (if_pc),

        // from cpu_ahb_if
        .inst_i             (rom_data),

        // from ex
        // .ex_branch_flag_i   (ex_branch_flag),

        // from ctrl
        .stalled_i          (stall[1]),
        .flush_i            (flush[1]),

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
        .ex_wreg_addr_i     (ex_wreg_addr),
        .ex_wreg_data_i     (ex_wreg_data),
        // .ex_branch_flag_i   (ex_branch_flag),
        .ex_aluop_i         (ex_aluop),

        // from mem
        .mem_wreg_i         (mem_wreg),
        .mem_wreg_addr_i    (mem_wreg_addr),
        .mem_wreg_data_i    (mem_wreg_data),

        // from csr_reg
        .csr_data_i         (csr_data),

        // to csr_reg
        .rcsr_addr_o        (id_rcsr_addr),

        // to regsfile
        .reg1_read_o        (id_reg1_read),
        .reg2_read_o        (id_reg2_read),
        .reg1_addr_o        (id_reg1_addr),
        .reg2_addr_o        (id_reg2_addr),

        // to ctrl
        .stallreq_o         (stallreq_from_id),

        // to id_ex
        .pc_o               (id_pc),
        .inst_o             (id_inst),
        .aluop_o            (id_aluop),
        .alusel_o           (id_alusel),
        .operand1_o         (id_operand1),
        .operand2_o         (id_operand2),
        .wreg_o             (id_wreg),
        .wreg_addr_o        (id_wreg_addr),

        .csr_data_o         (id_csr_data),
        .wcsr_o             (id_wcsr),
        .wcsr_addr_o        (id_wcsr_addr)
    );


    regsfile u_regsfile(
        .clk                (clk),
        .rst_n              (rst_n),
        //
        .int_assert_i       (interrupt_int_assert_o),

        // from mem_wb (wb)
        .we_i               (wb_wreg),
        .waddr_i            (wb_wreg_addr),
        .wdata_i            (wb_wreg_data),

        // from/to id
        .re1_i              (id_reg1_read),
        .raddr1_i           (id_reg1_addr),
        .rdata1_o           (reg1_data),

        .re2_i              (id_reg2_read),
        .raddr2_i           (id_reg2_addr),
        .rdata2_o           (reg2_data)
    );


    id_ex u_id_ex(
        .clk                (clk),
        .rst_n              (rst_n),

        // from id
        .id_pc_i            (id_pc),
        .id_inst_i          (id_inst),
        .id_aluop_i         (id_aluop),
        .id_alusel_i        (id_alusel),
        .id_operand1_i      (id_operand1),
        .id_operand2_i      (id_operand2),
        .id_wreg_i          (id_wreg),
        .id_wreg_addr_i     (id_wreg_addr),

        .id_csr_data_i      (id_csr_data),
        .id_wcsr_i          (id_wcsr),
        .id_wcsr_addr_i     (id_wcsr_addr),

        // from ex
        // .ex_branch_flag_i   (ex_branch_flag),
        
        // from ctrl
        .stalled_i          (stall[2]),
        .flush_i            (flush[2]),

        // to ex
        .ex_pc_o            (id_ex_pc),
        .ex_inst_o          (id_ex_inst),
        .ex_aluop_o         (id_ex_aluop),
        .ex_alusel_o        (id_ex_alusel),
        .ex_operand1_o      (id_ex_operand1),
        .ex_operand2_o      (id_ex_operand2),
        .ex_wreg_o          (id_ex_wreg),
        .ex_wreg_addr_o     (id_ex_wreg_addr),

        .ex_csr_data_o      (id_ex_csr_data),
        .ex_wcsr_o          (id_ex_wcsr),
        .ex_wcsr_addr_o     (id_ex_wcsr_addr)
    );


    ex u_ex(
        //
        .int_assert_i(interrupt_int_assert_o),
        .int_addr_i(interrupt_int_addr_o),

        // from id_ex
        .pc_i               (id_ex_pc),
        .inst_i             (id_ex_inst),
        .aluop_i            (id_ex_aluop),
        .alusel_i           (id_ex_alusel),
        .operand1_i         (id_ex_operand1),
        .operand2_i         (id_ex_operand2),
        .wreg_i             (id_ex_wreg),
        .wreg_addr_i        (id_ex_wreg_addr),

        .csr_data_i         (id_ex_csr_data),
        .wcsr_i             (id_ex_wcsr),
        .wcsr_addr_i        (id_ex_wcsr_addr),
        
        // from mul_div
        .muldiv_result_i    (muldiv_result),
        .muldiv_done_i      (muldiv_done),
        
        // to mul_div
        .muldiv_start_o     (muldiv_start),
        .muldiv_dividend_o  (dividend),
        .muldiv_divisor_o   (divisor),
        .mul_or_div_o       (mul0_div1),
        .muldiv_reg1_sign_o (x_signed0_unsigned1),
        .muldiv_reg2_sign_o (y_signed0_unsigned1),

        // to ex_mem
        .wreg_o             (ex_wreg),
        .wreg_addr_o        (ex_wreg_addr),
        .wreg_data_o        (ex_wreg_data),

        .aluop_o            (ex_aluop),
        .memaddr_o          (ex_memaddr),
        .operand2_o         (ex_operand2),
    
        // to csr_reg
        .wcsr_o             (ex_wcsr),
        .wcsr_addr_o        (ex_wcsr_addr),
        .wcsr_data_o        (ex_wcsr_data),

        // branch info
        .branch_flag_o      (ex_branch_flag),
        .branch_addr_o      (ex_branch_addr)
    );


    mul_div_32 u_mul_div_32(
        .clk                (clk),
        .reset_n            (rst_n),
        // input
        .enable_in          (muldiv_start),
        .x                  (dividend),
        .y                  (divisor),
        .mul0_div1          (mul0_div1),
        .x_signed0_unsigned1(x_signed0_unsigned1),
        .y_signed0_unsigned1(y_signed0_unsigned1),
        // output
        .enable_out         (muldiv_done),
        .z                  (muldiv_result)
        // .ov                     (ov)
    );


    ex_mem u_ex_mem(
        .clk                (clk),
        .rst_n              (rst_n),

        // from ex
        .ex_wreg_i          (ex_wreg),
        .ex_wreg_addr_i     (ex_wreg_addr),
        .ex_wreg_data_i     (ex_wreg_data),

        .ex_aluop_i         (ex_aluop),
        .ex_memaddr_i       (ex_memaddr),
        .ex_operand2_i      (ex_operand2),

        // from ctrl
        .stalled_i          (stall[3]),
        .flush_i            (flush[3]),

        // to mem
        .mem_wreg_o         (ex_mem_wreg),
        .mem_wreg_addr_o    (ex_mem_wreg_addr),
        .mem_wreg_data_o    (ex_mem_wreg_data),

        .mem_aluop_o        (ex_mem_aluop),
        .mem_memaddr_o      (ex_mem_memaddr),
        .mem_operand2_o     (ex_mem_operand2)
    );


    mem u_mem(
        // from ex_mem
        .wreg_i             (ex_mem_wreg),
        .wreg_addr_i        (ex_mem_wreg_addr),
        .wreg_data_i        (ex_mem_wreg_data),

        .aluop_i            (ex_mem_aluop),
        .memaddr_i          (ex_mem_memaddr),
        .operand2_i         (ex_mem_operand2),

        //
        .int_assert_i(interrupt_int_assert_o),

        // from cpu_ahb_mem
        .ram_data_i         (ram_rdata),
        
        // to cpu_ahb_mem
        .ram_addr_o         (ram_addr),
        .ram_we_o           (ram_we),
        .ram_data_o         (ram_wdata),
        .ram_sel_o          (ram_sel),
        .ram_ce_o           (ram_ce),
                
        // to mem_wb
        .wreg_o             (mem_wreg),
        .wreg_addr_o        (mem_wreg_addr),
        .wreg_data_o        (mem_wreg_data)
    );

    
    mem_wb u_mem_wb(
        .clk                (clk),
        .rst_n              (rst_n),

        // from mem
        .mem_wreg_i         (mem_wreg),
        .mem_wreg_addr_i    (mem_wreg_addr),
        .mem_wreg_data_i    (mem_wreg_data),

        // from ctrl
        .stalled_i          (stall[4]),
        .flush_i            (flush[4]),

        // to regsfile (wb)
        .wb_wreg_o          (wb_wreg),
        .wb_wreg_addr_o     (wb_wreg_addr),
        .wb_wreg_data_o     (wb_wreg_data)
    );


    ctrl u_ctrl(
        .stallreq_from_id_i         (stallreq_from_id),
        .stallreq_from_ex_i         (muldiv_start),
        .stallreq_from_mem_i        (stallreq_from_mem),
        .stallreq_from_if_i         (stallreq_from_if),
        .stallreq_from_interrupt_i  (stallreq_from_interrupt),

        .ex_branch_flag_i           (ex_branch_flag),   // from ex

        .stalled_o                  (stall),
        .flush_o                    (flush)
    );
    

    csr_reg u_csr_reg(
        .clk                (clk),
        .rst_n              (rst_n),

        // from ex
        .we_i               (ex_wcsr),
        .waddr_i            (ex_wcsr_addr), 
        .wdata_i            (ex_wcsr_data),

        // from id
        .raddr_i            (id_rcsr_addr),
        
        // to id
        .rdata_o            (csr_data),
        
        // to interrupt_ctrl
        .global_int_en_o        (global_int_en),
        .interrupt_csr_mtvec    (csr_mtvec),
        .interrupt_csr_mepc     (csr_mepc),
        .interrupt_csr_mstatus  (csr_mstatus),
        // .interrupt_data_o       (csr_interrupt_data),

        // from interrupt_ctrl
        .interrupt_we_i(interrupt_we_o),
        // .interrupt_raddr_i(interrupt_raddr),
        .interrupt_waddr_i(interrupt_waddr_o),
        .interrupt_data_i(interrupt_data_o)
    );

    
    // assign interrupt_int_assert_o = 0;

   interrupt_ctrl u_interrupt_ctrl(
        .clk                (clk),
        .rst_n              (rst_n),
        
        // top input
        .int_flag_i         (int_flag_i),
        
        // from id
        .inst_i             (id_inst),
        .inst_addr_i        (id_pc),
        
        // from ex
        .branch_flag_i      (ex_branch_flag),
        .branch_addr_i      (ex_branch_addr),
        .muldiv_start_i     (muldiv_start),

        // from csr_reg
        .global_int_en_i    (global_int_en),
        .csr_mtvec          (csr_mtvec),
        .csr_mepc           (csr_mepc),
        .csr_mstatus        (csr_mstatus),
        // .data_i             (csr_interrupt_data),

        // to csr_reg
        .we_o               (interrupt_we_o),
        .waddr_o            (interrupt_waddr_o),
        // .raddr_o            (interrupt_raddr),
        .data_o             (interrupt_data_o),
        .int_addr_o         (interrupt_int_addr_o),
        .int_assert_o       (interrupt_int_assert_o),
        
        // to ctrl
        .stallreq_interrupt_o(stallreq_from_interrupt)
   );

    cpu_ahb_if u_cpu_ahb_if(
        .clk                (clk),
        .rst_n              (rst_n),
        .cpu_addr_i         (rom_addr),
        .cpu_ce_i           (rom_ce),
        .cpu_we_i           (`WriteDisable),
        .cpu_writedata_i    (`ZeroWord),
        .cpu_sel_i          (3'b010),
        .M_HGRANT           (M1_HGRANT),
        .M_HRDATA           (M_HRDATA),

        .cpu_readdata_o     (rom_data),
        .M_HBUSREQ          (M1_HBUSREQ),
        .M_HADDR            (M1_HADDR),
        .M_HTRANS           (M1_HTRANS),
        .M_HSIZE            (M1_HSIZE),
        .M_HBURST           (M1_HBURST),
        .M_HWRITE           (M1_HWRITE),
        .M_HWDATA           (M1_HWDATA),
        .stallreq           (stallreq_from_if)
    );

    cpu_ahb_mem u_cpu_ahb_mem(
        .clk                (clk),
        .rst_n              (rst_n),
        .cpu_addr_i         (ram_addr),
        .cpu_ce_i           (ram_ce),
        .cpu_we_i           (ram_we),
        .cpu_writedata_i    (ram_wdata),
        .cpu_sel_i          (ram_sel),
        .M_HGRANT           (M0_HGRANT),
        .M_HRDATA           (M_HRDATA),
        .M_HREADY           (M_HREADY),

        .cpu_readdata_o     (ram_rdata),
        .M_HBUSREQ          (M0_HBUSREQ),
        .M_HADDR            (M0_HADDR),
        .M_HTRANS           (M0_HTRANS),
        .M_HSIZE            (M0_HSIZE),
        .M_HBURST           (M0_HBURST),
        .M_HWRITE           (M0_HWRITE),
        .M_HWDATA           (M0_HWDATA),
        .stallreq           (stallreq_from_mem)
    );


endmodule // yadan_riscv
