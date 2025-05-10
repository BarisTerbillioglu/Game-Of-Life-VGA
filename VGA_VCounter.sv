module VGA_VCounter(
    input  logic pixelClk,                // 25MHz pixel clock
    input  logic rst,                     // Reset signal
    input  logic enable,                  // Enable signal (from endOfLine)
    output logic [$clog2(525)-1:0] vCount // Vertical counter (0-524)
);
    
    // VGA vertical timing parameters - exact timing for 640x480@60Hz
    localparam V_TOTAL = 525; // Total vertical lines (including blanking)
    
    // Vertical counter
    always_ff @(posedge pixelClk or posedge rst) begin
        if (rst) begin
            vCount <= 0;
        end else if (enable) begin
            if (vCount == V_TOTAL - 1)
                vCount <= 0;
            else
                vCount <= vCount + 1;
        end
    end
    
endmodule