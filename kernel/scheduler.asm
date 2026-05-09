; ============================================================================
; Cooperative round-robin scheduler metadata.
; ============================================================================

init_scheduler:
    mov byte [current_task], 0
    mov byte [task_table + 0], TASK_RUNNING
    mov byte [task_table + 1], TASK_READY
    mov byte [task_table + 2], TASK_READY
    mov byte [task_table + 3], TASK_BLOCKED
    ret

schedule_next:
    inc byte [current_task]
    cmp byte [current_task], MAX_TASKS
    jb .done
    mov byte [current_task], 0
.done:
    ret

current_task db 0
task_table times MAX_TASKS db TASK_BLOCKED
