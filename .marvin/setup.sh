#!/bin/bash

# MAVEN Setup Script
# MMA's Agentic Virtual Executive Navigator
# Sets up a personalized MAVEN workspace for MMA staff

set -e

# Colors
GOLD='\033[38;5;214m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Helpers
header() { echo -e "\n${GOLD}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; echo -e "${GOLD}${BOLD}  $1${RESET}"; echo -e "${GOLD}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"; }
info() { echo -e "${BLUE}  ℹ ${RESET} $1"; }
success() { echo -e "${GREEN}  ✓ ${RESET} $1"; }
warn() { echo -e "${RED}  ! ${RESET} $1"; }
ask() { echo -en "${GOLD}  ? ${RESET} $1"; }

# ═══════════════════════════════════════════════════════════════
# WELCOME
# ═══════════════════════════════════════════════════════════════

clear
header "MAVEN — MMA's AI Assistant"

echo -e "  Welcome! MAVEN is your personal AI-powered assistant,"
echo -e "  built specifically for Marketing + Media Alliance staff."
echo -e ""
echo -e "  ${BOLD}What MAVEN can do:${RESET}"
echo -e "  ${DIM}─────────────────────────────────────────────────────${RESET}"
echo -e "  ${GOLD}Writing${RESET}     Draft emails, blog posts, social content,"
echo -e "             event promos, and member communications"
echo -e "             — all in MMA's brand voice."
echo -e ""
echo -e "  ${GOLD}Research${RESET}    Summarize Future Lab results, format"
echo -e "             think tank briefs, write case studies,"
echo -e "             and research any topic online."
echo -e ""
echo -e "  ${GOLD}Meetings${RESET}    Prep for upcoming calls, generate"
echo -e "             segmented follow-up emails, and"
echo -e "             summarize Slack channel activity."
echo -e ""
echo -e "  ${GOLD}Operations${RESET}  Manage Asana tasks, find documents"
echo -e "             on SharePoint, and track your work."
echo -e ""
echo -e "  ${GOLD}Memory${RESET}      MAVEN remembers your priorities,"
echo -e "             projects, and preferences across sessions."
echo -e ""
echo -e "  MAVEN knows MMA inside and out — our think tanks,"
echo -e "  Future Labs, events, teams, and brand guidelines"
echo -e "  are all built in."
echo -e ""

read -p "  Press Enter to get started..."

# ═══════════════════════════════════════════════════════════════
# PREREQUISITES
# ═══════════════════════════════════════════════════════════════

header "Checking Prerequisites"

# Check Claude Code
if command -v claude &>/dev/null; then
    success "Claude Code is installed"
else
    warn "Claude Code is not installed."
    echo ""
    info "Install it by visiting: https://claude.ai/download"
    info "Or run: brew install claude"
    echo ""
    info "After installing, run this setup script again."
    exit 1
fi

# Check git
if command -v git &>/dev/null; then
    success "Git is installed"
else
    warn "Git is not installed."
    info "Install it: xcode-select --install"
    exit 1
fi

# Check if we're in the MAVEN directory
MAVEN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ ! -f "$MAVEN_DIR/.claude/rules/mma-context.md" ]; then
    warn "This doesn't look like a MAVEN directory."
    info "Make sure you cloned the MAVEN repository first:"
    info "  git clone https://github.com/[repo]/MAVEN.git ~/maven"
    info "  cd ~/maven && ./.marvin/setup.sh"
    exit 1
fi
success "MAVEN directory found: $MAVEN_DIR"

# ═══════════════════════════════════════════════════════════════
# ABOUT CLAUDE CODE (brief intro)
# ═══════════════════════════════════════════════════════════════

header "Quick Intro: How MAVEN Works"

