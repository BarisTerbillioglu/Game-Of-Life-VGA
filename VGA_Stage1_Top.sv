module VGA_Stage1_Top(
    input  logic clk,           // System clock (100 MHz on Basys3)
    input  logic rst,           // Reset signal
    input  logic btnU,          // Up button - T18
    input  logic btnD,          // Down button - U17
    input  logic btnL,          // Left button - W19
    input  logic btnR,          // Right button - T17
    input  logic sw0,           // Left switch (unused in Stage 1)
    input  logic sw15,          // Right switch (unused in Stage 1)
    output logic [3:0] vgaRed,  // 4-bit VGA red channel
    output logic [3:0] vgaGreen,// 4-bit VGA green channel
    output logic [3:0] vgaBlue, // 4-bit VGA blue channel
    output logic hSync,         // Horizontal sync
    output logic vSync          // Vertical sync
);

    // VGA timing parameters
    localparam H_ACTIVE = 640;
    localparam V_ACTIVE = 480;
    
    // Internal signals
    logic pixelClk;                        // 25MHz pixel clock
    logic [$clog2(H_ACTIVE)-1:0] xPos;     // X position in active area
    logic [$clog2(V_ACTIVE)-1:0] yPos;     // Y position in active area
    logic pixelActive;                     // Pixel is in active display area
    
    // Button input signals for pattern controller
    logic [3:0] buttons;
    assign buttons = {btnU, btnD, btnL, btnR};
    
    // Modified pixel coordinates with scrolling applied
    logic [$clog2(H_ACTIVE)-1:0] xPosScrolled;
    logic [$clog2(V_ACTIVE)-1:0] yPosScrolled;
    
    // Checkerboard pattern parameters (increased size for better visibility)
    localparam CHECKER_SIZE = 16;  // Increased from 8 to 16
    
    // Start with a stationary pattern
    logic scrollingEnabled;
    logic [23:0] delayCounter;
    logic [3:0] lastButtons;
    
    // Delay counter for button debouncing and controlled scrolling
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            delayCounter <= 0;
            scrollingEnabled <= 0;
            lastButtons <= 4'b0000;
        end else begin
            delayCounter <= delayCounter + 1;
            lastButtons <= buttons;
            
            // Enable scrolling only when a button is pressed
            if (buttons != 4'b0000 && lastButtons == 4'b0000) begin
                scrollingEnabled <= 1;
            end
            
            // Reset to stationary pattern if reset pressed
            if (rst) begin
                scrollingEnabled <= 0;
            end
        end
    end
    
    // Generate pixel clock
    VGA_PixelClock pixelClockGen(
        .clk(clk),
        .rst(rst),
        .pixelClk(pixelClk)
    );
    
    // VGA controller for timing and sync signals
    VGA_Controller vgaController(
        .pixelClk(pixelClk),
        .rst(rst),
        .xPos(xPos),
        .yPos(yPos),
        .pixelActive(pixelActive),
        .hSync(hSync),
        .vSync(vSync)
    );
    
    // Scrolling controller - only enabled when scrollingEnabled is true
    VGA_ScrollController scrollController(
        .clk(clk),
        .rst(rst),
        .buttons(scrollingEnabled ? buttons : 4'b0000),
        .xPosIn(xPos),
        .yPosIn(yPos),
        .xPosOut(xPosScrolled),
        .yPosOut(yPosScrolled)
    );
    
    // Generate checkerboard pattern with pure black and white
    logic checkerPattern;
    assign checkerPattern = (((xPosScrolled / CHECKER_SIZE) & 1) ^ ((yPosScrolled / CHECKER_SIZE) & 1));
    
    // Set VGA color output based on checkerboard pattern - use pure colors
    always_comb begin
        if (pixelActive) begin
            if (checkerPattern) begin
                vgaRed   = 4'hF; // Pure white (maximum brightness)
                vgaGreen = 4'hF;
                vgaBlue  = 4'hF;
            end else begin
                vgaRed   = 4'h0; // Pure black
                vgaGreen = 4'h0;
                vgaBlue  = 4'h0;
            end
        end else begin
            vgaRed   = 4'h0; // Black during blanking periods
            vgaGreen = 4'h0;
            vgaBlue  = 4'h0;
        end
    end

endmodule