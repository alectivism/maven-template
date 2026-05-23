#!/bin/bash
# Claude Code statusline for subscription users.
# Format: model | effort | 🧠 ctx | Session <pace> N% · reset | Week <pace> N% · reset
#
# Pace = projected total at current burn rate, vs cap.
#   🟢 projected ≤ 80% · 🟡 80–100% · 🔴 > 100% (on pace to exceed)
#
# NOTE: Session/Week percents are token-counting proxies via ccusage, NOT
# Anthropic's real rate-limit API (no public endpoint exists). Recalibrate
# the divisors below every few weeks against claude.ai/settings.

# Calibrated 2026-05-12 against Team plan settings page using COST (USD), not
# raw tokens — cache-read tokens are 10% of fresh-token price, so token-based
# divisors drift heavily as conversation length grows. Cost is stable.
# Recalibrate by snapshotting ccusage cost AND Anthropic's % at the SAME moment.
#   $5.27 cost / 7% session   → ~$75 cap  (2026-05-11)
#   $183.39 cost / 25% weekly → ~$733 cap (2026-05-12, Teams plan)
# (multiply by 100 internally — bash has no floats)
SESSION_COST_CENTS="${CLAUDE_SESSION_COST_CENTS:-7500}"
WEEKLY_COST_CENTS="${CLAUDE_WEEKLY_COST_CENTS:-73300}"
WEEKLY_RESET_DOW=3   # 1=Mon..7=Sun. Wed=3.
WEEKLY_RESET_HOUR=9

input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
model_id=$(echo "$input" | jq -r '.model.id // ""')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

effort=$(jq -r '.effortLevel // "default"' ~/.claude/settings.json 2>/dev/null)

case "$model_id" in
  *opus-4-7*|*1m*|*200k*) ctx_window=1000000 ;;
  *) ctx_window=200000 ;;
esac

ctx_tokens=0
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  ctx_tokens=$(jq -s '
    [.[] | select(.message.usage)] | last as $last |
    (($last.message.usage.input_tokens // 0)
     + ($last.message.usage.cache_read_input_tokens // 0)
     + ($last.message.usage.cache_creation_input_tokens // 0))
  ' "$transcript" 2>/dev/null)
  [ -z "$ctx_tokens" ] || [ "$ctx_tokens" = "null" ] && ctx_tokens=0
fi
ctx_k=$(( (ctx_tokens + 500) / 1000 ))
ctx_pct=$(( ctx_tokens * 100 / ctx_window ))

pace_emoji() {
  local used=$1 elapsed=$2
  if [ "$elapsed" -lt 5 ]; then echo "🟢"; return; fi
  local projected=$(( used * 100 / elapsed ))
  if [ "$projected" -gt 100 ]; then echo "🔴"
  elif [ "$projected" -gt 80 ]; then echo "🟡"
  else echo "🟢"; fi
}

# Session (5h block) ----------------------------------------------------------
session_pct=0
session_pace="🟢"
session_reset="—"
block_json=$(ccusage blocks --active --json -O 2>/dev/null)
if [ -n "$block_json" ]; then
  block_cost_cents=$(echo "$block_json" | jq -r '((.blocks[0].costUSD // 0) * 100) | floor' 2>/dev/null)
  block_start=$(echo "$block_json" | jq -r '.blocks[0].startTime // empty' 2>/dev/null)
  block_end=$(echo "$block_json"   | jq -r '.blocks[0].endTime   // empty' 2>/dev/null)
  if [ -n "$block_cost_cents" ] && [ "$block_cost_cents" != "null" ] && [ "$SESSION_COST_CENTS" -gt 0 ]; then
    session_pct=$(( block_cost_cents * 100 / SESSION_COST_CENTS ))
  fi
  if [ -n "$block_start" ] && [ -n "$block_end" ]; then
    start_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S.000Z" "$block_start" +%s 2>/dev/null)
    end_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S.000Z" "$block_end" +%s 2>/dev/null)
    now_epoch=$(date +%s)
    window=$(( end_epoch - start_epoch ))
    elapsed=$(( now_epoch - start_epoch ))
    remaining=$(( end_epoch - now_epoch ))
    if [ "$window" -gt 0 ] && [ "$elapsed" -ge 0 ]; then
      pct_elapsed=$(( elapsed * 100 / window ))
      session_pace=$(pace_emoji "$session_pct" "$pct_elapsed")
    fi
    if [ "$remaining" -gt 0 ]; then
      h=$(( remaining / 3600 ))
      m=$(( (remaining % 3600) / 60 ))
      session_reset="${h}h${m}m"
    fi
  fi
fi

# Week (anchored to Wed 9 AM local) -------------------------------------------
week_pct=0
week_pace="🟢"
week_reset="—"
weekly_json=$(ccusage weekly --json -O 2>/dev/null)
if [ -n "$weekly_json" ]; then
  current_week_cost_cents=$(echo "$weekly_json" | jq -r '((.weekly[-1].totalCost // 0) * 100) | floor' 2>/dev/null)
  if [ -n "$current_week_cost_cents" ] && [ "$current_week_cost_cents" != "null" ] && [ "$WEEKLY_COST_CENTS" -gt 0 ]; then
    week_pct=$(( current_week_cost_cents * 100 / WEEKLY_COST_CENTS ))
  fi

  dow=$(date +%u)
  cur_hour=$(date +%H)
  days_until=$(( (WEEKLY_RESET_DOW - dow + 7) % 7 ))
  if [ "$days_until" -eq 0 ] && [ "$cur_hour" -ge "$WEEKLY_RESET_HOUR" ]; then
    days_until=7
  fi
  reset_date=$(date -v+${days_until}d "+%Y-%m-%d" 2>/dev/null)
  reset_target="${reset_date} $(printf '%02d' $WEEKLY_RESET_HOUR):00:00"
  reset_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S" "$reset_target" +%s 2>/dev/null)
  now_epoch=$(date +%s)
  remaining=$(( reset_epoch - now_epoch ))
  window=$(( 7 * 86400 ))
  elapsed=$(( window - remaining ))
  if [ "$window" -gt 0 ] && [ "$elapsed" -ge 0 ]; then
    pct_elapsed=$(( elapsed * 100 / window ))
    week_pace=$(pace_emoji "$week_pct" "$pct_elapsed")
  fi
  if [ "$remaining" -gt 0 ]; then
    d=$(( remaining / 86400 ))
    h=$(( (remaining % 86400) / 3600 ))
    week_reset="${d}d${h}h"
  fi
fi

printf "%s | %s | 🧠 %dk %d%% | Session %s %d%% · %s | Week %s %d%% · %s\n" \
  "$model" "$effort" \
  "$ctx_k" "$ctx_pct" \
  "$session_pace" "$session_pct" "$session_reset" \
  "$week_pace" "$week_pct" "$week_reset"
