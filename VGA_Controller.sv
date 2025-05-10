module VGA_Controller(
    input  logic pixelClk,                     // 25MHz pixel clock
    input  logic rst,                          // Reset signal
    output logic [$clog2(640)-1:0] xPos,       // X position within active area
    output logic [$clog2(480)-1:0] yPos,       // Y position within active area
    output logic pixelActive,                  // Pixel is in active display area
    output logic hSync,                        // Horizontal sync signal
    output logic vSync                         // Vertical sync signal
);
    
    // Counter outputs
    logic [$clog2(800)-1:0] hCount;
    logic [$clog2(525)-1:0] vCount;
    logic endOfLine;
    
    // Instantiate horizontal counter
    VGA_HCounter hCounter(
        .pixelClk(pixelClk),
        .rst(rst),
        .hCount(hCount),
        .endOfLine(endOfLine)
    );
    
    // Instantiate vertical counter
    VGA_VCounter vCounter(
        .pixelClk(pixelClk),
        .rst(rst),
        .enable(endOfLine),
        .vCount(vCount)
    );
    
    // Instantiate sync generators
    VGA_HSyncGenerator hSyncGen(
        .hCount(hCount),
        .hSync(hSync)
    );
    
    VGA_VSyncGenerator vSyncGen(
        .vCount(vCount),
        .vSync(vSync)
    );
    
    // Instantiate pixel generator
    VGA_PixelGenerator pixelGen(
        .hCount(hCount),
        .vCount(vCount),
        .xPos(xPos),
        .yPos(yPos),
        .pixelActive(pixelActive)
    );
    
endmodule