`include "yadan_defs.v"


module interrupt_ctrl(
    input   wire                    clk,
    input   wire                    rst_n,

    // top input
    input   wire    [`INT_BUS]      int_flag_i,     //中断标志信号

    // from id
    input   wire    [`InstBus]      inst_i,         //译码阶段指令
    input   wire    [`InstAddrBus]  inst_addr_i,    //译码阶段指令地址

    // from ex
    //input   wire    [`InstBus]      inst_ex_i,
    input   wire                    branch_flag_i,  //执行阶段分支标志信号
    input   wire    [`RegBus]       branch_addr_i,  //执行阶段分支地址
    input   wire                    div_i,          //除法操作信号

    // from csr_reg
    input   wire                    global_int_en_i,//全局中断使能信号
    input   wire    [`RegBus]       csr_mtvec,      //机器模式 中断向量基地址 Machine Trap-Vector Base-Address Register，用于设置中断入口地址
    input   wire    [`RegBus]       csr_mepc,       //机器模式 异常程序计数器 Machine Exception PC，指向发生异常的指令
    input   wire    [`RegBus]       csr_mstatus,    //机器模式 状态寄存器
    // input   wire    [`RegBus]       data_i,         //读csr数据
    
    // to csr_reg
    output  reg                     we_o,           //写使能 （写csr）
    output  reg     [`DataAddrBus]  waddr_o,        //写地址
    // output  reg     [`DataAddrBus]  raddr_o,        //读地址
    output  reg     [`RegBus]       data_o,         //写信号
    output  reg     [`InstAddrBus]  int_addr_o,     //中断入口地址
    output  reg                     int_assert_o,   //中断有效标志

    // to ctrl
    output  wire                    stallreq_interrupt_o    //流水线停顿请求
);
    
    // 主状态（并非状态机）
    localparam IDLE             = 3'b000;
    localparam SYNC             = 3'b001;   //处理同步中断（ecall或ebreak）
    localparam ASYNC            = 3'b010;   //处理异步中断（外部中断）
    localparam MRET             = 3'b100;   //处理中断返回指令mret

    // CSR状态机
    localparam CSR_IDLE         = 4'b0000;
    localparam CSR_MEPC         = 4'b0001;  //更新mepc寄存器
    localparam CSR_MCAUSE       = 4'b0010;  //更新mause寄存器，mcause用于存储异常或中断的原因，机器模式
    localparam CSR_MSTATUS      = 4'b0100;  //更新mstatus寄存器
    localparam CSR_MSTATUS_MRET = 4'b1000;  //处理mret指令，恢复mstatus寄存器
 
    reg [2:0]           state;
    reg                 state_flag;
    
    reg [2:0]           csr_state;
    reg [2:0]           csr_state_nxt;
    reg [31:0]          cause;
    reg [`InstAddrBus]  inst_addr;

    reg                 branch_flag_ff1;
    reg [`RegBus]       branch_addr_ff1;

    assign stallreq_interrupt_o = (state != IDLE) || (csr_state != CSR_IDLE);

    // 多个中断同时发生时，同步中断优先于异步中断
    // 完整的中断优先级处理暂时没有完成，目前每次只处理一个中断
    always @(*) begin
        if((inst_i == `INST_ECALL || inst_i == `INST_EBR) && (!div_i) && (!state_flag))
            state = SYNC;
        else if((|int_flag_i) && global_int_en_i && (!state_flag))
            state = ASYNC;
        else if(inst_i == `INST_MRET)
            state = MRET;
        else
            state = IDLE;
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            branch_flag_ff1 <= 'b0;
            branch_addr_ff1 <= 'b0;
        end else begin
            branch_flag_ff1 <= branch_flag_i;
            branch_addr_ff1 <= branch_addr_i;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable)
            csr_state <= CSR_IDLE;
        else
            csr_state <= csr_state_nxt;
    end

    always @(*) begin
        case (csr_state)
            CSR_IDLE: begin
                if(state == MRET)
                    csr_state_nxt = CSR_MSTATUS_MRET;
                else if((state == SYNC) || (state == ASYNC))
                    csr_state_nxt = CSR_MEPC;
                else 
                    csr_state_nxt = CSR_IDLE;
            end
            CSR_MEPC:           csr_state_nxt = CSR_MCAUSE;
            CSR_MCAUSE:         csr_state_nxt = CSR_MSTATUS;
            CSR_MSTATUS:        csr_state_nxt = CSR_IDLE;
            CSR_MSTATUS_MRET:   csr_state_nxt = CSR_IDLE;
            default:            csr_state_nxt = CSR_IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            cause <= `ZeroWord;
            inst_addr <= `ZeroWord;
            state_flag <= 0;
        end else if(state == SYNC) begin
            state_flag <= 1;
            if(inst_i == `INST_ECALL) 
                cause <= 32'd11;
            else if(inst_i == `INST_EBR)
                cause <= 32'd3;
            else 
                cause <= 32'd10;

            if(branch_flag_ff1 == `BranchEnable)
                inst_addr <= branch_addr_i - 4'h4;
            else 
                inst_addr <= inst_addr_i;
        end else if(state == ASYNC) begin
            state_flag <= 1;
            if(|int_flag_i[5:0] || |int_flag_i[13:10])
                cause <= {1'b1,6'h0,int_flag_i,11'h8};
            else if(|int_flag_i[9:6])
                cause <= {1'b1,6'h0,int_flag_i,11'h4};
            else 
                cause <= cause;

            if (branch_flag_i == `BranchEnable)
                inst_addr <= branch_addr_i;
            else if (branch_flag_ff1 == `BranchEnable)
                inst_addr <= branch_addr_ff1;
            else if (div_i)
                inst_addr <= inst_addr_i - 4'h4;
            else
                inst_addr <= inst_addr_i;
        end else if(state == MRET)
            state_flag <= 0; 
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            we_o            <= `WriteDisable;
            waddr_o         <= `ZeroWord;
            data_o          <= `ZeroWord;
            int_assert_o    <= `INT_DEASSERT;
            int_addr_o      <= `ZeroWord;
        end else begin
            case(csr_state)
                CSR_MEPC: begin
                    we_o            <= `WriteEnable;
                    waddr_o         <= {20'h0, `CSR_MEPC};
                    data_o          <= inst_addr;
                    int_assert_o    <= `INT_DEASSERT;
                    int_addr_o      <= `ZeroWord;
                end
                CSR_MCAUSE: begin
                    we_o            <= `WriteEnable;
                    waddr_o         <= {20'h0, `CSR_MCAUSE};
                    data_o          <= cause;
                    int_assert_o    <= `INT_ASSERT;
                    int_addr_o      <= csr_mtvec;
                end
                CSR_MSTATUS: begin
                    we_o            <= `WriteEnable;
                    waddr_o         <= {20'h0, `CSR_MSTATUS};
                    data_o          <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                    int_assert_o    <= `INT_DEASSERT;
                    int_addr_o      <= `ZeroWord;
                end
                CSR_MSTATUS_MRET: begin
                    we_o            <= `WriteEnable;
                    waddr_o         <= {20'h0, `CSR_MSTATUS};
                    data_o          <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                    int_assert_o    <= `INT_ASSERT;
                    int_addr_o      <= csr_mepc;
                end
                default: begin
                    we_o            <= `WriteDisable;
                    waddr_o         <= `ZeroWord;
                    data_o          <= `ZeroWord;
                    int_assert_o    <= `INT_DEASSERT;
                    int_addr_o      <= `ZeroWord;
                end
            endcase
        end
    end

 
 endmodule
