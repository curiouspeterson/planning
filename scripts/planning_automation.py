#!/usr/bin/env python3
# Business Planning Automation Script
# Created: This script provides enhanced business planning analysis capabilities, including document consistency verification,
# gap detection, complexity analysis, and automated report generation. It serves as a Python-based enhancement to the shell
# script infrastructure for improved validation and optimization. Last updated: 2025-05-19

import os
import re
import sys
import json
import argparse
import datetime
import subprocess
from collections import defaultdict, Counter
import logging

class BusinessPlanningAutomation:
    """
    Enhanced business planning automation system that provides document analysis,
    gap detection, consistency verification, and planning optimization.
    """

    def __init__(self, base_dir=None):
        """Initialize the automation system with the base directory."""
        self.base_dir = base_dir or os.getcwd()
        self.document_map = {
            "master_plan": os.path.join(self.base_dir, "master-plan.md"),
            "next_steps": os.path.join(self.base_dir, "next-steps.md"),
            "tasks": os.path.join(self.base_dir, "tasks.md"),
            "accomplishments": os.path.join(self.base_dir, "accomplishments.md"),
            "learnings": os.path.join(self.base_dir, "learnings.md"),
            "competitor_analysis": os.path.join(self.base_dir, "competitor-analysis.md"),
            "seo_strategy": os.path.join(self.base_dir, "seo-strategy.md"),
            "risk_register": os.path.join(self.base_dir, "risk-register.md"),
            "kpi_performance": os.path.join(self.base_dir, "kpi-performance.md")
        }
        self.strategic_goals = []
        self.kpis = {}
        self.tasks = []
        self.next_steps = []
        self.accomplishments = []
        self.learnings = []
        self.risks = []
        self.high_complexity_tasks = []
        self.high_priority_tasks = []
        self.completed_tasks = []
        self.identified_risks = []
        self.gap_report = {}
        self.terminology_issues = []
        
    def load_all_documents(self):
        """Load content from all planning documents."""
        print("Loading all planning documents...")
        self.load_master_plan()
        self.load_tasks()
        self.load_next_steps()
        self.load_accomplishments()
        self.load_learnings()
        self.load_risk_register()
        
    def load_master_plan(self):
        """Extract strategic goals and KPIs from master plan."""
        print("Loading strategic goals and KPIs from master plan...")
        try:
            with open(self.document_map["master_plan"], 'r') as f:
                content = f.read()
                
            # Extract strategic goals
            goal_pattern = r'\d+\.\s+\*\*([^*]+)\*\*:'
            self.strategic_goals = re.findall(goal_pattern, content)
            
            # Extract KPIs for each goal
            for goal in self.strategic_goals:
                kpi_pattern = fr'\*\*{re.escape(goal)}\*\*:.*?(?=\d+\.\s+\*\*|\Z)'
                kpi_sections = re.findall(kpi_pattern, content, re.DOTALL)
                
                if kpi_sections:
                    kpi_items = re.findall(r'   - ([^\n]+)', kpi_sections[0])
                    self.kpis[goal] = kpi_items
            
            print(f"Extracted {len(self.strategic_goals)} strategic goals and KPIs")
        except Exception as e:
            print(f"Error loading master plan: {e}")
    
    def load_tasks(self):
        """Extract tasks, priorities, and complexities from tasks.md."""
        print("Loading tasks...")
        try:
            with open(self.document_map["tasks"], 'r') as f:
                content = f.read()
            
            # Extract tasks from the table
            task_pattern = r'\|\s*([^|]+?)\s*\|\s*(High|Medium|Medium-High|Low)\s*\|\s*(High|Medium|Low)\s*\|\s*(To Do|In Progress|Done|Blocked)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|'
            task_matches = re.findall(task_pattern, content)
            
            self.tasks = []
            for match in task_matches:
                task = {
                    "description": match[0].strip(),
                    "priority": match[1].strip(),
                    "complexity": match[2].strip(),
                    "status": match[3].strip(),
                    "assigned": match[4].strip(),
                    "deadline": match[5].strip(),
                    "notes": match[6].strip()
                }
                self.tasks.append(task)
                
                # Track high complexity tasks
                if task["complexity"] == "High":
                    self.high_complexity_tasks.append(task)
                
                # Track high priority tasks
                if task["priority"] == "High":
                    self.high_priority_tasks.append(task)
                
                # Track completed tasks
                if task["status"] == "Done":
                    self.completed_tasks.append(task)
            
            print(f"Extracted {len(self.tasks)} tasks")
        except Exception as e:
            print(f"Error loading tasks: {e}")
    
    def load_next_steps(self):
        """Extract next steps from next-steps.md."""
        print("Loading next steps...")
        try:
            with open(self.document_map["next_steps"], 'r') as f:
                content = f.read()
            
            # Extract next steps (checklist items)
            next_step_pattern = r'- \[([ x])\] ([^\n]+)'
            next_step_matches = re.findall(next_step_pattern, content)
            
            self.next_steps = []
            for match in next_step_matches:
                is_completed = match[0] == 'x'
                description = match[1].strip()
                
                # Check for task reference
                task_ref_pattern = r'Task reference: "([^"]+)"'
                task_refs = re.findall(task_ref_pattern, description)
                task_ref = task_refs[0] if task_refs else None
                
                next_step = {
                    "description": description,
                    "completed": is_completed,
                    "task_reference": task_ref
                }
                self.next_steps.append(next_step)
            
            print(f"Extracted {len(self.next_steps)} next steps")
        except Exception as e:
            print(f"Error loading next steps: {e}")
    
    def load_accomplishments(self):
        """Extract accomplishments from accomplishments.md."""
        print("Loading accomplishments...")
        try:
            with open(self.document_map["accomplishments"], 'r') as f:
                content = f.read()
            
            # Extract accomplishments (list items with dates)
            accomplishment_pattern = r'- \*\*([^*]+)\*\*: ([^\n]+)'
            accomplishment_matches = re.findall(accomplishment_pattern, content)
            
            self.accomplishments = []
            for match in accomplishment_matches:
                accomplishment = {
                    "date": match[0].strip(),
                    "description": match[1].strip()
                }
                self.accomplishments.append(accomplishment)
            
            print(f"Extracted {len(self.accomplishments)} accomplishments")
        except Exception as e:
            print(f"Error loading accomplishments: {e}")
    
    def load_learnings(self):
        """Extract learnings and potential risks from learnings.md."""
        print("Loading learnings and risks...")
        try:
            with open(self.document_map["learnings"], 'r') as f:
                content = f.read()
            
            # Extract learnings from tables
            # Simplified pattern - in real implementation, you'd want more robust table parsing
            learning_pattern = r'\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|'
            learning_matches = re.findall(learning_pattern, content)
            
            self.learnings = []
            self.identified_risks = []
            
            for match in learning_matches:
                if any(col.strip() == "Situation/Context" for col in match):
                    continue  # Skip header rows
                
                learning = {
                    "situation": match[0].strip(),
                    "insight": match[1].strip(), 
                    "action": match[2].strip(),
                    "date": match[3].strip() if len(match) > 3 else ""
                }
                self.learnings.append(learning)
                
                # Check if this learning represents a risk
                risk_terms = ["risk", "challenge", "problem", "threat", "issue", "concern"]
                if any(term in learning["situation"].lower() or term in learning["insight"].lower() for term in risk_terms):
                    self.identified_risks.append(learning)
            
            print(f"Extracted {len(self.learnings)} learnings and {len(self.identified_risks)} risks")
        except Exception as e:
            print(f"Error loading learnings: {e}")
    
    def load_risk_register(self):
        """Extract risks from risk-register.md."""
        print("Loading risks from risk register...")
        try:
            with open(self.document_map["risk_register"], 'r') as f:
                content = f.read()
            
            # Extract risks from the table
            risk_pattern = r'\|\s*([^|]+?)\s*\|\s*(High|Medium|Low)\s*\|\s*(High|Medium|Low)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|'
            risk_matches = re.findall(risk_pattern, content)
            
            self.risks = []
            for match in risk_matches:
                risk = {
                    "description": match[0].strip(),
                    "probability": match[1].strip(),
                    "impact": match[2].strip(),
                    "mitigation": match[3].strip(),
                    "owner": match[4].strip(),
                    "status": match[5].strip() if len(match) > 5 else ""
                }
                self.risks.append(risk)
                
                # Identify high-impact risks without proper mitigation
                if (risk["impact"] == "High" and 
                    (not risk["mitigation"] or risk["mitigation"].lower() in ["tbd", "to be determined"])):
                    self.identified_risks.append(risk)
            
            print(f"Extracted {len(self.risks)} risks from risk register")
        except Exception as e:
            print(f"Error loading risk register: {e}")
            
    def verify_strategic_goal_implementation(self):
        """Check if all strategic goals have corresponding tasks."""
        print("\nVerifying strategic goal implementation...")
        goal_implementation = {}
        
        for goal in self.strategic_goals:
            # Count tasks related to this goal
            related_tasks = []
            for task in self.tasks:
                if goal.lower() in task["description"].lower():
                    related_tasks.append(task)
            
            goal_implementation[goal] = {
                "goal": goal,
                "task_count": len(related_tasks),
                "tasks": related_tasks,
                "has_high_priority_task": any(task["priority"] == "High" for task in related_tasks),
                "implementation_status": "Good" if len(related_tasks) > 0 else "Gap"
            }
            
            print(f"Goal: {goal}")
            print(f"  Tasks implementing this goal: {len(related_tasks)}")
            print(f"  Implementation status: {goal_implementation[goal]['implementation_status']}")
            
        # Store goals without tasks in the gap report
        goals_without_tasks = [goal for goal, data in goal_implementation.items() if data["task_count"] == 0]
        if goals_without_tasks:
            self.gap_report["goals_without_tasks"] = goals_without_tasks
            print(f"\nWARNING: {len(goals_without_tasks)} strategic goals have no implementing tasks!")
            for goal in goals_without_tasks:
                print(f"  - {goal}")
        
        return goal_implementation
    
    def verify_kpi_tracking(self):
        """Check if all KPIs have tracking mechanisms in tasks."""
        print("\nVerifying KPI tracking mechanisms...")
        kpi_tracking = {}
        
        for goal, kpi_list in self.kpis.items():
            for kpi in kpi_list:
                # Extract key terms from the KPI
                kpi_short = " ".join(kpi.split()[:3]) if len(kpi.split()) > 3 else kpi
                
                # Check for tasks that mention this KPI
                tracking_tasks = []
                for task in self.tasks:
                    # Look for KPI tracking terms
                    if ("track" in task["description"].lower() and kpi_short.lower() in task["description"].lower()) or \
                       ("measure" in task["description"].lower() and kpi_short.lower() in task["description"].lower()) or \
                       ("monitor" in task["description"].lower() and kpi_short.lower() in task["description"].lower()):
                        tracking_tasks.append(task)
                
                kpi_tracking[kpi] = {
                    "kpi": kpi,
                    "goal": goal,
                    "tracking_tasks": tracking_tasks,
                    "has_tracking": len(tracking_tasks) > 0,
                    "status": "Good" if len(tracking_tasks) > 0 else "Gap"
                }
                
                print(f"KPI: {kpi_short}...")
                print(f"  Tracking tasks: {len(tracking_tasks)}")
                print(f"  Status: {kpi_tracking[kpi]['status']}")
        
        # Store KPIs without tracking in the gap report
        kpis_without_tracking = [kpi for kpi, data in kpi_tracking.items() if not data["has_tracking"]]
        if kpis_without_tracking:
            self.gap_report["kpis_without_tracking"] = kpis_without_tracking
            print(f"\nWARNING: {len(kpis_without_tracking)} KPIs have no tracking mechanisms!")
            for kpi in kpis_without_tracking[:5]:  # Show first 5 for brevity
                print(f"  - {kpi}")
            if len(kpis_without_tracking) > 5:
                print(f"  - ... and {len(kpis_without_tracking) - 5} more")
        
        return kpi_tracking
    
    def analyze_task_complexity(self, task_description):
        """
        Analyzes a task description to determine if it's complex and suggest a breakdown.
        Returns a tuple of (is_complex: bool, breakdown_suggestion: list)
        """
        # Check for multiple verbs, distinct objects, or phases
        verbs = self._extract_verbs(task_description)
        objects = self._extract_objects(task_description)
        phases = self._extract_phases(task_description)
        
        is_complex = len(verbs) > 1 or len(objects) > 1 or len(phases) > 0
        breakdown_suggestion = []
        
        if is_complex:
            # Suggest breakdown based on verbs or phases
            if len(phases) > 0:
                for i, phase in enumerate(phases, 1):
                    breakdown_suggestion.append({
                        'sub_task': f"{phase}",
                        'priority': 'Medium',
                        'estimated_effort': 'TBD',
                        'dependencies': []
                    })
            else:
                for i, verb in enumerate(verbs, 1):
                    breakdown_suggestion.append({
                        'sub_task': f"{verb} {objects[0] if objects else 'component'}",
                        'priority': 'Medium',
                        'estimated_effort': 'TBD',
                        'dependencies': []
                    })
        
        return is_complex, breakdown_suggestion

    def _extract_verbs(self, text):
        # Placeholder for NLP logic to extract verbs
        # In a real implementation, use spaCy or similar for POS tagging
        return [word for word in text.split() if word.lower() in ['develop', 'create', 'implement', 'test', 'review', 'analyze']]

    def _extract_objects(self, text):
        # Placeholder for NLP logic to extract objects
        return [word for word in text.split() if word.lower() in ['system', 'feature', 'module', 'report', 'strategy']]

    def _extract_phases(self, text):
        # Placeholder for identifying phases or sequential terms
        phase_indicators = ['first', 'then', 'next', 'finally', 'after', 'before']
        return [word for word in text.split() if word.lower() in phase_indicators]

    def verify_task_completion_documentation(self):
        """Check if completed tasks are documented in accomplishments."""
        print("\nVerifying task completion documentation...")
        undocumented_completions = []
        
        for task in self.completed_tasks:
            is_documented = False
            for accomplishment in self.accomplishments:
                # Check if the task description is in the accomplishment
                if task["description"].lower() in accomplishment["description"].lower():
                    is_documented = True
                    break
            
            if not is_documented:
                undocumented_completions.append(task)
        
        print(f"Found {len(undocumented_completions)} completed tasks not documented in accomplishments:")
        for task in undocumented_completions:
            print(f"  - {task['description']}")
        
        if undocumented_completions:
            self.gap_report["undocumented_completions"] = undocumented_completions
        
        return undocumented_completions
    
    def check_high_priority_deadlines(self):
        """Check if all high priority tasks have deadlines."""
        print("\nChecking high priority task deadlines...")
        missing_deadlines = []
        
        for task in self.high_priority_tasks:
            if not task["deadline"] or not re.match(r'\d{4}-\d{2}-\d{2}', task["deadline"]):
                missing_deadlines.append(task)
        
        print(f"Found {len(missing_deadlines)} high priority tasks without deadlines:")
        for task in missing_deadlines:
            print(f"  - {task['description']}")
        
        if missing_deadlines:
            self.gap_report["high_priority_without_deadlines"] = missing_deadlines
        
        return missing_deadlines
    
    def check_risk_mitigation(self):
        """Check if identified risks have mitigation strategies."""
        print("\nChecking risk mitigation strategies...")
        unmitigated_risks = []
        
        for risk in self.identified_risks:
            has_mitigation = False
            
            # First check if the risk learning itself contains an action
            if risk["action"] and risk["action"].lower() not in ["tbd", "to be determined", ""]:
                has_mitigation = True
                continue
            
            # Then check if there are tasks addressing this risk
            for task in self.tasks:
                key_terms = set(risk["situation"].lower().split() + risk["insight"].lower().split())
                significant_terms = [term for term in key_terms if len(term) > 5]
                
                # Check if task addresses this risk using significant terms
                if any(term in task["description"].lower() for term in significant_terms):
                    mitigate_verbs = ["mitigate", "address", "resolve", "handle", "reduce", "manage"]
                    if any(verb in task["description"].lower() for verb in mitigate_verbs):
                        has_mitigation = True
                        break
            
            if not has_mitigation:
                unmitigated_risks.append(risk)
        
        print(f"Found {len(unmitigated_risks)} risks without clear mitigation strategies:")
        for risk in unmitigated_risks:
            print(f"  - Risk: {risk['situation'][:50]}{'...' if len(risk['situation']) > 50 else ''}")
            print(f"    Insight: {risk['insight'][:50]}{'...' if len(risk['insight']) > 50 else ''}")
        
        if unmitigated_risks:
            self.gap_report["unmitigated_risks"] = unmitigated_risks
        
        return unmitigated_risks
    
    def check_next_steps_task_alignment(self):
        """Check if all next steps have corresponding tasks."""
        print("\nChecking next steps to tasks alignment...")
        unaligned_steps = []
        
        for step in self.next_steps:
            if step["completed"]:
                continue  # Skip completed steps
                
            has_task = False
            
            # Check if it has a task reference
            if step["task_reference"]:
                # Verify the referenced task exists
                for task in self.tasks:
                    if step["task_reference"].lower() in task["description"].lower():
                        has_task = True
                        break
            else:
                # Check if the step description appears in any task
                for task in self.tasks:
                    # Clean up the description (remove any task reference notes)
                    clean_desc = re.sub(r'\(Task reference:.*?\)', '', step["description"]).strip()
                    if clean_desc.lower() in task["description"].lower():
                        has_task = True
                        break
            
            if not has_task:
                unaligned_steps.append(step)
        
        print(f"Found {len(unaligned_steps)} next steps without corresponding tasks:")
        for step in unaligned_steps:
            print(f"  - {step['description'][:50]}{'...' if len(step['description']) > 50 else ''}")
        
        if unaligned_steps:
            self.gap_report["unaligned_next_steps"] = unaligned_steps
        
        return unaligned_steps
    
    def check_learning_implementation(self):
        """Check if learnings have been implemented in tasks or strategy."""
        print("\nChecking learning implementation...")
        unimplemented_learnings = []
        
        for learning in self.learnings:
            # Skip learnings without clear actions
            if not learning["action"] or learning["action"].lower() in ["tbd", "to be determined", ""]:
                continue
                
            is_implemented = False
            
            # Extract key phrases from the action
            key_phrase = " ".join(learning["action"].split()[:5])
            
            # Check if this action is reflected in tasks
            for task in self.tasks:
                if key_phrase.lower() in task["description"].lower():
                    is_implemented = True
                    break
            
            if not is_implemented:
                unimplemented_learnings.append(learning)
        
        print(f"Found {len(unimplemented_learnings)} learnings that might not be implemented in tasks:")
        for learning in unimplemented_learnings:
            print(f"  - Learning: {learning['insight'][:50]}{'...' if len(learning['insight']) > 50 else ''}")
            print(f"    Action: {learning['action'][:50]}{'...' if len(learning['action']) > 50 else ''}")
        
        if unimplemented_learnings:
            self.gap_report["unimplemented_learnings"] = unimplemented_learnings
        
        return unimplemented_learnings
    
    def check_document_headers(self):
        """Check if all document headers are up-to-date."""
        print("\nChecking document headers...")
        outdated_headers = []
        
        for doc_name, doc_path in self.document_map.items():
            try:
                with open(doc_path, 'r') as f:
                    content = f.read()
                
                # Check for header pattern
                header_match = re.search(r'<!--.*Last updated: (\d{4}-\d{2}-\d{2}).*-->', content)
                
                if not header_match:
                    outdated_headers.append({
                        "document": doc_name,
                        "path": doc_path,
                        "issue": "Missing header"
                    })
                    continue
                
                header_date = header_match.group(1)
                last_modified = datetime.datetime.fromtimestamp(os.path.getmtime(doc_path)).strftime('%Y-%m-%d')
                
                if header_date != last_modified:
                    outdated_headers.append({
                        "document": doc_name,
                        "path": doc_path,
                        "issue": f"Header date ({header_date}) doesn't match last modification date ({last_modified})"
                    })
            except Exception as e:
                print(f"Error checking header for {doc_name}: {e}")
        
        print(f"Found {len(outdated_headers)} documents with header issues:")
        for doc in outdated_headers:
            print(f"  - {doc['document']}: {doc['issue']}")
        
        if outdated_headers:
            self.gap_report["outdated_headers"] = outdated_headers
        
        return outdated_headers
    
    def check_terminology_consistency(self):
        """Check for consistent terminology across documents."""
        print("\nChecking terminology consistency...")
        
        # Load all document content
        all_content = {}
        for doc_name, doc_path in self.document_map.items():
            try:
                with open(doc_path, 'r') as f:
                    all_content[doc_name] = f.read()
            except Exception as e:
                print(f"Error loading {doc_name}: {e}")
        
        # Extract potential key terms (capitalized multi-word phrases)
        key_terms = set()
        for content in all_content.values():
            terms = re.findall(r'\b[A-Z][a-zA-Z]+\s+[A-Z][a-zA-Z]+\b', content)
            key_terms.update(terms)
        
        # Check for variations of each term across documents
        inconsistent_terms = []
        
        for term in key_terms:
            term_variations = defaultdict(int)
            
            # Check for different forms (singular/plural/with suffix)
            base_term = term.lower()
            
            for doc_name, content in all_content.items():
                # Count base term
                if base_term in content.lower():
                    term_variations[f"{base_term} ({doc_name})"] += content.lower().count(base_term)
                
                # Count plurals
                if base_term + "s" in content.lower():
                    term_variations[f"{base_term}s ({doc_name})"] += content.lower().count(base_term + "s")
                
                # Count with 'ing' suffix
                if base_term + "ing" in content.lower():
                    term_variations[f"{base_term}ing ({doc_name})"] += content.lower().count(base_term + "ing")
            
            # If we have multiple variations, flag it
            if len(term_variations) > 1:
                inconsistent_terms.append({
                    "term": term,
                    "variations": dict(term_variations)
                })
        
        print(f"Found {len(inconsistent_terms)} potentially inconsistent terms:")
        for term_data in inconsistent_terms[:5]:  # Show first 5 for brevity
            print(f"  - {term_data['term']}:")
            for variation, count in term_data['variations'].items():
                print(f"    - {variation}: {count}")
                
        if len(inconsistent_terms) > 5:
            print(f"  - ... and {len(inconsistent_terms) - 5} more")
        
        if inconsistent_terms:
            self.gap_report["inconsistent_terminology"] = inconsistent_terms
        
        return inconsistent_terms
    
    def check_risk_register_maintenance(self):
        """Check if the risk register is properly maintained and aligned with identified risks."""
        print("\nChecking risk register maintenance...")
        
        # First, check if risks from learnings.md are present in risk-register.md
        risks_not_in_register = []
        for risk in self.identified_risks:
            if isinstance(risk, dict) and "situation" in risk:  # This is from learnings.md
                found_in_register = False
                for reg_risk in self.risks:
                    # Check if the learning risk description appears in any risk register entry
                    if (risk["situation"].lower() in reg_risk["description"].lower() or 
                        risk["insight"].lower() in reg_risk["description"].lower()):
                        found_in_register = True
                        break
                
                if not found_in_register:
                    risks_not_in_register.append(risk)
        
        # Check for high probability/impact risks without owners
        risks_without_owners = []
        for risk in self.risks:
            if (risk["probability"] == "High" or risk["impact"] == "High") and not risk["owner"]:
                risks_without_owners.append(risk)
        
        # Check for high probability/impact risks without mitigation plans
        risks_without_mitigation = []
        for risk in self.risks:
            if (risk["probability"] == "High" or risk["impact"] == "High") and not risk["mitigation"]:
                risks_without_mitigation.append(risk)
                
        # Check for risks without status updates
        risks_without_status = []
        for risk in self.risks:
            if not risk["status"]:
                risks_without_status.append(risk)
        
        print(f"Found {len(risks_not_in_register)} risks from learnings not in the risk register")
        for risk in risks_not_in_register[:3]:  # Show first 3 for brevity
            print(f"  - Learning: {risk['situation'][:50]}{'...' if len(risk['situation']) > 50 else ''}")
            print(f"    Insight: {risk['insight'][:50]}{'...' if len(risk['insight']) > 50 else ''}")
        
        print(f"Found {len(risks_without_owners)} high probability/impact risks without owners")
        for risk in risks_without_owners[:3]:  # Show first 3 for brevity
            print(f"  - Risk: {risk['description'][:50]}{'...' if len(risk['description']) > 50 else ''}")
            
        print(f"Found {len(risks_without_mitigation)} high probability/impact risks without mitigation plans")
        for risk in risks_without_mitigation[:3]:  # Show first 3 for brevity
            print(f"  - Risk: {risk['description'][:50]}{'...' if len(risk['description']) > 50 else ''}")
            
        print(f"Found {len(risks_without_status)} risks without status updates")
        for risk in risks_without_status[:3]:  # Show first 3 for brevity
            print(f"  - Risk: {risk['description'][:50]}{'...' if len(risk['description']) > 50 else ''}")
        
        # Store in gap report
        if risks_not_in_register:
            self.gap_report["risks_not_in_register"] = risks_not_in_register
        if risks_without_owners:
            self.gap_report["risks_without_owners"] = risks_without_owners
        if risks_without_mitigation:
            self.gap_report["risks_without_mitigation"] = risks_without_mitigation
        if risks_without_status:
            self.gap_report["risks_without_status"] = risks_without_status
            
        return {
            "risks_not_in_register": risks_not_in_register,
            "risks_without_owners": risks_without_owners,
            "risks_without_mitigation": risks_without_mitigation,
            "risks_without_status": risks_without_status
        }
    
    def check_kpi_performance_tracking(self):
        """Check if KPIs have actual performance data being tracked."""
        print("\nChecking KPI performance tracking...")
        
        kpis_without_tracking = []
        
        try:
            # Check if kpi-performance.md exists
            if not os.path.exists(self.document_map["kpi_performance"]):
                print("Warning: kpi-performance.md file does not exist.")
                for goal, kpi_list in self.kpis.items():
                    for kpi in kpi_list:
                        kpis_without_tracking.append({
                            "kpi": kpi,
                            "goal": goal,
                            "issue": "No KPI performance tracking file exists"
                        })
            else:
                with open(self.document_map["kpi_performance"], 'r') as f:
                    content = f.read()
                
                # For each KPI in master-plan.md, check if it appears in kpi-performance.md
                for goal, kpi_list in self.kpis.items():
                    for kpi in kpi_list:
                        # Extract key terms from the KPI
                        kpi_terms = ' '.join(kpi.split()[:3]) if len(kpi.split()) > 3 else kpi
                        
                        if kpi_terms.lower() not in content.lower():
                            kpis_without_tracking.append({
                                "kpi": kpi,
                                "goal": goal,
                                "issue": "KPI not found in performance tracking document"
                            })
            
            print(f"Found {len(kpis_without_tracking)} KPIs without performance tracking")
            for kpi_issue in kpis_without_tracking[:5]:  # Show first 5 for brevity
                print(f"  - {kpi_issue['kpi']} ({kpi_issue['goal']}): {kpi_issue['issue']}")
            
            if kpis_without_tracking:
                self.gap_report["kpis_without_performance_tracking"] = kpis_without_tracking
            
            return kpis_without_tracking
                
        except Exception as e:
            print(f"Error checking KPI performance tracking: {e}")
            return []
    
    def run_all_checks(self):
        """Run all consistency checks and gap detection."""
        print("\n=== Running comprehensive planning verification ===\n")
        self.load_all_documents()
        
        # Run all verification checks
        self.verify_strategic_goal_implementation()
        self.verify_kpi_tracking()
        self.analyze_task_complexity()
        self.verify_task_completion_documentation()
        self.check_high_priority_deadlines()
        self.check_risk_mitigation()
        self.check_next_steps_task_alignment()
        self.check_learning_implementation()
        self.check_document_headers()
        self.check_terminology_consistency()
        
        # Run new checks
        self.check_risk_register_maintenance()
        self.check_kpi_performance_tracking()
        self.check_resource_gaps()
        
        # Generate summary report
        self.generate_summary_report()
        
    def generate_summary_report(self):
        """Generate a summary report of all identified gaps and issues."""
        print("\n=== Planning Verification Summary Report ===\n")
        
        total_gaps = sum(len(gaps) for gaps in self.gap_report.values())
        print(f"Total issues identified: {total_gaps}")
        
        # Summarize each category
        categories = {
            "goals_without_tasks": "Strategic goals without implementing tasks",
            "kpis_without_tracking": "KPIs without tracking mechanisms",
            "tasks_needing_breakdown": "Complex tasks needing breakdown",
            "undocumented_completions": "Completed tasks not in accomplishments",
            "high_priority_without_deadlines": "High priority tasks without deadlines",
            "unmitigated_risks": "Risks without mitigation strategies",
            "unaligned_next_steps": "Next steps without corresponding tasks",
            "unimplemented_learnings": "Learnings not implemented in tasks",
            "outdated_headers": "Documents with header issues",
            "inconsistent_terminology": "Inconsistent terminology usage",
            "risks_not_in_register": "Risks from learnings not in the risk register",
            "risks_without_owners": "High probability/impact risks without owners",
            "risks_without_mitigation": "High probability/impact risks without mitigation plans",
            "risks_without_status": "Risks without status updates",
            "kpis_without_performance_tracking": "KPIs without performance tracking"
        }
        
        for category, description in categories.items():
            count = len(self.gap_report.get(category, []))
            if count > 0:
                print(f"- {description}: {count}")
        
        # Generate recommendations
        print("\nTop recommendations based on findings:")
        
        # Prioritize recommendations
        recommendations = []
        
        if "high_priority_without_deadlines" in self.gap_report and self.gap_report["high_priority_without_deadlines"]:
            recommendations.append("Add deadlines to all high priority tasks")
            
        if "goals_without_tasks" in self.gap_report and self.gap_report["goals_without_tasks"]:
            recommendations.append("Create implementing tasks for all strategic goals")
            
        if "kpis_without_tracking" in self.gap_report and self.gap_report["kpis_without_tracking"]:
            recommendations.append("Develop tracking mechanisms for all KPIs")
            
        if "tasks_needing_breakdown" in self.gap_report and self.gap_report["tasks_needing_breakdown"]:
            recommendations.append("Break down complex tasks into smaller components")
            
        if "undocumented_completions" in self.gap_report and self.gap_report["undocumented_completions"]:
            recommendations.append("Document all completed tasks in accomplishments.md")
            
        if "unmitigated_risks" in self.gap_report and self.gap_report["unmitigated_risks"]:
            recommendations.append("Develop mitigation strategies for identified risks")
            
        # Output recommendations
        for i, recommendation in enumerate(recommendations[:5], 1):
            print(f"{i}. {recommendation}")
        
        # Output next steps for running scripts
        print("\nSuggested next steps:")
        print("1. Run './scripts/check-consistency.sh' to verify document cross-references")
        print("2. Update document headers with current dates")
        print("3. Address the highest priority gaps identified in this report")
        print("4. Run './scripts/weekly-assessment.sh' after making changes to validate improvements")
        
        # Offer to save report to file
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d-%H%M")
        report_file = f"reports/planning-verification-{timestamp}.json"
        
        os.makedirs(os.path.dirname(report_file), exist_ok=True)
        with open(report_file, 'w') as f:
            json.dump({
                "timestamp": timestamp,
                "total_gaps": total_gaps,
                "gap_summary": {category: len(gaps) for category, gaps in self.gap_report.items()},
                "detailed_gaps": self.gap_report,
                "recommendations": recommendations
            }, f, indent=2)
        
        print(f"\nDetailed report saved to {report_file}")

    def check_tasks(self):
        print(f"{logging.getLogger().handlers[0].formatter.format(logging.LogRecord('root', logging.INFO, None, None, 'Checking task integrity...', None, None))}")
        tasks = self._parse_tasks()
        issues = []
        
        for task in tasks:
            if not task['Priority']:
                issues.append(f"Task {task['Task ID']} has no priority set")
            if not task['Status']:
                issues.append(f"Task {task['Task ID']} has no status set")
            if task['Priority'] == 'High' and not task['Deadline']:
                issues.append(f"High priority task {task['Task ID']} has no deadline")
            # Check for complexity
            is_complex, breakdown = self.analyze_task_complexity(task['Task'])
            if is_complex:
                issues.append(f"Task {task['Task ID']} appears complex and may need breakdown. Suggested breakdown: {breakdown}")
        
        return issues

    def check_risks(self):
        print(f"{logging.getLogger().handlers[0].formatter.format(logging.LogRecord('root', logging.INFO, None, None, 'Checking risk management...', None, None))}")
        risks = self._parse_risks()
        tasks = self._parse_tasks()
        learnings_content = self._read_file('learnings.md')
        master_plan_content = self._read_file('master-plan.md')
        issues = []
        
        # Check for risks without mitigation or owners
        for risk in risks:
            if not risk.get('Mitigation'):
                issues.append(f"Risk {risk['Risk ID']} has no mitigation strategy")
            if not risk.get('Owner'):
                issues.append(f"Risk {risk['Risk ID']} has no owner assigned")
            # Check if there's a corresponding task for mitigation
            mitigation_task_exists = any(task['Task'].lower() in risk.get('Mitigation', '').lower() for task in tasks)
            if not mitigation_task_exists and risk.get('Mitigation'):
                issues.append(f"Risk {risk['Risk ID']} mitigation strategy not found in tasks.md")
        
        # Scan learnings.md for potential risks
        potential_risks_from_learnings = self._extract_potential_risks(learnings_content)
        for potential_risk in potential_risks_from_learnings:
            if not any(potential_risk.lower() in risk['Description'].lower() for risk in risks):
                issues.append(f"Potential risk identified in learnings.md not in risk-register.md: {potential_risk}")
        
        # Scan master-plan.md for potential risks in challenges section
        potential_risks_from_master_plan = self._extract_potential_risks(master_plan_content, keywords=['challenge', 'risk', 'threat', 'obstacle'])
        for potential_risk in potential_risks_from_master_plan:
            if not any(potential_risk.lower() in risk['Description'].lower() for risk in risks):
                issues.append(f"Potential risk identified in master-plan.md not in risk-register.md: {potential_risk}")
        
        return issues

    def _extract_potential_risks(self, content, keywords=['risk', 'issue', 'problem', 'concern', 'threat', 'challenge']):
        # Extract lines or sections that might indicate risks
        lines = content.split('\n')
        potential_risks = []
        for line in lines:
            if any(keyword in line.lower() for keyword in keywords):
                potential_risks.append(line.strip())
        return potential_risks[:5]  # Limit to first 5 to avoid noise

    def check_kpis(self):
        print(f"{logging.getLogger().handlers[0].formatter.format(logging.LogRecord('root', logging.INFO, None, None, 'Checking KPI integrity...', None, None))}")
        master_plan_content = self._read_file('master-plan.md')
        kpi_performance_content = self._read_file('kpi-performance.md')
        issues = []
        
        # Extract KPIs from master-plan.md
        kpis = self._extract_kpis(master_plan_content)
        
        # Check if each KPI has an entry in kpi-performance.md
        for kpi in kpis:
            if not self._has_performance_entry(kpi, kpi_performance_content):
                issues.append(f"KPI '{kpi['name']}' from master-plan.md has no entry in kpi-performance.md")
            else:
                # Check if the entry has recent data
                last_updated = self._get_last_updated_date(kpi, kpi_performance_content)
                if last_updated and self._is_outdated(last_updated):
                    issues.append(f"KPI '{kpi['name']}' in kpi-performance.md has outdated data (last updated: {last_updated})")
                # Check if KPI is consistently off-target
                if self._is_off_target(kpi, kpi_performance_content):
                    issues.append(f"KPI '{kpi['name']}' is consistently off-target and needs strategic review")
        
        return issues

    def _extract_kpis(self, content):
        # Placeholder for extracting KPIs from master-plan.md
        lines = content.split('\n')
        kpis = []
        for line in lines:
            if 'KPI:' in line:
                kpi_name = line.split('KPI:')[-1].strip()
                kpis.append({'name': kpi_name, 'target': 'TBD'})
        return kpis

    def _has_performance_entry(self, kpi, performance_content):
        # Check if KPI has an entry in kpi-performance.md
        return kpi['name'].lower() in performance_content.lower()

    def _get_last_updated_date(self, kpi, performance_content):
        # Placeholder for extracting last updated date for a KPI
        import re
        pattern = re.compile(r'Last Updated: (\d{4}-\d{2}-\d{2})', re.IGNORECASE)
        match = pattern.search(performance_content)
        return match.group(1) if match else None

    def _is_outdated(self, date_str):
        from datetime import datetime
        if not date_str:
            return True
        date = datetime.strptime(date_str, '%Y-%m-%d')
        from datetime import timedelta
        return (datetime.now() - date) > timedelta(days=30)

    def _is_off_target(self, kpi, performance_content):
        # Placeholder for checking if KPI is consistently off-target
        return False  # Implement logic based on performance data

    def update_document_headers(self):
        """Update the 'Last updated' date in the header of all planning documents to today's date."""
        print(f"{logging.getLogger().handlers[0].formatter.format(logging.LogRecord('root', logging.INFO, None, None, 'Updating document headers...', None, None))}")
        today = datetime.datetime.now().strftime('%Y-%m-%d')
        updated_files = []
        
        for doc_name, doc_path in self.document_map.items():
            try:
                with open(doc_path, 'r') as f:
                    content = f.read()
                
                # Look for the header with 'Last updated' date
                header_pattern = re.compile(r'<!--.*?Last updated: \d{4}-\d{2}-\d{2}.*?-->', re.DOTALL)
                match = header_pattern.search(content)
                if match:
                    old_header = match.group(0)
                    new_header = old_header.replace(re.search(r'Last updated: \d{4}-\d{2}-\d{2}', old_header).group(0), f'Last updated: {today}')
                    content = content.replace(old_header, new_header)
                else:
                    # If no header found, add one
                    description = f"{doc_name.replace('_', ' ').title()} for business planning."
                    new_header = f"<!-- {description} Last updated: {today} -->"
                    content = new_header + '\n' + content
                
                with open(doc_path, 'w') as f:
                    f.write(content)
                updated_files.append(doc_name)
                print(f"Updated header for {doc_name}")
            except Exception as e:
                print(f"Error updating header for {doc_name}: {e}")
        
        return updated_files

    def check_resource_gaps(self):
        """Check for resource gaps by scanning tasks for resource mentions and cross-referencing with available resources."""
        print(f"{logging.getLogger().handlers[0].formatter.format(logging.LogRecord('root', logging.INFO, None, None, 'Checking for resource gaps...', None, None))}")
        tasks = self._parse_tasks()
        master_plan_content = self._read_file('master-plan.md')
        issues = []
        
        # Define common resource keywords
        resource_keywords = ['personnel', 'staff', 'team', 'developer', 'designer', 'budget', 'funding', 'tool', 'software', 'equipment', 'expertise', 'training']
        
        # Scan tasks for resource mentions
        for task in tasks:
            task_description = task['Task'].lower()
            mentioned_resources = [keyword for keyword in resource_keywords if keyword in task_description]
            if mentioned_resources:
                for resource in mentioned_resources:
                    # Check if this resource is mentioned as available in master-plan.md
                    if resource not in master_plan_content.lower():
                        issues.append(f"Task {task['Task ID']} mentions {resource} which may not be accounted for in master-plan.md")
                    # Check if the resource is flagged as scarce or high-demand in notes
                    if 'scarce' in task.get('Notes', '').lower() or 'high demand' in task.get('Notes', '').lower():
                        issues.append(f"Task {task['Task ID']} requires {resource} which is flagged as scarce or high-demand")
        
        return issues

