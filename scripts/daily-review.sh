#!/bin/bash
# Daily Review Script
# This script performs the daily review process automatically, now leveraging planning_automation.py for more robust checks.
# Updated: 2025-05-19

echo "=============================================="
echo "  DAILY REVIEW PROCESS - $(date +"%Y-%m-%d")"
echo "=============================================="

# Check for planning_automation.py and use it for advanced checks
if [ -x "./scripts/planning_automation.py" ]; then
    echo -e "\n\033[1mRunning Critical Daily Checks via Planning Automation:\033[0m"
    
    # Run specific daily checks using planning_automation.py
    python3 ./scripts/planning_automation.py --check headers --check completions --check deadlines --output "reports/daily-check-$(date +"%Y-%m-%d").json"
    
    # Extract key findings from the JSON report using jq if available
    if command -v jq &> /dev/null; then
        REPORT_FILE="reports/daily-check-$(date +"%Y-%m-%d").json"
        if [ -f "$REPORT_FILE" ]; then
            echo -e "\n\033[1mKey Issues Summary:\033[0m"
            echo "Documents with header issues: $(jq '.gap_summary.outdated_headers // 0' $REPORT_FILE)"
            echo "Completed tasks not in accomplishments: $(jq '.gap_summary.undocumented_completions // 0' $REPORT_FILE)"
            echo "High priority tasks without deadlines: $(jq '.gap_summary.high_priority_without_deadlines // 0' $REPORT_FILE)"
        fi
    else
        echo "Note: Install 'jq' for detailed JSON report parsing"
    fi
else
    echo "Advanced planning analysis script not found or not executable. Continuing with standard checks."
fi

# Check for modified files in the last 24 hours
echo -e "\n\033[1mRecently Modified Files:\033[0m"
find . -type f -name "*.md" -mtime -1 | grep -v "README.md" | while read file; do
    echo "- $file ($(date -r "$file" "+%Y-%m-%d %H:%M"))"
done

# Check for tasks due today or tomorrow
echo -e "\n\033[1mUpcoming Tasks:\033[0m"
grep -n "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" tasks.md | grep -E "$(date +"%Y-%m-%d")|$(date -v+1d +"%Y-%m-%d")" || echo "No tasks due in the next 48 hours"

# Check for high priority tasks
echo -e "\n\033[1mHigh Priority Tasks:\033[0m"
grep -n "High" tasks.md | grep -v "Done" || echo "No high priority tasks in progress"

# KPI Performance Check - New
echo -e "\n\033[1mKPI Performance Quick Check:\033[0m"
if [ -f "kpi-performance.md" ]; then
    echo "Checking for KPIs with recent updates..."
    # Find KPI tables with recent updates 
    grep -A 5 "Target.*Actual.*Variance" kpi-performance.md | grep -v "^---|^\s*$" | head -10
    
    # Look for significant variances (assuming they'd be marked with warning symbols)
    echo -e "\nPotential KPI issues:"
    grep -A 3 -E "warning|issue|problem|⚠️|❌" kpi-performance.md | head -10 || echo "No marked KPI issues found"
else
    echo "KPI performance tracking file not found."
fi

# Reminder for daily updates
echo -e "\n\033[1mRecommended Daily Actions:\033[0m"
echo "1. Update task statuses in tasks.md"
echo "2. Review and update next-steps.md priorities"
echo "3. Add any new accomplishments to accomplishments.md"
echo "4. Document new learnings in learnings.md"
echo "5. Update document headers for any modified files"
echo "6. Update KPI actuals in kpi-performance.md for daily/weekly metrics"

echo -e "\n=============================================="
echo "  DAILY REVIEW COMPLETE"
echo "==============================================\n" 