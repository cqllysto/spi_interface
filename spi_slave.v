///////////////////////////////////////////////////////////////////////////////
// Description: SPI (Serial Peripheral Interface) Slave
//              Creates slave based on input configuration.
//              Sends a byte one bit at a time on MISO
//              Will also receive byte data one bit at a time on MOSI.
//              Any data on input byte will be shipped out on MISO.
//
//              To kick-off transaction, user must pulse i_RX_DV.
//              This module supports multi-byte transmissions by pulsing
//              i_RX_DV and loading up i_RX_Byte when o_RX_Ready is high.
//
//              This module is only responsible for controlling Clk, MOSI, 
//              and MISO.
//
// Note:        i_Clk must be at least 2x faster than i_SPI_Clk
//
// Parameters:  SPI_MODE, can be 0, 1, 2, or 3.  See above.
//              Can be configured in one of 4 modes:
//              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
//               0   |             0             |        0
//               1   |             0             |        1
//               2   |             1             |        0
//               3   |             1             |        1
//              More: https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus#Mode_numbers
//              CLKS_PER_HALF_BIT - Sets frequency of o_SPI_Clk.  o_SPI_Clk is
//              derived from i_Clk.  Set to integer number of clocks for each
//              half-bit of SPI data.  E.g. 100 MHz i_Clk, CLKS_PER_HALF_BIT = 2
//              would create o_SPI_CLK of 25 MHz.  Must be >= 2
//
///////////////////////////////////////////////////////////////////////////////

module SPI_SLAVE
  #(parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF_BIT = 2)
  (
   // Control/Data Signals,
   input        i_Rst_L,     // FPGA Reset
   input        i_Clk,       // FPGA Clock
   
   // TX (MOSI) Signals
   input [7:0]  i_RX_Byte,        // Byte to transmit on MOSI
   input        i_RX_DV,          // Data Valid Pulse with i_RX_Byte
   output reg   o_RX_Ready,       // Transmit Ready for next byte
   
   // RX (MISO) Signals
   output reg       o_TX_DV,     // Data Valid pulse (1 clock cycle)
   output reg [7:0] o_TX_Byte,   // Byte received on MISO

   // SPI Interface
   output reg o_SPI_Clk,
   input      i_SPI_MOSI,
   output reg o_SPI_MISO
   );

  // SPI Interface (All Runs at SPI Clock Domain)
  wire w_CPOL;     // Clock polarity
  wire w_CPHA;     // Clock phase

  reg [$clog2(CLKS_PER_HALF_BIT*2)-1:0] r_SPI_Clk_Count;
  reg r_SPI_Clk;
  reg [4:0] r_SPI_Clk_Edges;
  reg r_Leading_Edge;
  reg r_Trailing_Edge;
  reg       r_RX_DV;
  reg [7:0] r_RX_Byte;

  reg [2:0] r_TX_Bit_Count;
  reg [2:0] r_RX_Bit_Count;

  // CPOL: Clock Polarity
  // CPOL=0 means clock idles at 0, leading edge is rising edge.
  // CPOL=1 means clock idles at 1, leading edge is falling edge.
  assign w_CPOL  = (SPI_MODE == 2) | (SPI_MODE == 3);

  // CPHA: Clock Phase
  // CPHA=0 means the "out" side changes the data on trailing edge of clock
  //              the "in" side captures data on leading edge of clock
  // CPHA=1 means the "out" side changes the data on leading edge of clock
  //              the "in" side captures data on the trailing edge of clock
  assign w_CPHA  = (SPI_MODE == 1) | (SPI_MODE == 3);


endmodule // SPI_Master