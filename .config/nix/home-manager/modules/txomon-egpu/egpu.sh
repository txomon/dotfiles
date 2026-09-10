# Unload the nvidia stack so the eGPU can be unplugged. Dependents first.
modules=(nvidia_uvm nvidia_drm nvidia_modeset nvidia)
failed=0

for m in "${modules[@]}"; do
	if ! lsmod | grep -q "^$m "; then
		echo "$m: not loaded"
		continue
	fi
	if sudo rmmod "$m"; then
		echo "$m: unloaded"
	else
		echo "$m: rmmod failed, something is still using it" >&2
		failed=1
	fi
done

exit "$failed"
