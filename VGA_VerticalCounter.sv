module VGA_VerticalCounter
    #(
        parameter LINE_LIMIT = 524
    )
    (
        input  logic pixelClk,
        input  logic rst, 
        input  logic Enable,
        output logic [11:0] vCount
    );

    always_ff @(posedge pixelClk or posedge rst) begin
        if (rst) begin
            vCount <= 0;
        end else begin
            if (Enable) begin
                if (vCount == LINE_LIMIT)
                    vCount <= 0;
                else
                    vCount <= vCount + 1;
            end
        end
    end

endmodule