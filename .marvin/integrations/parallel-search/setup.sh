#!/bin/bash
# Parallel Search MCP Setup Script
# Web search integration for Claude Code
# Created by Sterling Chin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Parallel Search MCP Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check Claude Code
if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓ Claude Code installed${NC}"
else
    echo -e "${RED}✗ Claude Code not found${NC}"
    echo "Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

echo ""
echo "Where should this integration be available?"
echo "  1) All projects (user-scoped)"
echo "  2) This project only (local-scoped)"
echo ""
echo -e "${YELLOW}Choice [1]:${NC}"
read -r SCOPE_CHOICE || exit 1
SCOPE_CHOICE=${SCOPE_CHOICE:-1}

case "$SCOPE_CHOICE" in
    1) SCOPE="user" ;;
    2) SCOPE="local" ;;
    *) echo "Choose 1 or 2. No configuration changed."; exit 1 ;;
esac

# Keep saved endpoints, credentials and overrides unless the user opts in.
if claude mcp get parallel-search > /dev/null 2>&1; then
    echo ""
    echo "Parallel Search is already configured."
    echo "Replace its configuration in $SCOPE scope? (y/N)"
    read -r REPLACE || REPLACE=""
    if [[ "$REPLACE" != "y" && "$REPLACE" != "Y" ]]; then
        echo "Keeping the existing configuration."
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}Adding Parallel Search MCP to Claude Code...${NC}"

# Remove existing if present
claude mcp remove parallel-search --scope "$SCOPE" 2>/dev/null || true

# Add Parallel Search remote MCP server
claude mcp add parallel-search --scope "$SCOPE" --transport http \
    https://search.parallel.ai/mcp \
    --header "User-Agent: maven-template/parallel-search"

echo ""
echo -e "${GREEN}Parallel Search MCP added!${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "  1. Start Claude Code:"
echo -e "     ${YELLOW}claude${NC}"
echo ""
echo "  2. Try it out:"
echo -e "     ${YELLOW}\"Search the web for latest Node.js releases\"${NC}"
echo -e "     ${YELLOW}\"What's the weather in San Francisco?\"${NC}"
echo ""
echo -e "${GREEN}You're all set!${NC}"
echo ""
