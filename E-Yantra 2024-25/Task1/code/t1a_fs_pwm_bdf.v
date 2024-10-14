// Copyright (C) 2020  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"
// CREATED		"Sat Sep 14 14:57:44 2024"

module t1a_fs_pwm_bdf(
	clk_50MHz,
	pulse_width,
	pwm_signal,
	clk_500Hz,
	clk_1MHz
);


input wire	clk_50MHz;
input wire	[3:0] pulse_width;
output wire	pwm_signal;
output wire	clk_500Hz;
output wire	clk_1MHz;

wire	SYNTHESIZED_WIRE_0;

assign	clk_1MHz = SYNTHESIZED_WIRE_0;




pwm_generator	b2v_inst(
	.clk_1MHz(SYNTHESIZED_WIRE_0),
	.pulse_width(pulse_width),
	.clk_500Hz(clk_500Hz),
	.pwm_signal(pwm_signal));


frequency_scaler	b2v_inst1(
	.clk_50MHz(clk_50MHz),
	.clk_1MHz(SYNTHESIZED_WIRE_0));


endmodule
