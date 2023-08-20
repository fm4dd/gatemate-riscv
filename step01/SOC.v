// -------------------------------------------------------
// SOC.v FemtoRV Tutorial step01 blinky    @20230711 fm4dd
//
// Requires: Gatemate E1 eval board v3.1B
//
// Note:
// Code is tested on a Gatemate E1 eval board v3.1B
// E1 onboard user button SW3 is assigned to RESET.
// LEDS[7:0] is assigned to E1 onboard Leds D1..D8.
// -------------------------------------------------------
   module SOC (
       input  CLK,        
       input  RESET,      
       output [7:0] LEDS, 
       input  RXD,        
       output TXD         
   );

   reg [4:0] count = 0;
   always @(posedge CLK) begin
      count <= count + 1;
   end
   assign LEDS[4:0] = ~count; // ~ to invert data
   assign LEDS[7:5] = 3'b111; // turn off LED5..7
   assign TXD  = 1'b0;        // not used for now

   endmodule
