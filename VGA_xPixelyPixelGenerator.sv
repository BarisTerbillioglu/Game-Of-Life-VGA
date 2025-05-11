module VGA_xPixelyPixelGenerator
    #(
        parameter HPIXEL = 640,
        parameter VPIXEL = 480,
        parameter PIXEL_LIMIT = 800,
        parameter LINE_LIMIT = 525
    )
    (
        input  logic [11:0] hCount,
        input  logic [11:0] vCount,
        output logic [11:0] xPixel,
        output logic [11:0] yPixel,
        output logic pixelDrawing
    );
    
    assign pixelDrawing = (hCount < HPIXEL) && (vCount < VPIXEL); 
    
    assign xPixel = (pixelDrawing) ? hCount : 0;
    assign yPixel = (pixelDrawing) ? vCount : 0;

endmodule