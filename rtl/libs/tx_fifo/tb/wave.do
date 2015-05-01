onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/i_wclk
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/i_wrst_n
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/i_push
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/i_rclk
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/i_rrst_n
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/i_pop
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/o_wptr
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/o_wren
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/o_rptr
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/o_rden
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/o_afull
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/o_aempty
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/fifo_empty
add wave -noupdate /tb/tx_fifo0/tx_fifo_ctlr/fifo_full
add wave -noupdate /tb/tx_fifo0/i_push
add wave -noupdate /tb/tx_fifo0/i_wdata
add wave -noupdate /tb/tx_fifo0/dp_ram/i_waddr
add wave -noupdate /tb/tx_fifo0/dp_ram/i_wen
add wave -noupdate /tb/tx_fifo0/dp_ram/i_wdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11 ns} 0} {{Cursor 2} {29806 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 201
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {75 ns}