echo -e "  MAVEN runs inside ${BOLD}Claude Code${RESET}, which is a terminal-based"
echo -e "  AI assistant. Here are the basics:"
echo -e ""
echo -e "  ${BOLD}Starting MAVEN:${RESET}"
echo -e "    Open your terminal, navigate to your maven folder,"
echo -e "    and type ${GOLD}claude${RESET}. Then type ${GOLD}/maven${RESET} to start your session."
echo -e ""
echo -e "  ${BOLD}Slash Commands:${RESET}  Type ${GOLD}/${RESET} to see available commands"
echo -e "    /maven     Start your day with a briefing"
echo -e "    /end       Save your session and sign off"
echo -e "    /update    Quick save mid-session"
echo -e "    /help      See all commands and skills"
echo -e ""
echo -e "  ${BOLD}Skills:${RESET}  MAVEN has 21+ built-in skills that activate"
echo -e "    automatically. Just describe what you need:"
echo -e "    ${DIM}\"Write an email to the membership team about...\"${RESET}"
echo -e "    ${DIM}\"Summarize the CAP lab results for the board\"${RESET}"
echo -e "    ${DIM}\"Prep me for my call with [Name]\"${RESET}"
echo -e "    ${DIM}\"Create a LinkedIn post promoting POSSIBLE\"${RESET}"
echo -e ""
echo -e "  ${BOLD}Memory:${RESET}  Tell MAVEN to remember things and it will."
echo -e "    Your preferences, projects, and context carry over"
echo -e "    between sessions."
echo -e ""
echo -e "  ${BOLD}Customization:${RESET}  Over time, you can ask MAVEN to create"
echo -e "    new skills for your specific repeatable workflows."
echo -e "    ${DIM}\"Create a skill for generating weekly status reports\"${RESET}"
echo -e ""

read -p "  Press Enter to continue..."

# ═══════════════════════════════════════════════════════════════
# GATHER USER INFO
# ═══════════════════════════════════════════════════════════════

header "Let's Set Up Your Profile"

echo -e "  A few quick questions so MAVEN can personalize your experience.\n"

# Name
ask "Your full name: "
read USER_NAME
if [ -z "$USER_NAME" ]; then
    warn "Name is required."
    exit 1
fi

# Role
ask "Your role/title at MMA: "
read USER_ROLE
if [ -z "$USER_ROLE" ]; then
    USER_ROLE="Team Member"
fi

# Department
echo -e ""
echo -e "  ${BOLD}Departments:${RESET}"
echo -e "  1) Leadership / Strategy"
echo -e "  2) Research (MATT, MOSTT, ALTT, DATT)"
echo -e "  3) Membership"
echo -e "  4) Sales / Business Development"
echo -e "  5) Marketing / Content"
echo -e "  6) Events / PMO"
echo -e "  7) Finance / Operations"
echo -e "  8) Design / Web"
echo -e "  9) Regional (APAC, LATAM, EMEA)"
echo -e "  10) Other"
echo -e ""
ask "Your department (number or name): "
read DEPT_INPUT

case "$DEPT_INPUT" in
    1) USER_DEPT="Leadership / Strategy" ;;
    2) USER_DEPT="Research" ;;
    3) USER_DEPT="Membership" ;;
    4) USER_DEPT="Sales / Business Development" ;;
    5) USER_DEPT="Marketing / Content" ;;
    6) USER_DEPT="Events / PMO" ;;
    7) USER_DEPT="Finance / Operations" ;;
    8) USER_DEPT="Design / Web" ;;
    9) USER_DEPT="Regional" ;;
    10) USER_DEPT="Other" ;;
    *) USER_DEPT="$DEPT_INPUT" ;;
esac

# Communication style
echo -e ""
echo -e "  ${BOLD}How should MAVEN communicate with you?${RESET}"
echo -e "  1) ${BOLD}Direct${RESET} — Straight to the point, no fluff (MMA default)"
echo -e "  2) ${BOLD}Friendly${RESET} — Warm but efficient"
echo -e "  3) ${BOLD}Detailed${RESET} — Thorough explanations, more context"
echo -e ""
ask "Style (1-3, default 1): "
read STYLE_INPUT

