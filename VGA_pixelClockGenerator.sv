module VGA_pixelClockGenerator 
    #(
        parameter DIV_BY = 16'h338F
    )
    (
        input  logic systemClk,
        input  logic rst,
        output logic pixelClk
    );

    logic [15:0] pix_cnt;
    logic pix_stb;

    always_ff @(posedge systemClk) begin
        if(rst == 1)
            {pix_stb, pix_cnt} <= 0;
        else
            {pix_stb, pix_cnt} <= pix_cnt + DIV_BY;
    end

    assign pixelClk = pix_stb;

endmodule