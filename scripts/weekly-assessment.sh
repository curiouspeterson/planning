#!/bin/bash
# Weekly Strategic Assessment Script
# This script conducts a comprehensive weekly strategic assessment, now with enhanced KPI performance tracking
# and integrated risk management. It leverages planning_automation.py for comprehensive analysis.
# Updated: 2025-05-19

echo "=============================================="
echo "  WEEKLY STRATEGIC ASSESSMENT - $(date +"%Y-%m-%d")"
echo "=============================================="

# Get the current week number for reporting
WEEK_NUM=$(date +"%U")

# Run planning_automation.py for comprehensive analysis
echo -e "\n\033[1mRunning Comprehensive Strategic Analysis:\033[0m"
if [ -x "./scripts/planning_automation.py" ]; then
    # Run all checks for comprehensive analysis
    python3 ./scripts/planning_automation.py --check all --output "reports/weekly-assessment-$WEEK_NUM.json"
    
    # Generate the weekly assessment report from the JSON
    if [ -f "reports/weekly-assessment-$WEEK_NUM.json" ]; then
        echo "Comprehensive planning analysis completed. JSON report saved to reports/weekly-assessment-$WEEK_NUM.json"
        
        # If jq is available, extract key metrics for reporting
        if command -v jq &> /dev/null; then
            # Extract gap summary for reporting
            GAP_SUMMARY=$(jq '.gap_summary' "reports/weekly-assessment-$WEEK_NUM.json")
            TOTAL_GAPS=$(jq '.total_gaps' "reports/weekly-assessment-$WEEK_NUM.json")
            
            echo -e "\n\033[1mPlanning Health Overview:\033[0m"
            echo "Total planning gaps identified: $TOTAL_GAPS"
            
            # Generate the weekly assessment report
            cat > "reports/weekly-assessment-report-$(date +"%Y-%m-%d").md" << EOL
# Weekly Strategic Assessment Report

<!-- Generated from weekly-assessment.sh and planning_automation.py. This document provides a comprehensive strategic assessment based on automated analysis of all planning documents. Last updated: $(date +"%Y-%m-%d") -->

## Executive Summary

This weekly assessment was conducted on $(date +"%Y-%m-%d") (Week $WEEK_NUM) using the planning automation system.

* **Total Planning Gaps Identified:** $TOTAL_GAPS
* **Document Consistency:** $(jq '.gap_summary.outdated_headers // 0' "reports/weekly-assessment-$WEEK_NUM.json") document headers need updating
* **Strategic Alignment:** $(jq '.gap_summary.goals_without_tasks // 0' "reports/weekly-assessment-$WEEK_NUM.json") strategic goals lack implementation tasks

## Strategic Goal Progress

Based on automated analysis of tasks.md, accomplishments.md, and KPI performance metrics:

### Completed Initiatives
$(grep "Done" tasks.md | grep "High" | awk -F '|' '{print "* " $2 " (" $8 ")"}' | head -5)

### Priorities In Progress
$(grep "In Progress" tasks.md | grep "High" | awk -F '|' '{print "* " $2 " (" $8 ") - Due: " $9}' | head -5)

## KPI Performance Summary

Based on the kpi-performance.md tracking:

$(if [ -f "kpi-performance.md" ]; then
    echo "### Key Performance Indicators"
    echo ""
    # Extract KPIs with actual data
    grep -A 3 "Target.*Actual.*Variance" kpi-performance.md | grep -v "Target.*Actual.*Variance" | grep -v "^--" | grep -v "^$" | grep -v "||" | head -15
    echo ""
    # Extract any KPIs with significant variances
    echo "### Significant Variances"
    echo ""
    grep -A 5 -E "warning|issue|problem|⚠️|❌|critical" kpi-performance.md | head -10 || echo "No significant variances identified."
else
    echo "KPI performance tracking not found or not populated."
fi)

## Risk Assessment

Based on automated analysis of risk-register.md:

### Critical Risks
$(if [ -f "risk-register.md" ]; then
    grep -A 3 "High.*High" risk-register.md | grep -v "^--" | head -10 || echo "No critical risks identified."
else
    echo "Risk register not found or not populated."
fi)

### Risk Management Issues
* $(jq '.gap_summary.risks_without_mitigation // 0' "reports/weekly-assessment-$WEEK_NUM.json") high-impact risks without mitigation plans
* $(jq '.gap_summary.risks_without_owners // 0' "reports/weekly-assessment-$WEEK_NUM.json") high-impact risks without assigned owners

## Resource Allocation

Based on task analysis:

### Project Effort Distribution
$(grep -v "\*\*" tasks.md | grep "|" | awk -F '|' '{print $5 "|" $8}' | grep -v "-|-" | awk '{sum[$2] += $1} END {for (project in sum) print "* " project ": " sum[project] " person-days"}' | sort -k4 -nr | head -10)

## Recommended Action Items

Based on the gaps identified in this assessment:

