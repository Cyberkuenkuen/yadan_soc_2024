`include "yadan_defs.v"


module interrupt_ctrl(
    input   wire                    clk,
    input   wire                    rst_n,
    input   wire                    global_int_en_i,
    input   wire    [`INT_BUS]      int_flag_i,
    input   wire    [`InstBus]      inst_i,
    input   wire    [`InstAddrBus]  inst_addr_i,
    //input   wire    [`InstBus]      inst_ex_i,
    input   wire                    branch_flag_i,
    input   wire    [`RegBus]       branch_addr_i,
    input   wire                    div_i,
    //input   wire    [`RegBus]       data_i,
    input   wire    [`RegBus]       csr_mtvec,
    input   wire    [`RegBus]       csr_mepc,
    input   wire    [`RegBus]       csr_mstatus,

    output  wire                    stallreq_interrupt_o,
    output  reg                     we_o,
    output  reg     [`DataAddrBus]  waddr_o,
    output  reg     [`DataAddrBus]  raddr_o,
    output  reg     [`RegBus]       data_o,
    output  reg     [`InstAddrBus]  int_addr_o,
    output  reg                     int_assert_o
);
 
    localparam IDLE             = 2'b00;
    localparam SYNC             = 2'b01;
    localparam ASYNC            = 2'b10;
    localparam MRET             = 2'b11;

    localparam CSR_IDLE         = 3'b000;
    localparam CSR_MEPC         = 3'b001;
    localparam CSR_MCAUSE       = 3'b010;
    localparam CSR_MSTATUS      = 3'b011;
    localparam CSR_MSTATUS_MRET = 3'b100;
 
    wire    [1:0]   state;
    wire            sync_ena;
    wire            async_ena;
    wire            mret_ena;
    
    reg     [2:0]           csr_state;
    reg     [2:0]           csr_state_nxt;
    reg     [31:0]          cause;
    reg     [`InstAddrBus]  inst_addr;
    reg                     state_flag;

    assign stallreq_interrupt_o = (state != IDLE) | (csr_state != CSR_IDLE);
    assign sync_ena             = (inst_i == `INST_ECALL || inst_i == `INST_EBR) & (~div_i) & (~state_flag);
    assign async_ena            = (|int_flag_i) & global_int_en_i & (~state_flag);
    assign mret_ena             = inst_i == `INST_MRET;

    assign state        = ({2{sync_ena}} & SYNC) | ({2{async_ena}} & ASYNC) | ({2{mret_ena}} & MRET);

    reg                       branch_flag_ff1;
    reg     [`RegBus]   branch_addr_ff1;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            branch_flag_ff1 <= 1'b0;
            branch_addr_ff1 <= 'h0;
        end
        else begin
            branch_flag_ff1 <= branch_flag_i;
            branch_addr_ff1 <= branch_addr_i;
        end
    end

    always @(posedge clk) begin
        if(rst_n == `RstEnable)
            csr_state <= CSR_IDLE;
        else 
            csr_state <= csr_state_nxt;
    end

    always @(*) begin
        if(rst_n == `RstEnable) begin
            csr_state_nxt <= CSR_IDLE;
        end
        else begin
            case (csr_state)
                CSR_IDLE : begin
                    if(state == MRET)
                        csr_state_nxt <= CSR_MSTATUS_MRET;
                    else if((state == SYNC) || (state == ASYNC))
                        csr_state_nxt <= CSR_MEPC;
                    else 
                        csr_state_nxt <= CSR_IDLE;
                end
                CSR_MEPC : 
                    csr_state_nxt <= CSR_MCAUSE;
                CSR_MCAUSE :
                    csr_state_nxt <= CSR_MSTATUS;
                CSR_MSTATUS :
                    csr_state_nxt <= CSR_IDLE;
                CSR_MSTATUS_MRET : 
                    csr_state_nxt <= CSR_IDLE;
                default :
                    csr_state_nxt <= CSR_IDLE;
            endcase
        end
    end

    always @(posedge clk) begin
        if(rst_n == `RstEnable) begin
            cause <= `ZeroWord;
            inst_addr <= `ZeroWord;
            state_flag <= 0;
        end
        else if(state == SYNC) begin
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
        end
        else if(state == ASYNC) begin
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
        end
        else if(state == MRET)
            state_flag <= 0; 
    end

    always @(posedge clk) begin
        if(rst_n == `RstEnable) begin
            we_o            <= `WriteDisable;
            waddr_o         <= `ZeroWord;
            data_o          <= `ZeroWord;
            int_assert_o    <= `INT_DEASSERT;
            int_addr_o      <= `ZeroWord;
        end
        else begin
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
