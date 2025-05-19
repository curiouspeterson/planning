#!/bin/bash
# Document Consistency Check Script
# This script verifies consistency across all planning documents.
# Updated: 2025-05-16 with enhanced checks for complex tasks, specific KPI tracking, learning implementation, and risk management.
# Updated: 2025-05-16 with improved parsing for task references in next-steps.md and accomplishments.md.
# Updated: 2025-05-16 with automatic header date updates using current date.

# Fetch current date for updating headers
CURRENT_DATE=$(date +'%Y-%m-%d')
echo "Current date for header updates: $CURRENT_DATE"

# Function to update header of a file
update_header() {
    local file=$1
    local header_pattern=$2
    if grep -q "Last updated:" "$file"; then
        sed -i '' "s/Last updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/Last updated: $CURRENT_DATE/" "$file"
        echo "Updated header date to $CURRENT_DATE in $file"
    else
        echo "No header with 'Last updated:' found in $file"
    fi
}

# Update headers of all planning documents
echo -e "\n\033[1mUpdating Document Headers:\033[0m"
update_header "master-plan.md" "Strategic plan for Signature Med Support"
update_header "next-steps.md" "Outlines immediate priorities and focus areas"
update_header "tasks.md" "Detailed task list for Signature Med Support"
update_header "accomplishments.md" "Record of completed tasks and milestones"
update_header "learnings.md" "Documents lessons learned and insights"
update_header "kpi-performance.md" "Tracks Key Performance Indicators"

echo "=============================================="
echo "  DOCUMENT CONSISTENCY CHECK - $(date +"%Y-%m-%d")"
echo "=============================================="

# Strategic Goals Consistency
echo -e "\n\033[1mStrategic Goals Consistency Check:\033[0m"
# Extract goals from master-plan.md
echo "Checking if strategic goals are consistently referenced:"
grep -A 1 "^[0-9]\." master-plan.md | grep -E "^\*\*.*\*\*:" | sed 's/\*\*//g' | sed 's/://g' | while read -r goal; do
    echo "Goal: $goal"
    # Check presence in other key documents
    in_next_steps=$(grep -c "$goal" next-steps.md)
    in_tasks=$(grep -c "$goal" tasks.md)
    in_accomplishments=$(grep -c "$goal" accomplishments.md)
    
    echo "  - References in next-steps.md: $in_next_steps"
    echo "  - References in tasks.md: $in_tasks"
    echo "  - References in accomplishments.md: $in_accomplishments"
    
    if [[ $in_next_steps -eq 0 && $in_tasks -eq 0 && $in_accomplishments -eq 0 ]]; then
        echo "  - \033[31mWarning: Goal not referenced in any working documents\033[0m"
    fi
done

# Detailed KPI Tracking Consistency
echo -e "\n\033[1mDetailed KPI Tracking Consistency:\033[0m"
# First, extract KPI categories from master-plan.md
grep -n "^[0-9]\. \*\*.*\*\*:" master-plan.md | sed 's/.*\*\*\(.*\)\*\*.*/\1/' | while read -r kpi_category; do
    echo "KPI Category: $kpi_category"
    # Check if KPIs are being tracked in tasks
    if grep -q "$kpi_category" tasks.md; then
        echo "  - Has tracking mechanisms in tasks.md"
        
        # Now extract specific KPIs in this category
        line_num=$(grep -n "^[0-9]\. \*\*$kpi_category\*\*:" master-plan.md | cut -d ":" -f 1)
        end_line=$((line_num + 20))  # Look ahead up to 20 lines
        
        # Extract specific KPIs (lines starting with "   - ")
        specific_kpis=$(sed -n "${line_num},${end_line}p" master-plan.md | grep "^   - " | sed 's/^   - //')
        
        # Check each specific KPI
        echo "$specific_kpis" | while read -r specific_kpi; do
            if [[ -n "$specific_kpi" ]]; then
                # Extract the first few words to make a more focused search
                kpi_short=$(echo "$specific_kpi" | awk '{print $1, $2, $3}')
                if grep -q "$kpi_short" tasks.md; then
                    echo "    - Specific KPI '$kpi_short...' has tracking task"
                else
                    echo "    - \033[31mWarning: Specific KPI '$kpi_short...' may not have a tracking task\033[0m"
                fi
            fi
        done
    else
        echo "  - \033[31mWarning: No tracking mechanisms found in tasks.md\033[0m"
    fi
