#!/bin/bash
# Status Report Generation Script
# This script generates a comprehensive status report of the business planning progress.
# Updated: 2025-05-11

# Create a dated report file
report_date=$(date +"%Y-%m-%d")
report_file="reports/status-report-${report_date}.md"

# Ensure reports directory exists
mkdir -p reports

echo "Generating comprehensive status report to $report_file..."

# Begin the report
cat > "$report_file" << EOL
# Signature Med Support Business Status Report
**Report Date:** $report_date

## Executive Summary

This report provides a comprehensive overview of the current status of Signature Med Support's business development, including progress on strategic goals, key accomplishments, and recommendations for next steps.

## Current Business Phase

EOL

# Add phase information
current_phase=$(grep -A 2 "Current High-Level Focus / Phase" master-plan.md | grep -v "Current" | head -1)
phase_description=$(grep -A 10 "Current High-Level Focus / Phase" master-plan.md | grep -v "Current High-Level Focus / Phase" | grep -v "^##" | head -10)

cat >> "$report_file" << EOL
$current_phase

$phase_description

## Strategic Goals Progress

EOL

# Add strategic goals progress
grep -A 1 "^[0-9]\." master-plan.md | grep -E "^\*\*.*\*\*:" | sed 's/\*\*//g' | sed 's/://g' | while read -r goal; do
    # Find related tasks
    related_tasks=$(grep -n "$goal" tasks.md || echo "No related tasks found")
    
    # Count tasks by status
    total_related=$(echo "$related_tasks" | grep -v "No related" | wc -l)
    completed=$(echo "$related_tasks" | grep "Done" | wc -l)
    
    # Calculate progress percentage if there are related tasks
    if [[ $total_related -gt 0 ]]; then
        progress=$((completed * 100 / total_related))
        status="$progress% complete ($completed of $total_related tasks)"
    else
        status="No tracking tasks found"
    fi
    
    # Write to report
    cat >> "$report_file" << EOL
### $goal
- **Status:** $status
- **Recent Accomplishments:** 
$(grep -n "$goal" accomplishments.md | sed 's/^.*| /  - /' || echo "  - None recorded yet")
- **Key Tasks In Progress:**
$(grep -n "$goal" tasks.md | grep "In Progress" | sed 's/^.*| /  - /' || echo "  - None currently in progress")

EOL
done

# Add KPI tracking section
cat >> "$report_file" << EOL
## KPI Tracking

EOL

grep -n "^[0-9]\. \*\*.*\*\*:" master-plan.md | sed 's/.*\*\*\(.*\)\*\*.*/\1/' | while read -r kpi_category; do
    cat >> "$report_file" << EOL
### $kpi_category KPIs
$(grep -A 10 "$kpi_category" master-plan.md | grep "^   - " | sed 's/^   - /- /')

EOL
done

# Add accomplishments section
cat >> "$report_file" << EOL
## Recent Accomplishments

| Date | Accomplishment | Impact |
|------|---------------|--------|
EOL

# Get last 5 accomplishments
grep -A 2 "^|" accomplishments.md | grep -v "^|--" | grep -v "Date" | head -5 >> "$report_file"

# Add learnings section
cat >> "$report_file" << EOL

## Key Learnings & Insights

| Date | Learning | Action Taken/Planned |
|------|----------|---------------------|
EOL

# Get last 5 learnings
grep -A 2 "^|" learnings.md | grep -v "^|--" | grep -v "Situation/Context" | head -5 | awk -F '|' '{print "| " $2 " | " $4 " | " $5 " |"}' >> "$report_file"

# Add tasks section
cat >> "$report_file" << EOL

## Task Status Overview

EOL

# Count tasks by status and priority
total_tasks=$(grep -c "^|" tasks.md)
done_tasks=$(grep -c "Done" tasks.md)
in_progress=$(grep -c "In Progress" tasks.md)
todo_tasks=$(grep -c "To Do" tasks.md)
blocked_tasks=$(grep -c "Blocked" tasks.md)

high_priority=$(grep -c "High" tasks.md)
high_done=$(grep "High" tasks.md | grep -c "Done")
high_pending=$((high_priority - high_done))

cat >> "$report_file" << EOL
- **Total Tasks:** $total_tasks
- **Completed:** $done_tasks ($(( done_tasks * 100 / total_tasks ))%)
- **In Progress:** $in_progress
- **To Do:** $todo_tasks
- **Blocked:** $blocked_tasks
- **High Priority Tasks:** $high_priority (${high_done} completed, ${high_pending} pending)

### High Priority Tasks in Progress

| Task | Deadline | Notes |
|------|----------|-------|
EOL

# Add high priority tasks in progress
grep "High" tasks.md | grep "In Progress" | awk -F '|' '{print "| " $2 " | " $6 " | " $7 " |"}' >> "$report_file"

# Add blocked tasks section if any exist
if [[ $blocked_tasks -gt 0 ]]; then
    cat >> "$report_file" << EOL

### Blocked Tasks Requiring Attention

| Task | Priority | Blocker |
|------|----------|---------|
EOL
    grep "Blocked" tasks.md | awk -F '|' '{print "| " $2 " | " $3 " | " $7 " |"}' >> "$report_file"
fi

# Add next steps section
cat >> "$report_file" << EOL

## Upcoming Priorities

### This Week's Focus
EOL

# Extract the "Immediate Next Actions" section from next-steps.md
sed -n '/^## Immediate Next Actions/,/^---/p' next-steps.md | grep -v "^---" >> "$report_file"

# Add recommendations section
cat >> "$report_file" << EOL

## Recommendations

Based on the current status and progress, the following actions are recommended:

1. **Address Blocked Tasks:** Resolve blockers for the ${blocked_tasks} tasks currently stalled
2. **Focus on High Priority Items:** Complete the remaining ${high_pending} high priority tasks
3. **Update KPI Tracking:** Ensure all KPI categories have specific tracking mechanisms
4. **Document New Learnings:** Continue capturing insights as they emerge
5. **Maintain Document Consistency:** Run the consistency check weekly to ensure alignment
EOL

# Add specific recommendations based on phase and progress
if [[ $high_pending -gt 5 ]]; then
    echo "6. **Re-evaluate Priorities:** Consider reducing the number of high priority tasks to improve focus" >> "$report_file"
fi

if grep -q "Warning" <(./scripts/check-consistency.sh); then
    echo "7. **Fix Document Inconsistencies:** Address the warnings identified in the document consistency check" >> "$report_file"
fi

# Close the report
cat >> "$report_file" << EOL

---

*This report was automatically generated based on the current state of the business planning documents.*
EOL

echo "Status report generated successfully at $report_file"
echo "Run 'cat $report_file' to view the report" 