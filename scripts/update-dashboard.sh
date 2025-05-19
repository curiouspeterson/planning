#!/bin/bash

# Script to automatically update the progress dashboard with tasks from all task files
# Last updated: 2025-05-18

# Set the base directory
BASE_DIR="$(pwd)"
DASHBOARD_FILE="$BASE_DIR/progress-dashboard.md"
TASK_FILES=("$BASE_DIR/tasks-"*.md)
TEMP_FILE="$BASE_DIR/temp_dashboard.md"

echo "Updating Progress Dashboard..."

# Function to count tasks by status in a file
count_tasks() {
    local file=$1
    local total=$(grep -c "^| TID-" "$file")
    local todo=$(grep -c "| To Do |" "$file")
    local inprogress=$(grep -c "| In Progress |" "$file")
    local done=$(grep -c "| Done |" "$file")
    
    echo "$total $todo $inprogress $done"
}

# Function to extract high-priority tasks
extract_high_priority_tasks() {
    local file=$1
    local category=$(basename "$file" .md | sed 's/tasks-//g' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
    
    # Extract lines with High priority and Critical priority
    grep -E "^| TID-[0-9]+ .*\| (High|Critical) \|" "$file" | 
    while IFS= read -r line; do
        # Extract task ID, description, priority, deadline, and status
        task_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        description=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
        deadline=$(echo "$line" | awk -F'|' '{print $9}' | xargs)
        status=$(echo "$line" | awk -F'|' '{print $6}' | xargs)
        notes=$(echo "$line" | awk -F'|' '{print $10}' | xargs)
        
        # Output in the format for the dashboard
        echo "| $task_id | $category | $description | $deadline | $status | $notes |"
    done
}

# Create a temporary file with the header and intro sections preserved
grep -B 1000 "^## Task Completion by Category" "$DASHBOARD_FILE" > "$TEMP_FILE"

# Add the Task Completion section header
echo "## Task Completion by Category" >> "$TEMP_FILE"
echo "| Category | Total Tasks | To Do | In Progress | Done | Completion Rate (%) |" >> "$TEMP_FILE"
echo "|----------|-------------|-------|-------------|------|---------------------|" >> "$TEMP_FILE"

# Process each task file and update task counts
for file in "${TASK_FILES[@]}"; do
    filename=$(basename "$file" .md)
    category=$(echo "${filename#tasks-}" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
    
    # Skip non-category files
    if [[ "$filename" == "tasks" ]]; then
        continue
    fi
    
    # Count tasks by status
    counts=($(count_tasks "$file"))
    total=${counts[0]}
    todo=${counts[1]}
    inprogress=${counts[2]}
    done=${counts[3]}
    
    # Calculate completion rate
    if [[ $total -eq 0 ]]; then
        completion=0
    else
        completion=$(( (done * 100) / total ))
    fi
    
    # Add the row to the table
    echo "| $category | $total | $todo | $inprogress | $done | $completion% |" >> "$TEMP_FILE"
done

# Add the Strategic Alignment section preserved
grep -A 1000 "^## Strategic Alignment Summary" "$DASHBOARD_FILE" | 
grep -B 1000 "^## High-Priority Tasks Overview" >> "$TEMP_FILE"

# Add the High-Priority Tasks section header
echo "## High-Priority Tasks Overview" >> "$TEMP_FILE"
echo "| Task ID | Category | Task Description | Deadline | Status | Notes |" >> "$TEMP_FILE"
echo "|---------|----------|------------------|----------|--------|-------|" >> "$TEMP_FILE"

# Extract high-priority tasks from all files
for file in "${TASK_FILES[@]}"; do
    filename=$(basename "$file" .md)
    
    # Skip non-category files
    if [[ "$filename" == "tasks" ]]; then
        continue
    fi
    
    extract_high_priority_tasks "$file" >> "$TEMP_FILE"
done

# Add the Recently Added Tasks section preserved
grep -A 1000 "^## Recently Added High-Priority Tasks" "$DASHBOARD_FILE" | 
grep -B 1000 "Return to \[Task List Index\]" >> "$TEMP_FILE"

# Add the footer
echo "Return to [Task List Index](tasks.md) for detailed task lists by category." >> "$TEMP_FILE"

# Replace the original dashboard with the updated one
mv "$TEMP_FILE" "$DASHBOARD_FILE"

echo "Progress Dashboard updated successfully!" 