done

# Task Priority Consistency
echo -e "\n\033[1mTask Priority Consistency:\033[0m"
# Check if high priority tasks align with strategic goals
high_priority_tasks=$(grep "High" tasks.md | sed 's/^| \(.*\) |.*$/\1/')
echo "Checking strategic alignment of high priority tasks:"
echo "$high_priority_tasks" | while read -r task; do
    aligned=false
    while read -r goal; do
        if [[ "$task" == *"$goal"* ]]; then
            aligned=true
            echo "  - Task aligns with goal: $goal"
            break
        fi
    done < <(grep -A 1 "^[0-9]\." master-plan.md | grep -E "^\*\*.*\*\*:" | sed 's/\*\*//g' | sed 's/://g')
    
    if [[ "$aligned" == "false" ]]; then
        echo "  - \033[31mWarning: High priority task may not align with strategic goals: $task\033[0m"
    fi
done

# Phase Consistency
echo -e "\n\033[1mPhase Consistency:\033[0m"
current_phase=$(grep -A 1 "Current High-Level Focus / Phase" master-plan.md | grep -v "Current" | grep -o "Phase [0-9].*:" | head -1)
echo "Current phase: $current_phase"
# Check if phase is consistently referenced
if ! grep -q "$current_phase" next-steps.md; then
    echo "  - \033[31mWarning: Current phase not referenced in next-steps.md\033[0m"
fi
if ! grep -q "Phase" tasks.md; then
    echo "  - \033[31mWarning: No phase references in tasks.md\033[0m"
fi

# Next Steps to Tasks Consistency
echo -e "\n\033[1mNext Steps to Tasks Consistency:\033[0m"
echo "Checking if items in next-steps.md have corresponding tasks:"
grep -o "\- \[ \].*" next-steps.md | while read -r next_step; do
    # Clean up the next step text
    cleaned_step=$(echo "$next_step" | sed 's/- \[ \] //')
    
    # Extract Task ID if available in the format (Task ID: TID-XXX)
    task_id=$(echo "$cleaned_step" | grep -o "Task ID: TID-[0-9]*" | grep -o "TID-[0-9]*")
    
    if [[ -n "$task_id" ]]; then
        # Check if the Task ID exists in tasks.md
        if grep -q "$task_id" tasks.md; then
            continue
        else
            echo "  - \033[31mWarning: Task ID not found in tasks.md: $task_id\033[0m"
        fi
    else
        # If no Task ID, check if the step text itself exists in tasks.md
        step_text=$(echo "$cleaned_step" | sed 's/ (Task ID:.*//')
        if ! grep -q "$step_text" tasks.md; then
            echo "  - \033[31mWarning: Next step not found in tasks.md and has no Task ID: $step_text\033[0m"
        fi
    fi
done

# Task to Accomplishment Flow
echo -e "\n\033[1mTask to Accomplishment Flow:\033[0m"
echo "Checking for completed tasks not in accomplishments:"
while IFS='|' read -r _ task_id _ _ _ status _ _ _ _ _; do
    if [[ "$status" == *"Done"* ]]; then
        task_id=$(echo "$task_id" | sed 's/ //g')
        if [[ -n "$task_id" && "$task_id" == "TID-"* ]]; then
            if ! grep -q "$task_id" accomplishments.md; then
                echo "  - \033[31mWarning: Completed task not found in accomplishments.md: $task_id\033[0m"
            fi
        fi
    fi
done < <(grep "| TID-" tasks.md)

