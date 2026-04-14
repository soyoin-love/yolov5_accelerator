onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -L blk_mem_gen_v8_4_8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.rbuf xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {rbuf.udo}

run 1000ns

quit -force
