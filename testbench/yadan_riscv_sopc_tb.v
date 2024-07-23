`timescale  1ns/1ps
`include "../RTL/core/yadan_defs.v"
`define IVERILOG 1


module  yadan_riscv_sopc_tb();
    reg       CLOCK_50;
    reg       rst;

    wire    uart_rx, uart_tx;
    wire    spi_master_sck, spi_master_scs, spi_master_sdo;
    reg     spi_master_sdi;
    wire    test_sck, test_scs, test_sdi, test_sdo;
    // wire    gpio[15:0];

    
    // 每隔 10ns CLOCK_50 信号翻转一次，所以周期是 20ns, 对应 50MHz
    initial begin
        CLOCK_50    = 1'b0;
        forever #10 CLOCK_50    = ~CLOCK_50;
    end 

    // 例化最小 sopc
    yadan_riscv_sopc u_yadan_riscv_sopc(
        .clk(CLOCK_50),
        .rst(rst),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .spi_master_sck(spi_master_sck),
        .spi_master_scs(spi_master_scs),
        .spi_master_sdi(spi_master_sdi),
        .spi_master_sdo(spi_master_sdo),

        .test_sck(test_sck),	
        .test_scs(test_scs),	
        .test_sdi(test_sdi),	
        .test_sdo(test_sdo)/* ,
        .gpio(gpio) */
    );


`ifdef IVERILOG
    // 使用文件 inst_rom.data 初始化指令存储器
    // initial $readmemh("./inst_rom.data", u_bitty_riscv_sopc.u_inst_rom.inst_mem);
    // initial $readmemh("./inst_rom.data", u_bitty_riscv_sopc.u_data_rom.data_mem);
    // initial $readmemh("./inst_rom.data", u_bitty_riscv_sopc.u_data_ram.data_mem);
    // initial $readmemh("./inst_data0.data", u_bitty_riscv_sopc.u_data_ram.data_mem0);
    // initial $readmemh("./inst_data1.data", u_bitty_riscv_sopc.u_data_ram.data_mem1);
    // initial $readmemh("./inst_data2.data", u_bitty_riscv_sopc.u_data_ram.data_mem2);
    // initial $readmemh("./inst_data3.data", u_bitty_riscv_sopc.u_data_ram.data_mem3);
    initial $readmemh ("./inst_rom.data", u_yadan_riscv_sopc.u_data_rom.u_inst_rom.inst_mem);
`else   // ModelSim 下
    // initial $readmemh("inst_rom.data", u_bitty_riscv_sopc.u_inst_rom.inst_mem);
    // initial $readmemh("inst_rom.data", u_bitty_riscv_sopc.u_data_ram.data_mem);
    // initial $readmemh("inst_data0.data", u_bitty_riscv_sopc.u_data_ram.data_mem0);
    // initial $readmemh("inst_data1.data", u_bitty_riscv_sopc.u_data_ram.data_mem1);
    // initial $readmemh("inst_data2.data", u_bitty_riscv_sopc.u_data_ram.data_mem2);
    // initial $readmemh("inst_data3.data", u_bitty_riscv_sopc.u_data_ram.data_mem3);
`endif

    wire[`RegBus]  x3  =  u_yadan_riscv_sopc.u_yadan_riscv.u_regsfile.x3_gp_w;
    // wire[`RegBus]  x3  =  u_yadan_riscv_sopc.u_yadan_riscv.u_regsfile.reg_r3_q;
    // wire[31:0]  x3  =  u_bitty_riscv_sopc.u_bitty_riscv.u_regsfile.x3_gp_w;

    wire[`RegBus]  x26  =  u_yadan_riscv_sopc.u_yadan_riscv.u_regsfile.x26_s10_w;
    wire[`RegBus]  x27 =  u_yadan_riscv_sopc.u_yadan_riscv.u_regsfile.x27_s11_w;
    // wire[`RegBus]  x27 =  u_yadan_riscv_sopc.u_yadan_riscv.u_regsfile.reg_r27_q;
    // wire[31:0]  x26 =  u_bitty_riscv_sopc.u_bitty_riscv.u_regsfile.regs[26];
    // wire[31:0]  x27 =  u_bitty_riscv_sopc.u_bitty_riscv.u_regsfile.regs[27];

    // 最初时刻，复位信号有效，在第 195ns，复位信号无效，最小 SOPC 开始运行
    // 运行 1000ns 后，暂停仿真
    initial begin
        rst = 1'b0;
        #195    rst = 1'b1;
        $display("--------- test running --------");
       
        wait(x26 == 32'h1);     // 测试结束
        #100
        if (x27 == 32'h1) begin     // 27bit 为 1 就 ok
            $display("pass");
            $display("********** ######### ***********");
            $display("********** test pass ***********");
            $display("********** ######### ***********");
        end else begin
            $display("fail");
            $display("********** ######### ***********");
            $display("********** test fail ***********");
            $display("********** ######### ***********");
            $display("test fail inst = %2d", x3);       // 第多少条指令出错
        end
`ifdef IVERILOG
        $finish;
`else
        $stop;
`endif
    end

    initial begin
        
        #1000000
        $display("#####--Time out--#####");
        $display("time");
`ifdef IVERILOG
        $finish;
`else
        $stop;
`endif
    end

`ifdef IVERILOG
    initial begin
        $display("#####-- Dump start --#####");
        $dumpfile("./yadan_riscv_sopc_tb.vcd");
        $dumpvars;

    end
`endif


endmodule // yadan_riscv_sopc_tb
