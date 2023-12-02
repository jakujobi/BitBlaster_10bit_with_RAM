module t_ff(
    input logic t,
    input logic clk,
    output logic q,
    output logic q_bar
);

logic tn, tandq_bar, tnandq, tnandq_barortnandq;
// tn = not t
// tnandqbar = tn & q_bar
// tnandq = tn & q
// tnandqbarortnandq = tnandqbar | tnandq

assign tn = ~t;
assign tnandq = tn & q;
assign tandq_bar = t & q_bar;
assign tnandq_barortnandq = tandq_bar | tnandq;

d_ff module1 (
    .d(tnandq_barortnandq),
    .clk(clk),
    .q(q),
    .q_bar(q_bar)
);


// module t_ff(input t, input clk, output reg q);

// always @(posedge clk) begin
//     if (t) begin
//         q <= ~q;
//     end
// end

// endmodule


endmodule