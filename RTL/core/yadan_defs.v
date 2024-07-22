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


//******    全局宏定义   *******//
`define RstEnable               1'b0            // 复位信号
`define RstDisable              1'b1
`define Enable                  1'b1
`define Disable                 1'b0
`define ZeroWord                32'h00000000    // 32位的数值0
`define WriteEnable             1'b1            
`define WriteDisable            1'b0    
`define ReadEnable              1'b1
`define ReadDisable             1'b0
`define AluOpBus                5:0             //译码阶段的输出 aluop_o 宽度
`define AluSelBus               3:0             //译码阶段的输出 alusel_o 宽度
`define InstValid               1'b1
`define InstInvalid             1'b0
`define True_v                  1'b1
`define False_v                 1'b0
`define BranchEnable            1'b1
`define BranchDisable           1'b0
`define ChipEnable              1'b1
`define ChipDisable             1'b0
`define Stop                    1'b1
`define NoStop                  1'b0
`define Signed                  1'b0
`define Unsigned                1'b1
// `define StartAdd                32'h0001008c
`define StartAdd                32'h00000000
`define INSTADD_END             32'h00018000

//******    与具体指令相关的宏定义    ******//
`define INST_I_TYPE             7'b0010011      // I-type 指令
`define INST_ADDI               3'b000          // addi
`define INST_SLTI               3'b010          // slti
`define INST_SLTIU              3'b011          // sltiu
`define INST_XORI               3'b100          // xori
`define INST_ORI                3'b110          // ori 指令
`define INST_ANDI               3'b111          // andi
`define INST_SLLI               3'b001          // slli
`define INST_SRI                3'b101          // srli  // [30]bit = 0
//`define INST_SRAI             3'b101          // srai  // [30]bit = 1 需要根据 [31:25]来区分 srli 和 srai  其实就是 第 30 位

`define INST_R_TYPE             7'b0110011      // R-type inst
`define INST_ADD                3'b000          // add   // [30]bit = 0
//`define INST_SUB              3'b000          // sub   // [30]bit = 1 
`define INST_SLL                3'b001          // sll 
`define INST_SLT                3'b010          // slt
`define INST_SLTU               3'b011          // sltu
`define INST_XOR                3'b100          // xor
`define INST_SRL                3'b101          // srl   // [30]bit = 0
//`define INST_SRA              3'b101          // sra   // [30]bit = 1
`define INST_OR                 3'b110          // or
`define INST_AND                3'b111          // and

// M type inst
`define INST_MUL                3'b000          //乘法，忽略溢出
`define INST_MULH               3'b001
`define INST_MULHSU             3'b010
`define INST_MULHU              3'b011
`define INST_DIV                3'b100
`define INST_DIVU               3'b101
`define INST_REM                3'b110
`define INST_REMU               3'b111

`define INST_B_TYPE             7'b1100011      // B-type inst
`define INST_BEQ                3'b000          // beq
`define INST_BNE                3'b001          // bne
`define INST_BLT                3'b100          // blt
`define INST_BGE                3'b101          // bge
`define INST_BLTU               3'b110          // bltu
`define INST_BGEU               3'b111          // bgeu

`define INST_JAL                7'b1101111      // J-type inst //jal
`define INST_JALR               7'b1100111      // jalr

`define INST_LUI                7'b0110111      // lui  U-type inst
`define INST_AUIPC              7'b0010111      // auipc

`define INST_L_TYPE             7'b0000011      // I-type Load inst 
`define INST_LB                 3'b000          // lb
`define INST_LH                 3'b001          // lh
`define INST_LW                 3'b010          // lw
`define INST_LBU                3'b100          // lbu
`define INST_LHU                3'b101          // lhu

`define INST_S_TYPE             7'b0100011      // S-type store inst
`define INST_SB                 3'b000          // sb
`define INST_SH                 3'b001          // sh
`define INST_SW                 3'b010          // sw

`define INST_F_TYPE             7'b0001111      // fence inst
`define INST_F                  3'b000          // fence
`define INST_FI                 3'b001          // fence.i