def main():
    parser = argparse.ArgumentParser(description="Enhanced business planning verification tool")
    parser.add_argument("--dir", help="Base directory for planning documents", default=None)
    parser.add_argument("--output", help="Output file for detailed report", default=None)
    parser.add_argument("--check", choices=["all", "goals", "kpis", "tasks", "complexity", "completions", "deadlines", "risks", "alignment", "learning", "headers", "terminology", "risk_register", "kpi_performance", "resources"], default="all", help="Specific check to run")
    parser.add_argument("--update-headers", action="store_true", help="Update document headers with current date")
    
    args = parser.parse_args()
    
    automation = BusinessPlanningAutomation(args.dir)
    
    if args.update_headers:
        automation.update_document_headers()
        sys.exit(0)
    
    if args.check == "all":
        automation.run_all_checks()
    else:
        automation.load_all_documents()
        
        check_map = {
            "goals": automation.verify_strategic_goal_implementation,
            "kpis": automation.verify_kpi_tracking,
            "tasks": automation.verify_task_completion_documentation,
            "complexity": automation.analyze_task_complexity,
            "completions": automation.verify_task_completion_documentation,
            "deadlines": automation.check_high_priority_deadlines,
            "risks": automation.check_risk_mitigation,
            "alignment": automation.check_next_steps_task_alignment,
            "learning": automation.check_learning_implementation,
            "headers": automation.check_document_headers,
            "terminology": automation.check_terminology_consistency,
            "risk_register": automation.check_risk_register_maintenance,
            "kpi_performance": automation.check_kpi_performance_tracking,
            "resources": automation.check_resource_gaps
        }
        
        if args.check in check_map:
            check_map[args.check]()
        else:
            print(f"Unknown check: {args.check}")
            sys.exit(1)
    
    # If an output file is specified, save the report there
    if args.output:
        with open(args.output, 'w') as f:
            json.dump({
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d-%H%M"),
                "gap_summary": {category: len(gaps) for category, gaps in automation.gap_report.items()},
                "detailed_gaps": automation.gap_report
            }, f, indent=2)
        print(f"Detailed report saved to {args.output}")

if __name__ == "__main__":
    main() 