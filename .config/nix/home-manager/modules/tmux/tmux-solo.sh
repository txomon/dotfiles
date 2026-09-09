# Flip a client to a "solo" session that holds ONLY one window (linked/shared).
#
# Normally triggered by the tmux 'prefix S' key binding, which passes the
# current window id and the pressing client. It can also be run directly from a
# shell inside tmux with no arguments, in which case it solos the current window
# for the current client.
#
# The window is *linked*, not moved: it keeps living in the default session and
# killing/detaching the solo never destroys it. Re-soloing the same window
# reuses its solo session (identity is keyed on the immutable window id, so it
# survives tmux's automatic window renaming and never collides on shared names).
#
# Args (optional; supplied by the key binding):
#   $1  wid     window id             (e.g. "@3")
#   $2  client  invoking client name  (e.g. "/dev/pts/4")
# writeShellApplication runs this under `set -u`, and both arguments are
# optional: the key binding passes them, a direct call does not.
wid="${1:-}"; client="${2:-}"

if [ -z "$wid" ] || [ -z "$client" ]; then
	if [ -z "${TMUX:-}" ]; then
		echo "tmux-solo: run this from inside tmux (or use the 'prefix S' binding)." >&2
		exit 2
	fi
	# Direct invocation: fall back to the current window / current client.
	[ -z "$wid" ] && wid=$(tmux display-message -p '#{window_id}')
	[ -z "$client" ] && client=$(tmux display-message -p '#{client_name}')
fi

# Reuse an existing solo session for THIS window (match by immutable id, not name).
name=$(tmux list-windows -a -F '#{window_id} #{session_name}' \
	| awk -v w="$wid" '$1 == w && $2 ~ /^solo-/ { print $2; exit }')

if [ -z "$name" ]; then
	wname=$(tmux display-message -p -t "$wid" '#{window_name}')
	slug=$(printf '%s' "$wname" | LC_ALL=C tr -c 'A-Za-z0-9_-' '-')
	name="solo-${slug}-${wid#@}"
	tmux new-session -d -s "$name"
	tmux link-window -s "$wid" -t "$name:1" -k
fi

tmux switch-client -c "$client" -t "$name"
