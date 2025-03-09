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

`include "../core/yadan_defs.v"

module yadan_riscv_sopc(
    input   wire        clk,
    input   wire        rst,

    // input   wire        set_mode,
    input   wire        uart_rx,
    output  wire        uart_tx,
    output             spi_master_sck,
	output             spi_master_scs,
	input              spi_master_sdi,
	output             spi_master_sdo,

    output 	test_sck,	
    output  test_scs,	
    output  test_sdi,	
    output  test_sdo/* ,
    inout  wire        [15:0]gpio */
);

    assign test_sck = spi_master_sck;
    assign test_scs = spi_master_scs;
    assign test_sdi = spi_master_sdi;
    assign test_sdo = spi_master_sdo;

        wire         M0_HGRANT;
        wire         M1_HGRANT;
        wire   [31:0]  M_HRDATA;
        wire   [ 1:0]  M_HRESP;
        wire   M_HREADY;

        // yadan_riscv Outputs
        wire  M0_HBUSREQ;
        wire  [31:0]  M0_HADDR;
        wire  [ 1:0]  M0_HTRANS;
        wire  [ 2:0]  M0_HSIZE;
        wire  [ 2:0]  M0_HBURST;
        wire  [ 3:0]  M0_HPROT;
        wire  M0_HLOCK;
        wire  M0_HWRITE;
        wire  [31:0]  M0_HWDATA;
        wire  M1_HBUSREQ;
        wire  [31:0]  M1_HADDR;
        wire  [ 1:0]  M1_HTRANS;
        wire  [ 2:0]  M1_HSIZE;
        wire  [ 2:0]  M1_HBURST;
        wire  [ 3:0]  M1_HPROT;
        wire  M1_HLOCK;
        wire  M1_HWRITE;
        wire  [31:0]  M1_HWDATA;

        //interrupt 
        wire gpio_int;
        wire [1:0] s_spim_event;
        wire [`INT_BUS] intn;
        wire timer_0_Oint,timer_0_Cint,timer_1_Oint,timer_1_Cint;
        wire uartint;
        // assign intn = {timer_1_Cint,timer_1_Oint,timer_0_Cint,timer_0_Oint,s_spim_event,gpio_int,uartint};
        assign intn = {timer_1_Cint,timer_1_Oint,timer_0_Cint,timer_0_Oint,4'b0};
        
yadan_riscv  u_yadan_riscv (
    // in
    .clk                     ( clk          ),
    .rst_n                   ( rst          ),
    // .int_flag_i              ( intn         ),// 8'b0
    .int_flag_i              ( 8'b0         ),
    .M0_HGRANT               ( M0_HGRANT    ),
    .M1_HGRANT               ( M1_HGRANT    ),
    .M_HRDATA                ( M_HRDATA     ),
    .M_HRESP                 ( M_HRESP      ),
    .M_HREADY                ( M_HREADY     ),
    
    // out
    .M0_HBUSREQ              ( M0_HBUSREQ   ),
    .M0_HADDR                ( M0_HADDR     ),
    .M0_HTRANS               ( M0_HTRANS    ),
    .M0_HSIZE                ( M0_HSIZE     ),
    .M0_HBURST               ( M0_HBURST    ),
    .M0_HPROT                ( M0_HPROT     ),
    .M0_HLOCK                ( M0_HLOCK     ),
    .M0_HWRITE               ( M0_HWRITE    ),
    .M0_HWDATA               ( M0_HWDATA    ),
    .M1_HBUSREQ              ( M1_HBUSREQ   ),
    .M1_HADDR                ( M1_HADDR     ),
    .M1_HTRANS               ( M1_HTRANS    ),
    .M1_HSIZE                ( M1_HSIZE     ),
    .M1_HBURST               ( M1_HBURST    ),
    .M1_HPROT                ( M1_HPROT     ),
    .M1_HLOCK                ( M1_HLOCK     ),
    .M1_HWRITE               ( M1_HWRITE    ),
    .M1_HWDATA               ( M1_HWDATA    )
); 

    // amba_ahb_m2s3 Inputs 
    wire   S0_HREADY;        
    wire   [ 1:0]  S0_HRESP; 
    wire   [31:0]  S0_HRDATA;
    wire   [15:0]  S0_HSPLIT;
    wire   S1_HREADY;
    wire   [ 1:0]  S1_HRESP;
    wire   [31:0]  S1_HRDATA;
    wire   [15:0]  S1_HSPLIT;
    wire   S2_HREADY;
    wire   [ 1:0]  S2_HRESP;
    wire   [31:0]  S2_HRDATA;
    wire   [15:0]  S2_HSPLIT;
    wire   S3_HREADY;
    wire   [ 1:0]  S3_HRESP;
    wire   [31:0]  S3_HRDATA;
    wire   [15:0]  S3_HSPLIT;
    wire   S4_HREADY;
    wire   [ 1:0]  S4_HRESP;
    wire   [31:0]  S4_HRDATA;
    wire   [15:0]  S4_HSPLIT;

    // amba_ahb_m2s3 Outputs
    wire  [31:0]  S_HADDR;
    wire  S_HWRITE;
    wire  [ 1:0]  S_HTRANS;
    wire  [ 2:0]  S_HSIZE;
    wire  [ 2:0]  S_HBURST;
    wire  [31:0]  S_HWDATA;
    wire  [ 3:0]  S_HPROT;
    wire  S_HREADY;
    wire  [ 3:0]  S_HMASTER;
    wire  S_HMASTLOCK;
    wire  S0_HSEL;
    wire  S1_HSEL;
    wire  S2_HSEL;
    wire  S3_HSEL;
    wire  S4_HSEL;


amba_ahb_m2s5  u_amba_ahb_m2s5 (
    .HRESETn                 ( rst       ),
    .HCLK                    ( clk          ),
    .M0_HBUSREQ              ( M0_HBUSREQ    ),
    .M0_HADDR                ( M0_HADDR      ),
    .M0_HTRANS               ( M0_HTRANS     ),
    .M0_HSIZE                ( M0_HSIZE      ),
    .M0_HBURST               ( M0_HBURST     ),
    .M0_HPROT                ( M0_HPROT      ),
    .M0_HLOCK                ( M0_HLOCK      ),
    .M0_HWRITE               ( M0_HWRITE     ),
    .M0_HWDATA               ( M0_HWDATA     ),
    .M1_HBUSREQ              ( M1_HBUSREQ    ),
    .M1_HADDR                ( M1_HADDR      ),
    .M1_HTRANS               ( M1_HTRANS     ),
    .M1_HSIZE                ( M1_HSIZE      ),
    .M1_HBURST               ( M1_HBURST     ),
    .M1_HPROT                ( M1_HPROT      ),
    .M1_HLOCK                ( M1_HLOCK      ),
    .M1_HWRITE               ( M1_HWRITE     ),
    .M1_HWDATA               ( M1_HWDATA     ),
    .S0_HREADY               ( S0_HREADY     ),
    .S0_HRESP                ( S0_HRESP      ),
    .S0_HRDATA               ( S0_HRDATA     ),
    .S0_HSPLIT               ( S0_HSPLIT     ),
    .S1_HREADY               ( S1_HREADY     ),
    .S1_HRESP                ( S1_HRESP      ),
    .S1_HRDATA               ( S1_HRDATA     ),
    .S1_HSPLIT               ( S1_HSPLIT     ),
    .S2_HREADY               ( S2_HREADY     ),
    .S2_HRESP                ( S2_HRESP      ),
    .S2_HRDATA               ( S2_HRDATA     ),
    .S2_HSPLIT               ( S2_HSPLIT     ),
    .S3_HREADY               ( S3_HREADY     ),
    .S3_HRESP                ( S3_HRESP      ),
    .S3_HRDATA               ( S3_HRDATA     ),
    .S3_HSPLIT               ( S3_HSPLIT     ),
    .S4_HREADY               ( S4_HREADY     ),
    .S4_HRESP                ( S4_HRESP      ),
    .S4_HRDATA               ( S4_HRDATA     ),
    .S4_HSPLIT               ( S4_HSPLIT     ),

    .REMAP                   ( 1'b0         ),

    .M0_HGRANT               ( M0_HGRANT     ),
    .M1_HGRANT               ( M1_HGRANT     ),
    .M_HRDATA                ( M_HRDATA      ),
    .M_HRESP                 ( M_HRESP       ),
    .M_HREADY                ( M_HREADY      ),
    .S_HADDR                 ( S_HADDR       ),
    .S_HWRITE                ( S_HWRITE      ),
    .S_HTRANS                ( S_HTRANS      ),
    .S_HSIZE                 ( S_HSIZE       ),
    .S_HBURST                ( S_HBURST      ),
    .S_HWDATA                ( S_HWDATA      ),
    .S_HPROT                 ( S_HPROT       ),
    .S_HREADY                ( S_HREADY      ),
    .S_HMASTER               ( S_HMASTER     ),
    .S_HMASTLOCK             ( S_HMASTLOCK   ),
    .S0_HSEL                 ( S0_HSEL       ),
    .S1_HSEL                 ( S1_HSEL       ),
    .S2_HSEL                 ( S2_HSEL       ),
    .S3_HSEL                 ( S3_HSEL       ),
    .S4_HSEL                 ( S4_HSEL       )

);


    AHB2MEM_ROM  u_data_rom (
    .HCLK             (clk),
    .HRESETn          (rst),
    .HSEL             (S0_HSEL),  // AHB inputs
    .HADDR            (S_HADDR),
    .HTRANS           (S_HTRANS),
    .HSIZE            (S_HSIZE),
    .HWRITE           (S_HWRITE),
    .HWDATA           (S_HWDATA),
    .HREADY           (M_HREADY),

    // .HSPLIT           (S0_HSPLIT),
    .HREADYOUT        (S0_HREADY), // Outputs
    .HRDATA           (S0_HRDATA),
    .HRESP            (S0_HRESP)
  );

   AHB2MEM_RAM  u_data_ram (
    .HCLK             (clk),
    .HRESETn          (rst),
    .HSEL             (S1_HSEL),  // AHB inputs
    .HADDR            (S_HADDR),
    .HTRANS           (S_HTRANS),
    .HSIZE            (S_HSIZE),
    .HWRITE           (S_HWRITE),
    .HWDATA           (S_HWDATA),
    .HREADY           (M_HREADY),

    // .HSPLIT           (S1_HSPLIT),
    .HREADYOUT        (S1_HREADY), // Outputs
    .HRDATA           (S1_HRDATA),
    .HRESP            (S1_HRESP)
  );
    
    wire S_PENABLE  ;
    wire [31:0] S_PADDR    ;
    wire S_PWRITE   ;
    wire [31:0] S_PWDATA   ;    

    wire S1_PSEL    ;
    wire [31:0] S1_PRDATA  ;
    wire S1_PREADY  ;
    wire S1_PSLVERR ;

    wire S0_PSEL    ;
    wire [31:0] S0_PRDATA  ; 
    wire S0_PREADY  ;   
    wire S0_PSLVERR ;

    wire S2_PSEL ;
    wire [31:0] S2_PRDATA   ;
    wire S2_PREADY  ;
    wire S2_PSLVERR ;

    wire S3_PSEL ;
    wire [31:0] S3_PRDATA   ;
    wire S3_PREADY  ;
    wire S3_PSLVERR ;

    wire S4_PSEL ;
    wire [31:0] S4_PRDATA   ;
    wire S4_PREADY  ;
    wire S4_PSLVERR ;

    wire S5_PSEL ;
    wire [31:0] S5_PRDATA   ;
    wire S5_PREADY  ;
    wire S5_PSLVERR ;

    wire S6_PSEL ;
    wire [31:0] S6_PRDATA   ;
    wire S6_PREADY  ;
    wire S6_PSLVERR ;

    wire S7_PSEL ;
    wire [31:0] S7_PRDATA   ;
    wire S7_PREADY  ;
    wire S7_PSLVERR ;

    wire S8_PSEL ;
    wire [31:0] S8_PRDATA   ;
    wire S8_PREADY  ;
    wire S8_PSLVERR ;

    assign S4_PREADY = 1'b1;
    assign S4_PSLVERR = 1'b1;
    assign S5_PREADY = 1'b1;
    assign S5_PSLVERR = 1'b1;
    assign S6_PREADY = 1'b1;
    assign S6_PSLVERR = 1'b1;
    assign S7_PREADY = 1'b1;
    assign S7_PSLVERR = 1'b1;
    assign S8_PREADY = 1'b1;
    assign S8_PSLVERR = 1'b1;


    ahb_to_apb_9s u_ahb_to_apb_9s(
        .HRESETn        (rst),   
        .HCLK           (clk),
        .HSEL           (S4_HSEL),
        .HADDR          (S_HADDR),
        .HTRANS         (S_HTRANS),
        .HPROT          (S_HPROT),
        // .HLOCK          (),
        .HWRITE         (S_HWRITE),
        .HSIZE          (S_HSIZE),
        .HBURST         (S_HBURST),
        .HWDATA         (S_HWDATA),
        .HREADYin       (M_HREADY),   
        .PCLK           (clk),
        .PRESETn        (rst),

        .HRDATA         (S4_HRDATA),
        .HRESP          (S4_HRESP),
        .HREADYout      (S4_HREADY),   
        .S_PENABLE      (S_PENABLE  ),   
        .S_PADDR        (S_PADDR    ),   
        .S_PWRITE       (S_PWRITE   ),   
        .S_PWDATA       (S_PWDATA   ),   
        .S0_PSEL        (S0_PSEL    ),   
        .S0_PRDATA      (S0_PRDATA  ),   
        .S0_PREADY      (S0_PREADY  ),       
        .S0_PSLVERR     (S0_PSLVERR ),  
        .S1_PSEL        (S1_PSEL    ),   
        .S1_PRDATA      (S1_PRDATA  ),
        .S1_PREADY      (S1_PREADY  ),       
        .S1_PSLVERR     (S1_PSLVERR ),
        .S2_PSEL        (S2_PSEL    ),   
        .S2_PRDATA      (S2_PRDATA  ),
        .S2_PREADY      (S2_PREADY  ),       
        .S2_PSLVERR     (S2_PSLVERR ),
        .S3_PSEL        (S3_PSEL    ),   
        .S3_PRDATA      (S3_PRDATA  ),
        .S3_PREADY      (S3_PREADY  ),       
        .S3_PSLVERR     (S3_PSLVERR ),
        .S4_PSEL        (S4_PSEL    ),   
        .S4_PRDATA      (S4_PRDATA  ),
        .S4_PREADY      (S4_PREADY  ),       
        .S4_PSLVERR     (S4_PSLVERR ),
        .S5_PSEL        (S5_PSEL    ),   
        .S5_PRDATA      (S5_PRDATA  ),
        .S5_PREADY      (S5_PREADY  ),       
        .S5_PSLVERR     (S5_PSLVERR ),
        .S6_PSEL        (S6_PSEL    ),   
        .S6_PRDATA      (S6_PRDATA  ),
        .S6_PREADY      (S6_PREADY  ),       
        .S6_PSLVERR     (S6_PSLVERR ),
        .S7_PSEL        (S7_PSEL    ),   
        .S7_PRDATA      (S7_PRDATA  ),
        .S7_PREADY      (S7_PREADY  ),       
        .S7_PSLVERR     (S7_PSLVERR ),
        .S8_PSEL        (S8_PSEL    ),   
        .S8_PRDATA      (S8_PRDATA  ),
        .S8_PREADY      (S8_PREADY  ),       
        .S8_PSLVERR     (S8_PSLVERR )
    );

/* wire [31:0] gpio_in_w;
wire [31:0] gpio_out_w;
wire [31:0] gpio_oe_w;

assign gpio_in_w[15:0] = gpio[15:0];

assign gpio[0] = gpio_oe_w[0] ? gpio_out_w[0] : 1'bz;
assign gpio[1] = gpio_oe_w[1] ? gpio_out_w[1] : 1'bz;
assign gpio[2] = gpio_oe_w[2] ? gpio_out_w[2] : 1'bz;
assign gpio[3] = gpio_oe_w[3] ? gpio_out_w[3] : 1'bz;
assign gpio[4] = gpio_oe_w[4] ? gpio_out_w[4] : 1'bz;
assign gpio[5] = gpio_oe_w[5] ? gpio_out_w[5] : 1'bz;
assign gpio[6] = gpio_oe_w[6] ? gpio_out_w[6] : 1'bz;
assign gpio[7] = gpio_oe_w[7] ? gpio_out_w[7] : 1'bz;

assign gpio[8 ] = gpio_oe_w[8 ] ? gpio_out_w[8 ] : 1'bz;
assign gpio[9 ] = gpio_oe_w[9 ] ? gpio_out_w[9 ] : 1'bz;
assign gpio[10] = gpio_oe_w[10] ? gpio_out_w[10] : 1'bz;
assign gpio[11] = gpio_oe_w[11] ? gpio_out_w[11] : 1'bz;
assign gpio[12] = gpio_oe_w[12] ? gpio_out_w[12] : 1'bz;
assign gpio[13] = gpio_oe_w[13] ? gpio_out_w[13] : 1'bz;
assign gpio[14] = gpio_oe_w[14] ? ~gpio_out_w[14] : 1'bz;
assign gpio[15] = gpio_oe_w[15] ? gpio_out_w[15] : 1'bz; */
/* 
apb_gpio#(
    .APB_ADDR_WIDTH        ( 12 ),
    .PAD_NUM               ( 32 )
)u_apb_gpio(
    .HCLK            ( clk            ),
    .HRESETn         ( rst         ),
    
    .PADDR          ( S_PADDR[11:0]          ),
    .PWDATA         ( S_PWDATA         ),
    .PWRITE          ( S_PWRITE          ),
    .PSEL            ( S4_HSEL & S1_PSEL            ),
    .PENABLE         ( S_PENABLE         ),

    .PRDATA         ( S1_PRDATA         ),
    .PREADY          ( S1_PREADY          ),
    .PSLVERR         ( S1_PSLVERR         ),
    .gpio_in        ( gpio_in_w        ),
    .gpio_in_sync   (    ),
    .gpio_out       ( gpio_out_w       ),
    .gpio_dir       ( gpio_oe_w       ),
    .gpio_padcfg    (     ),
    .interrupt       ( gpio_int      )
);

	apb_uart u_uart_apb( 
        .CLK      (  clk       ),
        .RSTN     (  rst       ),
        .PSEL     (  S4_HSEL & S0_PSEL       ),
        .PENABLE  (  S_PENABLE       ),
        .PWRITE   (  S_PWRITE       ),
        .PADDR    (  S_PADDR[4:2]       ),
        .PWDATA   (  S_PWDATA       ),
        .PRDATA   (  S0_PRDATA       ),
        .PREADY   (  S0_PREADY       ),
        .PSLVERR  (  S0_PSLVERR       ),
        .INT      (  uartint       ),
        .OUT1N    (         ),
        .OUT2N    (         ),
        .RTSN     (         ),
        .DTRN     (         ),
        .CTSN     (         ),
        .DSRN     (         ),
        .DCDN     (  1'b1       ),
        .RIN      (  1'b1       ),
        .SIN      (  uart_rx       ),
        .SOUT     (  uart_tx       )
    ); */


  //////////////////////////////////////////////////////////////////
  ///                                                            ///
  /// APB Slave 2: APB SPI Master interface                      ///
  ///                                                            ///
  //////////////////////////////////////////////////////////////////

  /* apb_spi_master
  #(
      .BUFFER_DEPTH(8)
  )
  apb_spi_master_i
  (
    .HCLK         ( clk   ),
    .HRESETn      ( rst        ),

    .PADDR        ( S_PADDR[11:0]),
    .PWDATA       ( S_PWDATA     ),
    .PWRITE       ( S_PWRITE     ),
    .PSEL         ( S4_HSEL & S2_PSEL       ),
    .PENABLE      ( S_PENABLE    ),
    .PRDATA       ( S2_PRDATA     ),
    .PREADY       ( S2_PREADY     ),
    .PSLVERR      ( S2_PSLVERR    ),

    .events_o     ( s_spim_event ),

    .spi_clk      ( spi_master_sck  ),
    .spi_csn0     ( spi_master_scs ),
    .spi_csn1     (  ),
    .spi_csn2     (  ),
    .spi_csn3     (  ),
    .spi_mode     (  ),
    .spi_sdo0     ( spi_master_sdo ),
    .spi_sdo1     (  ),
    .spi_sdo2     (  ),
    .spi_sdo3     (  ),
    .spi_sdi0     ( spi_master_sdi ),
    .spi_sdi1     ( 1'b0 ),
    .spi_sdi2     ( 1'b0 ),
    .spi_sdi3     ( 1'b0 )
  );
*/

    apb_timer u_apb_timer(
        .HCLK       (  clk     ),
        .HRESETn    (  rst     ),
        .PSEL       (  S4_HSEL & S3_PSEL     ),
        .PENABLE    (  S_PENABLE     ),
        .PWRITE     (  S_PWRITE     ),
        .PADDR      (  S_PADDR[11:0]     ),
        .PWDATA     (  S_PWDATA     ),

        .PREADY     (  S3_PREADY     ),
        .PRDATA     (  S3_PRDATA     ),

        .PSLVERR    (S3_PSLVERR),

        .irq_o      ({timer_1_Cint,timer_1_Oint,timer_0_Cint,timer_0_Oint})
    ); 



endmodule // 
