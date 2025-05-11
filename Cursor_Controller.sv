module Cursor_Controller(
    input  logic clk,
    input  logic rst,
    input  logic btnU,
    input  logic btnD,
    input  logic btnL,
    input  logic btnR,
    output logic [9:0] cursorX,  // 10 bits for 640 pixels
    output logic [8:0] cursorY   // 9 bits for 480 pixels
);

    // Button debouncing signals
    logic [3:0] buttons;
    assign buttons = {btnU, btnD, btnL, btnR};
    logic [3:0] lastButtons;
    logic [21:0] debounceCounter;  // Increased size for better synthesis
    logic [3:0] debouncedButtons;
    logic [3:0] btnSync [0:1];     // Synchronizer flip-flops
    
    // Synchronize buttons to avoid metastability
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btnSync[0] <= 4'b0000;
            btnSync[1] <= 4'b0000;
        end else begin
            btnSync[0] <= buttons;
            btnSync[1] <= btnSync[0];
        end
    end
    
    // Button debouncing with better logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            debounceCounter <= 0;
            lastButtons <= 4'b0000;
            debouncedButtons <= 4'b0000;
        end else begin
            debounceCounter <= debounceCounter + 1;
            
            // Button debouncing with proper delay and edge detection
            if (debounceCounter == 0) begin  // Check every 2^22 cycles
                lastButtons <= debouncedButtons;
                if (btnSync[1] == btnSync[0]) begin
                    debouncedButtons <= btnSync[1];
                end
            end
        end
    end
    
    // Combined cursor position control in a single always block
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cursorX <= 10'd320;
            cursorY <= 9'd240;
        end else if (debounceCounter == 0) begin
            // Only move cursor on button press (rising edge detection)
            if (debouncedButtons[3] && !lastButtons[3] && cursorY > 0) // Up
                cursorY <= cursorY - 1;
            else if (debouncedButtons[2] && !lastButtons[2] && cursorY < 9'd479) // Down
                cursorY <= cursorY + 1;
            else if (debouncedButtons[1] && !lastButtons[1] && cursorX > 0) // Left
                cursorX <= cursorX - 1;
            else if (debouncedButtons[0] && !lastButtons[0] && cursorX < 10'd639) // Right
                cursorX <= cursorX + 1;
        end
    end

endmodule