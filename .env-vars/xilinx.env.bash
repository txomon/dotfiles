alias acroread="evince"
if [ -d /opt/Xilinx ]; then
    alias xilinx="source /opt/Xilinx/$(ls -1 /opt/Xilinx/ | head)/ISE_DS/settings64.sh"
fi
