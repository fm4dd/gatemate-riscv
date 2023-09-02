// -------------------------------------------------------
// soc.v FemtoRV Tutorial step05 regbank   @20230711 fm4dd
//
// Requires: Gatemate E1 eval board v3.1B
//
// Notes:
// Step 5 creates a RISC-V CPU register bank and state
// machine. 5 LEDS show the state.
//
// Code is tested on a Gatemate E1 eval board v3.1B
// E1 onboard user button SW3 is assigned to RESET.
// LEDS[7:0] is assigned to E1 onboard Leds D1..D8.
// 
// How to run: make, make prog and make test
// -------------------------------------------------------
`default_nettype none

module SOC (
    input  CLK,        // E1 system clock 
    input  RESET,      // E1 user button
    output [7:0] LEDS, // E1 onboard LEDs
    input  RXD,        // UART receive
    output TXD         // UART transmit
);

   wire clk;    // internal clock
   wire resetn; // internal reset signal, goes low on reset
   
   reg [31:0] MEM [0:447]; // 447 is min to get CC_BRAM_20K
   reg [31:0] PC;          // program counter
   reg [31:0] instr;       // current instruction
   wire [4:0] leds;

   initial begin
      PC = 0;
      
      // add x0, x0, x0
      //                   rs2   rs1  add  rd   ALUREG
      instr = 32'b0000000_00000_00000_000_00000_0110011;
      // add x1, x0, x0
      //                    rs2   rs1  add  rd   ALUREG
      MEM[0] = 32'b0000000_00000_00000_000_00001_0110011;
      // addi x1, x1, 1
      //             imm         rs1  add  rd   ALUIMM
      MEM[1] = 32'b000000000001_00001_000_00001_0010011;
      // addi x1, x1, 1
      //             imm         rs1  add  rd   ALUIMM
      MEM[2] = 32'b000000000001_00001_000_00001_0010011;
      // addi x1, x1, 1
      //             imm         rs1  add  rd   ALUIMM
      MEM[3] = 32'b000000000001_00001_000_00001_0010011;
      // addi x1, x1, 1
      //             imm         rs1  add  rd   ALUIMM
      MEM[4] = 32'b000000000001_00001_000_00001_0010011;

      // ebreak
      //                                        SYSTEM
      MEM[5] = 32'b000000000001_00000_000_00000_1110011;
       
   end

   
   // See the table P. 105 in RISC-V manual
   
   // The 10 RISC-V instructions
   wire isALUreg  =  (instr[6:0] == 7'b0110011); // rd <- rs1 OP rs2   
   wire isALUimm  =  (instr[6:0] == 7'b0010011); // rd <- rs1 OP Iimm
   wire isBranch  =  (instr[6:0] == 7'b1100011); // if(rs1 OP rs2) PC<-PC+Bimm
   wire isJALR    =  (instr[6:0] == 7'b1100111); // rd <- PC+4; PC<-rs1+Iimm
   wire isJAL     =  (instr[6:0] == 7'b1101111); // rd <- PC+4; PC<-PC+Jimm
   wire isAUIPC   =  (instr[6:0] == 7'b0010111); // rd <- PC + Uimm
   wire isLUI     =  (instr[6:0] == 7'b0110111); // rd <- Uimm   
   wire isLoad    =  (instr[6:0] == 7'b0000011); // rd <- mem[rs1+Iimm]
   wire isStore   =  (instr[6:0] == 7'b0100011); // mem[rs1+Simm] <- rs2
   wire isSYSTEM  =  (instr[6:0] == 7'b1110011); // special

   // The 5 immediate formats
   wire [31:0] Uimm={    instr[31],   instr[30:12], {12{1'b0}}};
   wire [31:0] Iimm={{21{instr[31]}}, instr[30:20]};
   wire [31:0] Simm={{21{instr[31]}}, instr[30:25],instr[11:7]};
   wire [31:0] Bimm={{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
   wire [31:0] Jimm={{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};

   // Source and destination registers
   wire [4:0] rs1Id = instr[19:15];
   wire [4:0] rs2Id = instr[24:20];
   wire [4:0] rdId  = instr[11:7];

   // function codes
   wire [2:0] funct3 = instr[14:12];
   wire [6:0] funct7 = instr[31:25];
   
   // The registers bank
   reg [31:0] RegisterBank [0:31];
   reg [31:0] rs1;
   reg [31:0] rs2;
   wire [31:0] writeBackData;
   wire        writeBackEn;
   assign writeBackData = 0; // for now
   assign writeBackEn = 0;   // for now

`ifdef BENCH   
   integer i;
   initial begin
      for(i=0; i<32; ++i) begin
	 RegisterBank[i] = 0;
      end
   end
`endif   

   // The state machine
   
   localparam FETCH_INSTR = 0;
   localparam FETCH_REGS  = 1;
   localparam EXECUTE     = 2;
   reg [1:0] state = FETCH_INSTR;
   
   always @(posedge clk) begin
      if(!resetn) begin
	 PC    <= 0;
	 state <= FETCH_INSTR;
	 instr <= 32'b0000000_00000_00000_000_00000_0110011; // NOP
      end else begin
	 if(writeBackEn && rdId != 0) begin
	    RegisterBank[rdId] <= writeBackData;
	 end
	 
	 case(state)
	   FETCH_INSTR: begin
	      instr <= MEM[PC];
	      state <= FETCH_REGS;
	   end
	   FETCH_REGS: begin
	      rs1 <= RegisterBank[rs1Id];
	      rs2 <= RegisterBank[rs2Id];
	      state <= EXECUTE;
	   end
	   EXECUTE: begin
	      if(!isSYSTEM) begin
		 PC <= PC + 1;
	      end
	      state <= FETCH_INSTR;	      
`ifdef BENCH      
	      if(isSYSTEM) $finish();
`endif      
	   end
	 endcase
      end 
   end 

   assign leds = isSYSTEM ? 31 : (1 << state);
   assign {LEDS[4:0], LEDS[7:5]} = {~leds, 3'b111};


`ifdef BENCH
   always @(posedge clk) begin
      if(state == FETCH_REGS) begin
	 case (1'b1)
	   isALUreg: $display(
			      "ALUreg rd=%d rs1=%d rs2=%d funct3=%b",
			      rdId, rs1Id, rs2Id, funct3
			      );
	   isALUimm: $display(
			      "ALUimm rd=%d rs1=%d imm=%0d funct3=%b",
			      rdId, rs1Id, Iimm, funct3
			      );
	   isBranch: $display("BRANCH");
	   isJAL:    $display("JAL");
	   isJALR:   $display("JALR");
	   isAUIPC:  $display("AUIPC");
	   isLUI:    $display("LUI");	
	   isLoad:   $display("LOAD");
	   isStore:  $display("STORE");
	   isSYSTEM: $display("SYSTEM");
	 endcase 
	 if(isSYSTEM) begin
	    $finish();
	 end
      end 
   end
`endif	      

   // Gearbox and reset circuitry.
   Clockworks #(
     .SLOW(21)         // Divide clock frequency by 2^21
   )CW(
     .CLK(CLK),
     .RESET(~RESET),   // Gatemate RESET needs ~ to flip
     .clk(clk),
     .resetn(resetn)
   );

   assign TXD  = 1'b0; // not used for now   
   
endmodule
