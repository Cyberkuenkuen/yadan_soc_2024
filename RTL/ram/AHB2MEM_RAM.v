
////////////////////////////////////////////////////////////////////////////////
// AHB Memory Module
////////////////////////////////////////////////////////////////////////////////
`include "../core/yadan_defs.v"

module AHB2MEM_RAM
   #(parameter MEMWIDTH = 12)               // Size = 4KB
   (
   input wire           HSEL,
   input wire           HCLK,
   input wire           HRESETn,
   input wire           HREADY,
   input wire    [31:0] HADDR,
   input wire     [1:0] HTRANS,
   input wire           HWRITE,
   input wire     [2:0] HSIZE,
   input wire    [31:0] HWDATA,
//    output wire   [15:0] HSPLIT,
   output wire          HREADYOUT,
   output wire    [31:0] HRDATA,
   output wire   [1:0]  HRESP
   );

   assign HREADYOUT = 1'b1; // Always ready
   assign HRESP     = 2'b00;
//    assign HSPLIT    = 16'h0;
      

    reg [3:0] byteena;

    reg[`ByteWidth] data_i0;
    reg[`ByteWidth] data_i1;
    reg[`ByteWidth] data_i2;
    reg[`ByteWidth] data_i3;
    wire wren ;

    assign wren = (HSEL && HWRITE) && HTRANS[1];

   // Sample the Address Phase    

   always @(*)//posedge HCLK or negedge HRESETn)
   begin
      if(!HRESETn)
      begin
        //  we <= 1'b0;
        //  buf_hwaddr <= 32'h0;
        byteena = 4'b0000;
        data_i0 = 8'h0;
        data_i1 = 8'h0;
        data_i2 = 8'h0;
        data_i3 = 8'h0;
      end
      else begin
         if(HREADY)
         begin
            data_i0 = HWDATA[7:0];
            data_i1 = HWDATA[15:8];
            data_i2 = HWDATA[23:16];
            data_i3 = HWDATA[31:24];
            byteena = 4'b1111;
            if(wren) begin
                if(HSIZE == 3'b000) begin
                    if (HADDR[1:0] == 2'b00) begin
                        data_i0 = HWDATA[7:0];
                        byteena = 4'b0001;
                    end
                    if (HADDR[1:0] == 2'b01) begin
                        data_i1 = HWDATA[7:0];
                        byteena = 4'b0010;
                    end
                    if (HADDR[1:0] == 2'b10) begin
                        data_i2 = HWDATA[7:0];
                        byteena = 4'b0100;
                    end
                    if (HADDR[1:0] == 2'b11) begin
                        data_i3 = HWDATA[7:0];
                        byteena = 4'b1000;
                    end
                end
                else if (HSIZE == 3'b001) begin
                    if (HADDR[1:0] == 2'b00) begin
                        data_i0 = HWDATA[7:0];
                        data_i1 = HWDATA[15:8];
                        byteena = 4'b0011;
                    end
                    if (HADDR[1:0] == 2'b10) begin
                        data_i2 = HWDATA[7:0];
                        data_i3 = HWDATA[15:8];
                        byteena = 4'b1100;
                    end
                end
                else begin
                    data_i0 = HWDATA[7:0];
                    data_i1 = HWDATA[15:8];
                    data_i2 = HWDATA[23:16];
                    data_i3 = HWDATA[31:24];
                    byteena = 4'b1111;
                end
            end
             else begin byteena <= 4'b0000; end
          end
          else begin
              data_i0 = HWDATA[7:0];
              data_i1 = HWDATA[15:8];
              data_i2 = HWDATA[23:16];
              data_i3 = HWDATA[31:24];
              byteena = 4'b0000;
          end
        end
   end
   
//     dataram  u_ram
//     (
//         .addra(HADDR[15:2]),
//         .wea(byteena),
//         .clka(~HCLK),
//         .dia({data_i3,data_i2,data_i1,data_i0}),
// //        .wren(wren),
//         .doa(HRDATA)
//     );


    data_ram u_data_ram(
        .clk(~HCLK),
        .rst(HRESETn),
        .ce(`ReadEnable),
        .we(wren),
        .addr(HADDR[15:2]),
        .sel(HSIZE),
        .data_i({data_i3,data_i2,data_i1,data_i0}),
        .data_o((HRDATA))
    );


endmodule
