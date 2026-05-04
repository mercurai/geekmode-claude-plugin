---
name: tasks
description: Interactive task CRUD — list, create, update, start, stop, pause, and resume monitoring tasks via the gm CLI.
triggers:
  - /tasks
  - "list tasks"
  - "show tasks"
  - "create task"
  - "start task"
  - "stop task"
  - "pause task"
  - "resume task"
---

# Tasks Skill

Manage geekmode-rust monitoring tasks interactively.

## Steps

### 1. List current tasks

```bash
gm tasks list
```

Output includes: task ID, event ID, status (running/stopped/paused/error), last updated.

### 2. Inspect a task

```bash
gm tasks get <id>
```

Shows full task config: event filters, section targets, price constraints, and current slot assignment.

### 3. Modify task state

Choose the operation based on current task state:

```bash
gm tasks start <id>    # stopped → running
gm tasks stop <id>     # running → stopped
gm tasks pause <id>    # running → paused (state preserved)
gm tasks resume <id>   # paused → running
```

### 4. Engine-level control

To start or stop all tasks at once:

```bash
gm engine start-all    # activate all tasks
gm engine stop-all     # deactivate all tasks
gm engine status       # slot count and engine state
```

**Confirm task count before running engine-level commands.**

## Usage Notes

- Tasks can only be started if the engine has available slots.
- Paused tasks retain their availability snapshot; stopped tasks do not.
- After changing task state, re-run `gm tasks list` to confirm the new status.
- For task creation or config changes, use `gm config` or the desktop UI.
