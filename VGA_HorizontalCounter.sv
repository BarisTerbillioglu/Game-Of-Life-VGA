module VGA_HorizontalCounter
    #(
        parameter PIXEL_LIMIT = 799
    )
    (
        input  logic pixelClk,
        input  logic rst, 
        output logic [11:0] hCount,
        output logic EndOfLine
    );

    assign EndOfLine = (hCount == PIXEL_LIMIT);

    always_ff @(posedge pixelClk or posedge rst) begin
        if (rst) begin
            hCount <= 0;
        end else begin
            if (hCount == PIXEL_LIMIT)
                hCount <= 0;
            else
                hCount <= hCount + 1;
        end
    end

endmodule