`define INST_CSR_TYPE           7'b1110011      // csr inst
`define INST_ECALL              32'h73//3'b000          // ecall  [20]bit 为 0
`define INST_EBR                32'h00100073//3'b000          // ebreak [20]bit 为 1
`define INST_CSRRW              3'b001          // csrrw
`define INST_CSRRS              3'b010          // csrrs
`define INST_CSRRC              3'b011          // csrrc
`define INST_CSRRWI             3'b101          // csrrwi
`define INST_CSRRSI             3'b110          // csrrsi
`define INST_CSRRCI             3'b111          // csrrci

`define INST_NONE               7'b0000000

`define INST_MRET   32'h30200073
`define INST_RET    32'h00008067

//******    执行时对应的指令进行操作相关宏定义  *******//
//AluOp
`define EXE_NONE                6'b000000
`define EXE_ADD                 6'b000001
`define EXE_SUB                 6'b000010
`define EXE_AND                 6'b000011
`define EXE_OR                  6'b000100
`define EXE_XOR                 6'b000101 
`define EXE_SLL                 6'b000110
`define EXE_SRL                 6'b000111
`define EXE_SRA                 6'b001000

`define EXE_SLT                 6'b001001
`define EXE_SLTU                6'b001010 

`define EXE_LUI                 6'b001011 
 
`define EXE_BEQ                 6'b001100
`define EXE_BNE                 6'b001101
`define EXE_BLT                 6'b001110
`define EXE_BGE                 6'b001111
`define EXE_BLTU                6'b010000
`define EXE_BGEU                6'b010001
`define EXE_JAL                 6'b010010
`define EXE_JALR                6'b010011

`define EXE_LB                  6'b010100
`define EXE_LH                  6'b010101
`define EXE_LW                  6'b010110
`define EXE_LBU                 6'b010111
`define EXE_LHU                 6'b011000

`define EXE_SB                  6'b011001
`define EXE_SH                  6'b011010
`define EXE_SW                  6'b011011

`define EXE_CSRRW               6'b011100    // csrrw\csrrwi
`define EXE_CSRRS               6'b011101    // csrrs\csrrsi
`define EXE_CSRRC               6'b011110    // csrrc\csrrci

`define EXE_MUL                 6'b011111
`define EXE_MULH                6'b100000
`define EXE_MULHSU              6'b100001
`define EXE_MULHU               6'b100010
`define EXE_DIV                 6'b100011
`define EXE_DIVU                6'b100100
`define EXE_REM                 6'b100101
`define EXE_REMU                6'b100110

//AluSel
`define EXE_RES_LOGIC           4'b0001
`define EXE_RES_SHIFT           4'b0010
`define EXE_RES_ARITH           4'b0011
`define EXE_RES_COMPARE         4'b0100
`define EXE_RES_LOAD            4'b0101
`define EXE_RES_STORE           4'b0110
`define EXE_RES_BRANCH          4'b0111
`define EXE_RES_CSR             4'b1000

`define EXE_RES_NONE            4'b0000

