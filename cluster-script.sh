# -------------------------------
# Kubernetes context switcher
# -------------------------------
kcu() {
    local contexts=(
        "ack-nextapp"
        "ack-prod-shared"
        "onprem-prod"
        "devops-rbac"
        "ack-nonprod"
        "onprem-nonprod-k0s"
        "k3d-mycluster"
    )

    local context_count=${#contexts[@]}

    echo "Available Kubernetes contexts:"
    for (( i=1; i<=context_count; i++ )); do
        local display_name="${contexts[i]}"
        if [[ "$display_name" == "devops-rbac" ]]; then
            display_name="k0s-onprem-prod"
        fi
        echo "$i) $display_name"
    done

    local choice
    read "choice?Enter the number: "

    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$context_count" ]; then
        echo "Invalid selection!"
        return 1
    fi

    local selected="${contexts[$choice]}"

    # --- THE FIX STARTS HERE ---
    # 1. Create a unique kubeconfig file for THIS terminal session only
    # This uses the Process ID ($$) to ensure uniqueness
    export KUBECONFIG_SAVED="$KUBECONFIG"
    local session_config="/tmp/kubeconfig-session-$$"
    
    # 2. If the session file doesn't exist yet, "flatten" your merged configs into it
    if [[ ! -f "$session_config" ]]; then
        kubectl config view --flatten > "$session_config"
        chmod 600 "$session_config"
    fi

    # 3. Tell THIS terminal to use the private file
    export KUBECONFIG="$session_config"
    # --- THE FIX ENDS HERE ---

    if kubectl config use-context "$selected" --kubeconfig="$KUBECONFIG"; then
        echo "Switched session to: $selected"
    else
        echo "Failed to switch context."
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
