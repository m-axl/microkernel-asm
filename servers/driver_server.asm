; ============================================================================
; Driver server stub.
; ============================================================================

driver_server_init:
    mov byte [driver_server_state], TASK_READY
    ret

driver_server_tick:
    ret

start_servers:
    call fs_server_init
    call driver_server_init

    mov al, 0
    mov bl, FS_SERVER_ID
    mov cl, MSG_BOOT
    call ipc_send
    ret

driver_server_state db TASK_BLOCKED
