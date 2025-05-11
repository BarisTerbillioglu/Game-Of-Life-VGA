module VGA_Stage3_Top_Fixed_Swap(
    input  logic clk,           // System clock (100 MHz on Basys3)
    input  logic rst,           // Reset signal
    input  logic btnU,          // Up button
    input  logic btnD,          // Down button
    input  logic btnL,          // Left button
    input  logic btnR,          // Right button
    input  logic btnC,          // Center button
    input  logic sw0,           // Start/stop simulation
    input  logic sw15,          // Clear grid and stop
    output logic [3:0] vgaRed,  // 4-bit VGA red channel
    output logic [3:0] vgaGreen,// 4-bit VGA green channel
    output logic [3:0] vgaBlue, // 4-bit VGA blue channel
    output logic hSync,         // Horizontal sync
    output logic vSync          // Vertical sync
);

    // VGA signals
    logic [11:0] xPixel;
    logic [11:0] yPixel;
    logic pixelDrawing;
    
    // Cursor signals
    logic [6:0] cursorX;
    logic [5:0] cursorY;
    
    // Button synchronization (replace Debouncer)
    logic [2:0] btnC_sync;
    logic btnC_prev;
    logic btnC_edge;
    
    // Simulation control signals
    logic simulating;
    logic clear_grid;
    logic start_update;
    logic grid_swap;
    logic game_busy;
    
    // Current grid memory signals
    logic [6:0] current_grid_read_x;
    logic [5:0] current_grid_read_y;
    logic current_grid_cell_state;
    logic current_grid_write_enable;
    logic [6:0] current_grid_write_x;
    logic [5:0] current_grid_write_y;
    logic current_grid_write_value;
    
    // Next grid memory signals
    logic [6:0] next_grid_read_x;
    logic [5:0] next_grid_read_y;
    logic next_grid_cell_state;
    logic next_grid_write_enable;
    logic [6:0] next_grid_write_x;
    logic [5:0] next_grid_write_y;
    logic next_grid_write_value;
    
    // Game engine signals
    logic [6:0] game_read_x;
    logic [5:0] game_read_y;
    logic game_cell_state;
    logic [6:0] game_write_x;
    logic [5:0] game_write_y;
    logic game_write_value;
    logic game_write_enable;
    
    // Cell toggle state for cursor
    typedef enum logic [1:0] {
        TOGGLE_IDLE,
        TOGGLE_READ,
        TOGGLE_WRITE
    } toggle_state_t;
    
    toggle_state_t toggle_state;
    
    // Grid swap state
    typedef enum logic [1:0] {
        SWAP_IDLE,
        SWAP_PROCESSING,
        SWAP_COMPLETE
    } swap_state_t;
    
    swap_state_t swap_state;
    logic [6:0] swap_x;
    logic [5:0] swap_y;
    logic swap_cell_value;
    
    // Simple button synchronization for center button
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btnC_sync <= 3'b000;
            btnC_prev <= 1'b0;
        end else begin
            btnC_sync <= {btnC_sync[1:0], btnC};
            btnC_prev <= btnC_sync[2];
        end
    end
    assign btnC_edge = btnC_sync[2] && !btnC_prev;
    
    // VGA Block
    VGA_Block 
        #(.MODES(0))
        vgaBlock(
            .systemClk_125MHz(clk),
            .rst(rst),
            .xPixel(xPixel),
            .yPixel(yPixel),
            .pixelDrawing(pixelDrawing),
            .hSYNC(hSync),
            .vSYNC(vSync)
        );
    
    // Cursor Controller (no debouncer)
    Cursor_Controller_Modular cursorController(
        .clk(clk),
        .rst(rst),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .cursorX(cursorX),
        .cursorY(cursorY)
    );
    
    // Simulation Controller (no debouncer)
    Simulation_Control_Modular simController(
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .sw15(sw15),
        .game_busy(game_busy || (swap_state != SWAP_IDLE)),
        .simulating(simulating),
        .clear_grid(clear_grid),
        .start_update(start_update),
        .grid_swap(grid_swap)
    );
    
    // Game Logic Engine 
    Game_Logic_Modular gameEngine(
        .clk(clk),
        .rst(rst),
        .start_update(start_update),
        .simulating(simulating),
        .busy(game_busy),
        .read_x(game_read_x),
        .read_y(game_read_y),
        .cell_state(game_cell_state),
        .write_x(game_write_x),
        .write_y(game_write_y),
        .write_value(game_write_value),
        .write_enable(game_write_enable)
    );
    
    // Cell toggle state machine for cursor
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            toggle_state <= TOGGLE_IDLE;
        end else begin
            case (toggle_state)
                TOGGLE_IDLE: begin
                    if (!simulating && btnC_edge) begin
                        toggle_state <= TOGGLE_READ;
                    end
                end
                
                TOGGLE_READ: begin
                    // Must spend an entire cycle in READ state
                    toggle_state <= TOGGLE_WRITE;
                end
                
                TOGGLE_WRITE: begin
                    // Must spend an entire cycle in WRITE state 
                    toggle_state <= TOGGLE_IDLE;
                end
                
                default: toggle_state <= TOGGLE_IDLE;
            endcase
        end
    end
    
    // Grid swap state machine
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            swap_state <= SWAP_IDLE;
            swap_x <= 7'd0;
            swap_y <= 6'd0;
        end else begin
            case (swap_state)
                SWAP_IDLE: begin
                    if (grid_swap && !game_busy) begin
                        swap_state <= SWAP_PROCESSING;
                        swap_x <= 7'd0;
                        swap_y <= 6'd0;
                    end
                end
                
                SWAP_PROCESSING: begin
                    // Move to next cell
                    if (swap_x == 79) begin
                        swap_x <= 7'd0;
                        if (swap_y == 59) begin
                            swap_state <= SWAP_COMPLETE;
                        end else begin
                            swap_y <= swap_y + 1;
                        end
                    end else begin
                        swap_x <= swap_x + 1;
                    end
                end
                
                SWAP_COMPLETE: begin
                    swap_state <= SWAP_IDLE;
                end
                
                default: swap_state <= SWAP_IDLE;
            endcase
        end
    end
    
    // Helper logic for grid reads - needed for renderer
    logic [6:0] renderer_read_x;
    logic [5:0] renderer_read_y;
    
    // Calculate renderer grid position from pixels
    assign renderer_read_x = xPixel[9:3]; // Divide by 8
    assign renderer_read_y = yPixel[8:3]; // Divide by 8
    
    // Memory access control - completely separate for current and next grid
    always_comb begin
        // Current grid defaults to renderer
        current_grid_read_x = renderer_read_x;
        current_grid_read_y = renderer_read_y;
        current_grid_write_enable = 1'b0;
        current_grid_write_x = 7'd0;
        current_grid_write_y = 6'd0;
        current_grid_write_value = 1'b0;
        
        // Next grid defaults - game engine
        next_grid_read_x = 7'd0;
        next_grid_read_y = 6'd0;
        next_grid_write_enable = 1'b0;
        next_grid_write_x = 7'd0;
        next_grid_write_y = 6'd0;
        next_grid_write_value = 1'b0;
        
        // Connect game engine to grids
        game_cell_state = current_grid_cell_state;
        
        // Handle toggle state for drawing - HIGHEST PRIORITY
        if (toggle_state == TOGGLE_READ) begin
            current_grid_read_x = cursorX;
            current_grid_read_y = cursorY;
        end else if (toggle_state == TOGGLE_WRITE) begin
            current_grid_write_enable = 1'b1;
            current_grid_write_x = cursorX;
            current_grid_write_y = cursorY;
            current_grid_write_value = ~current_grid_cell_state;
        end
        
        // Handle game simulation - SECOND PRIORITY
        if (game_busy && simulating) begin
            // Only override read if it's not already being used for toggle
            if (toggle_state != TOGGLE_READ) begin
                current_grid_read_x = game_read_x;
                current_grid_read_y = game_read_y;
            end
            
            // Game writes to next grid
            next_grid_write_enable = game_write_enable;
            next_grid_write_x = game_write_x;
            next_grid_write_y = game_write_y;
            next_grid_write_value = game_write_value;
        end
        
        // Handle grid swap - THIRD PRIORITY 
        if (swap_state == SWAP_PROCESSING) begin
            // Read from next grid
            next_grid_read_x = swap_x;
            next_grid_read_y = swap_y;
            
            // Write to current grid (only if not already writing for toggle)
            if (toggle_state != TOGGLE_WRITE) begin
                current_grid_write_enable = 1'b1;
                current_grid_write_x = swap_x;
                current_grid_write_y = swap_y;
                current_grid_write_value = next_grid_cell_state;
            end
        end
    end
    
    // Current grid memory
    Grid_Memory_Modular currentGrid(
        .clk(clk),
        .rst(rst),
        .clearGrid(clear_grid),
        .writeCell(current_grid_write_enable),
        .writeX(current_grid_write_x),
        .writeY(current_grid_write_y),
        .writeValue(current_grid_write_value),
        .readX(current_grid_read_x),
        .readY(current_grid_read_y),
        .cellState(current_grid_cell_state)
    );
    
    // Next grid memory
    Grid_Memory_Modular nextGrid(
        .clk(clk),
        .rst(rst),
        .clearGrid(clear_grid),
        .writeCell(next_grid_write_enable),
        .writeX(next_grid_write_x),
        .writeY(next_grid_write_y),
        .writeValue(next_grid_write_value),
        .readX(next_grid_read_x),
        .readY(next_grid_read_y),
        .cellState(next_grid_cell_state)
    );
    
    // Grid Renderer
    Grid_Renderer_Modular gridRenderer(
        .pixelActive(pixelDrawing),
        .xPixel(xPixel),
        .yPixel(yPixel),
        .cursorX(cursorX),
        .cursorY(cursorY),
        .cellState(current_grid_cell_state),
        .simulating(simulating),
        .gridX(renderer_read_x),
        .gridY(renderer_read_y),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue)
    );

endmodule