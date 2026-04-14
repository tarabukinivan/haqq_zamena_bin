#!/bin/bash
# run_all_evals.sh — Sequential evaluation across all Affine environments.
# Resilient to API failures, timeouts, and crashes. Skips failed envs and continues.
#
# Usage:
#   bash run_all_evals.sh                                    # default model
#   bash run_all_evals.sh user/repo-name                     # custom model
#   bash run_all_evals.sh user/repo-name http://host:port/v1 # custom model + URL
#
# Usage:
#   bash run_all_evals.sh                                    # default model
#   bash run_all_evals.sh user/repo-name                     # custom model
#   bash run_all_evals.sh user/repo-name http://host:port/v1 # custom model + URL

set +e  # Don't exit on error

# Activate venv
echo "Activating venv..."
source /root/affine-cortex/.venv/bin/activate
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to activate venv"
    exit 1
fi
echo "Venv activated: $(which af)"

MODEL="${1:-ajtaltarabukin2022/merged_champion_v5opus}"
BASE_URL="${2:-http://172.17.0.1:30000/v1}"
LOG_DIR="/root/finetuneqwen/eval_logs"
mkdir -p "$LOG_DIR"

echo "Model:  $MODEL"
echo "URL:    $BASE_URL"
echo "Logs:   $LOG_DIR"

# Track results
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

run_eval() {
    local env="$1"
    local samples="$2"
    local logfile="$LOG_DIR/eval_${env,,}.log"
    TOTAL=$((TOTAL + 1))

    echo ""
    echo "=============================================="
    echo "[$TOTAL] Running: $env ($samples samples)"
    echo "Log: $logfile"
    echo "=============================================="

    # Check if server is reachable first
    echo "Checking server at $BASE_URL..."
    if ! curl -s --max-time 10 "$BASE_URL/models" > /dev/null 2>&1; then
        echo "WARNING: Server not reachable at $BASE_URL, skipping $env"
        SKIPPED=$((SKIPPED + 1))
        echo "[$env] SKIPPED (server unreachable)" >> "$logfile"
        return 1
    fi
    echo "Server is reachable."

    # Run eval with timeout (MEMORY gets 60min, others 30min)
    local timeout_min=30
    if [ "$env" = "MEMORY" ]; then
        timeout_min=60
    fi
    local timeout_sec=$((timeout_min * 60))

    echo "Starting eval (timeout: ${timeout_min}min)..."
    timeout "$timeout_sec" af eval --env "$env" \
        --base-url "$BASE_URL" \
        --model "$MODEL" \
        --samples "$samples" \
        2>&1 | tee "$logfile"

    local exit_code=${PIPESTATUS[0]}

    if [ $exit_code -eq 124 ]; then
        echo "[$env] FAILED (timeout after ${timeout_min}min)"
        FAILED=$((FAILED + 1))
        echo "TIMEOUT after ${timeout_min}min" >> "$logfile"
    elif [ $exit_code -ne 0 ]; then
        echo "[$env] FAILED (exit code: $exit_code)"
        FAILED=$((FAILED + 1))
    else
        echo "[$env] PASSED"
        PASSED=$((PASSED + 1))
    fi

    echo ""
}

# Run evaluations sequentially
run_eval "GAME"     30
run_eval "DISTILL"  30
run_eval "LIVEWEB"  10
run_eval "NAVWORLD" 10
run_eval "SWE"      10
run_eval "MEMORY"   5

# Summary
echo ""
echo "=============================================="
echo "EVALUATION SUMMARY"
echo "=============================================="
echo "Total:  $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Skipped: $SKIPPED"
echo ""
echo "Logs saved to: $LOG_DIR/"
ls -la "$LOG_DIR/"

exit 0
