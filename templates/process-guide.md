<!-- Template for standardizing processes for recurring activities in the planning system. Last updated: 2025-05-18 -->

# Process Guide Template

## Purpose
This template provides a structured approach to documenting standard processes for recurring activities in the planning system. Use this template to create clear, repeatable processes that ensure consistency and efficiency.

## How to Use This Template
1. Create a new file in the `templates` directory for each distinct process
2. Follow the structure below to document the process
3. Reference these process guides in automation scripts and documentation

## Process Documentation Structure

### Process Name: [Name of Process]
**Owner:** [Team or Role Responsible]
**Frequency:** [Daily/Weekly/Monthly/Quarterly/As Needed]
**Estimated Time:** [Time Required to Complete]

### Purpose and Objectives
[Provide a brief description of why this process exists and what it aims to achieve]

### Prerequisites
- [Required access, tools, or information needed before starting]
- [Any preparation steps that must be completed]

### Process Steps
1. **[Step 1 Name]**
   - Detailed description of the action required
   - Specific tools or commands to use
   - Expected outcome of this step

2. **[Step 2 Name]**
   - Detailed description of the action required
   - Specific tools or commands to use
   - Expected outcome of this step

3. **[Step 3 Name]**
   - [Continue with all required steps in sequence]

### Output and Deliverables
- [Description of the expected outputs or deliverables]
- [Where to store or document the results]
- [Who should receive or review the outputs]

### Common Issues and Resolutions
| Issue | Cause | Resolution |
|-------|-------|------------|
| [Typical Issue 1] | [Typical Cause] | [Steps to Resolve] |
| [Typical Issue 2] | [Typical Cause] | [Steps to Resolve] |

### Related Processes
- [Link to related process guides]
- [Dependencies on other processes]

### Change History
| Date | Change Description | Changed By |
|------|-------------------|------------|
| [Date] | [Description of Change] | [Name/Role] |

## Example Process Guide

### Process Name: Daily Review Process
**Owner:** Planning Team
**Frequency:** Daily
**Estimated Time:** 30 minutes

### Purpose and Objectives
The daily review process ensures that planning documents remain current, task statuses are updated, and any inconsistencies are addressed promptly. It helps maintain alignment between strategic goals and day-to-day activities.

### Prerequisites
- Access to all planning documents
- Latest version of the codebase pulled from repository
- Permission to run scripts and update documents

### Process Steps
1. **Run the Daily Review Script**
   - Execute `./scripts/daily-review.sh` from the terminal in the planning system root directory
   - Review the output for any reported issues or inconsistencies
   - If errors occur, check script permissions and file paths

2. **Update Task Statuses**
   - Open task files for any work completed in the last 24 hours
   - Update the "Status" field for completed tasks to "Done"
   - Update the "Status" field for started tasks to "In Progress"
   - Include any relevant notes about progress or blockers

3. **Document New Accomplishments**
   - For each task marked as "Done," add an entry to `accomplishments.md`
   - Include the task ID, description, completion date, and any measurable impact
   - Format the entry according to the established structure in the file

4. **Record New Learnings**
   - Document any insights or learnings from the day's activities in `learnings.md`
   - Include the date, context, key insight, and planned actions
   - Ensure entries follow the established format in the file

5. **Update Document Headers**
   - Check the headers of any modified documents
   - Update the "Last updated" date in the header comment for any changed files
   - Ensure the description in the header accurately reflects current content

6. **Update KPI Metrics**
   - For any KPIs with daily tracking, update the actual values in `kpi-performance.md`
   - Add notes explaining significant variations from expected values

7. **Run Consistency Check (Optional)**
   - If significant changes were made, run `./scripts/check-consistency.sh`
   - Address any newly identified inconsistencies

### Output and Deliverables
- Updated task statuses in task files
- New entries in `accomplishments.md` for completed tasks
- New entries in `learnings.md` for insights gained
- Updated document headers with current dates
- Updated KPI values in `kpi-performance.md`
- Record of any identified issues in daily review report

### Common Issues and Resolutions
| Issue | Cause | Resolution |
|-------|-------|------------|
| Daily review script fails to run | Lack of execution permissions | Run `chmod +x ./scripts/daily-review.sh` to grant permissions |
| Task files show conflicts | Multiple people updating simultaneously | Resolve conflicts in git, then rerun the daily review |
| Missing KPI data | New metrics without tracking mechanism | Add tracking mechanism in `kpi-performance.md` with initial values |

### Related Processes
- Weekly Assessment Process (for more comprehensive strategic review)
- Three-Day Review Process (for document consistency checks)

### Change History
| Date | Change Description | Changed By |
|------|-------------------|------------|
| 2025-05-18 | Initial creation of process guide | Planning Team | 