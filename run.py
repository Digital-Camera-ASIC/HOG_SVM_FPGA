import subprocess

def run_simulation():
    subprocess.run("mingw32-make", shell=True, cwd="./uvm_test_hog/sim")
    # command = "vsim -batch -do run_sim.do > log.txt"
    # subprocess.run(command, shell=True)

run_simulation()