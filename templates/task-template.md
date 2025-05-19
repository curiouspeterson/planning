# Task Template
<!-- Updated with Task ID, Estimated Effort, and Project/Initiative fields to improve task tracking, resource planning, and dependency management. Last updated: 2025-05-19 -->

When adding new tasks to tasks.md, use this format:

| Task ID | Task | Priority | Complexity | Est. Effort (days) | Status | Assigned | Project/Initiative | Deadline | Notes | Dependencies |
|---|-----|----|----|----|----|----|----|----|----|----|
| TID-001 | [Clear task description] | High/Medium/Low | High/Medium/Low | [Number] | To Do | [Person] | [Project Name] | YYYY-MM-DD | [Additional context] | [Dependent tasks] |

Guidelines for creating tasks:
- Task IDs should follow the format TID-XXX (where XXX is a sequential number)
- Task descriptions should be action-oriented and specific
- Priority should reflect business impact and time-sensitivity
- Complexity should assess the task's size, interdependencies, and required expertise
- Estimated Effort should indicate expected days of work to complete the task
- Initial status for new tasks is always "To Do"
- Project/Initiative field should indicate which larger effort this task belongs to
- Deadlines should be set for time-sensitive tasks
- Notes should include context, dependencies, or additional information

## Complexity Assessment Guidelines

A task is likely **High Complexity** if it:
- Requires multiple distinct skill sets
- Estimated time exceeds 3 days of work
- Involves multiple stakeholders or dependencies
- Contains multiple deliverables or outcomes
- Includes broad scope (e.g., "develop a system" rather than "configure a component")

High complexity tasks should be considered for breakdown into smaller sub-tasks.

## Task Breakdown Structure

When breaking down complex tasks, follow this structure:

1. Create a parent task that describes the overall objective
2. Create multiple child tasks that represent logical components of the parent task
3. Add "Parent Task: [Task ID]" to the Notes field of each child task
4. Add "Child Tasks: [Task IDs]" to the Notes field of the parent task

Example:
| Task ID | Task | Priority | Complexity | Est. Effort (days) | Status | Assigned | Project/Initiative | Deadline | Notes | Dependencies |
|---|-----|----|----|----|----|----|----|----|----|----|
| TID-042 | Research top 3 competitors' pricing | High | Low | 2 | To Do | User | Market Research | 2025-05-25 | Focus on enterprise tier specifically | [Dependent tasks] |
| TID-043 | Develop client tracking platform | High | High | 10 | To Do | Dev Team | Client Management | 2025-07-15 | Child Tasks: TID-044, TID-045, TID-046 | [Dependent tasks] |
| TID-044 | Design user interface for dashboard | Medium | Medium | 3 | To Do | UI Team | Client Management | 2025-06-10 | Parent Task: TID-043 | [Dependent tasks] | 