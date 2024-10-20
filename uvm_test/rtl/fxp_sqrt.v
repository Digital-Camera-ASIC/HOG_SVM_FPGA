

//--------------------------------------------------------------------------------------------------------
// Module  : fxp_sqrt
// Type    : synthesizable
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: square root
//           combinational logic
//           not recommended due to the long critical path
//--------------------------------------------------------------------------------------------------------

module fxp_sqrt #(
    parameter WII  = 8,
    parameter WIF  = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire [WII+WIF-1:0] in,
    output wire [WOI+WOF-1:0] out,
    output wire               overflow
);

localparam WTI = (WII%2==1) ? WII+1 : WII;
localparam WRI = WTI/2;

localparam [WII+WIF-1:0] ONEI = 1;
localparam [WTI+WIF-1:0] ONET = 1;
localparam [WRI+WIF-1:0] ONER = 1;

reg [WRI+WIF:0] resushort = 0;

integer ii;

reg                sign;
reg  [WTI+WIF-1:0] inu, resu2, resu2tmp, resu;

always @ (*) begin
    sign = in[WII+WIF-1];
    inu = 0;
    inu[WII+WIF-1:0] = sign ? (~in)+ONEI : in;
    {resu2,resu} = 0;
    for(ii=WRI-1; ii>=-WIF; ii=ii-1) begin
        resu2tmp = resu2;
        if(ii>=0) resu2tmp = resu2tmp + (resu<<( 1+ii));
        else      resu2tmp = resu2tmp + (resu>>(-1-ii));
        if(2*ii+WIF>=0) resu2tmp = resu2tmp + ( ONET << (2*ii+WIF) );
        if(resu2tmp<=inu && inu!=0) begin
            resu[ii+WIF] = 1'b1;
            resu2 = resu2tmp;
        end
    end
    resushort = sign ? (~resu[WRI+WIF:0])+ONER : resu[WRI+WIF:0];
end

fxp_zoom # (
    .WII      ( WRI+1          ),
    .WIF      ( WIF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( resushort      ),
    .out      ( out            ),
    .overflow ( overflow       )
);

endmodule

