module Grid_Memory_Modular(
    input  logic clk,
    input  logic rst,
    input  logic clearGrid,
    input  logic writeCell,
    input  logic [6:0] writeX,           // 0-79
    input  logic [5:0] writeY,           // 0-59
    input  logic [6:0] readX,            // 0-79
    input  logic [5:0] readY,            // 0-59
    input  logic writeValue,             // Value to write
    output logic cellState               // Current cell state
);

    // Grid parameters
    localparam WIDTH = 80;
    localparam HEIGHT = 60;
    localparam TOTAL_CELLS = WIDTH * HEIGHT;  // 4,800 cells
    
    // Pack into 32-bit words for Block RAM efficiency
    localparam WORDS = 150;  // (4800 + 31) / 32 = 150
    
    // Block RAM declaration
    (* RAM_STYLE="BLOCK" *) reg [31:0] memory [0:WORDS-1];
    
    // Clear state machine
    reg clearing;
    reg [7:0] clear_addr;
    
    // Address calculation
    wire [12:0] write_cell_addr = writeY * WIDTH + writeX;
    wire [12:0] read_cell_addr = readY * WIDTH + readX;
    wire [7:0] write_word_addr = write_cell_addr[12:5];
    wire [4:0] write_bit_pos = write_cell_addr[4:0];
    wire [7:0] read_word_addr = read_cell_addr[12:5];
    wire [4:0] read_bit_pos = read_cell_addr[4:0];
    
    // Memory operations - writing and clearing
    always @(posedge clk) begin
        if (rst) begin
            clearing <= 1'b0;
            clear_addr <= 8'd0;
            
            // Initialize all memory to 0 on reset
            for (int i = 0; i < WORDS; i++) begin
                memory[i] <= 32'd0;
            end
        end else if (clearGrid && !clearing) begin
            clearing <= 1'b1;
            clear_addr <= 8'd0;
        end else if (clearing) begin
            memory[clear_addr] <= 32'd0;
            if (clear_addr == 8'd149) begin  // WORDS-1
                clearing <= 1'b0;
            end else begin
                clear_addr <= clear_addr + 8'd1;
            end
        end else if (writeCell && write_cell_addr < TOTAL_CELLS) begin
            // Read-modify-write to avoid loss of other bits in the word
            memory[write_word_addr][write_bit_pos] <= writeValue;
        end
    end
    
    // Memory operations - reading
    reg [31:0] read_data;
    
    always @(posedge clk) begin
        if (read_cell_addr < TOTAL_CELLS) begin
            read_data <= memory[read_word_addr];
        end else begin
            read_data <= 32'd0;
        end
    end
    
    // Extract cell state
    assign cellState = read_data[read_bit_pos];
    
endmodule