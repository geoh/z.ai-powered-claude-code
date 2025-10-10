#!/bin/bash

# Reset to default
RESET='\033[0m'

# Foreground colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
DEFAULT='\033[0;39m'

# Bold foreground colors
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_PURPLE='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'
BOLD_DEFAULT='\033[1;39m'

# Background colors
BG_BLACK='\033[0;40m'
BG_RED='\033[0;41m'
BG_GREEN='\033[0;42m'
BG_YELLOW='\033[0;43m'
BG_BLUE='\033[0;44m'
BG_PURPLE='\033[0;45m'
BG_CYAN='\033[0;46m'
BG_WHITE='\033[0;47m'
BG_DEFAULT='\033[0;39m'

# Read JSON input once
input=$(cat)

# Helper functions for common extractions
get_hook_event() { echo "$input" | jq -r '.hook_event_name'; }
get_session_id() { echo "$input" | jq -r '.session_id'; }
get_transcript_path() { echo "$input" | jq -r '.transcript_path'; }
get_cwd() { echo "$input" | jq -r '.cwd'; }
get_model_id() { echo "$input" | jq -r '.model.id'; }
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_output_style() { echo "$input" | jq -r '.output_style.name'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_api_duration() { echo "$input" | jq -r '.cost.total_api_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Show git branch if in a git repo
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | 🌿 ${BOLD_BLUE}${BRANCH}${RESET}"
    fi
fi

# Use the helpers
MODEL_ID=$(get_model_id)
MODEL_NAME=$(get_model_name)
CURRENT_DIR=$(get_current_dir)
# Escape backslashes in the current directory path to prevent interpretation as escape sequences
CURRENT_DIR_ESCAPED=$(echo "${CURRENT_DIR##*/}" | sed 's/\\/\\\\/g')
LINES_ADDED=$(get_lines_added)
LINES_REMOVED=$(get_lines_removed)
API_DURATION=$(($(get_api_duration) / 1000))
DURATION=$(($(get_duration) / 1000))
COST=$(get_cost)
COST_ROUNDED=$(awk 'BEGIN{printf "%.3f", '"$COST"'}')

# Build the output
OUTPUT="${RESET}"

if [[ ${MODEL_ID} == claude-* ]]; then
  OUTPUT+="👾"
else
  OUTPUT+="👹"
fi

OUTPUT+=" [ ${BOLD_WHITE}${MODEL_NAME}${RESET} ]" # Model name
OUTPUT+=" 📁 ${BOLD_YELLOW}${CURRENT_DIR_ESCAPED}${RESET}" # Current dir
OUTPUT+="${GIT_BRANCH} ${BOLD_GREEN}+${RESET}${LINES_ADDED} ${BOLD_RED}-${RESET}${LINES_REMOVED}" # Git stuff
OUTPUT+=" | ⌚ ${GREEN}${API_DURATION}${RESET}/${PURPLE}${DURATION}${RESET}s" # Duration
OUTPUT+=" | 💲${GREEN}${COST_ROUNDED}${RESET}" # Cost

if [[ ${MODEL_ID} == claude-* ]]; then
  OUTPUT+=" 👾"
else
  OUTPUT+=" 👹"
fi

echo -e "$OUTPUT"