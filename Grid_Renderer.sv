module Grid_Renderer_Modular(
    input  logic pixelActive,
    input  logic [11:0] xPixel,
    input  logic [11:0] yPixel,
    input  logic [6:0] cursorX,
    input  logic [5:0] cursorY,
    input  logic cellState,
    input  logic simulating,
    output logic [6:0] gridX,    // Grid position to read from memory
    output logic [5:0] gridY,    // Grid position to read from memory
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue
);

    // Grid parameters - each cell is 8x8 pixels
    localparam CELL_SIZE = 8;
    
    // Calculate grid position and cell position
    wire [6:0] grid_x = xPixel[9:3];  // Divide by 8
    wire [5:0] grid_y = yPixel[8:3];  // Divide by 8
    wire [2:0] cell_x = xPixel[2:0];  // Position within cell
    wire [2:0] cell_y = yPixel[2:0];  // Position within cell
    
    // Check if on grid edge
    wire on_edge = (cell_x == 0) || (cell_y == 0);
    
    // Check if cursor is at this position
    wire on_cursor = (grid_x == cursorX) && (grid_y == cursorY);
    
    // Request cell state for current grid position
    assign gridX = grid_x;
    assign gridY = grid_y;
    
    // Color generation with clear priority
    always_comb begin
        if (pixelActive && grid_x < 80 && grid_y < 60) begin
            if (on_edge) begin
                // Black grid lines
                vgaRed   = 4'h0;
                vgaGreen = 4'h0;
                vgaBlue  = 4'h0;
            end else if (!simulating && on_cursor) begin
                // Yellow cursor when not simulating
                vgaRed   = 4'hF;
                vgaGreen = 4'hF;
                vgaBlue  = 4'h0;
            end else if (cellState) begin
                // Black for alive cells
                vgaRed   = 4'h0;
                vgaGreen = 4'h0;
                vgaBlue  = 4'h0;
            end else begin
                // White for dead cells
                vgaRed   = 4'hF;
                vgaGreen = 4'hF;
                vgaBlue  = 4'hF;
            end
        end else begin
            // Black during blanking or outside grid
            vgaRed   = 4'h0;
            vgaGreen = 4'h0;
            vgaBlue  = 4'h0;
        end
    end
    
endmodule