# File Header Consistency
echo -e "\n\033[1mFile Header Consistency:\033[0m"
echo "Checking for consistent and up-to-date headers:"
for file in master-plan.md next-steps.md tasks.md accomplishments.md learnings.md; do
    has_header=$(grep -c "<!-- .* Last updated:" "$file")
    if [[ $has_header -eq 0 ]]; then
        echo "  - \033[31mWarning: Missing header in $file\033[0m"
    else
        last_updated=$(grep "Last updated:" "$file" | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}")
        last_modified=$(date -r "$file" "+%Y-%m-%d")
        if [[ "$last_updated" != "$last_modified" ]]; then
            echo "  - \033[31mWarning: Header date ($last_updated) doesn't match last modification date ($last_modified) in $file\033[0m"
        fi
    fi
done

# Terminology Consistency
echo -e "\n\033[1mTerminology Consistency:\033[0m"
# Extract key terms from master-plan.md
key_terms=$(grep -o '\b[A-Z][a-zA-Z]\+\s\+[A-Z][a-zA-Z]\+\b' master-plan.md | sort | uniq)
echo "Checking consistency of key terms across documents:"
for term in $key_terms; do
    variants=$(grep -o "\b${term}\b\|\b${term}s\b\|\b${term}ing\b" *.md | sort | uniq -c | sort -nr)
    if [[ $(echo "$variants" | wc -l) -gt 1 ]]; then
        echo "  - \033[31mTerminology inconsistency for: $term\033[0m"
        echo "$variants" | sed 's/^/    /'
    fi
done

# Complex Task Analysis
echo -e "\n\033[1mComplex Task Analysis:\033[0m"
echo "Checking for potentially complex tasks that might need breakdown:"
complex_task_keywords=("develop" "create" "implement" "design" "establish" "build")

for keyword in "${complex_task_keywords[@]}"; do
    # Find tasks with these keywords and count the number of commas (indicating multiple components)
    complex_tasks=$(grep -i "| $keyword" tasks.md | grep -v "High" | grep -v "Done")
    
    if [[ -n "$complex_tasks" ]]; then
        echo "Potential complex tasks with '$keyword':"
        echo "$complex_tasks" | while read -r task_line; do
            # Count commas in the task description
            task_desc=$(echo "$task_line" | sed 's/^| \(.*\) |.*$/\1/')
            commas=$(echo "$task_desc" | grep -o "," | wc -l)
            ands=$(echo "$task_desc" | grep -o " and " | wc -l)
            
            # If task contains multiple components (commas or "and"), flag it
            if [[ $commas -gt 1 || $ands -gt 1 ]]; then
                # Check if it's marked as High complexity
                if [[ "$task_line" == *"High"*"High"* ]]; then
                    # Task already marked as high priority and high complexity
                    continue
                else
                    echo "  - \033[33mPotential complex task needing breakdown: $task_desc\033[0m"
                fi
            fi
        done
    fi
done

# Learning Implementation Check
echo -e "\n\033[1mLearning Implementation Check:\033[0m"
echo "Checking if learnings have been implemented in tasks or strategy:"
while IFS='|' read -r _ date _ action _; do
    if [[ -n "$action" && "$action" != "Action/Avoidance" && "$action" != "--"* ]]; then
        if [[ "$action" == *"TBD"* || "$action" == "To be determined"* || -z "$action" ]]; then
            echo "  - \033[31mWarning: Learning found without clear action plan on $date\033[0m"
            continue
        fi
        key_phrase=$(echo "$action" | awk '{print $1, $2, $3, $4, $5}')
        if ! grep -q "$key_phrase" tasks.md; then
            echo "  - \033[33mLearning action might not be reflected in tasks.md: '$key_phrase...' from $date\033[0m"
        fi
    fi
done < <(grep "^|" learnings.md)

# Resource Gap Analysis
echo -e "\n\033[1mResource Gap Analysis:\033[0m"
echo "Checking if resources mentioned in strategy have implementation tasks:"

