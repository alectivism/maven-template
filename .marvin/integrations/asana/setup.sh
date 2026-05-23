#!/bin/bash

# MMA MARVIN - Asana Integration Setup
# Connects Asana for task and project management

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_color() { printf "${1}${2}${NC}\n"; }

print_color "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$CYAN" "Asana Integration Setup"
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

# Get PAT
echo ""
echo "Asana uses a Personal Access Token (PAT) for authentication."
echo "Get yours from: https://app.asana.com/0/developer-console"
echo ""
read -p "Paste your Asana PAT: " ASANA_PAT

if [[ -z "$ASANA_PAT" ]]; then
    print_color "$RED" "No PAT provided. Setup cancelled."
    exit 1
fi

# Install
claude mcp remove asana 2>/dev/null || true
claude mcp add asana -s "$SCOPE" -e ASANA_ACCESS_TOKEN="$ASANA_PAT" -- npx -y @roychri/mcp-server-asana

echo ""
print_color "$GREEN" "Asana integration installed!"
print_color "$GREEN" "Capabilities: search tasks, create tasks, update tasks, manage projects"
echo ""
print_color "$YELLOW" "Restart Claude Code to activate."
