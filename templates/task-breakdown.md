<!-- Template for breaking down complex tasks into manageable sub-tasks. Last updated: 2025-05-18 -->

# Complex Task Breakdown Template

## Purpose
This template provides a structured approach to breaking down high complexity tasks into smaller, more manageable sub-tasks. Use this process for any task that meets the complexity criteria defined in `tasks.md`.

## When to Use This Template
Apply this breakdown process when a task:
- Requires multiple distinct skill sets
- Has an estimated effort exceeding 3 days
- Involves multiple stakeholders or dependencies
- Contains multiple deliverables or outcomes
- Includes broad scope (e.g., "develop a system" rather than "configure a component")

## Task Breakdown Process

### Step 1: Task Analysis
1. **Original Task ID:** [Insert original task ID, e.g., TID-XXX]
2. **Original Task Description:** [Insert task description from the task file]
3. **Complexity Assessment:**
   - [ ] Multiple skill sets required. List: ________________
   - [ ] Estimated effort > 3 days (Actual estimate: ___ days)
   - [ ] Multiple stakeholders/dependencies involved. List: ________________
   - [ ] Multiple deliverables/outcomes required. List: ________________
   - [ ] Broad scope requiring further definition

### Step 2: Define Component Sub-Tasks
Break down the original task into logical components. For each sub-task:

1. **Sub-Task Description:** Clear, actionable description of the component work
2. **Required Skills:** Specific skills or expertise needed
3. **Estimated Effort:** in days (should be significantly less than the parent task)
4. **Dependencies:** Any prerequisites, including other sub-tasks
5. **Deliverables:** Tangible outputs from this sub-task

### Step 3: Create Sub-Task Entries

**Parent Task**
| Task ID | Task | Priority | Complexity | Est. Effort (days) | Status | Assigned | Project/Initiative | Deadline | Notes | Dependencies |
|---------|------|----------|------------|-------------------|--------|----------|-------------------|----------|-------|--------------|
| TID-XXX | [Original Task Description] | [Priority] | High | [Original Estimate] | To Do | [Assigned To] | [Project] | [Deadline] | Parent task with Child Tasks: TID-XXX+1, TID-XXX+2, etc. | [Original Dependencies] |

**Sub-Tasks**
| Task ID | Task | Priority | Complexity | Est. Effort (days) | Status | Assigned | Project/Initiative | Deadline | Notes | Dependencies |
|---------|------|----------|------------|-------------------|--------|----------|-------------------|----------|-------|--------------|
| TID-XXX+1 | [Sub-Task 1 Description] | [Priority] | [Complexity] | [Est. Effort] | To Do | [Assigned To] | [Project] | [Deadline] | Parent Task: TID-XXX | [Dependencies] |
| TID-XXX+2 | [Sub-Task 2 Description] | [Priority] | [Complexity] | [Est. Effort] | To Do | [Assigned To] | [Project] | [Deadline] | Parent Task: TID-XXX | [Dependencies including TID-XXX+1 if sequential] |
| TID-XXX+3 | [Sub-Task 3 Description] | [Priority] | [Complexity] | [Est. Effort] | To Do | [Assigned To] | [Project] | [Deadline] | Parent Task: TID-XXX | [Dependencies] |

### Step 4: Update Task Files
1. Add the parent task to the appropriate task file if it doesn't exist yet
2. Add all sub-tasks to the same task file
3. Update the "Notes" field in the parent task to list all child task IDs
4. Update the "Notes" field in each sub-task to reference the parent task ID
5. Set appropriate dependencies between sub-tasks if they must be completed sequentially

## Example Breakdown

**Original Task:** Develop proprietary travel risk management platform (High complexity, 20 days)

**Broken Down:**
- Parent Task (TID-235): Design proprietary travel risk management platform architecture (High complexity, 8 days)
- Sub-Task 1 (TID-236): Develop real-time threat intelligence module (High complexity, 10 days)
- Sub-Task 2 (TID-237): Implement client tracking functionality (High complexity, 7 days)
- Sub-Task 3 (TID-238): Develop emergency response coordination system (High complexity, 9 days)
- Sub-Task 4 (TID-239): Create AI-powered risk prediction algorithms (Medium complexity, 8 days)
- Sub-Task 5 (TID-240): Integrate medical provider network into platform (Medium complexity, 5 days)

Note that the sub-tasks may have their own complexity ratings, and the sum of sub-task effort may exceed the original estimate as dependencies are accounted for.

## Recommended Maximum Sub-Tasks
Aim for 3-7 sub-tasks per parent task. If you find yourself creating more than 7 sub-tasks, consider whether the parent task should be split into multiple separate parent tasks. 