module Canvas_Memory(
    input  logic clk,
    input  logic rst,
    input  logic clearCanvas,
    input  logic drawPixel,
    input  logic [9:0] writeX,           // 10 bits for 0-639
    input  logic [8:0] writeY,           // 9 bits for 0-479
    input  logic [9:0] readX,            // 10 bits for 0-639
    input  logic [8:0] readY,            // 9 bits for 0-479
    output logic pixelState
);

    // Reduce to 320x240 to fit in available resources
    localparam WIDTH = 320;
    localparam HEIGHT = 240;
    localparam TOTAL_PIXELS = WIDTH * HEIGHT;  // 76,800 bits
    
    // Pack into 32-bit words for Block RAM efficiency
    localparam WORDS = 2400;  // (76800 + 31) / 32 = 2400
    
    // Simplified Block RAM declaration
    reg [31:0] memory [0:WORDS-1];
    
    // Scale coordinates down to 320x240
    wire [8:0] scaled_write_x = writeX[9:1];  // Divide by 2
    wire [7:0] scaled_write_y = writeY[8:1];  // Divide by 2
    wire [8:0] scaled_read_x = readX[9:1];    // Divide by 2
    wire [7:0] scaled_read_y = readY[8:1];    // Divide by 2
    
    // Address calculation
    wire [16:0] write_pixel_addr = scaled_write_y * WIDTH + scaled_write_x;
    wire [16:0] read_pixel_addr = scaled_read_y * WIDTH + scaled_read_x;
    
    wire [11:0] write_word_addr = write_pixel_addr[16:5];  // Divide by 32
    wire [4:0] write_bit_pos = write_pixel_addr[4:0];      // Bit position
    
    wire [11:0] read_word_addr = read_pixel_addr[16:5];
    wire [4:0] read_bit_pos = read_pixel_addr[4:0];
    
    // Clear state machine
    reg clearing;
    reg [11:0] clear_addr;
    
    always @(posedge clk) begin
        if (rst || (clearCanvas && !clearing)) begin
            clearing <= 1'b1;
            clear_addr <= 12'd0;
        end else if (clearing) begin
            memory[clear_addr] <= 32'd0;
            if (clear_addr == 12'd2399) begin  // WORDS-1
                clearing <= 1'b0;
            end else begin
                clear_addr <= clear_addr + 12'd1;
            end
        end else if (drawPixel && write_pixel_addr < TOTAL_PIXELS) begin
            memory[write_word_addr][write_bit_pos] <= 1'b1;
        end
    end
    
    // Read operation with registered output
    reg [31:0] read_data;
    always @(posedge clk) begin
        if (read_pixel_addr < TOTAL_PIXELS) begin
            read_data <= memory[read_word_addr];
        end else begin
            read_data <= 32'd0;
        end
    end
    
    // Extract pixel state
    assign pixelState = read_data[read_bit_pos];
    
endmodule
