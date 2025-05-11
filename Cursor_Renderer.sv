module Cursor_Renderer(
    input  logic [$clog2(640)-1:0] xPos,
    input  logic [$clog2(480)-1:0] yPos,
    input  logic [$clog2(640)-1:0] cursorX,
    input  logic [$clog2(480)-1:0] cursorY,
    input  logic pixelActive,
    output logic isCursor
);

    // Plus-shaped cursor display logic
    always_comb begin
        isCursor = pixelActive && (
            // Horizontal bar (5 pixels wide)
            ((xPos >= cursorX - 2) && (xPos <= cursorX + 2) && (yPos == cursorY)) ||
            // Vertical bar (5 pixels tall)
            ((yPos >= cursorY - 2) && (yPos <= cursorY + 2) && (xPos == cursorX))
        );
    end

endmodule