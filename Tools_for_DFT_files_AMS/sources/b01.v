`timescale 1ns / 1ps

module b01 (line1, line2, reset, outp, overflw, clock);
   input line1; 
   input line2; 
   input reset; 
   output outp; 
   output overflw; 
   input clock; 

   reg outp;
   reg overflw;

   reg[2:0] stato, stato_next; 

   parameter a = 0; 
   parameter b = 1; 
   parameter c = 2; 
   parameter e = 3; 
   parameter f = 4; 
   parameter g = 5; 
   parameter wf0 = 6; 
   parameter wf1 = 7; 

   always @(posedge clock or posedge reset)
   begin
      if (reset == 1'b1)
         stato = a; 
      else
         stato = stato_next; 
   end

   always @(stato or line1 or line2 )
   begin
         case (stato)
            a :
                     begin
                        if (line1 == 1'b1 & line2 == 1'b1)
                           stato_next = f; 
                        else
                           stato_next = b; 
                        outp <= line1 ^ line2 ; 
                        overflw <= 1'b0 ; 
                     end
            e :
                     begin
                        if (line1 == 1'b1 & line2 == 1'b1)
                           stato_next = f; 
                        else
                           stato_next = b; 
                        outp <= line1 ^ line2 ; 
                        overflw <= 1'b1 ; 
                     end
            b :
                     begin
                        if (line1 == 1'b1 & line2 == 1'b1)
                           stato_next = g; 
                        else
                           stato_next = c; 
                        outp <= line1 ^ line2 ; 
                        overflw <= 1'b0 ; 
                     end
            f :
                     begin
                        if (line1 == 1'b1 | line2 == 1'b1)
                           stato_next = g; 
                        else
                           stato_next = c; 
                        outp <= ~(line1 ^ line2) ; 
                        overflw <= 1'b0 ; 
                     end
            c :
                     begin
                        if (line1 == 1'b1 & line2 == 1'b1)
                           stato_next = wf1; 
                        else
                           stato_next = wf0; 
                        outp <= line1 ^ line2 ; 
                        overflw <= 1'b0 ; 
                     end
            g :
                     begin
                        if (line1 == 1'b1 | line2 == 1'b1)
                           stato_next = wf1; 
                        else
                           stato_next = wf0; 
                        outp <= ~(line1 ^ line2) ; 
                        overflw <= 1'b0 ; 
                     end
            wf0 :
                     begin
                        if (line1 == 1'b1 & line2 == 1'b1)
                           stato_next = e; 
                        else
                           stato_next = a; 
                        outp <= line1 ^ line2 ; 
                        overflw <= 1'b0 ; 
                     end
            wf1 :
                     begin
                        if (line1 == 1'b1 | line2 == 1'b1)
                           stato_next = e; 
                        else
                           stato_next = a; 
                        outp <= ~(line1 ^ line2) ; 
                        overflw <= 1'b0 ; 
                     end
         endcase 
  end
endmodule

