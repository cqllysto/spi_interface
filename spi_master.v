module spi_master 
  #(parameter CLK_DIV = 2,
    parameter SPI_MODE = 0)
    (  
    // Control Signals
    input rst, // FPGA reset
    output clk, // FPGA clock

    // MOSI (TX) Signals
    input [7:0] i_mosi_byte, // Data to transmit on MOSI
    input i_mosi_dv,    // Data valid pulse with MOSI data
    output o_mosi_ready,     // Transmit ready for next byte

    // MISO (RX) Signals
    output reg o_miso_dv, // Data valid pulse 
    output reg [7:0] o_miso_byte, // Data received by MISO

    // SPI Interface
    output reg o_pi_clk,
    output reg o_spi_mosi,
    input i_spi_miso 
    );

    // SPI Interface
    wire w_cpol;
    wire w_cpha;

    reg [$clog2(CLK_DIV*2)-1:0] r_spi_clk_count;
    reg r_spi_clk;
    reg [4:0] r_spi_clk_edges;
    reg r_leading_edge;
    reg r_trailing_edge;
    reg r_mosi_dv;
    reg [7:0] r_mosi_byte;
    reg [2:0] r_miso_bit_count;
    reg [2:0] r_mosi_bit_count;


    // Clock Polarity
    // CPOL = 0 means clock idles at 0, leading edge is the rising edge
    // CPOL = 1 means clock idles at 1, leading edge is the falling edge
    assign w_cpol = (SPI_MODE == 2) | (SPI_MODE == 3);

    // Clock Phase
    // cpha = 0 means the "out" side changes the data on the trailing edge of the clock
                    // the "in" side caputures the data on the leading edge of the clock
    // cpha = 0 means the "out" side changes the data on the leading edge of the clock
                    // the "in" side caputures the data on the trailing edge of the clock
    assign w_cpha = (SPI_MODE == 1) | (SPI_MODE == 3);

// Generate SPI clock correct number of times when DV pulse comes in
always @(posedge clk or negedge rst)
begin
  if (~rst)
  begin
    o_mosi_ready <= 1'b0;
    r_spi_clk_edges <= 0;
    r_leading_edge <= 1'b0;
    r_trailing_edge <= 1'b0;
    r_spi_clk <= w_cpol; // assign default state to idle state
    r_spi_clk_count <= 0;
  end

end




endmodule