# Define common resource types to look for
resource_types=("technology" "platform" "system" "database" "software" "hardware" "staff" "specialist" "expert" "consultant" "partner" "vendor" "equipment" "tool" "training")

for resource in "${resource_types[@]}"; do
    # Find resources mentioned in master-plan.md
    resources_found=$(grep -i "$resource" master-plan.md)
    
    if [[ -n "$resources_found" ]]; then
        echo "Checking resources of type '$resource':"
        echo "$resources_found" | while read -r line; do
            # Extract the context (10 words around the resource)
            context=$(echo "$line" | grep -o -E ".{0,30}$resource.{0,30}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            # If meaningful context found, check if it's in tasks.md
            if [[ -n "$context" && "$context" != "$resource" ]]; then
                # Look for key terms in the context
                key_terms=$(echo "$context" | tr -cs '[:alpha:]' '\n' | sort | uniq)
                
                match_found=false
                for term in $key_terms; do
                    if [[ ${#term} -gt 5 && "$term" != "$resource" ]]; then
                        if grep -q -i "$term.*$resource" tasks.md || grep -q -i "$resource.*$term" tasks.md; then
                            match_found=true
                            break
                        fi
                    fi
                done
                
                if [[ "$match_found" == "false" ]]; then
                    echo "  - \033[33mPotential resource gap: '$context' mentioned in strategy but may not have implementation tasks\033[0m"
                fi
            fi
        done
    fi
done

# Risk Management Check
echo -e "\n\033[1mRisk Management Check:\033[0m"
echo "Checking for potential risks without mitigation strategies:"

# Look for risk-related terms in learnings.md
risk_terms=("challenge" "problem" "risk" "threat" "issue" "concern" "difficult" "obstacle" "barrier")

for term in "${risk_terms[@]}"; do
    risks_found=$(grep -i "$term" learnings.md)
    
    if [[ -n "$risks_found" ]]; then
        echo "Checking risks related to '$term':"
        echo "$risks_found" | while read -r line; do
            # Skip table headers
            if [[ "$line" == *"Situation/Context"* ]]; then
                continue
            fi
            
            # Extract the context (20 words around the term)
            context=$(echo "$line" | grep -o -E ".{0,40}$term.{0,40}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            # Check if there's a mitigation plan in tasks.md
            mitigation_found=false
            
            # Extract key terms from the context
            key_terms=$(echo "$context" | tr -cs '[:alpha:]' '\n' | grep -v -E '^.{1,4}$' | sort | uniq)
            
            for key_term in $key_terms; do
                if [[ ${#key_term} -gt 5 && "$key_term" != "$term" ]]; then
                    if grep -q -i "mitigat.*$key_term" tasks.md || \
                       grep -q -i "address.*$key_term" tasks.md || \
                       grep -q -i "resolv.*$key_term" tasks.md || \
                       grep -q -i "handl.*$key_term" tasks.md; then
                        mitigation_found=true
                        break
                    fi
                fi
            done
            
            if [[ "$mitigation_found" == "false" && -n "$context" ]]; then
                echo "  - \033[33mPotential risk without mitigation: '$context'\033[0m"
            fi
        done
    fi
done

# Deadline Coverage Check
echo -e "\n\033[1mDeadline Coverage Check:\033[0m"
echo "Checking for high priority tasks without deadlines:"

high_priority_no_deadline=$(grep "High" tasks.md | grep -v "Done" | grep -v "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}")

if [[ -n "$high_priority_no_deadline" ]]; then
    echo "  - \033[31mWarning: The following high priority tasks lack deadlines:\033[0m"
    echo "$high_priority_no_deadline" | while read -r task_line; do
        task_desc=$(echo "$task_line" | sed 's/^| \(.*\) |.*$/\1/')
        echo "    - $task_desc"
    done
else
    echo "  - All high priority tasks have deadlines. Good job!"
fi

echo -e "\n=============================================="
echo "  DOCUMENT CONSISTENCY CHECK COMPLETE"
echo "==============================================\n" 