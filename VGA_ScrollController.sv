module VGA_ScrollController(
    input  logic clk,                          // System clock
    input  logic rst,                          // Reset signal
    input  logic [3:0] buttons,                // {btnU, btnD, btnL, btnR}
    input  logic [$clog2(640)-1:0] xPosIn,     // Original X position
    input  logic [$clog2(480)-1:0] yPosIn,     // Original Y position
    output logic [$clog2(640)-1:0] xPosOut,    // Scrolled X position
    output logic [$clog2(480)-1:0] yPosOut     // Scrolled Y position
);
    
    // VGA display dimensions
    localparam H_ACTIVE = 640;
    localparam V_ACTIVE = 480;
    
    // Scrolling offsets
    logic [$clog2(H_ACTIVE)-1:0] xOffset;
    logic [$clog2(V_ACTIVE)-1:0] yOffset;
    
    // Scrolling speed control - much slower for better visibility
    localparam SCROLL_SPEED_DIV = 23;  // Higher value = slower scrolling
    logic [23:0] scrollTimer;          // Timer for scroll speed
    
    // Direction control signals
    logic [1:0] scrollDirection;       // 00: right, 01: up, 10: down, 11: left
    
    // Extract button signals
    logic btnUp, btnDown, btnLeft, btnRight;
    assign {btnUp, btnDown, btnLeft, btnRight} = buttons;
    
    // Determine scrolling direction based on button inputs
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            scrollDirection <= 2'b00;  // Default: scroll right
        end else begin
            if (btnUp)
                scrollDirection <= 2'b01;  // Up
            else if (btnDown)
                scrollDirection <= 2'b10;  // Down
            else if (btnLeft)
                scrollDirection <= 2'b11;  // Left
            else if (btnRight)
                scrollDirection <= 2'b00;  // Right
        end
    end
    
    // Scrolling timer with much slower rate
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            scrollTimer <= 0;
            xOffset <= 0;
            yOffset <= 0;
        end else begin
            scrollTimer <= scrollTimer + 1;
            
            // Update offsets at a much slower rate
            if (scrollTimer[SCROLL_SPEED_DIV]) begin
                scrollTimer <= 0;
                if (|buttons) begin  // Only scroll if any button is pressed
                    case (scrollDirection)
                        2'b00: xOffset <= xOffset + 1;  // Right
                        2'b01: yOffset <= yOffset - 1;  // Up
                        2'b10: yOffset <= yOffset + 1;  // Down
                        2'b11: xOffset <= xOffset - 1;  // Left
                    endcase
                end
            end
        end
    end
    
    // Apply scrolling offsets to input coordinates with modulo operation
    // to ensure we stay within display bounds
    always_comb begin
        xPosOut = (xPosIn + xOffset) % H_ACTIVE;
        yPosOut = (yPosIn + yOffset) % V_ACTIVE;
    end
    
endmodule