//************  define csr registers  ***************//
//--------------------------------------------------------------------
// CSR Registers - Simulation control
//--------------------------------------------------------------------
`define CSR_DSCRATCH       12'h7b2
`define CSR_SIM_CTRL       12'h8b2
`define CSR_SIM_CTRL_MASK  32'hFFFFFFFF
    `define CSR_SIM_CTRL_EXIT (0 << 24)
    `define CSR_SIM_CTRL_PUTC (1 << 24)

//--------------------------------------------------------------------
// CSR Registers
//--------------------------------------------------------------------
`define CSR_MSTATUS       12'h300
`define CSR_MSTATUS_MASK  32'hFFFFFFFF
`define CSR_MISA          12'h301
`define CSR_MISA_MASK     32'hFFFFFFFF
    `define MISA_RV32     32'h40000000
    `define MISA_RVI      32'h00000100
    `define MISA_RVE      32'h00000010
    `define MISA_RVM      32'h00001000
    `define MISA_RVA      32'h00000001
    `define MISA_RVF      32'h00000020
    `define MISA_RVD      32'h00000008
    `define MISA_RVC      32'h00000004
    `define MISA_RVS      32'h00040000
    `define MISA_RVU      32'h00100000
`define CSR_MEDELEG       12'h302
`define CSR_MEDELEG_MASK  32'h0000FFFF
`define CSR_MIDELEG       12'h303
`define CSR_MIDELEG_MASK  32'h0000FFFF
`define CSR_MIE           12'h304
`define CSR_MIE_MASK      `IRQ_MASK
`define CSR_MTVEC         12'h305
`define CSR_MTVEC_MASK    32'hFFFFFFFF
`define CSR_MSCRATCH      12'h340
`define CSR_MSCRATCH_MASK 32'hFFFFFFFF
`define CSR_MEPC          12'h341
`define CSR_MEPC_MASK     32'hFFFFFFFF
`define CSR_MCAUSE        12'h342
`define CSR_MCAUSE_MASK   32'h8000000F
`define CSR_MTVAL         12'h343
`define CSR_MTVAL_MASK    32'hFFFFFFFF
`define CSR_MIP           12'h344
`define CSR_MIP_MASK      `IRQ_MASK
`define CSR_MCYCLE        12'hc00
`define CSR_MCYCLE_MASK   32'hFFFFFFFF
`define CSR_MCYCLEH       12'hc80
`define CSR_MCYCLEH_MASK  32'hFFFFFFFF
`define CSR_MTIME         12'hc01
`define CSR_MTIME_MASK    32'hFFFFFFFF
`define CSR_MTIMEH        12'hc81
`define CSR_MTIMEH_MASK   32'hFFFFFFFF
`define CSR_MHARTID       12'hF14
`define CSR_MHARTID_MASK  32'hFFFFFFFF

// Non-std
`define CSR_MTIMECMP        12'h7c0
`define CSR_MTIMECMP_MASK   32'hFFFFFFFF

//-----------------------------------------------------------------
// CSR Registers - Supervisor
//-----------------------------------------------------------------
`define CSR_SSTATUS       12'h100
`define CSR_SSTATUS_MASK  `SR_SMODE_MASK
`define CSR_SIE           12'h104
`define CSR_SIE_MASK      ((1 << `IRQ_S_EXT) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_S_SOFT))
`define CSR_STVEC         12'h105
`define CSR_STVEC_MASK    32'hFFFFFFFF
`define CSR_SSCRATCH      12'h140
`define CSR_SSCRATCH_MASK 32'hFFFFFFFF
`define CSR_SEPC          12'h141
`define CSR_SEPC_MASK     32'hFFFFFFFF
`define CSR_SCAUSE        12'h142
`define CSR_SCAUSE_MASK   32'h8000000F
`define CSR_STVAL         12'h143
`define CSR_STVAL_MASK    32'hFFFFFFFF
`define CSR_SIP           12'h144
`define CSR_SIP_MASK      ((1 << `IRQ_S_EXT) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_S_SOFT))
`define CSR_SATP          12'h180
`define CSR_SATP_MASK     32'hFFFFFFFF

//--------------------------------------------------------------------
// CSR Registers - DCACHE control
//--------------------------------------------------------------------
`define CSR_DFLUSH            12'h3a0 // pmpcfg0
`define CSR_DFLUSH_MASK       32'hFFFFFFFF
`define CSR_DWRITEBACK        12'h3a1 // pmpcfg1
`define CSR_DWRITEBACK_MASK   32'hFFFFFFFF
`define CSR_DINVALIDATE       12'h3a2 // pmpcfg2
`define CSR_DINVALIDATE_MASK  32'hFFFFFFFF

//--------------------------------------------------------------------
// Status Register
//--------------------------------------------------------------------
`define SR_UIE         (1 << 0)
`define SR_UIE_R       0
`define SR_SIE         (1 << 1)
`define SR_SIE_R       1
`define SR_MIE         (1 << 3)
`define SR_MIE_R       3
`define SR_UPIE        (1 << 4)
`define SR_UPIE_R      4
`define SR_SPIE        (1 << 5)
`define SR_SPIE_R      5
`define SR_MPIE        (1 << 7)
`define SR_MPIE_R      7
`define SR_SPP         (1 << 8)
`define SR_SPP_R       8

`define SR_MPP_SHIFT   11
`define SR_MPP_MASK    2'h3
`define SR_MPP_R       12:11
`define SR_MPP_U       `PRIV_USER
`define SR_MPP_S       `PRIV_SUPER
`define SR_MPP_M       `PRIV_MACHINE

`define SR_SUM_R        18
`define SR_SUM          (1 << `SR_SUM_R)

`define SR_MPRV_R       17
`define SR_MPRV         (1 << `SR_MPRV_R)

`define SR_MXR_R        19
`define SR_MXR          (1 << `SR_MXR_R)

`define SR_SMODE_MASK   (`SR_UIE | `SR_SIE | `SR_UPIE | `SR_SPIE | `SR_SPP | `SR_SUM)



//******    与指令存储器 ROM 相关的宏定义    ******//
`define InstAddrBus             31:0            // rom 地址总线宽度
`define InstBus                 31:0            // rom 数据总线宽度
`define InstMemNum              4096            // rom 实际大小 64KB, iverilog 需要为 4K 仿真
`define InstMemNumLog2          11              // rom 实际使用地址线宽度，(2^12 - 1 = 4K)

//******                RAM              *******//
`define DataAddrBus             31:0            // ram addr bus
`define DataBus                 31:0            // ram data bus
`define DataMemNum              4096            // ram 64k, iverilog 需要为 4K 仿真
`define DataMemNumLog2          11              // (2^12 - 1 = 4K)
`define ByteWidth               7:0             // one Byte 8bit

//******    与通用寄存器 regfile 有关宏定义  ******//
`define RegAddrBus              4:0             // regfile 模块的地址线宽度
`define RegBus                  31:0            // regfile 模块的数据线宽度
`define RegWidth                32              // 通用寄存器宽度
`define DoubleRegWidth          64              
`define DoubleRegBus            63:0
`define RegNum                  32              // 通用寄存器的数量
`define RegNumLog2              5               // 寻址通用寄存器使用的地址位数
`define NOPRegAddr              5'b00000

//--------------------------------------------------------------------
// Privilege levels
//--------------------------------------------------------------------
`define PRIV_USER         2'd0
`define PRIV_SUPER        2'd1
`define PRIV_MACHINE      2'd3


//--------------------------------------------------------------------
// Exception Causes
//--------------------------------------------------------------------
`define EXCEPTION_W                        6
`define EXCEPTION_MISALIGNED_FETCH         6'h10
`define EXCEPTION_FAULT_FETCH              6'h11
`define EXCEPTION_ILLEGAL_INSTRUCTION      6'h12
`define EXCEPTION_BREAKPOINT               6'h13
`define EXCEPTION_MISALIGNED_LOAD          6'h14
`define EXCEPTION_FAULT_LOAD               6'h15
`define EXCEPTION_MISALIGNED_STORE         6'h16
`define EXCEPTION_FAULT_STORE              6'h17
`define EXCEPTION_ECALL                    6'h18
`define EXCEPTION_ECALL_U                  6'h18
`define EXCEPTION_ECALL_S                  6'h19
`define EXCEPTION_ECALL_H                  6'h1a
`define EXCEPTION_ECALL_M                  6'h1b
`define EXCEPTION_PAGE_FAULT_INST          6'h1c
`define EXCEPTION_PAGE_FAULT_LOAD          6'h1d
`define EXCEPTION_PAGE_FAULT_STORE         6'h1f
`define EXCEPTION_EXCEPTION                6'h10
`define EXCEPTION_INTERRUPT                6'h20
`define EXCEPTION_ERET                     6'h30
`define EXCEPTION_FENCE                    6'h31
`define EXCEPTION_TYPE_MASK                6'h30
`define EXCEPTION_SUBTYPE_R                3:0

