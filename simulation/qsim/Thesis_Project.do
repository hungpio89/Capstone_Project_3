onerror {quit -f}
vlib work
vlog -work work Thesis_Project.vo
vlog -work work Thesis_Project.vt
vsim -novopt -c -t 1ps -L cycloneiv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.Thesis_Project_vlg_vec_tst
vcd file -direction Thesis_Project.msim.vcd
vcd add -internal Thesis_Project_vlg_vec_tst/*
vcd add -internal Thesis_Project_vlg_vec_tst/i1/*
add wave /*
run -all
