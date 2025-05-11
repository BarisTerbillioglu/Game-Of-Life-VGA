module VGA_HorizontalSyncGenerator 
    #(
        parameter HPIXEL = 640, 
        parameter H_FRONT_PORCH = 16, 
        parameter H_SYNC_PULSE = 96, 
        parameter H_BACK_PORCH = 48,
        parameter H_Polarity = 0
    ) 
    (
        input  logic [11:0] hCount,
        output logic hSYNC
    );

    logic temp;
    assign temp = (hCount >= (HPIXEL + H_FRONT_PORCH)) && 
                  (hCount < (HPIXEL + H_FRONT_PORCH + H_SYNC_PULSE));

    // 0 = low during Sync pulse
    // 1 = high during Sync pulse
    assign hSYNC = (H_Polarity == 0) ? ~temp : temp;

endmodule