case "$STYLE_INPUT" in
    2) COMM_STYLE="Friendly and warm but efficient. Include brief context when presenting information." ;;
    3) COMM_STYLE="Thorough and detailed. Provide context, explain reasoning, and offer alternatives." ;;
    *) COMM_STYLE="Direct and concise. Lead with the answer. No filler or pleasantries." ;;
esac

# Primary tools
ask "Which tools do you use most? (e.g., Outlook, Slack, Asana): "
read USER_TOOLS
if [ -z "$USER_TOOLS" ]; then
    USER_TOOLS="Outlook, Slack, Asana"
fi

success "Profile captured!"

# ═══════════════════════════════════════════════════════════════
# CREATE PERSONAL FILES
# ═══════════════════════════════════════════════════════════════

header "Creating Your Workspace"

# Create CLAUDE.md (user's personal config)
if [ -f "$MAVEN_DIR/CLAUDE.md" ] && ! grep -q "\[Your name\]" "$MAVEN_DIR/CLAUDE.md"; then
    info "CLAUDE.md already personalized — skipping"
else
    cat > "$MAVEN_DIR/CLAUDE.md" << CLAUDEMD
# MAVEN — $USER_NAME's AI Assistant

MAVEN = MMA's Agentic Virtual Executive Navigator

## Your Profile

**Name:** $USER_NAME
**Role:** $USER_ROLE
**Department:** $USER_DEPT
**Primary Tools:** $USER_TOOLS

## Communication Style

$COMM_STYLE

## Your Preferences

<!-- Add preferences below. MAVEN reads this file at the start of every session. -->
<!-- Examples: -->
<!-- - "Always cc Angela on emails about Greg's schedule" -->
<!-- - "I prefer bullet points over paragraphs" -->
<!-- - "My current project focus is POSSIBLE 2026" -->

## Notes

<!-- Add anything you want MAVEN to remember here. -->
<!-- You can also tell MAVEN "remember that..." and it will update this file. -->
CLAUDEMD
    success "Created CLAUDE.md with your profile"
fi

# Create state/current.md
if [ -f "$MAVEN_DIR/state/current.md" ] && ! grep -q "\[Add your priorities here\]" "$MAVEN_DIR/state/current.md"; then
    info "state/current.md already exists — skipping"
else
    mkdir -p "$MAVEN_DIR/state"
    cat > "$MAVEN_DIR/state/current.md" << STATEMD
# Current State — $USER_NAME

**Last Updated:** $(date +%Y-%m-%d)

## Active Priorities
1. Get comfortable with MAVEN
2. [Add your priorities here]
3. [Add your priorities here]

## Open Threads
- [ ] Complete MAVEN setup and explore capabilities
- [ ] [Add open items here]

## Recent Context
- Just set up MAVEN ($(date +%Y-%m-%d))
STATEMD
    success "Created state/current.md"
fi

# Create state/goals.md
if [ -f "$MAVEN_DIR/state/goals.md" ] && ! grep -q "\[Add your goals\]" "$MAVEN_DIR/state/goals.md"; then
    info "state/goals.md already exists — skipping"
else
    cat > "$MAVEN_DIR/state/goals.md" << GOALSMD
# Goals — $USER_NAME

## Work Goals
- [Add your goals]

## Personal Development Goals
- Learn to use MAVEN effectively for daily workflows
- [Add your goals]
GOALSMD
    success "Created state/goals.md"
fi

# Create .env from .env.example
if [ -f "$MAVEN_DIR/.env" ]; then
    info ".env already exists — skipping"
else
    if [ -f "$MAVEN_DIR/.env.example" ]; then
        cp "$MAVEN_DIR/.env.example" "$MAVEN_DIR/.env"
        success "Created .env from template"
    fi
