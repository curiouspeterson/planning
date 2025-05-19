#!/bin/bash
# Three-Day Comprehensive Review Script
# This script performs a thorough review of all documents every 3 days, now leveraging planning_automation.py for more robust checks.
# Updated: 2025-05-19

echo "=============================================="
echo "  THREE-DAY COMPREHENSIVE REVIEW - $(date +"%Y-%m-%d")"
echo "=============================================="

# Run planning_automation.py for comprehensive checks
if [ -x "./scripts/planning_automation.py" ]; then
    echo -e "\n\033[1mRunning Comprehensive Planning Analysis:\033[0m"
    
    # Run multiple checks using planning_automation.py
    python3 ./scripts/planning_automation.py --check goals --check kpis --check complexity --check risk_register --check learning --output "reports/three-day-check-$(date +"%Y-%m-%d").json"
    
    # Extract key findings from the JSON report using jq if available
    if command -v jq &> /dev/null; then
        REPORT_FILE="reports/three-day-check-$(date +"%Y-%m-%d").json"
        if [ -f "$REPORT_FILE" ]; then
            echo -e "\n\033[1mKey Issues Summary:\033[0m"
            echo "Strategic goals without tasks: $(jq '.gap_summary.goals_without_tasks // 0' $REPORT_FILE)"
            echo "KPIs without tracking mechanisms: $(jq '.gap_summary.kpis_without_tracking // 0' $REPORT_FILE)"
            echo "Complex tasks needing breakdown: $(jq '.gap_summary.tasks_needing_breakdown // 0' $REPORT_FILE)"
            echo "Unimplemented learnings: $(jq '.gap_summary.unimplemented_learnings // 0' $REPORT_FILE)"
            echo "Risks without proper handling: $(jq '.gap_summary.risks_without_mitigation // 0' $REPORT_FILE)"
            
            # If there are significant issues, suggest detailed review
            total_issues=$(jq '.total_gaps // 0' $REPORT_FILE)
            if [ "$total_issues" -gt 10 ]; then
                echo -e "\n\033[33mSignificant planning gaps detected. Consider reviewing the full JSON report for details.\033[0m"
            fi
        fi
    else
        echo "Note: Install 'jq' for detailed JSON report parsing"
    fi
else
    echo "Advanced planning analysis script not found or not executable. Continuing with basic checks."
fi

# First run the daily review
echo -e "\n\033[1mRunning Daily Review First:\033[0m"
./scripts/daily-review.sh

# Comprehensive task analysis - This is still valuable to keep outside of planning_automation.py
echo -e "\n\033[1mComprehensive Task Analysis:\033[0m"
total_tasks=$(grep -c "^|" tasks.md)
done_tasks=$(grep -c "Done" tasks.md)
in_progress=$(grep -c "In Progress" tasks.md)
todo_tasks=$(grep -c "To Do" tasks.md)
blocked_tasks=$(grep -c "Blocked" tasks.md)

echo "Task Status Overview:"
echo "  - Total Tasks: $total_tasks"
echo "  - Completed: $done_tasks"
echo "  - In Progress: $in_progress"
echo "  - To Do: $todo_tasks"
echo "  - Blocked: $blocked_tasks"

if [[ $blocked_tasks -gt 0 ]]; then
    echo -e "\n\033[1mBlocked Tasks (Need Attention):\033[0m"
    grep -n "Blocked" tasks.md | while read -r line; do
        echo "  - $line"
    done
fi

# Project Initiative Distribution - New analysis leveraging the enhanced tasks.md
echo -e "\n\033[1mProject/Initiative Distribution:\033[0m"
echo "Tasks by project/initiative:"
grep -v "\*\*" tasks.md | grep "|" | awk -F '|' '{print $8}' | sort | uniq -c | sort -nr | head -10

# Effort Distribution - New analysis leveraging the enhanced tasks.md
echo -e "\n\033[1mEffort Distribution:\033[0m"
echo "Total estimated effort by project initiative:"
grep -v "\*\*" tasks.md | grep "|" | awk -F '|' '{print $5 "|" $8}' | grep -v "-|-" | awk '{sum[$2] += $1} END {for (project in sum) print sum[project] " days: " project}' | sort -nr

# KPI Performance Tracking
echo -e "\n\033[1mKPI Performance Overview:\033[0m"
if [ -f "kpi-performance.md" ]; then
    # Count KPIs with actual values
    total_kpis=$(grep -c "Target.*Actual.*Variance" kpi-performance.md)
    kpis_with_data=$(grep -A 2 "Target.*Actual.*Variance" kpi-performance.md | grep -v "Target.*Actual.*Variance" | grep -v "^--" | grep -v "^$" | grep -v "||" | wc -l)
    
    echo "KPI Tracking Status:"
    echo "  - Total KPIs being tracked: $total_kpis"
    echo "  - KPIs with actual data: $kpis_with_data"
    
    # Look for significant variances (assuming they'd be marked with warning symbols)
    echo -e "\nSignificant KPI Variances:"
    grep -A 5 -E "warning|issue|problem|⚠️|❌|critical" kpi-performance.md || echo "No marked KPI issues found"
else
    echo "KPI performance tracking file not found."
fi

# Recommendations for updates
echo -e "\n\033[1mRecommended Three-Day Actions:\033[0m"
echo "1. Reconcile any misalignments between strategic goals and tasks"
echo "2. Ensure KPIs have proper tracking mechanisms and actual data in kpi-performance.md"
echo "3. Convert insights in learnings.md to actionable tasks"
echo "4. Address any blocked tasks immediately"
echo "5. Update phase-specific focus areas if needed"
echo "6. Break down complex tasks into manageable components with proper parent-child relationships"
echo "7. Ensure all risks in risk-register.md have owners and mitigation strategies"

echo -e "\n=============================================="
echo "  THREE-DAY REVIEW COMPLETE"
echo "==============================================\n" 