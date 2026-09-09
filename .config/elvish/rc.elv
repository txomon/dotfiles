use epm
use os

use direnv
use tfenv

set edit:insert:binding[Ctrl-W] = $edit:kill-small-word-left~
set edit:insert:binding[Ctrl-F] = $edit:-instant:start~

var extra-paths = [~/bin]
var append-paths = [~/.pyenv/shims]
set paths = [(each {|p| if (os:is-dir $p) { put $p }} $extra-paths) $@paths (each {|p| if (os:is-dir $p) { put $p }} $append-paths)]

eval (starship init elvish)

set-env CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional

eval (carapace _carapace|slurp)
eval (zoxide init elvish | slurp)

fn open {|@a| xdg-open $@a }
fn cs {|@a| claude --dangerously-skip-permissions $@a }
fn chj { sudo chown -R javier: . }
fn atm10-rcon {|@a| ssh -t gandalf 'podman exec -it all-the-mods-10 rcon-cli' $@a }
fn xcc {|@a| xclip -selection clipboard $@a }
fn xcp {|@a| xclip -selection primary $@a }
fn git-send-email-openwrt {|@a| git send-email --from "Javier Domingo Cansino <javierdo1@gmail.com>" --cc "openwrt-devel@lists.openwrt.org" --smtp-server smtp.gmail.com --smtp-encryption ssl --confirm --smtp-user javierdo1@gmail.com $@a }
fn kubetoken {
  try { kubectl get pods > /dev/null } catch e { }
  try {
    kubectl config view --raw | grep access-token | sed -e 's/.*: //' | xclip -selection clipboard
    echo "Kubernetes access token for context "(kubectl config current-context)" copied"
  } catch e {
    echo "kubetoken: no access-token in the current kubeconfig" >&2
  }
}
