module cut (clock, reset, s,
           dv, l_in, test_in, fz_L,
           lclk, read_a, test_out,
   	   scan_in, scan_out, scan_en);

input clock;
input reset;
input s;
input dv;
input l_in;
input [1:0] test_in;
input scan_in;
output reg scan_out;
input scan_en;
output fz_L;
output lclk;
output [4:0] read_a;
output [1:0] test_out;

wire   clock;
wire   reset;
wire   s;
wire   dv;
wire   l_in;
wire   [1:0] test_in;
reg    fz_L;
wire   lclk;
wire   [4:0] read_a;
wire   [1:0] test_out;
wire   conflict;

localparam [2:0]
  IDLE = 0,
  LZ= 1,
  WR= 2,
  SS= 3,
  SD = 4,
  STZ= 5,
  WE= 6;

reg  [2:0] nxt;
reg  [2:0] cur;
reg  [4:0] read_a_i;
reg  [4:0] read_a_next;
reg  lclk_i;
reg  lclk_next;
reg  clearCounter;
reg  load_counter;
reg  out3;
reg  out4;
wire  comp;
reg  [1:0] test_out_i;

  assign read_a = read_a_i;
  assign lclk = lclk_i;
  assign test_out = test_out_i;

  always @(posedge clock) begin
    if(reset == 1'b 1) begin
      cur <= IDLE;
      read_a_i <= 5'b00000;
      lclk_i <= 1'b0;
      scan_out <= 0;
    end
    else if(scan_en == 1'b 1) begin
	scan_out <= cur;
	cur <= read_a_i;
	read_a_i <= lclk_i;	
	lclk_i <= test_out_i; 
    end
    else
    begin
      cur <= nxt;
      read_a_i <= read_a_next;
      lclk_i <= lclk_next;
    end
  end

  always @(*) begin
    case(cur)
    IDLE : begin
      if(s == 1'b 1 && dv == 1'b 0)
        nxt = WE;
      else 
        nxt = IDLE;
      clearCounter = 1'b 1;
      fz_L = 1'b 0;
      load_counter = 1'b 0;
    end
    WE: begin
      if(s == 1'b 1) begin
	   if(dv == 1'b 0)
          nxt = WE;
	   else
	     nxt = LZ;
      end
      else begin
        nxt = IDLE;
      end
      clearCounter = 1'b 1;
      fz_L = 1'b 0;
      load_counter = 1'b 0;
    end
    LZ: begin
      if(s == 1'b 1) begin
        if(l_in == 1'b 0)
          nxt = SS;
        else
          nxt = WR;
      end
      else
        nxt = IDLE;
      clearCounter = 1'b 1;
      fz_L = 1'b 0;
      load_counter = 1'b 1;
    end
    WR: begin
      if(s == 1'b 1) begin
        if(l_in == 1'b 1)
          nxt = WR;
        else
          nxt = SS;
      end
      else
        nxt = IDLE;
      clearCounter = 1'b 1;
      fz_L = 1'b 0;
      load_counter = 1'b 1;
    end
    SS: begin
      if(s == 1'b 0 || conflict == 1'b 1)
        nxt = IDLE;
      else
        nxt = SD;
      fz_L = 1'b 0;
      clearCounter = 1'b 0;
      load_counter = 1'b 0;
    end
    SD : begin
      if(s == 1'b 0 || conflict == 1'b 1)
        nxt = IDLE;
      else if(read_a_i == {3{1'b0}})
        nxt = STZ;
      else
        nxt = SD;
      fz_L = 1'b 1;
      clearCounter = 1'b 0;
      load_counter = 1'b 0;
    end
    STZ: begin
      if(s == 1'b 0 || conflict == 1'b 1)
        nxt = IDLE;
      else if(read_a_i == 5'b 11001)
        nxt = SS;
      else 
        nxt = STZ;
      fz_L = 1'b 0;
      clearCounter = 1'b 0;
      load_counter = 1'b 0;
    end
    default : begin
      nxt = IDLE;
      fz_L = 1'b 0;
      clearCounter = 1'b 0;
      load_counter = 1'b 0;
    end
    endcase
  end

  always @(*) begin
    if(clearCounter == 1'b 1) begin
      read_a_next = 5'b 11000;
      lclk_next = 1'b 0;
    end
    else begin
      if(read_a_i == 5'b 11001) begin
        if(lclk_i == 1'b 0)
          lclk_next = 1'b 1;
        else
          lclk_next = 1'b 0;
      end
      else 
        lclk_next = lclk_i;
      read_a_next = read_a_i - 1'b 1;
    end
  end

  always @(posedge clock) begin
    if(reset == 1'b 1)
      test_out_i <= 2'b 00;
    else if (scan_en) begin
      test_out_i <= out3;
    end
    else if(load_counter == 1'b 1) 
      test_out_i <= test_in + 2'b 10;
    else 
      test_out_i <= test_out_i + 1'b 1;
  end

  assign comp = (!(test_out[0] ^ test_in[0])) &
   			 (!(test_out[1] ^ test_in[1]));

 always @(posedge clock) begin
    if(reset == 1'b 1) begin
      out3 <= 1'b 0;
      out4 <= 1'b 0;
    end
    else if (scan_en) begin
      out3 <= out4;
      out4 <= scan_in; 
    end
    else begin
      out3 <= comp;
      out4 <= out3;
    end
  end

  assign conflict = out3 & out4;

endmodule
