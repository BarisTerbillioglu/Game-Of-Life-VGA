module VGA_HCounter(
    input  logic pixelClk,                // 25MHz pixel clock
    input  logic rst,                     // Reset signal
    output logic [$clog2(800)-1:0] hCount,// Horizontal counter (0-799)
    output logic endOfLine                // End of line indicator
);
    
    // VGA horizontal timing parameters - exact timing for 640x480@60Hz
    localparam H_TOTAL = 800; // Total horizontal pixels (including blanking)
    
    // Horizontal counter
    always_ff @(posedge pixelClk or posedge rst) begin
        if (rst) begin
            hCount <= 0;
        end else begin
            if (hCount == H_TOTAL - 1)
                hCount <= 0;
            else
                hCount <= hCount + 1;
        end
    end
    
    // End of line signal - triggered exactly at the end of line
    assign endOfLine = (hCount == H_TOTAL - 1);
    
endmodule