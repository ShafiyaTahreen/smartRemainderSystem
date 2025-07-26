`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2025 08:19:39
// Design Name: 
// Module Name: Test_prj
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// reminder_system(
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reminder_system(
     (* clock_buffer = "IBUFG" *) input   clk,
               input                   rst,
               input                   stop_sw,
               output reg     [7:0]    led,
               output reg              led_1pps,
               output reg              cube
    );

wire clk_int;
wire rst_int, rst_int_dcm;

reg [25:0] rst_gen;

reg [20:0] slot_clock_counter;
reg [17:0] slot_clock_flywheel;


reg  [20:0]     counter;
reg  clock_out;
wire clk_int_fb; 
wire clk_int_dcm;

reg [7:0] led_int;
reg led__int_1pps;
reg cube_int;


assign rst_int = rst_int_dcm;

always @(posedge clk_int or negedge rst_int) begin
    if (!rst_int)
        counter <= 20'h0;
    else if (counter == 20'h3D089)//h3D085
		counter <= 20'h0;
    else
		counter <= counter + 1;
end

always @(posedge clk_int or negedge rst_int) begin
    if (!rst_int )begin
        led <= 2'h0;
        led_1pps <= 1'b0;
        cube <=1'b0;
    end else begin
        led <= led_int;
        led_1pps <= led__int_1pps;
        cube <=cube_int;
    end
end

always @(posedge clk_int or negedge rst_int) begin
	if (!rst_int)begin
		slot_clock_flywheel <= 18'h0;
		slot_clock_counter <= 11'h0;
    end else if (counter == 20'h3D089)begin //5ms
        slot_clock_counter <= slot_clock_counter + 1;
    end else if (slot_clock_counter >= 11'hC8) begin//1 Sec     counter = 200
        slot_clock_flywheel <= slot_clock_flywheel + 1;//generating flywheel for every 1 second
        slot_clock_counter <= 11'h0;
    end else if (slot_clock_counter == 11'hC7) begin
        led__int_1pps <= ~ led__int_1pps ;//1'b0;
    end else if(slot_clock_flywheel == 18'h3C)begin// 1min      Flywheel counter = 60
        led_int <= 8'b00000001;
        cube_int <= 1'b1;
    end else if(slot_clock_flywheel == 18'h78)begin// 2min      Flywheel counter = 120
        led_int <= 8'b00000010;
        cube_int <= 1'b1;
    end else if(slot_clock_flywheel == 18'h12C)begin// 5min     Flywheel counter = 300
        led_int <= 8'b00000100;
        cube_int <= 1'b1;
	end else if(slot_clock_flywheel == 18'h258)begin// 10min    Flywheel counter = 600
        led_int <= 8'b00001000;
        cube_int <= 1'b1;
	end else if(slot_clock_flywheel == 18'hE10)begin//1Hr       Flywheel counter = 3600
        led_int <= 8'b00010000;
        cube_int <= 1'b1;
	end else if(slot_clock_flywheel == 18'h1518)begin//1.3Hrs   Flywheel counter = 5400
        led_int <= 8'b00100000;
        cube_int <= 1'b1;
    end else if(slot_clock_flywheel == 18'h1C20)begin//2Hrs     Flywheel counter = 7200
        led_int <= 8'b01000000;
        cube_int <= 1'b1;
	end else if (slot_clock_flywheel == 18'h15180)begin//24Hrs  Flywheel counter = 86400
        slot_clock_flywheel <= 18'h0;
    end else if (stop_sw == 1'b1)begin
        led_int <= 8'h00;
        cube_int <= 1'b0;
    end
end

//DCM Instantiation for filtering the input clock
   DCM_SP  #( .CLK_FEEDBACK             ("1X"),
              .CLKDV_DIVIDE             (2.0),
              .CLKFX_DIVIDE             (1),
              .CLKFX_MULTIPLY           (4),
              .CLKIN_DIVIDE_BY_2        ("FALSE"),
              .CLKIN_PERIOD             (10.000000),
              .CLKOUT_PHASE_SHIFT       ("NONE"),
              .DESKEW_ADJUST            ("SYSTEM_SYNCHRONOUS"),
              .DFS_FREQUENCY_MODE       ("LOW"),
              .DLL_FREQUENCY_MODE       ("LOW"),
              .DUTY_CYCLE_CORRECTION    ("TRUE"),
              .PHASE_SHIFT              (0),
              .STARTUP_WAIT             ("FALSE"),
              .DSS_MODE                 ("NONE")
            ) clk_dcm (
                      .CLKIN    (clk),
                      .CLKFB    (clk_int_fb),
                      .RST      (rst),
                      .PSEN     (1'b0),
                      .PSINCDEC (1'b0),
                      .PSCLK    (1'b0),
                      .DSSEN    (1'b0),
                      .CLK0     (clk_int_fb),
                      .CLK90    (),
                      .CLK180   (),
                      .CLK270   (),
                      .CLKDV    (clk_int),
                      .CLK2X    (),
                      .CLK2X180 (),
                      .CLKFX    (),
                      .CLKFX180 (),
                      .STATUS   (),
                      .LOCKED   (rst_int_dcm),
                      .PSDONE   ()
                    );

endmodule