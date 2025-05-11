module Drawing_Controller(
    input  logic clk,
    input  logic rst,
    input  logic btnC,
    input  logic sw15,
    input  logic [9:0] cursorX,   // 10 bits for 640 pixels
    input  logic [8:0] cursorY,   // 9 bits for 480 pixels
    output logic drawPixel,
    output logic clearCanvas,
    output logic [9:0] drawX,     // 10 bits for 640 pixels
    output logic [8:0] drawY      // 9 bits for 480 pixels
);

    // Synchronize button input
    logic [2:0] btnC_sync;
    logic [2:0] sw15_sync;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btnC_sync <= 3'b000;
            sw15_sync <= 3'b000;
        end else begin
            btnC_sync <= {btnC_sync[1:0], btnC};
            sw15_sync <= {sw15_sync[1:0], sw15};
        end
    end
    
    // Detect rising edge for button and falling edge for switch
    logic btnC_edge;
    logic sw15_edge;
    logic last_btnC;
    logic last_sw15;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            last_btnC <= 1'b0;
            last_sw15 <= 1'b0;
        end else begin
            last_btnC <= btnC_sync[2];
            last_sw15 <= sw15_sync[2];
        end
    end
    
    // Edge detection
    assign btnC_edge = btnC_sync[2] && !last_btnC;
    assign sw15_edge = sw15_sync[2] != last_sw15;
    
    // Generate draw pulse on button press
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            drawPixel <= 1'b0;
        end else begin
            drawPixel <= btnC_edge;
        end
    end
    
    // Generate clear pulse on switch toggle
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            clearCanvas <= 1'b1; // Clear on reset
        end else begin
            clearCanvas <= sw15_edge;
        end
    end
    
    // Pass cursor position to memory
    assign drawX = cursorX;
    assign drawY = cursorY;
    
endmodule