fi

# Create directories
mkdir -p "$MAVEN_DIR/sessions" "$MAVEN_DIR/reports" "$MAVEN_DIR/content"
# Add .gitkeep files so directories are tracked
touch "$MAVEN_DIR/sessions/.gitkeep" "$MAVEN_DIR/reports/.gitkeep"
success "Created workspace directories"

# ═══════════════════════════════════════════════════════════════
# SHELL ALIAS
# ═══════════════════════════════════════════════════════════════

header "Terminal Shortcut"

SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

ALIAS_CMD="alias maven='cd $MAVEN_DIR && claude'"

if [ -n "$SHELL_RC" ]; then
    if grep -q "alias maven=" "$SHELL_RC" 2>/dev/null; then
        info "Shell alias already exists — skipping"
    else
        echo -e "\n# MAVEN - MMA's AI Assistant" >> "$SHELL_RC"
        echo "$ALIAS_CMD" >> "$SHELL_RC"
        success "Added 'maven' shortcut to $SHELL_RC"
        info "After setup, open a new terminal and type ${BOLD}maven${RESET} to start"
    fi
else
    warn "Couldn't find .zshrc or .bashrc"
    info "Add this to your shell config manually:"
    echo -e "    $ALIAS_CMD"
fi

# ═══════════════════════════════════════════════════════════════
# INTEGRATIONS
# ═══════════════════════════════════════════════════════════════

header "Connect Your Tools"

echo -e "  MAVEN works best when connected to your work tools."
echo -e "  We'll set up the essentials first, then offer extras.\n"

# --- CORE INTEGRATIONS ---

echo -e "  ${BOLD}Core Integrations (recommended for everyone):${RESET}\n"

# MS365
echo -e "  ${BOLD}1. Microsoft 365${RESET} — Email, calendar, SharePoint"
echo -e "     ${DIM}Read/send email, check your calendar, find documents${RESET}"
ask "Set up MS365? (Y/n): "
read SETUP_MS365
if [[ ! "$SETUP_MS365" =~ ^[Nn]$ ]]; then
    if [ -f "$MAVEN_DIR/.marvin/integrations/ms365/setup.sh" ]; then
        bash "$MAVEN_DIR/.marvin/integrations/ms365/setup.sh"
    else
        warn "MS365 setup script not found. Ask Alec for help."
    fi
fi

# Parallel Search (auto-install, no config needed)
echo -e ""
info "Setting up web search (free, automatic)..."
if [ -f "$MAVEN_DIR/.marvin/integrations/parallel-search/setup.sh" ]; then
    bash "$MAVEN_DIR/.marvin/integrations/parallel-search/setup.sh" --auto 2>/dev/null || true
    success "Web search ready"
else
    info "Web search setup not found — can be configured later"
fi

# Slack
echo -e ""
echo -e "  ${BOLD}2. Slack${RESET} — Read channels, search messages"
echo -e "     ${DIM}Summarize channels, catch up on discussions${RESET}"
ask "Set up Slack? (Y/n): "
read SETUP_SLACK
if [[ ! "$SETUP_SLACK" =~ ^[Nn]$ ]]; then
    if [ -f "$MAVEN_DIR/.marvin/integrations/slack/setup.sh" ]; then
        bash "$MAVEN_DIR/.marvin/integrations/slack/setup.sh"
    else
        warn "Slack setup script not found. Ask Alec for help."
    fi
fi

# Asana
echo -e ""
echo -e "  ${BOLD}3. Asana${RESET} — Task and project management"
echo -e "     ${DIM}Create tasks, check project status, manage assignments${RESET}"
ask "Set up Asana? (Y/n): "
read SETUP_ASANA
if [[ ! "$SETUP_ASANA" =~ ^[Nn]$ ]]; then
    if [ -f "$MAVEN_DIR/.marvin/integrations/asana/setup.sh" ]; then
        bash "$MAVEN_DIR/.marvin/integrations/asana/setup.sh"
    else
        warn "Asana setup script not found. Ask Alec for help."
    fi
