module VGA_PixelGenerator(
    input  logic [$clog2(800)-1:0] hCount,     // Horizontal counter
    input  logic [$clog2(525)-1:0] vCount,     // Vertical counter
    output logic [$clog2(640)-1:0] xPos,       // X position within active area
    output logic [$clog2(480)-1:0] yPos,       // Y position within active area
    output logic pixelActive                   // Pixel is in active display area
);
    
    // VGA timing parameters
    localparam H_ACTIVE = 640;
    localparam V_ACTIVE = 480;
    
    // Determine if current pixel is in the active display area
    assign pixelActive = (hCount < H_ACTIVE) && (vCount < V_ACTIVE);
    
    // Calculate the X and Y coordinates within the active area
    assign xPos = pixelActive ? hCount : 0;
    assign yPos = pixelActive ? vCount : 0;
    
endmodule