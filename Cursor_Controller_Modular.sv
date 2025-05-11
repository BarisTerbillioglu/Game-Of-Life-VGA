module Cursor_Controller_Modular(
    input  logic clk,
    input  logic rst,
    input  logic btnU,
    input  logic btnD,
    input  logic btnL,
    input  logic btnR,
    output logic [6:0] cursorX,  // 0-79
    output logic [5:0] cursorY   // 0-59
);

    // Cursor position registers
    logic [6:0] cursorX_reg;
    logic [5:0] cursorY_reg;
    
    // Button synchronization
    logic [2:0] btnU_sync, btnD_sync, btnL_sync, btnR_sync;
    logic btnU_prev, btnD_prev, btnL_prev, btnR_prev;
    
    // Synchronize buttons (simpler version without Debouncer)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btnU_sync <= 3'b000;
            btnD_sync <= 3'b000;
            btnL_sync <= 3'b000;
            btnR_sync <= 3'b000;
            btnU_prev <= 1'b0;
            btnD_prev <= 1'b0;
            btnL_prev <= 1'b0;
            btnR_prev <= 1'b0;
        end else begin
            // Shift in new button values
            btnU_sync <= {btnU_sync[1:0], btnU};
            btnD_sync <= {btnD_sync[1:0], btnD};
            btnL_sync <= {btnL_sync[1:0], btnL};
            btnR_sync <= {btnR_sync[1:0], btnR};
            
            // Store previous synchronized values for edge detection
            btnU_prev <= btnU_sync[2];
            btnD_prev <= btnD_sync[2];
            btnL_prev <= btnL_sync[2];
            btnR_prev <= btnR_sync[2];
        end
    end
    
    // Edge detection for buttons
    wire btnU_edge = btnU_sync[2] && !btnU_prev;
    wire btnD_edge = btnD_sync[2] && !btnD_prev;
    wire btnL_edge = btnL_sync[2] && !btnL_prev;
    wire btnR_edge = btnR_sync[2] && !btnR_prev;
    
    // Cursor movement logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cursorX_reg <= 7'd40;  // Start at center
            cursorY_reg <= 6'd30;  // Start at center
        end else begin
            // Up button - decrement Y if not at top
            if (btnU_edge && cursorY_reg > 0) begin
                cursorY_reg <= cursorY_reg - 1;
            end
            
            // Down button - increment Y if not at bottom
            if (btnD_edge && cursorY_reg < 59) begin
                cursorY_reg <= cursorY_reg + 1;
            end
            
            // Left button - decrement X if not at left edge
            if (btnL_edge && cursorX_reg > 0) begin
                cursorX_reg <= cursorX_reg - 1;
            end
            
            // Right button - increment X if not at right edge
            if (btnR_edge && cursorX_reg < 79) begin
                cursorX_reg <= cursorX_reg + 1;
            end
        end
    end
    
    // Output cursor position
    assign cursorX = cursorX_reg;
    assign cursorY = cursorY_reg;
    
endmodule