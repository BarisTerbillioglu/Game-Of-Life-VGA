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

    // Improved synchronization and debouncing
    logic [2:0] btnC_sync;
    logic [2:0] sw15_sync;
    
    // Multi-stage synchronizer for button and switch
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btnC_sync <= 3'b000;
            sw15_sync <= 3'b000;
        end else begin
            btnC_sync <= {btnC_sync[1:0], btnC};
            sw15_sync <= {sw15_sync[1:0], sw15};
        end
    end
    
    // Debounce counters - much longer debounce for switch
    logic [23:0] btnC_debounce;  // ~167ms at 100MHz
    logic [26:0] sw15_debounce;  // ~1.34s at 100MHz - very long to prevent accidental clears
    
    logic stable_btnC, stable_sw15;
    logic last_stable_btnC, last_stable_sw15;
    
    // Button debouncing
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btnC_debounce <= 0;
            stable_btnC <= 0;
            last_stable_btnC <= 0;
        end else begin
            if (btnC_sync[2] == btnC_sync[1]) begin
                if (btnC_debounce == 24'hFFFFFF) begin
                    stable_btnC <= btnC_sync[2];
                    last_stable_btnC <= stable_btnC;
                end else begin
                    btnC_debounce <= btnC_debounce + 1;
                end
            end else begin
                btnC_debounce <= 0;
            end
        end
    end
    
    // Switch debouncing with longer delay
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sw15_debounce <= 0;
            stable_sw15 <= 0;
            last_stable_sw15 <= 0;
        end else begin
            if (sw15_sync[2] == sw15_sync[1]) begin
                if (sw15_debounce == 27'h3FFFFFF) begin  // Much longer debounce
                    stable_sw15 <= sw15_sync[2];
                    last_stable_sw15 <= stable_sw15;
                end else begin
                    sw15_debounce <= sw15_debounce + 1;
                end
            end else begin
                sw15_debounce <= 0;
            end
        end
    end
    
    // Edge detection
    logic btnC_edge;
    logic sw15_edge;
    
    assign btnC_edge = stable_btnC && !last_stable_btnC;
    assign sw15_edge = stable_sw15 != last_stable_sw15;
    
    // Generate draw pulse on button press
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            drawPixel <= 1'b0;
        end else begin
            drawPixel <= btnC_edge;
        end
    end
    
    // Generate clear pulse only on switch toggle - with additional confirmation
    logic clear_confirm;
    logic [7:0] clear_confirm_counter;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            clearCanvas <= 1'b1; // Clear on reset
            clear_confirm <= 1'b0;
            clear_confirm_counter <= 0;
        end else begin
            if (sw15_edge && !clear_confirm) begin
                // Start confirmation period
                clear_confirm <= 1'b1;
                clear_confirm_counter <= 0;
                clearCanvas <= 1'b0;
            end else if (clear_confirm) begin
                if (clear_confirm_counter < 8'd200) begin  // Require switch to be stable for 200 cycles
                    clear_confirm_counter <= clear_confirm_counter + 1;
                    clearCanvas <= 1'b0;
                end else begin
                    // Only clear after confirmation period
                    clearCanvas <= 1'b1;
                    clear_confirm <= 1'b0;
                end
            end else begin
                clearCanvas <= 1'b0;
            end
        end
    end
    
    // Pass cursor position to memory
    assign drawX = cursorX;
    assign drawY = cursorY;
    
endmodule
