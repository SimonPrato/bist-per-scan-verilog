`timescale 1ns / 1ps

module b01_tb;

/* declaracao de um array de 10 vectores com 2 bits cada
   (usado para armazenar os vectores de teste lidos de um ficheiro) */
reg [0:1] pattern_mem[0:9];        

/* declaracao das entradas que nao necessitam de receber vectores
   de teste (clock e reset) */
reg clk, res;

/* declaracao das entradas e saidas */                     
wire outp, over, pin_1, pin_2;

/* declaracao da variavel usada para indexar o array */
integer index;  

/* correspondencia das entradas do circuito aos bits
   armazenados no array, usando a variavel "index" para
   indexacao */                    
assign {pin_1, pin_2} = pattern_mem[index]; 

/* instanciacao do modulo b01 e correspondencia dos terminais */
b01 uut ( .line1(pin_1),
          .line2(pin_2),
          .reset(res),
          .outp(outp),
          .overflw(over),
          .clock(clk));

initial
begin

  /* inicializacao do reset a '1' (estado activo) */
  res = 1;

  /* inicializacao do clock a '0' */
  clk = 0;

  /* apos 100ns o reset passa a '0' (estado desactivo) */
  #100 res = 0;

  /* inicializacao do index que depois sera incrementado em cada clock */
  index = 0;

  /* le o array de bits (vectores de teste) do ficheiro externo b01.vec */
  $readmemb("b01.vec", pattern_mem);
 
  forever
  begin
    /* nos flancos descendentes sao mostrados os sinais e incrementado o index para seleccao do
       proximo vector de teste */
    @(negedge clk)
    begin
      $display( "index %d, line1 %b, line2 %b, out %b, over %b", index+1, pin_1, pin_2, outp, over);

      index = index + 1;
    end
  end
end

/* processo para geracao do clock com periodo 2000 */
always 
  #1000 clk = ~clk;

initial
begin
  /* condicao para terminar a simulacao: chegar a posicao 10 do array */
  wait(index == 10)   

  $finish;
end

endmodule
