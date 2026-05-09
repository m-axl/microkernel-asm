; ============================================================================
; File-system server stub.
; ============================================================================

fs_server_init:
    mov byte [fs_server_state], TASK_READY
    ret

fs_server_tick:
    call ipc_receive
    cmp al, MSG_EMPTY
    je .idle
.idle:
    ret

fs_server_state db TASK_BLOCKED
