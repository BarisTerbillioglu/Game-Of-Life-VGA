module VGA_VerticalSyncGenerator 
    #(
        parameter VPIXEL = 480,
        parameter V_FRONT_PORCH = 10,
        parameter V_SYNC_PULSE = 2, 
        parameter V_BACK_PORCH = 33,
        parameter V_Polarity = 0
    ) 
    (
        input  logic [11:0] vCount,
        output logic vSYNC
    );

    logic temp;
    assign temp = (vCount >= (VPIXEL + V_FRONT_PORCH)) && 
                  (vCount < (VPIXEL + V_FRONT_PORCH + V_SYNC_PULSE));

    // 0 = low during Sync pulse
    // 1 = high during Sync pulse
    assign vSYNC = (V_Polarity == 0) ? ~temp : temp;

endmodule