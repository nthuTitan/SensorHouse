module top(clk,rst_n,DS18B20,light_in,seg,AN,enable,light_out);
input clk;
input rst_n;
inout DS18B20;
input light_in;
output [7:0]seg;
output [3:0]AN;
output enable;
output light_out;

wire [15:0] t_buf;
wire dclk;
drive_module U0(clk,rst_n,DS18B20,t_buf);
clock_divider_17 clk_trans (clk,dclk);
display U1(dclk,{t_buf[11:8],t_buf[7:4],t_buf[3:0],4'd0},seg,AN);
van U2(clk, rst_n, {t_buf[11:8], t_buf[7:4], t_buf[3:0], 4'd0}, enable);
light U3(light_in, light_out);

endmodule

module drive_module(clk,rst_n,one_wire,temperature);
input clk;
input rst_n;
inout one_wire;
output [15:0]temperature;

reg [5:0]cnt;
always@(posedge clk or negedge rst_n)
if (!rst_n)begin
  cnt <= 0;
end
else begin
  if (cnt==49)begin
    cnt<=0;
  end
  else begin
    cnt<=cnt+1'b1;
  end
end

reg clk_1us;
always@(posedge clk or negedge rst_n)
if (!rst_n)begin
  clk_1us <= 0;
end
else begin
  if (cnt <= 24)begin
    clk_1us <= 0;
  end
  else begin
    clk_1us <= 1;
  end
end

reg [19:0] cnt_1us;
reg cnt_1us_clear;
always@(posedge clk_1us)begin
if (cnt_1us_clear)begin
  cnt_1us <= 0;
end
else begin
  cnt_1us <= cnt_1us + 1'b1;
end
end

parameter S00     = 5'h00;
parameter S0      = 5'h01;
parameter S1      = 5'h03;
parameter S2      = 5'h02;
parameter S3      = 5'h06;
parameter S4      = 5'h07;
parameter S5      = 5'h05;
parameter S6      = 5'h04;
parameter S7      = 5'h0C;
parameter WRITE0  = 5'h0D;
parameter WRITE1  = 5'h0F;
parameter WRITE00 = 5'h0E;
parameter WRITE01 = 5'h0A;
parameter READ0   = 5'h0B;
parameter READ1   = 5'h09;
parameter READ2   = 5'h08;
parameter READ3   = 5'h18;
reg [4:0] state;
reg one_wire_buf;
reg [15:0] temperature_buf;
reg [5:0] step;
reg [3:0] bit_valid;

always @(posedge clk_1us or negedge rst_n)begin
  if (!rst_n)begin
    one_wire_buf <= 1'bZ;
    step         <= 0;
    state        <= S00;
  end
  else begin
    case (state)
      S00:begin              //0000 0000 0001 1111 16 bit for
            temperature_buf <= 16'h001F;
            state <= S0;
          end
      S0:begin
            cnt_1us_clear <= 1;
            one_wire_buf  <= 0;
            state <= S1;
         end
      S1:begin
           cnt_1us_clear <= 0;
           if (cnt_1us == 500)begin
             cnt_1us_clear <= 1;
             one_wire_buf  <= 1'bZ;
             state <= S2;
           end
         end
      S2:begin
           cnt_1us_clear <= 0;
           if (cnt_1us == 100)begin
             cnt_1us_clear <= 1;
             state <= S3;
           end
         end
      S3:begin
           if (~one_wire)begin
             state <= S4;
           end
          else if (one_wire)begin
             state <= S0;
          end
         end
      S4:begin
           cnt_1us_clear <= 0;
           if (cnt_1us == 400)begin
             cnt_1us_clear <= 1;
             state <= S5;
           end
         end
      S5:begin
           if(step == 0)begin
             step  <= step + 1'b1;
             state <= WRITE0;
           end
           else if (step == 1)begin
             step  <= step + 1'b1;
             state <= WRITE0;
           end
           else if (step == 2)begin
             one_wire_buf <= 0;
             step  <= step + 1'b1;
             state <= WRITE01;
           end
           else if (step == 3)begin
             one_wire_buf <= 0;
             step  <= step + 1'b1;
             state <= WRITE01;
           end
           else if (step == 4)begin
             step  <= step + 1'b1;
             state <= WRITE0;
           end
           else if (step == 5)begin
             step  <= step + 1'b1;
             state <= WRITE0;
           end
           else if (step == 6)begin
              one_wire_buf <= 0;
              step <= step + 1'b1;
              state <= WRITE01;
          end
          else if (step == 7)begin
              one_wire_buf <= 0;
              step <= step + 1'b1;
              state <= WRITE01;
          end
          else if (step == 8)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 9)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 10)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 11)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 12)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 13)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 14)begin
            one_wire_buf <= 0;
            step         <= step + 1'b1;
            state        <= WRITE01;
          end
          else if (step == 15)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 16)begin
            one_wire_buf <= 1'bZ;
            step <= step + 1'b1;
            state <= S6;
          end
          else if (step == 17)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 18)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 19)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 20)begin
            step  <= step + 1'b1;
            state <= WRITE01;
            one_wire_buf <= 0;
          end
          else if (step == 21)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 22)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 23)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 24)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 25)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 26)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 27)begin
            one_wire_buf <= 0;
            step         <= step + 1'b1;
            state        <= WRITE01;
          end
          else if (step == 28)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 29)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 30)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 31)begin
            step  <= step + 1'b1;
            state <= WRITE0;
          end
          else if (step == 32)begin
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= WRITE01;
          end
          else if (step == 33)begin
            step  <= step + 1'b1;
            state <= S7;
          end
          end
      S6:begin
           cnt_1us_clear <= 0;
           if (cnt_1us == 750000 | one_wire)begin
              cnt_1us_clear <= 1;
              state <= S0;
           end
         end
      S7: begin
          if (step == 34)begin
             bit_valid    <= 0;
             one_wire_buf <= 0;
             step <= step + 1'b1;
             state <= READ0;
          end
          else if (step == 35)begin
             bit_valid <= bit_valid + 1'b1;
             one_wire_buf <= 0;
             step <= step + 1'b1;
             state <= READ0;
          end
          else if (step == 36)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 37)begin
            bit_valid <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 38)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 39)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 40)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 41)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 42)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 43)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 44)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 45)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 46)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 47)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 48)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 49)begin
            bit_valid    <= bit_valid + 1'b1;
            one_wire_buf <= 0;
            step <= step + 1'b1;
            state <= READ0;
          end
          else if (step == 50)begin
            step <= 0;
            state <= S0;
          end
        end
      WRITE0 :begin
                cnt_1us_clear <= 0;
                one_wire_buf  <= 0;
                if (cnt_1us == 80)begin
                   cnt_1us_clear <= 1;
                   one_wire_buf  <= 1'bZ;
                   state         <= WRITE00;
                end
            end
      WRITE00 :state <= S5;
      WRITE01 :state <= WRITE1;
      WRITE1 :begin
                cnt_1us_clear <= 0;
                one_wire_buf  <= 1'bZ;
                if (cnt_1us == 80)
                begin
                  cnt_1us_clear <= 1;
                  state         <= S5;
                end
              end
      READ0 : state <= READ1;
      READ1 :begin
              cnt_1us_clear <= 0;
              one_wire_buf  <= 1'bZ;
              if (cnt_1us == 10)
              begin
                cnt_1us_clear <= 1;
                state         <= READ2;
              end
            end
      READ2 :begin
               temperature_buf[bit_valid] <= one_wire;
               state                      <= READ3;
            end
      READ3 :begin
               cnt_1us_clear <= 0;
               if (cnt_1us == 55)begin
                 cnt_1us_clear <= 1;
                 state         <= S7;
               end
             end
      default : state <= S00;
    endcase
  end
