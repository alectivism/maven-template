#!/bin/bash

# MMA MARVIN - Salesforce Integration Setup
# Connects Salesforce CRM for membership and pipeline management

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_color() { printf "${1}${2}${NC}\n"; }

print_color "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_color "$CYAN" "Salesforce Integration Setup"
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

echo ""
echo "Salesforce uses OAuth for authentication."
echo "You'll need to authenticate via browser after installation."
echo ""

# Install
claude mcp remove salesforce 2>/dev/null || true
claude mcp add salesforce -s "$SCOPE" -- npx -y @salesforce/mcp --toolsets all

echo ""
print_color "$GREEN" "Salesforce integration installed!"
print_color "$GREEN" "Capabilities: query records, manage contacts, run SOQL, membership tracking"
echo ""
print_color "$YELLOW" "Restart Claude Code to authenticate via browser."