fi

# --- OPTIONAL INTEGRATIONS ---

echo -e ""
echo -e "  ${BOLD}Optional Integrations:${RESET}"
echo -e "  ${DIM}These add extra capabilities. Skip any you don't need.${RESET}\n"

echo -e "  4) ${BOLD}Fireflies${RESET}     — Meeting transcription and search"
echo -e "  5) ${BOLD}Granola${RESET}       — AI meeting notes (recommended)"
echo -e "  6) ${BOLD}Salesforce${RESET}    — CRM, member data (mainly Sales team)"
echo -e "  7) ${BOLD}OpenAI${RESET}        — GPT models for comparison tasks"
echo -e "  8) ${BOLD}Gemini${RESET}        — Google AI models"
echo -e "  9) ${BOLD}ElevenLabs${RESET}    — Text-to-speech, audio generation"
echo -e "  10) ${BOLD}Context7${RESET}     — Up-to-date library docs (technical users)"
echo -e "  11) ${BOLD}Exa${RESET}          — Advanced web search (requires API key)"
echo -e ""
ask "Enter numbers to install (e.g., 4 5 8), or press Enter to skip: "
read OPTIONAL_CHOICES

for choice in $OPTIONAL_CHOICES; do
    case "$choice" in
        4)
            info "Setting up Fireflies..."
            if [ -f "$MAVEN_DIR/.marvin/integrations/fireflies/setup.sh" ]; then
                bash "$MAVEN_DIR/.marvin/integrations/fireflies/setup.sh"
            else
                warn "Fireflies setup not found. Ask Alec for the API key."
            fi
            ;;
        5)
            info "Setting up Granola..."
            if [ -f "$MAVEN_DIR/.marvin/integrations/granola/setup.sh" ]; then
                bash "$MAVEN_DIR/.marvin/integrations/granola/setup.sh"
            else
                info "Granola connects via the claude.ai Granola connector."
                info "In Claude Code, run: claude mcp add granola"
                info "Or enable the Granola connector in claude.ai settings."
                success "Granola noted — see instructions above"
            fi
            ;;
        6)
            info "Setting up Salesforce..."
            if [ -f "$MAVEN_DIR/.marvin/integrations/salesforce/setup.sh" ]; then
                bash "$MAVEN_DIR/.marvin/integrations/salesforce/setup.sh"
            else
                warn "Salesforce setup not found. Ask Alec for help."
            fi
            ;;
        7)
            info "Setting up OpenAI..."
            ask "OpenAI API key: "
            read OPENAI_KEY
            if [ -n "$OPENAI_KEY" ]; then
                echo "OPENAI_API_KEY=$OPENAI_KEY" >> "$MAVEN_DIR/.env"
                success "OpenAI key saved to .env"
            fi
            ;;
        8)
            info "Setting up Gemini..."
            ask "Gemini API key: "
            read GEMINI_KEY
            if [ -n "$GEMINI_KEY" ]; then
                echo "GEMINI_API_KEY=$GEMINI_KEY" >> "$MAVEN_DIR/.env"
                success "Gemini key saved to .env"
            fi
            ;;
        9)
            info "Setting up ElevenLabs..."
            ask "ElevenLabs API key: "
            read ELEVENLABS_KEY
            if [ -n "$ELEVENLABS_KEY" ]; then
                echo "ELEVENLABS_API_KEY=$ELEVENLABS_KEY" >> "$MAVEN_DIR/.env"
                success "ElevenLabs key saved to .env"
            fi
            ;;
        10)
            info "Context7 is available as an MCP server."
            info "It will be configured automatically if installed."
            success "Context7 noted — configure via 'claude mcp add'"
            ;;
        11)
            info "Setting up Exa..."
            ask "Exa API key (get one at exa.ai): "
            read EXA_KEY
            if [ -n "$EXA_KEY" ]; then
                echo "EXA_API_KEY=$EXA_KEY" >> "$MAVEN_DIR/.env"
                success "Exa key saved to .env"
            fi
            ;;
        *)
            warn "Unknown option: $choice — skipping"
            ;;
    esac
