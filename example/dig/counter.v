/*
* COUNTER.v -- Simple Digital Counter Example in Verilog
*
* (c) 2021 Harald Pretl (harald.pretl@jku.at)
* Johannes Kepler University Linz, Institute for Integrated Circuits
*/

module counter #(parameter WIDTH=4) (
  output reg [WIDTH-1:0] out_o,
  input                  clk_i,
  input	                 reset_i
);

  always @(posedge clk_i) begin
    // we use a synchronous reset
    if (reset_i) begin
      out_o <= {WIDTH{1'b0}};
    end else begin
      out_o <= out_o + 1'b1;
    end
  end

endmodule // counter
