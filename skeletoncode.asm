include Irvine32.inc    ; Include the Irvine32 library

.data
    ; Player's starting position (center)
    center_x db 40      ; Column (X)
    center_y db 12      ; Row (Y)

    ; Characters representing rotations
    up_char db '^'
    down_char db 'v'
    left_char db '<'
    right_char db '>'

    ; Default character (initial direction)
    current_char db '^'

    ; Colors for the emitter and player
    color_red db 4       ; Red
    color_green db 2     ; Green
    color_yellow db 14   ; Yellow (for fire symbol)
    current_color db 4   ; Default player color (red)
    emitter_color1 db 2  ; Green
    emitter_color2 db 4  ; Red
    fire_color db 14     ; Fire symbol color (Yellow)

    ; Emitter properties
    emitter_symbol db '#'
    emitter_row db 10    ; Two rows above player (fixed row for emitter)
    emitter_col db 1     ; Starting column of the emitter

    ; Fire symbol properties (fired from player)
    fire_symbol db '*'
    fire_row db 0        ; Fire will be fired from the player's position
    fire_col db 0        ; Initial fire column will be set in the update logic

.code

fire proc
    ; Fire a projectile from the player's current face direction
    push ax
    push dx

    mov dl, center_x      ; Fire column starts at the player's X position
    mov dh, center_y      ; Fire row starts at the player's Y position

    mov al, current_char
    cmp al, up_char
    je fire_up
    cmp al, down_char
    je fire_down
    cmp al, left_char
    je fire_left
    cmp al, right_char
    je fire_right
    jmp end_fire

fire_up:
    dec dh                ; Move fire position upwards
    jmp fire_loop

fire_down:
    inc dh                ; Move fire position downwards
    jmp fire_loop

fire_left:
    dec dl                ; Move fire position leftwards
    jmp fire_loop

fire_right:
    inc dl                ; Move fire position rightwards
    jmp fire_loop

fire_loop:
    ; Ensure fire stays within the bounds of the emitter wall
    cmp dl, 1             ; Left wall boundary
    jl end_fire
    cmp dl, 79            ; Right wall boundary
    jg end_fire
    cmp dh, 10            ; Upper wall boundary
    jl end_fire
    cmp dh, 12            ; Lower wall boundary
    jg end_fire

    ; Print the fire symbol at the current position
    mov al, fire_color    ; Set fire color
    call SetTextColor
    mov dl, fire_symbol   ; Set fire symbol
    call Gotoxy
    call WriteChar

    ; Continue moving fire in the current direction (recursive)
    call fire_loop

end_fire:
    pop dx
    pop ax
    ret
fire endp

check_for_key_press proc
    ; Check if a key has been pressed and update player position or shape
    call ReadKey         ; Wait for a key press

    cmp ah, 48h          ; Up arrow key
    je up_arrow
    cmp ah, 50h          ; Down arrow key
    je down_arrow
    cmp ah, 4Dh          ; Right arrow key
    je right_arrow
    cmp ah, 4Bh          ; Left arrow key
    je left_arrow

    ret                  ; If no key matches, return to main loop

up_arrow:
    cmp center_y, 10     ; Prevent moving above the emitter wall
    jle no_move
    mov al, up_char      ; Set the character to '^'
    mov current_char, al
    dec byte ptr center_y; Move up
    ; Print the updated player character
    mov dl, current_char
    call SetTextColor
    call Gotoxy
    call WriteChar
    ret

down_arrow:
    cmp center_y, 12     ; Prevent moving below the emitter wall
    jge no_move
    mov al, down_char    ; Set the character to 'v'
    mov current_char, al
    inc byte ptr center_y; Move down
    ; Print the updated player character
    mov dl, current_char
    call SetTextColor
    call Gotoxy
    call WriteChar
    ret

right_arrow:
    cmp center_x, 79     ; Prevent moving beyond the right wall
    jge no_move
    mov al, right_char   ; Set the character to '>'
    mov current_char, al
    inc byte ptr center_x; Move right
    ; Print the updated player character
    mov dl, current_char
    call SetTextColor
    call Gotoxy
    call WriteChar
    ret

left_arrow:
    cmp center_x, 1      ; Prevent moving beyond the left wall
    jle no_move
    mov al, left_char    ; Set the character to '<'
    mov current_char, al
    dec byte ptr center_x; Move left
    ; Print the updated player character
    mov dl, current_char
    call SetTextColor
    call Gotoxy
    call WriteChar
    ret

no_move:
    ret

check_for_key_press endp

draw_emitter proc
    ; Draw the emitter with alternating colors
    push ax
    push cx
    push dx

    mov cx, 80           ; Number of columns (console width)
    mov dl, emitter_col
    mov dh, emitter_row

emitter_loop:
    ; Alternate emitter colors between green and red
    mov al, emitter_color1
    call SetTextColor

    mov al, emitter_symbol
    call Gotoxy
    call WriteChar

    ; Toggle color for the next symbol
    cmp al, emitter_color1
    jne set_green
    mov al, emitter_color2
    jmp next_symbol

set_green:
    mov al, emitter_color1

next_symbol:
    inc dl               ; Move to the next column
    cmp dl, 80           ; Wrap around at the end of the row
    jne emitter_loop
    mov dl, emitter_col  ; Reset column

    pop dx
    pop cx
    pop ax
    ret
draw_emitter endp


print_character proc
    ; Set text color
    mov al, current_color
    call SetTextColor

    ; Move the cursor to the current position
    mov dl, [center_x]
    mov dh, [center_y]
    call Gotoxy

    ; Print the current character
    mov dl, current_char
    call WriteChar
    ret
print_character endp


initialize_screen proc
    ; Draw the emitter at the start
    call draw_emitter
    ; Set the initial player character position
    call print_character
    ret
initialize_screen endp

update_emitter proc
    ; Update the emitter symbols to animate the line
    push ax
    push cx
    push dx

    mov cx, 80           ; Number of columns (console width)
    mov dl, emitter_col
    mov dh, emitter_row

    ; Redraw emitter with updated colors
emitter_update_loop:
    ; Alternate emitter colors between green and red
    cmp al, emitter_color1
    jne set_green_color
    mov al, emitter_color2
    jmp draw_symbol

set_green_color:
    mov al, emitter_color1

draw_symbol:
    mov al, emitter_symbol
    call Gotoxy
    call WriteChar

    inc dl               ; Move to the next column
    cmp dl, 80           ; Wrap around at the end of the row
    jne emitter_update_loop
    mov dl, emitter_col  ; Reset column

    pop dx
    pop cx
    pop ax
    ret
update_emitter endp

main proc
    ; Initialize screen and emitter
    call initialize_screen

    ; Main loop for player movement and updates
main_loop:
    call check_for_key_press
    call update_emitter
    call fire    ; Call the fire procedure
    jmp main_loop

main endp
end main
