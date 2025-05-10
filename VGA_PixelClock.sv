module VGA_PixelClock(
    input  logic clk,     // 100MHz system clock from Basys3
    input  logic rst,     // Reset signal
    output logic pixelClk // 25MHz pixel clock for VGA
);
    
    // For 640x480@60Hz VGA, we need 25.175MHz but 25MHz is close enough
    // To get 25MHz from 100MHz, divide by 4 (100/4 = 25)
    
    // Counter to divide the 100MHz clock
    logic [1:0] counter;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            pixelClk <= 0;
        end else begin
            if (counter == 2'd1) begin
                pixelClk <= ~pixelClk; // Toggle the pixel clock
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
    
endmodule