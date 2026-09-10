# Copy the current context's OIDC access token to the clipboard.

# Force a refresh. An unreachable cluster is worth saying out loud, but it is
# not fatal: the kubeconfig may still hold a token that is good enough.
#
# timeout, not --request-timeout: kubectl retries API discovery five times, so
# --request-timeout=5s still costs 25 seconds against a cluster that is down.
if ! timeout 5s kubectl "$@" get pods >/dev/null 2>&1; then
	echo "kubetoken: kubectl get pods failed, the token below may be stale" >&2
fi

# `config current-context` ignores --context, so ask the minified view which
# context the flags actually selected.
context=$(kubectl "$@" config view --minify -o jsonpath='{.current-context}')

# --minify scopes the view to that one context. Without it, --raw dumps every
# context and grep takes whichever token happens to come first in the file.
if ! token=$(kubectl "$@" config view --minify --raw | grep -m1 access-token | sed -e 's/.*: //'); then
	echo "kubetoken: no access-token in the kubeconfig for context $context" >&2
	exit 1
fi

printf '%s' "$token" | xclip -selection clipboard
echo "Kubernetes access token for context $context copied"
