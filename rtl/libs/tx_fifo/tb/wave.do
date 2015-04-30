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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2731 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {31387 ns}
