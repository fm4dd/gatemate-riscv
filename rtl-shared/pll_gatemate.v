/* 
 * 
 *   FPGA kind      : Gatemate CCGMA1
 *   Input frequency: 10 MHz
 */

 module femtoPLL #(
    parameter freq = 40   // default target MHz frequency as int
 ) (
    input wire pclk,
    output wire clk
 );

`ifdef BENCH
   // fix target MHz frequency string for iVerlog
   // which does not understand $sformatf()
   localparam freq_str = "10.0";
`else
   // convert target MHz frequency from int to string
   // CC_PLL description in UG1001 primitives library
   localparam freq_str = $sformatf("%d.0",freq);
`endif

   wire clk270, clk180, clk90, clk_ref_out;
   wire usr_pll_lock_stdy, usr_pll_lock;

   CC_PLL #(
      .REF_CLK("10.0"),    // PLL input clock speed in MHz
      .OUT_CLK(freq_str),  // PLL output frequency in MHz
      .PERF_MD("ECONOMY"), // LOWPOWER, ECONOMY, SPEED
      .LOW_JITTER(1),      // 0: disable, 1: enable low jitter mode
      .CI_FILTER_CONST(2), // optional CI filter constant
      .CP_FILTER_CONST(4)  // optional CP filter constant
   ) pll_inst (
      .CLK_REF(pclk), 
      .CLK_FEEDBACK(1'b0),
      .USR_CLK_REF(1'b0),
      .USR_LOCKED_STDY_RST(1'b0),
      .USR_PLL_LOCKED_STDY(usr_pll_lock_stdy),
      .USR_PLL_LOCKED(usr_pll_lock),
      .CLK270(clk270),
      .CLK180(clk180),
      .CLK90(clk90),
      .CLK0(clk),
      .CLK_REF_OUT(clk_ref_out)
   );
endmodule
