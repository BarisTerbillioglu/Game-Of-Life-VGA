module Game_Logic_Modular(
    input  logic clk,
    input  logic rst,
    input  logic start_update,
    input  logic simulating,
    output logic busy,
    
    // Memory interface for reading
    output logic [6:0] read_x,
    output logic [5:0] read_y,
    input  logic cell_state,
    
    // Memory interface for writing
    output logic [6:0] write_x,
    output logic [5:0] write_y,
    output logic write_value,
    output logic write_enable
);

    // State machine states
    typedef enum logic [3:0] {
        IDLE,
        READ_CENTER,
        WAIT_CENTER,
        READ_NEIGHBOR,
        WAIT_NEIGHBOR,
        APPLY_RULES,
        WRITE_NEXT,
        INCREMENT_CELL
    } state_t;
    
    state_t state;
    
    // Cell being processed
    logic [6:0] cell_x;
    logic [5:0] cell_y;
    
    // Center cell value
    logic center_cell;
    
    // Neighbor counting
    logic [3:0] live_neighbors;
    
    // Neighbor offsets (8 surrounding cells)
    // We'll go through these one by one
    logic [2:0] neighbor_index;
    logic signed [1:0] neighbor_offset_x [0:7];
    logic signed [1:0] neighbor_offset_y [0:7];
    
    // Initialize neighbor offsets (8 surrounding cells)
    initial begin
        // Top-left, Top, Top-right
        neighbor_offset_x[0] = -1; neighbor_offset_y[0] = -1;
        neighbor_offset_x[1] =  0; neighbor_offset_y[1] = -1;
        neighbor_offset_x[2] =  1; neighbor_offset_y[2] = -1;
        
        // Left, Right
        neighbor_offset_x[3] = -1; neighbor_offset_y[3] =  0;
        neighbor_offset_x[4] =  1; neighbor_offset_y[4] =  0;
        
        // Bottom-left, Bottom, Bottom-right
        neighbor_offset_x[5] = -1; neighbor_offset_y[5] =  1;
        neighbor_offset_x[6] =  0; neighbor_offset_y[6] =  1;
        neighbor_offset_x[7] =  1; neighbor_offset_y[7] =  1;
    end
    
    // Game logic state machine
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            busy <= 1'b0;
            cell_x <= 7'd0;
            cell_y <= 6'd0;
            live_neighbors <= 4'd0;
            write_enable <= 1'b0;
            neighbor_index <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    // Reset signals
                    write_enable <= 1'b0;
                    
                    // Start processing when requested
                    if (start_update && simulating) begin
                        state <= READ_CENTER;
                        busy <= 1'b1;
                        cell_x <= 7'd0;
                        cell_y <= 6'd0;
                    end else begin
                        busy <= 1'b0;
                    end
                end
                
                READ_CENTER: begin
                    // Read current cell state
                    read_x <= cell_x;
                    read_y <= cell_y;
                    state <= WAIT_CENTER;
                    live_neighbors <= 4'd0;  // Reset neighbor count
                    neighbor_index <= 3'd0;  // Start with first neighbor
                end
                
                WAIT_CENTER: begin
                    // Wait one cycle for memory read to complete
                    center_cell <= cell_state;  // Save center cell value
                    state <= READ_NEIGHBOR;
                end
                
                READ_NEIGHBOR: begin
                    // Check if we're done reading all neighbors
                    if (neighbor_index < 8) begin
                        // Calculate neighbor coordinates
                        logic signed [7:0] nx, ny;
                        nx = $signed({1'b0, cell_x}) + $signed(neighbor_offset_x[neighbor_index]);
                        ny = $signed({1'b0, cell_y}) + $signed(neighbor_offset_y[neighbor_index]);
                        
                        // Check if neighbor is within grid bounds
                        if (nx >= 0 && nx < 80 && ny >= 0 && ny < 60) begin
                            read_x <= nx[6:0];
                            read_y <= ny[5:0];
                            state <= WAIT_NEIGHBOR;
                        end else begin
                            // Skip invalid neighbor
                            neighbor_index <= neighbor_index + 1;
                            state <= READ_NEIGHBOR;
                        end
                    end else begin
                        // All neighbors checked, apply rules
                        state <= APPLY_RULES;
                    end
                end
                
                WAIT_NEIGHBOR: begin
                    // Wait one cycle for memory read to complete
                    if (cell_state) begin
                        // This neighbor is alive, increment count
                        live_neighbors <= live_neighbors + 1;
                    end
                    
                    // Move to next neighbor
                    neighbor_index <= neighbor_index + 1;
                    state <= READ_NEIGHBOR;
                end
                
                APPLY_RULES: begin
                    // Apply Conway's Game of Life rules
                    if (center_cell) begin
                        // Live cell
                        if (live_neighbors < 2 || live_neighbors > 3) begin
                            // Dies due to underpopulation or overpopulation
                            write_value <= 1'b0;
                        end else begin
                            // Survives (2 or 3 neighbors)
                            write_value <= 1'b1;
                        end
                    end else begin
                        // Dead cell
                        if (live_neighbors == 3) begin
                            // Becomes alive (exactly 3 neighbors)
                            write_value <= 1'b1;
                        end else begin
                            // Stays dead
                            write_value <= 1'b0;
                        end
                    end
                    
                    state <= WRITE_NEXT;
                end
                
                WRITE_NEXT: begin
                    // Write the next state to memory
                    write_x <= cell_x;
                    write_y <= cell_y;
                    write_enable <= 1'b1;
                    state <= INCREMENT_CELL;
                end
                
                INCREMENT_CELL: begin
                    // Move to next cell
                    write_enable <= 1'b0;
                    
                    if (cell_x == 79) begin
                        cell_x <= 7'd0;
                        if (cell_y == 59) begin
                            // Finished entire grid
                            state <= IDLE;
                            busy <= 1'b0;
                        end else begin
                            // Move to next row
                            cell_y <= cell_y + 1;
                            state <= READ_CENTER;
                        end
                    end else begin
                        // Move to next column
                        cell_x <= cell_x + 1;
                        state <= READ_CENTER;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule