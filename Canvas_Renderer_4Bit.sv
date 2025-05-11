module Canvas_Renderer_4Bit(
    input  logic pixelActive,
    input  logic isCursor,
    input  logic pixelState,
    output logic [3:0] vgaRed,    // 4-bit red (Basys3 limitation)
    output logic [3:0] vgaGreen,  // 4-bit green  
    output logic [3:0] vgaBlue    // 4-bit blue
);

    // Debug: Make drawn pixels more visible with bright colors
    always_comb begin
        if (pixelActive) begin
            if (isCursor) begin
                // Cursor color - bright green
                vgaRed   = 4'b0000;
                vgaGreen = 4'b1111;
                vgaBlue  = 4'b0000;
            end else if (pixelState) begin
                // Drawn pixel color - bright red for maximum visibility
                vgaRed   = 4'b1111;
                vgaGreen = 4'b0000;
                vgaBlue  = 4'b0000;
            end else begin
                // Background color - white
                vgaRed   = 4'b1111;
                vgaGreen = 4'b1111;
                vgaBlue  = 4'b1111;
            end
        end else begin
            // Black during blanking periods
            vgaRed   = 4'b0000;
            vgaGreen = 4'b0000;
            vgaBlue  = 4'b0000;
        end
    end

endmodule