`define MCAUSE_INT                      31
`define MCAUSE_MISALIGNED_FETCH         ((0 << `MCAUSE_INT) | 0)
`define MCAUSE_FAULT_FETCH              ((0 << `MCAUSE_INT) | 1)
`define MCAUSE_ILLEGAL_INSTRUCTION      ((0 << `MCAUSE_INT) | 2)
`define MCAUSE_BREAKPOINT               ((0 << `MCAUSE_INT) | 3)
`define MCAUSE_MISALIGNED_LOAD          ((0 << `MCAUSE_INT) | 4)
`define MCAUSE_FAULT_LOAD               ((0 << `MCAUSE_INT) | 5)
`define MCAUSE_MISALIGNED_STORE         ((0 << `MCAUSE_INT) | 6)
`define MCAUSE_FAULT_STORE              ((0 << `MCAUSE_INT) | 7)
`define MCAUSE_ECALL_U                  ((0 << `MCAUSE_INT) | 8)
`define MCAUSE_ECALL_S                  ((0 << `MCAUSE_INT) | 9)
`define MCAUSE_ECALL_H                  ((0 << `MCAUSE_INT) | 10)
`define MCAUSE_ECALL_M                  ((0 << `MCAUSE_INT) | 11)
`define MCAUSE_PAGE_FAULT_INST          ((0 << `MCAUSE_INT) | 12)
`define MCAUSE_PAGE_FAULT_LOAD          ((0 << `MCAUSE_INT) | 13)
`define MCAUSE_PAGE_FAULT_STORE         ((0 << `MCAUSE_INT) | 15)
`define MCAUSE_INTERRUPT                (1 << `MCAUSE_INT)

//--------------------------------------------------------------------
// IRQ Numbers
//--------------------------------------------------------------------
`define IRQ_S_SOFT   1
`define IRQ_M_SOFT   3
`define IRQ_S_TIMER  5
`define IRQ_M_TIMER  7
`define IRQ_S_EXT    9
`define IRQ_M_EXT    11
`define IRQ_MIN      (`IRQ_S_SOFT)
`define IRQ_MAX      (`IRQ_M_EXT + 1)
`define IRQ_MASK     ((1 << `IRQ_M_EXT)   | (1 << `IRQ_S_EXT)   |                       (1 << `IRQ_M_TIMER) | (1 << `IRQ_S_TIMER) |                       (1 << `IRQ_M_SOFT)  | (1 << `IRQ_S_SOFT))

`define SR_IP_MSIP_R      `IRQ_M_SOFT
`define SR_IP_MTIP_R      `IRQ_M_TIMER
`define SR_IP_MEIP_R      `IRQ_M_EXT
`define SR_IP_SSIP_R      `IRQ_S_SOFT
`define SR_IP_STIP_R      `IRQ_S_TIMER
`define SR_IP_SEIP_R      `IRQ_S_EXT

//interrupt

`define INT_ASSERT              1'b1
`define INT_DEASSERT            1'b0

`define INT_BUS 7:0
`define INT_NONE 8'h0
`define INT_RET 8'hff
`define INT_TIMER0 8'b00000001
`define INT_TIMER0_ENTRY_ADDR 32'h4

`define MUL     1'b0
`define DIV     1'b1