module Simulation_Control_Modular(
    input  logic clk,
    input  logic rst,
    input  logic sw0,              // Start/stop simulation
    input  logic sw15,             // Clear grid and stop
    input  logic game_busy,        // Game engine is busy
    output logic simulating,       // Simulation active
    output logic clear_grid,       // Clear grid signal
    output logic start_update,     // Start game update
    output logic grid_swap         // Swap grids signal
);

    // Simulation state
    logic simulating_reg;
    logic [28:0] sim_timer;  // Increased for slower timing
    
    // Switch synchronization (simple debouncing)
    logic [2:0] sw0_sync;
    logic [2:0] sw15_sync;
    logic sw0_prev;
    logic sw15_prev;
    
    // Update control
    logic update_running;
    
    // Simple synchronization instead of debouncer
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sw0_sync <= 3'b000;
            sw15_sync <= 3'b000;
        end else begin
            sw0_sync <= {sw0_sync[1:0], sw0};
            sw15_sync <= {sw15_sync[1:0], sw15};
        end
    end
    
    // Simulation timing and control
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            simulating_reg <= 1'b0;
            sw0_prev <= 1'b0;
            sw15_prev <= 1'b0;
            sim_timer <= 0;
            clear_grid <= 1'b0;
            start_update <= 1'b0;
            grid_swap <= 1'b0;
            update_running <= 1'b0;
        end else begin
            // Default values
            clear_grid <= 1'b0;
            start_update <= 1'b0;
            grid_swap <= 1'b0;
            
            // Edge detection using synchronizers
            sw0_prev <= sw0_sync[2];
            sw15_prev <= sw15_sync[2];
            
            // Handle switch actions
            if (sw0_sync[2] && !sw0_prev) begin
                // Toggle simulation state on rising edge
                simulating_reg <= ~simulating_reg;
            end
            
            if (sw15_sync[2] != sw15_prev) begin
                // Clear grid and stop simulation on any change
                clear_grid <= 1'b1;
                simulating_reg <= 1'b0;
                update_running <= 1'b0;
            end
            
            // Simulation timing - Slowed down
            if (simulating_reg && !update_running && !game_busy) begin
                sim_timer <= sim_timer + 1;
                if (sim_timer >= 29'd100000000) begin // ~1s at 100MHz
                    sim_timer <= 0;
                    start_update <= 1'b1;
                    update_running <= 1'b1;
                end
            end
            
            // Handle game completion
            if (update_running && !game_busy && !start_update) begin
                grid_swap <= 1'b1;
                update_running <= 1'b0;
            end
        end
    end
    
    // Output simulation state
    assign simulating = simulating_reg;
    
endmodule