; ============================================================================
; Single-mailbox IPC placeholder.
; ============================================================================

init_ipc:
    mov byte [msg_type], MSG_EMPTY
    mov byte [msg_src], 0
    mov byte [msg_dst], 0
    ret

ipc_send:
    mov [msg_src], al
    mov [msg_dst], bl
    mov [msg_type], cl
    ret

ipc_receive:
    mov al, [msg_type]
    ret

msg_src db 0
msg_dst db 0
msg_type db MSG_EMPTY
msg_data times MSG_MAX_DATA db 0