end

assign one_wire = one_wire_buf;
wire [15:0] t_buf = temperature_buf & 16'h07FF;
assign temperature[3:0]   = (t_buf[3:0] * 10) >> 4;
assign temperature[7:4]   = (((t_buf[7:4] * 10) >> 4) >= 4'd10) ? (((t_buf[7:4] * 10) >> 4) - 'd10) : ((t_buf[7:4] * 10) >> 4);
assign temperature[11:8]  = (((t_buf[7:4] * 10) >> 4) >= 4'd10) ? (((t_buf[11:8] * 10) >> 4) + 'd1) + 'd2 : ((t_buf[11:8] * 10) >> 4) + 'd2;
assign temperature[15:12] = temperature_buf[12] ? 1 : 0;

endmodule

module display(clk,data,AN,seg);
input clk;
input [15:0]data;
output reg [3:0]AN;
output reg [7:0]seg;

reg [1:0]now_count, next_now_count;
reg [7:0]next_seg;
reg [3:0]num;

always@(posedge clk) begin
    now_count <= next_now_count;
end

always@(posedge clk)begin
    seg <= next_seg;
    next_now_count <= now_count+2'b01;
    if(now_count==2'b00)begin
      AN <= 4'b1110;
      num <= data[3:0];
    end
    else if(now_count==2'b01)begin
      AN <= 4'b1101;
      num <= data[7:4];
    end
    else if(now_count==2'b10)begin
      AN <= 4'b1011;
      num <= data[11:8];
    end
    else begin
      AN <= 4'b0111;
      num <= data[15:12];
    end
end

always @(*) begin
    if(now_count==2'b00) begin
        if(num==4'd0) next_seg=8'b11000000;
        else if(num==4'd1) next_seg=8'b11111001;
        else if(num==4'd2) next_seg=8'b10100100;
        else if(num==4'd3) next_seg=8'b10110000;
        else if(num==4'd4) next_seg=8'b10011001;
        else if(num==4'd5) next_seg=8'b10010010;
        else if(num==4'd6) next_seg=8'b10000010;
        else if(num==4'd7) next_seg=8'b11111000;
        else if(num==4'd8) next_seg=8'b10000000;
        else if(num==4'd9) next_seg=8'b10010000;
        else if(num==4'd10) next_seg=8'b10001000;
        else if(num==4'd11) next_seg=8'b10000011;
        else if(num==4'd12) next_seg=8'b11000110;
        else if(num==4'd13) next_seg=8'b10100001;
        else if(num==4'd14) next_seg=8'b10000110;
        else if(num==4'd15) next_seg=8'b10001110;
        else next_seg=8'b11111111;
    end
    else if(now_count==2'b01)begin
      if(num==4'd0) next_seg=8'b11000000;
      else if(num==4'd1) next_seg=8'b11111001;
      else if(num==4'd2) next_seg=8'b10100100;
      else if(num==4'd3) next_seg=8'b10110000;
      else if(num==4'd4) next_seg=8'b10011001;
      else if(num==4'd5) next_seg=8'b10010010;
      else if(num==4'd6) next_seg=8'b10000010;
      else if(num==4'd7) next_seg=8'b11111000;
      else if(num==4'd8) next_seg=8'b10000000;
      else if(num==4'd9) next_seg=8'b10010000;
      else if(num==4'd10) next_seg=8'b10001000;
      else if(num==4'd11) next_seg=8'b10000011;
      else if(num==4'd12) next_seg=8'b11000110;
      else if(num==4'd13) next_seg=8'b10100001;
      else if(num==4'd14) next_seg=8'b10000110;
      else if(num==4'd15) next_seg=8'b10001110;
      else next_seg=8'b11111111;
    end
    else if(now_count==2'b10)begin
      if(num==4'd0) next_seg=8'b01000000;
      else if(num==4'd1) next_seg=8'b01111001;
      else if(num==4'd2) next_seg=8'b00100100;
      else if(num==4'd3) next_seg=8'b00110000;
      else if(num==4'd4) next_seg=8'b00011001;
      else if(num==4'd5) next_seg=8'b00010010;
      else if(num==4'd6) next_seg=8'b00000010;
      else if(num==4'd7) next_seg=8'b01111000;
      else if(num==4'd8) next_seg=8'b00000000;
      else if(num==4'd9) next_seg=8'b00010000;
      else if(num==4'd10) next_seg=8'b00001000;
      else if(num==4'd11) next_seg=8'b00000011;
      else if(num==4'd12) next_seg=8'b01000110;
      else if(num==4'd13) next_seg=8'b00100001;
      else if(num==4'd14) next_seg=8'b00000110;
      else if(num==4'd15) next_seg=8'b00001110;
      else next_seg=8'b11111111;
    end
    else begin
      if(num==4'd0) next_seg=8'b11000000;
      else if(num==4'd1) next_seg=8'b11111001;
      else if(num==4'd2) next_seg=8'b10100100;
      else if(num==4'd3) next_seg=8'b10110000;
      else if(num==4'd4) next_seg=8'b10011001;
      else if(num==4'd5) next_seg=8'b10010010;
      else if(num==4'd6) next_seg=8'b10000010;
      else if(num==4'd7) next_seg=8'b11111000;
      else if(num==4'd8) next_seg=8'b10000000;
      else if(num==4'd9) next_seg=8'b10010000;
      else if(num==4'd10) next_seg=8'b10001000;
      else if(num==4'd11) next_seg=8'b10000011;
      else if(num==4'd12) next_seg=8'b11000110;
      else if(num==4'd13) next_seg=8'b10100001;
      else if(num==4'd14) next_seg=8'b10000110;
      else if(num==4'd15) next_seg=8'b10001110;
      else next_seg=8'b11111111;
    end
end

endmodule

module van(clk, rst_n, temperature, enable);
input clk, rst_n;
input [15:0] temperature;
output reg enable;

reg next_enable;

always@(posedge clk)begin
  if(!rst_n)begin
      enable <= 1'b0;
  end
  else begin
      enable <= next_enable;
  end
end

always@(*)begin
  if((temperature[15:12]>4'd3) || (temperature[15:12]==4'd2 && temperature[11:8]>4'd5))begin
    next_enable=1'b1;
  end
  else begin
    next_enable=1'b0;
  end
end

endmodule

module light(light_in, light_out);
input light_in;
output light_out;

assign light_out=(light_in) ? 1 : 0;

endmodule

module clock_divider_17 (clk,dclk);
input clk;
output reg dclk;
reg [16:0]cnt=17'd0, next_cnt;

always@(posedge clk) begin
    cnt <= next_cnt;
end

always@(*) begin
  next_cnt=cnt+17'd1;
  if (cnt < 2**16)
    dclk = 1'd1;
  else
    dclk = 1'd0;
end
endmodule
