; ============================================================================
; Shared constants for the current Milestone 0 real-mode kernel.
; ============================================================================

KERNEL_LOAD_ADDR    equ 0x1000
STACK_TOP           equ 0x9000

; Protected mode constants
STACK_TOP_PM        equ 0x90000

VGA_BUFFER          equ 0xB800
VGA_COLS            equ 80
VGA_ROWS            equ 25
VGA_ATTR_NORMAL     equ 0x0F
VGA_ATTR_TITLE      equ 0x0B
VGA_ATTR_OK         equ 0x0A
VGA_ATTR_WARN       equ 0x0E

COM1                equ 0x3F8

PAGE_SIZE           equ 4096
MEMORY_BASE         equ 0x2000
MEMORY_LIMIT        equ 0x8000

MAX_TASKS           equ 4
TASK_READY          equ 0
TASK_RUNNING        equ 1
TASK_BLOCKED        equ 2

MSG_EMPTY           equ 0
MSG_BOOT            equ 1
MSG_MAX_DATA        equ 32

FS_SERVER_ID        equ 1
DRIVER_SERVER_ID    equ 2
