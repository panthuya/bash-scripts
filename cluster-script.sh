# -------------------------------
# Kubernetes context switcher
# -------------------------------
kcu() {
    # List of contexts exactly as they appear in 'kubectl config get-contexts'
    local contexts=(
        "ack-nextapp"
        "ack-prod-shared"
        "onprem-prod"
        "devops-rbac"
        "ack-nonprod"
        "onprem-nonprod-k0s"
    )

    local context_count=${#contexts[@]}

    echo "Available Kubernetes contexts:"
    for (( i=1; i<=context_count; i++ )); do
        local display_name="${contexts[i]}"
        
        # Rename "devops-rbac" to "k0s-onprem-prod" ONLY for the display menu
        if [[ "$display_name" == "devops-rbac" ]]; then
            display_name="k0s-onprem-prod"
        fi
        
        echo "$i) $display_name"
    done

    # Zsh-compatible input prompt
    local choice
    read "choice?Enter the number of the context to switch to: "

    # Validate input
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$context_count" ]; then
        echo "Invalid selection!"
        return 1
    fi

    # Select the real context name based on the number
    local selected="${contexts[$choice]}"

    # Switch context safely
    if kubectl config use-context "$selected"; then
        echo "Switched to context: $selected"
    else
        echo "Failed to switch context: $selected"
        return 1
    fi
}

# -------------------------------
# Show current K8s context in prompt
# -------------------------------
kube_context() {
    kubectl config current-context 2>/dev/null
}

setopt PROMPT_SUBST
PROMPT='%{$fg[cyan]%}⚓ $(kube_context)%{$reset_color%} '$PROMPT

# -------------------------------
# Kubernetes / CLI paths
# -------------------------------
alias k=kubectl
export KUBECONFIG=~/.kube/ack-nextapp.yaml:~/.kube/ack-nonprod.yaml:~/.kube/ack-prod-shared.yaml:~/.kube/onprem-nonprod-k0s.yaml:~/.kube/onprem-prod.yaml:~/.kube/k0s-onprem-prod.yaml

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH=$PATH:/opt/wso2/apictl
export PATH=$PATH:/usr/local/go/bin
alias mydir='cd /mnt/c/Users/panthuya/Downloads/'

# -------------------------------
# NVM
# -------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
