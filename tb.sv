`timescale 1ns/1ps

module tt_um_pong_tb;

    // Clock & reset
    reg clk = 0;
    reg rst_n = 0;

    // DUT inputs
    reg [7:0] ui_in   = 0;
    reg [7:0] uio_in  = 0;
    reg       ena     = 1;

    // DUT outputs
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Clock generation
    always #10 clk = ~clk; // 50 MHz

    // Instantiate the DUT
    tt_um_pong dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Simulation parameters
    localparam integer TOTAL_CYCLES = 420_000;
    integer cycle_count;
    integer file;

    // Binary dump: 2 bytes per cycle (uo_out + uio_out)
    initial begin
        file = $fopen("pong_dump.bin", "wb");
        if (!file) begin
            $display("ERROR: Cannot open output file.");
            $finish;
        end

        // Reset pulse
        rst_n = 0;
        #50;
        rst_n = 1;

        // Run simulation for TOTAL_CYCLES
        for (cycle_count = 0; cycle_count < TOTAL_CYCLES; cycle_count = cycle_count + 1) begin
            @(posedge clk);
            $fwrite(file, "%c%c", uo_out, uio_out);

            // Optional: drive some test inputs
            ui_in  <= ui_in + 1;
            uio_in <= uio_in + 2;
        end

        $display("Simulation finished. Data saved to pong_dump.bin");
        $fclose(file);
        $finish;
    end

endmodule
