function kubetoken 
	kubectl get pods 1>/dev/null
	cat ~/.kube/config | grep access-token | sed -e 's/.*: //' | xclip -selection clipboard
	echo Kubernetes access token for context (kubectl config current-context) copied
end
