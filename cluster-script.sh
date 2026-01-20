kcu() {
    # Hardcoded list of contexts (FIXED NAME)
    local contexts=(
        "ack-nextapp"
        "ack-prod-shared"
        "onprem-prod"
        "ack-nonprod"
        "onprem-nonprod-k0s"
    )

    local context_count=${#contexts[@]}

    echo "Available Kubernetes contexts:"
    local i
    for (( i=1; i<=context_count; i++ )); do
        echo "$i) ${contexts[$i]}"
    done

    # Prompt user
    local choice
    read "?Enter the number of the context to switch to: " choice

    # Validate input
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$context_count" ]; then
        echo "Invalid selection!"
        return 1
    fi

    local selected="${contexts[$choice]}"

    # SAFE SWITCH (checks kubectl exit code)
    if kubectl config use-context "$selected"; then
        echo "Switched to context: $selected"
    else
        echo "Failed to switch context: $selected"
        return 1
    fi
}

kube_context() {
    kubectl config current-context 2>/dev/null
}

# Emojs
#K8S_ANIM=(🐳 🚀 🌊 ⚓ 🌈)
#K8S_ANIM_IDX=0
#k8s_anim_icon() {
#  echo "${K8S_ANIM[$K8S_ANIM_IDX]}"
#}
#
#precmd() {
#  ((K8S_ANIM_IDX++))
#  (( K8S_ANIM_IDX > ${#K8S_ANIM[@]} )) && K8S_ANIM_IDX=1
#}

# Override prompt icon ONLY (logic unchanged)
#PROMPT='%{$fg[cyan]%} $(k8s_anim_icon) $(kube_context)%{$reset_color%} '$PROMPT
# Append context to the Git segment like (main)
# Zsh will show it in parentheses only if it exists
PROMPT='%{$fg[cyan]%}🐳 $(kube_context)%{$reset_color%} '$PROMPT
