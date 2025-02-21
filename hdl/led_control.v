module led_control #(
    parameter   SW_W    = 11 // slide window width

) (
    input                       clk,
    input                       rst,
    input                       o_valid,
    input                       is_person,
    input   [SW_W - 1   : 0]    sw_id, // slide window index
    output reg                  led
);
    always @(posedge clk) begin
        if(~rst)
            led <= 0;
        else if(o_valid && ~|sw_id && ~is_person) begin // valid and sw_id == 0 and not person
            led <= 0;
        end else if(is_person)
            led <= 1;
    end
endmodule