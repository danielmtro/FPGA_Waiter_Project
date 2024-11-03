	vga_interface u0 (
		.clk_clk                                         (<connected-to-clk_clk>),                                         //                                       clk.clk
		.reset_reset_n                                   (<connected-to-reset_reset_n>),                                   //                                     reset.reset_n
		.video_scaler_0_avalon_scaler_sink_startofpacket (<connected-to-video_scaler_0_avalon_scaler_sink_startofpacket>), //         video_scaler_0_avalon_scaler_sink.startofpacket
		.video_scaler_0_avalon_scaler_sink_endofpacket   (<connected-to-video_scaler_0_avalon_scaler_sink_endofpacket>),   //                                          .endofpacket
		.video_scaler_0_avalon_scaler_sink_valid         (<connected-to-video_scaler_0_avalon_scaler_sink_valid>),         //                                          .valid
		.video_scaler_0_avalon_scaler_sink_ready         (<connected-to-video_scaler_0_avalon_scaler_sink_ready>),         //                                          .ready
		.video_scaler_0_avalon_scaler_sink_data          (<connected-to-video_scaler_0_avalon_scaler_sink_data>),          //                                          .data
		.video_vga_controller_0_external_interface_CLK   (<connected-to-video_vga_controller_0_external_interface_CLK>),   // video_vga_controller_0_external_interface.CLK
		.video_vga_controller_0_external_interface_HS    (<connected-to-video_vga_controller_0_external_interface_HS>),    //                                          .HS
		.video_vga_controller_0_external_interface_VS    (<connected-to-video_vga_controller_0_external_interface_VS>),    //                                          .VS
		.video_vga_controller_0_external_interface_BLANK (<connected-to-video_vga_controller_0_external_interface_BLANK>), //                                          .BLANK
		.video_vga_controller_0_external_interface_SYNC  (<connected-to-video_vga_controller_0_external_interface_SYNC>),  //                                          .SYNC
		.video_vga_controller_0_external_interface_R     (<connected-to-video_vga_controller_0_external_interface_R>),     //                                          .R
		.video_vga_controller_0_external_interface_G     (<connected-to-video_vga_controller_0_external_interface_G>),     //                                          .G
		.video_vga_controller_0_external_interface_B     (<connected-to-video_vga_controller_0_external_interface_B>)      //                                          .B
	);

