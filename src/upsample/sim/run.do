# 1. 退出当前可能正在运行的仿真
quit -sim

encoding system utf-8
# 2. 清除控制台信息，保持界面整洁
.main clear

# 3. 创建并映射工作库 (work)
vlib work
vmap work work

# 4. 编译源代码 (-sv 表示支持 SystemVerilog 语法)
# 提示：+incdir+ 用于指定 `include 文件的搜索路径。
# 根据你 upsample.v 中 `include "../../parameters.v" 的层级，这里可能需要调整包含路径 
vlog -work work -sv +incdir+../../ ../src/*.v

# 5. 编译仿真测试台 (在 sim 目录下)
vlog -work work -sv ./*.sv

# 6. 启动仿真
# -voptargs="+acc" 的作用是阻止 ModelSim 优化掉内部信号，确保你能抓到所有底层波形
vsim -voptargs="+acc" work.tb_upsample_fifo

# 7. 添加波形
# 这一句会自动把 testbench 下的所有顶层信号加入波形窗口
add wave -position insertpoint sim:/tb_upsample_fifo/*

# (可选) 如果你想专门观察 upsample_fifo 内部的指针和空满信号，可以解除下面这行的注释：
add wave -position insertpoint sim:/tb_upsample_fifo/dut/*

# 8. 运行仿真
# run -all 表示一直运行到代码中遇到 $finish，或者你手动停止
run -all