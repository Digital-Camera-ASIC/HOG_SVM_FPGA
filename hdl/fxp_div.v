
//--------------------------------------------------------------------------------------------------------
// Module  : fxp_div
// Type    : synthesizable
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: division
//           combinational logic
//           not recommended due to the long critical path
//--------------------------------------------------------------------------------------------------------

module fxp_div #(
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire [WIIA+WIFA-1:0] dividend,
    input  wire [WIIB+WIFB-1:0] divisor,
    output reg  [WOI +WOF -1:0] out,
    output reg                  overflow
);

initial {out, overflow} = 0;

localparam WRI = WOI+WIIB > WIIA ? WOI+WIIB : WIIA;
localparam WRF = WOF+WIFB > WIFA ? WOF+WIFB : WIFA;

reg                  sign = 1'b0;
reg  [WIIA+WIFA-1:0] udividend = 0;
reg  [WIIB+WIFB-1:0]  udivisor = 0;
reg  [ WRI+ WRF-1:0] acc=0, acct=0;
wire [ WRI+ WRF-1:0] divd, divr;

localparam  [WIIA+WIFA-1:0] ONEA = 1;
localparam  [WIIB+WIFB-1:0] ONEB = 1;
localparam  [WOI + WOF-1:0] ONEO = 1;

always @ (*) begin  // convert dividend and divisor to positive number
    sign      = dividend[WIIA+WIFA-1] ^ divisor[WIIB+WIFB-1];
    udividend = dividend[WIIA+WIFA-1] ? (~dividend)+ONEA : dividend;
    udivisor  =  divisor[WIIB+WIFB-1] ? (~ divisor)+ONEB : divisor ;
end

fxp_zoom # (
    .WII      ( WIIA      ),
    .WIF      ( WIFA      ),
    .WOI      ( WRI       ),
    .WOF      ( WRF       ),
    .ROUND    ( 0         )
) dividend_zoom (
    .in       ( udividend ),
    .out      ( divd      ),
    .overflow (           )
);

fxp_zoom # (
    .WII      ( WIIB      ),
    .WIF      ( WIFB      ),
    .WOI      ( WRI       ),
    .WOF      ( WRF       ),
    .ROUND    ( 0         )
)  divisor_zoom (
    .in       ( udivisor  ),
    .out      ( divr      ),
    .overflow (           )
);

integer shamt;

always @ (*) begin
    acc = 0;
    for(shamt=WOI-1; shamt>=-WOF; shamt=shamt-1) begin
        if(shamt>=0)
            acct = acc + (divr<<shamt);
        else
            acct = acc + (divr>>(-shamt));
        if( acct <= divd ) begin
            acc = acct;
            out[WOF+shamt] = 1'b1;
        end else
            out[WOF+shamt] = 1'b0;
    end
    
    if(ROUND && ~(&out)) begin
        acct = acc+(divr>>(WOF));
        if(acct-divd<divd-acc)
            out=out+1;
    end
    
    overflow = 1'b0;
    if(sign) begin
        if(out[WOI+WOF-1]) begin
            if(|out[WOI+WOF-2:0]) overflow = 1'b1;
            out[WOI+WOF-1] = 1'b1;
            out[WOI+WOF-2:0] = 0;
        end else begin
            out = (~out) + ONEO;
        end
    end else begin
        if(out[WOI+WOF-1]) begin
            overflow = 1'b1;
            out[WOI+WOF-1] = 1'b0;
            out[WOI+WOF-2:0] = {(WOI+WOF){1'b1}};
        end
    end
end

endmodule
