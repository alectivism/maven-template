#!/bin/bash

# MMA MARVIN - Fireflies Integration Setup
# Connects Fireflies for meeting transcription

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_color() { printf "${1}${2}${NC}\n"; }

print_color "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$CYAN" "Fireflies Integration Setup"
print_color "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check for Claude Code
if ! command -v claude >/dev/null 2>&1; then
    print_color "$RED" "Claude Code is required. Install it first."
    exit 1
fi

# Scope selection
echo "Where should this integration be available?"
echo "  1) Just this project (project scope)"
echo "  2) All Claude Code projects (user scope)"
read -p "Choose [1/2]: " SCOPE_CHOICE

case $SCOPE_CHOICE in
    1) SCOPE="project" ;;
    *) SCOPE="user" ;;
esac

# Get API key
echo ""
echo "Fireflies uses an API key for authentication."
echo "Get yours from: https://app.fireflies.ai/integrations/custom/fireflies"
echo ""
read -p "Paste your Fireflies API key: " FF_KEY

if [[ -z "$FF_KEY" ]]; then
    print_color "$RED" "No API key provided. Setup cancelled."
    exit 1
fi

# Install
claude mcp remove fireflies 2>/dev/null || true
claude mcp add fireflies -s "$SCOPE" --transport http https://api.fireflies.ai/mcp --header "Authorization: Bearer $FF_KEY"

echo ""
print_color "$GREEN" "Fireflies integration installed!"
print_color "$GREEN" "Capabilities: search transcripts, get summaries, retrieve meeting notes"
echo ""
print_color "$YELLOW" "Restart Claude Code to activate."
