module VGA_Stage2_Top_Modular(
    input  logic clk,           // System clock (100 MHz on Basys3)
    input  logic rst,           // Reset signal
    input  logic btnU,          // Up button
    input  logic btnD,          // Down button
    input  logic btnL,          // Left button
    input  logic btnR,          // Right button
    input  logic btnC,          // Center button for drawing
    input  logic sw15,          // Right switch - Clear canvas switch
    output logic [3:0] R,       // 4-bit VGA red channel
    output logic [3:0] G,       // 4-bit VGA green channel
    output logic [3:0] B,       // 4-bit VGA blue channel
    output logic hSYNC,         // Horizontal sync
    output logic vSYNC          // Vertical sync
);

    // Internal signals
    logic [11:0] xPixel;        // X position in active area
    logic [11:0] yPixel;        // Y position in active area
    logic pixelDrawing;         // Pixel is in active display area
    
    // Cursor signals
    logic [9:0] cursorX;        // 10 bits for cursor X (0-639)
    logic [8:0] cursorY;        // 9 bits for cursor Y (0-479)
    logic isCursor;
    
    // Drawing signals
    logic drawPixel;
    logic clearCanvas;
    logic [9:0] drawX;          // 10 bits for draw X
    logic [8:0] drawY;          // 9 bits for draw Y
    logic pixelState;
    
    // Generate pixel clock (25MHz from 100MHz)
    VGA_pixelClockGenerator 
        #(.DIV_BY(16'h2882))    // For 25MHz from 100MHz
        pixelClockGen(
            .systemClk(clk),
            .rst(rst),
            .pixelClk()  // Not using pixelClk directly
        );
    
    // VGA controller using your existing VGA_Block module
    VGA_Block 
        #(.MODES(0))            // 640x480 mode
        vgaBlock(
            .systemClk_125MHz(clk),
            .rst(rst),
            .xPixel(xPixel),
            .yPixel(yPixel),
            .pixelDrawing(pixelDrawing),
            .hSYNC(hSYNC),
            .vSYNC(vSYNC)
        );
    
    // Cursor controller
    Cursor_Controller cursorController(
        .clk(clk),
        .rst(rst),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .cursorX(cursorX),
        .cursorY(cursorY)
    );
    
    // Cursor renderer
    Cursor_Renderer cursorRenderer(
        .xPos(xPixel[9:0]),
        .yPos(yPixel[8:0]),
        .cursorX(cursorX),
        .cursorY(cursorY),
        .pixelActive(pixelDrawing),
        .isCursor(isCursor)
    );
    
    // Drawing controller
    Drawing_Controller drawingController(
        .clk(clk),
        .rst(rst),
        .btnC(btnC),
        .sw15(sw15),
        .cursorX(cursorX),
        .cursorY(cursorY),
        .drawPixel(drawPixel),
        .clearCanvas(clearCanvas),
        .drawX(drawX),
        .drawY(drawY)
    );
    
    // Canvas memory
    Canvas_Memory canvasMemory(
        .clk(clk),
        .rst(rst),
        .clearCanvas(clearCanvas),
        .drawPixel(drawPixel),
        .writeX(drawX),
        .writeY(drawY),
        .readX(xPixel[9:0]),
        .readY(yPixel[8:0]),
        .pixelState(pixelState)
    );
    
    // Canvas renderer for 4-bit RGB
    Canvas_Renderer_4Bit canvasRenderer(
        .pixelActive(pixelDrawing),
        .isCursor(isCursor),
        .pixelState(pixelState),
        .vgaRed(R),
        .vgaGreen(G),
        .vgaBlue(B)
    );

endmodule