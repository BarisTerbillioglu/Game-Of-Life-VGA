module VGA_VSyncGenerator(
    input  logic [$clog2(525)-1:0] vCount, // Vertical counter
    output logic vSync                     // Vertical sync signal
);
    
    // VGA vertical timing parameters
    localparam V_ACTIVE       = 480;
    localparam V_FRONT_PORCH  = 10;
    localparam V_SYNC_PULSE   = 2;
    
    // Generate vertical sync signal (active low)
    assign vSync = ~((vCount >= (V_ACTIVE + V_FRONT_PORCH)) && 
                    (vCount < (V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE)));
    
endmodule