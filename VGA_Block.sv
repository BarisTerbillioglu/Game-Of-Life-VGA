module VGA_Block
    #(
        parameter MODES = 0,

        parameter DIV_BY = (MODES == 0) ? 16'h338F : ((MODES == 1) ? 16'h51EC : ((MODES == 2) ? 16'h851F : 16'hAF1B )),

        parameter HPIXEL = (MODES == 0) ? 640 : ((MODES == 1) ? 800: ((MODES == 2) ? 1024 : 1366)),
        parameter H_FRONT_PORCH = (MODES == 0) ? 16 : ((MODES == 1) ? 40: ((MODES == 2) ? 24 : 70)),
        parameter H_SYNC_PULSE = (MODES == 0) ? 96 : ((MODES == 1) ? 128: ((MODES == 2) ? 136 : 143)),
        parameter H_BACK_PORCH = (MODES == 0) ? 48 : ((MODES == 1) ? 88: ((MODES == 2) ? 160 : 213)),

        parameter VPIXEL = (MODES == 0) ? 480 : ((MODES == 1) ? 600: ((MODES == 2) ? 768 : 768)),
        parameter V_FRONT_PORCH = (MODES == 0) ? 10 : ((MODES == 1) ? 1: ((MODES == 2) ? 3 : 3)),
        parameter V_SYNC_PULSE = (MODES == 0) ? 2 : ((MODES == 1) ? 4: ((MODES == 2) ? 6 : 3)),
        parameter V_BACK_PORCH = (MODES == 0) ? 33 : ((MODES == 1) ? 23: ((MODES == 2) ? 29 : 24)),

        parameter H_Polarity = (MODES == 0) ? 0: ((MODES == 1) ? 1 : ((MODES == 2) ? 0 : 1)),
        parameter V_Polarity = (MODES == 0) ? 0: ((MODES == 1) ? 1 : ((MODES == 2) ? 0 : 1)),

        parameter PIXEL_LIMIT = HPIXEL + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH,
        parameter LINE_LIMIT = VPIXEL + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH
    )
    (
        input  logic systemClk_125MHz,
        input  logic rst,

        output logic [11:0] xPixel,          // Fixed bit width
        output logic [11:0] yPixel,          // Fixed bit width
        output logic pixelDrawing,

        output logic hSYNC,
        output logic vSYNC
    );

    logic pixelClk, EndOfLine;
    logic [11:0] hCount;                     // Fixed bit width
    logic [11:0] vCount;                     // Fixed bit width

    VGA_pixelClockGenerator 
        #(
            .DIV_BY(DIV_BY)
        )
        VGApixelClockGneratorIns
        (
            .systemClk(systemClk_125MHz),
            .rst(rst),
            .pixelClk(pixelClk)
        );

    // Use VGA_HorizontalCounter
    VGA_HorizontalCounter
        #(
            .PIXEL_LIMIT(PIXEL_LIMIT-1)
        )
        HCounterIns
        (
            .pixelClk(pixelClk),
            .rst(rst), 
            .hCount(hCount),
            .EndOfLine(EndOfLine)
        );

    // Use VGA_HorizontalSyncGenerator (updated name)
    VGA_HorizontalSyncGenerator 
        #(
            .HPIXEL(HPIXEL), 
            .H_FRONT_PORCH(H_FRONT_PORCH), 
            .H_SYNC_PULSE(H_SYNC_PULSE), 
            .H_BACK_PORCH(H_BACK_PORCH),
            .H_Polarity(H_Polarity)
        ) 
        HSyncGenIns
        (
            .hCount(hCount),
            .hSYNC(hSYNC)
        );

    // Use VGA_VerticalCounter
    VGA_VerticalCounter
        #(
            .LINE_LIMIT(LINE_LIMIT-1)
        )
        VerticalCOuntins
        (
            .pixelClk(pixelClk),
            .rst(rst), 
            .Enable(EndOfLine),
            .vCount(vCount)
        );

    // Use VGA_VerticalSyncGenerator (updated name)
    VGA_VerticalSyncGenerator 
        #(
            .VPIXEL(VPIXEL),
            .V_FRONT_PORCH(V_FRONT_PORCH),
            .V_SYNC_PULSE(V_SYNC_PULSE),
            .V_BACK_PORCH(V_BACK_PORCH),
            .V_Polarity(V_Polarity)
        ) 
        VsyngenIns
        (
            .vCount(vCount),
            .vSYNC(vSYNC)
        );

    // Use VGA_xPixelyPixelGenerator
    VGA_xPixelyPixelGenerator
        #(
            .HPIXEL(HPIXEL),
            .VPIXEL(VPIXEL),
            .PIXEL_LIMIT(PIXEL_LIMIT),
            .LINE_LIMIT(LINE_LIMIT)
        )
        xPixelyPixelGeneratorIns
        (
            .hCount(hCount),
            .vCount(vCount),
            .xPixel(xPixel),
            .yPixel(yPixel),
            .pixelDrawing(pixelDrawing)
        );

endmodule