1. **Strategic Goal Alignment:** Address $(jq '.gap_summary.goals_without_tasks // 0' "reports/weekly-assessment-$WEEK_NUM.json") strategic goals without implementation tasks
2. **KPI Tracking:** Implement tracking for $(jq '.gap_summary.kpis_without_tracking // 0' "reports/weekly-assessment-$WEEK_NUM.json") KPIs lacking measurement mechanisms
3. **Risk Management:** Develop mitigation strategies for $(jq '.gap_summary.risks_without_mitigation // 0' "reports/weekly-assessment-$WEEK_NUM.json") high-impact risks
4. **Task Complexity:** Break down $(jq '.gap_summary.tasks_needing_breakdown // 0' "reports/weekly-assessment-$WEEK_NUM.json") complex tasks into smaller components
5. **Document Maintenance:** Update $(jq '.gap_summary.outdated_headers // 0' "reports/weekly-assessment-$WEEK_NUM.json") document headers that are outdated

## Appendix: Planning System Health

* Document consistency checks: $(jq '.consistency_checks_run // 0' "reports/weekly-assessment-$WEEK_NUM.json")
* Documents analyzed: $(jq '.documents_analyzed // 0' "reports/weekly-assessment-$WEEK_NUM.json")
* KPIs tracked: $(if [ -f "kpi-performance.md" ]; then grep -c "Target.*Actual.*Variance" kpi-performance.md; else echo "0"; fi)
* Identified risks: $(if [ -f "risk-register.md" ]; then grep -c "^|.*|.*|.*|" risk-register.md; else echo "0"; fi)

EOL

            echo "Weekly assessment report generated: reports/weekly-assessment-report-$(date +"%Y-%m-%d").md"
        else
            echo "Note: Install 'jq' for automated report generation"
        fi
    fi
else
    echo "Planning automation script not found. Continuing with basic checks."
fi

# Run the three-day review (which includes the daily review)
echo -e "\n\033[1mRunning Three-Day Review as Part of Weekly Assessment:\033[0m"
./scripts/three-day-review.sh

# KPI Analysis from kpi-performance.md
echo -e "\n\033[1mStrategic KPI Analysis:\033[0m"
if [ -f "kpi-performance.md" ]; then
    # Extract KPI categories
    echo "KPI Categories:"
    grep -E "^## [^#]" kpi-performance.md | sed 's/^## //g' | while read -r category; do
        echo "  - $category"
        # Count KPIs with data in this category
        section_start=$(grep -n "^## $category" kpi-performance.md | cut -d':' -f1)
        next_section=$(grep -n "^## " kpi-performance.md | awk -v line="$section_start" '$1 > line {print $1; exit}' | cut -d':' -f1)
        if [ -z "$next_section" ]; then
            next_section=$(wc -l kpi-performance.md | awk '{print $1}')
        fi
        
        kpis_in_category=$(sed -n "${section_start},${next_section}p" kpi-performance.md | grep -c "^### ")
        kpis_with_data=$(sed -n "${section_start},${next_section}p" kpi-performance.md | grep -A 3 "Target.*Actual.*Variance" | grep -v "Target.*Actual.*Variance" | grep -v "^--" | grep -v "^$" | grep -v "||" | wc -l)
        
        echo "    * $kpis_in_category KPIs defined, $kpis_with_data with data"
    done
    
    # Identify KPIs with significant variances
    echo -e "\nSignificant KPI Variances (Critical):"
    grep -A 10 -B 1 -E "warning|issue|problem|⚠️|❌|critical" kpi-performance.md | head -20
else
    echo "KPI performance tracking file not found."
fi

# Risk Register Analysis
echo -e "\n\033[1mRisk Register Analysis:\033[0m"
if [ -f "risk-register.md" ]; then
    # Count risks by severity
    total_risks=$(grep -c "^|.*|.*|.*|" risk-register.md)
    high_prob_high_impact=$(grep -c "High.*High" risk-register.md)
    high_prob_medium_impact=$(grep -c "High.*Medium" risk-register.md)
    medium_prob_high_impact=$(grep -c "Medium.*High" risk-register.md)
    low_severity=$(grep -c "Low.*Low" risk-register.md)
    
    echo "Risk Distribution:"
    echo "  - Total risks tracked: $total_risks"
    echo "  - High probability & high impact: $high_prob_high_impact"
    echo "  - High probability & medium impact: $high_prob_medium_impact"
    echo "  - Medium probability & high impact: $medium_prob_high_impact"
    echo "  - Low severity (Low probability & low impact): $low_severity"
    
    # Critical risks (high probability & high impact)
    echo -e "\nCritical Risks (High Probability & High Impact):"
    grep "High.*High" risk-register.md | head -10
    
    # Risks without mitigation
    echo -e "\nRisks Without Mitigation Strategies:"
    grep "^|.*|.*|.*|" risk-register.md | grep -v "mitigation" | grep -E "High|Medium" | head -10
else
    echo "Risk register file not found."
fi

# Recommendations
echo -e "\n\033[1mWeekly Strategic Recommendations:\033[0m"
echo "1. Review the generated weekly assessment report for comprehensive analysis"
echo "2. Address strategic goals without implementation tasks"
echo "3. Update KPI actuals and analyze variances in kpi-performance.md"
echo "4. Develop mitigation plans for critical risks"
echo "5. Ensure task progress aligns with strategic priorities"
echo "6. Adjust resource allocation based on effort distribution analysis"
echo "7. Break down complex tasks into manageable components"

echo -e "\n=============================================="
echo "  WEEKLY ASSESSMENT COMPLETE"
echo "  Report saved to: reports/weekly-assessment-report-$(date +"%Y-%m-%d").md"
echo "==============================================\n" 