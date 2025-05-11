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
    // This still gives reasonable drawing capability
    localparam WIDTH = 320;
    localparam HEIGHT = 240;
    localparam TOTAL_PIXELS = WIDTH * HEIGHT;  // 76,800 bits
    
    // Pack into 32-bit words for Block RAM efficiency
    localparam WORDS = (TOTAL_PIXELS + 31) / 32;  // 2,400 words
    
    // Force Block RAM usage
    (* ram_style = "block" *)
    (* rw_addr_collision = "yes" *)
    reg [31:0] memory [0:WORDS-1];
    
    // Initialize memory
    initial begin
        for (integer i = 0; i < WORDS; i++) begin
            memory[i] = 32'b0;
        end
    end
    
    // Scale coordinates down to 320x240
    logic [8:0] scaled_write_x = writeX[9:1];  // Divide by 2
    logic [7:0] scaled_write_y = writeY[8:1];  // Divide by 2
    logic [8:0] scaled_read_x = readX[9:1];    // Divide by 2
    logic [7:0] scaled_read_y = readY[8:1];    // Divide by 2
    
    // Address calculation
    logic [16:0] write_pixel_addr;
    logic [16:0] read_pixel_addr;
    logic [11:0] write_word_addr;
    logic [11:0] read_word_addr;
    logic [4:0] write_bit_pos;
    logic [4:0] read_bit_pos;
    
    always_comb begin
        write_pixel_addr = scaled_write_y * WIDTH + scaled_write_x;
        write_word_addr = write_pixel_addr[16:5];  // Divide by 32
        write_bit_pos = write_pixel_addr[4:0];     // Bit position
        
        read_pixel_addr = scaled_read_y * WIDTH + scaled_read_x;
        read_word_addr = read_pixel_addr[16:5];
        read_bit_pos = read_pixel_addr[4:0];
    end
    
    // Clear state machine
    logic clearing;
    logic [11:0] clear_addr;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            clearing <= 1'b1;
            clear_addr <= 0;
        end else if (clearCanvas && !clearing) begin
            clearing <= 1'b1;
            clear_addr <= 0;
        end else if (clearing) begin
            memory[clear_addr] <= 32'b0;
            if (clear_addr == WORDS-1) begin
                clearing <= 1'b0;
            end else begin
                clear_addr <= clear_addr + 1;
            end
        end else if (drawPixel && write_pixel_addr < TOTAL_PIXELS) begin
            memory[write_word_addr][write_bit_pos] <= 1'b1;
        end
    end
    
    // Read operation with registered output
    reg [31:0] read_data;
    always_ff @(posedge clk) begin
        if (read_pixel_addr < TOTAL_PIXELS) begin
            read_data <= memory[read_word_addr];
        end else begin
            read_data <= 32'b0;
        end
    end
    
    // Extract pixel state
    assign pixelState = read_data[read_bit_pos];
    
endmodule