done

echo ""
success "Integrations configured!"
info "You can add more integrations later. Ask MAVEN for help."

# ═══════════════════════════════════════════════════════════════
# GETTING UPDATES
# ═══════════════════════════════════════════════════════════════

header "Staying Up to Date"

echo -e "  MAVEN is actively maintained by Alec Foster."
echo -e "  New skills, context updates, and improvements are"
echo -e "  published regularly."
echo -e ""
echo -e "  ${BOLD}To get the latest updates:${RESET}"
echo -e ""
echo -e "    ${GOLD}cd ~/maven && git pull${RESET}"
echo -e ""
echo -e "  Or inside MAVEN, type ${GOLD}/sync${RESET}"
echo -e ""
echo -e "  Your personal files (CLAUDE.md, state, sessions)"
echo -e "  are ${BOLD}never overwritten${RESET} by updates."
echo -e ""

read -p "  Press Enter to continue..."

# ═══════════════════════════════════════════════════════════════
# DONE
# ═══════════════════════════════════════════════════════════════

header "You're All Set!"

echo -e "  ${BOLD}$USER_NAME${RESET}, MAVEN is ready to go.\n"
echo -e "  ${BOLD}What MAVEN knows about MMA:${RESET}"
echo -e "  ├── Think tanks (MATT, MOSTT, ALTT, DATT)"
echo -e "  ├── Future Labs (CAP, A3, ACE, SIFT, AURA, RAIL, ARC)"
echo -e "  ├── Events (POSSIBLE, CMO Summit, SMARTIES)"
echo -e "  ├── Teams, staff, Slack channels"
echo -e "  ├── SharePoint sites and document locations"
echo -e "  ├── Brand voice and formatting standards"
echo -e "  └── 2026 strategic priorities"
echo -e ""
echo -e "  ${BOLD}21+ Skills Ready to Use:${RESET}"
echo -e "  ├── ${GOLD}Writing:${RESET} emails, blog posts, social, event promos, member comms"
echo -e "  ├── ${GOLD}Research:${RESET} lab summaries, think tank briefs, case studies, web research"
echo -e "  ├── ${GOLD}Meetings:${RESET} follow-ups, prep, Slack summaries"
echo -e "  └── ${GOLD}Operations:${RESET} Asana tasks, SharePoint navigation"
echo -e ""
echo -e "  ${BOLD}Next Steps:${RESET}"
echo -e "  1. Open a new terminal window"
echo -e "  2. Type ${GOLD}maven${RESET} (or ${GOLD}cd ~/maven && claude${RESET})"
echo -e "  3. Type ${GOLD}/maven${RESET} to get your first briefing"
echo -e "  4. Type ${GOLD}/help${RESET} to see everything MAVEN can do"
echo -e ""
echo -e "  ${BOLD}Tips:${RESET}"
echo -e "  • Just describe what you need — MAVEN will figure out which skill to use"
echo -e "  • Start each day with ${GOLD}/maven${RESET} and end with ${GOLD}/end${RESET}"
echo -e "  • Tell MAVEN to ${GOLD}remember${RESET} things and they'll carry over"
echo -e "  • Ask MAVEN to ${GOLD}create a skill${RESET} for your repeatable workflows"
echo -e ""
echo -e "  Questions? Reach out to Alec Foster on Slack (#ai-upskilling)"
echo -e "  or email alec.foster@mmaglobal.com"
echo -e ""
echo -e "${GOLD}${BOLD}  Happy marketing! 🚀${RESET}"
echo -e ""
