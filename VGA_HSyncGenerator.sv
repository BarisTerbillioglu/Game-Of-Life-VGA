module VGA_HSyncGenerator(
    input  logic [$clog2(800)-1:0] hCount, // Horizontal counter
    output logic hSync                     // Horizontal sync signal
);
    
    // VGA horizontal timing parameters
    localparam H_ACTIVE       = 640;
    localparam H_FRONT_PORCH  = 16;
    localparam H_SYNC_PULSE   = 96;
    
    // Generate horizontal sync signal (active low)
    assign hSync = ~((hCount >= (H_ACTIVE + H_FRONT_PORCH)) && 
                    (hCount < (H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE)));
    
endmodule