.model small
.stack 100h

.data 
    ; Mensajes para usuario
    msg_ingresar db 'Ingrese nombre del estudiante (max 20 caracteres): $'
    msg_contador db 13,10, 'Estudiante $'
    msg_total db ' /15: $'
    msg_completado db 13,10,10, 'Se han guardado 15 estudiantes.$'
    msg_continuar db 13,10, 'Presione cualquier tecla para continuar...$'

    ;Buffer para entrada de nombre
    buffer db 21 ;maximo 20 caracteres + enter
            db ? ;espacio para longitud real
            db 21 dup('$') ;espacio para el nombre

    ;Array para almacenar los 15 nobres
    estudiantes db 15 dup(20 dup('$')) ;15 estudiantes, cada uno con 20 caracteres
    
    ;variables de control
    contador db 0
    nueva_linea db 13,10,'$'

.code
main proc 
    mov ax, @data
    mov ds, ax
    mov es, ax

    mov cx, 15 ; pedir 15 estudiantes

ingresar_nombres:
    ;Mostrar mensaje con contador
    mov ah, 09h
    lea dx, msg_contador
    int 21h

    ;Mostrar el numero
    call mostrar_numero

    ;Mostrar "/15"
    mov ah, 09h
    lea dx, msg_total
    int 21h

    ;Mostrar mensaje para ingresar nombre
    mov ah, 09h
    lea dx, msg_ingresar
    int 21h

    ;Pedir nombre
    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; Guardar nombre en el array
    call guardar_nombre

    ;Incrementar contador
    inc contador

    ;Nueva linea
    mov ah, 09h
    lea dx, nueva_linea
    int 21h

    loop ingresar_nombres

    ;Mostrar mensaje de completado
    mov ah, 09h
    lea dx, msg_completado
    int 21h

    ;Esperar tecla para continuar
    mov ah, 09h
    lea dx, msg_continuar
    int 21h
    mov ah, 01h
    int 21h

    ;Termianr programa
    mov ax, 4C00h
    int 21h

main endp

;Procedimiento para mostrar numero
mostrar_numero proc
    push ax
    push bx
    push dx

    ; Cargar el contador (solo AL)
    mov al, contador  
    inc al            ; numero actual (1-15)
    mov ah, 0         
    
    cmp al, 10
    jb un_digito

    ;Para dos digitos (10-15)
    mov bl, 10
    div bl            ; AL = decenas, AH = unidades

    ;imprimir decenas
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h

    ;imprimir unidades
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    jmp fin_mostrar

;Para un digito (1-9)
un_digito:
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h

fin_mostrar:
    pop dx
    pop bx
    pop ax
    ret
mostrar_numero endp

;Procedimiento para guardar nombres en el array
guardar_nombre proc
    pusha
    push cx

    ;calcular posicion en el array
    mov al, contador
    mov ah, 0
    mov bl, 20
    mul bl
    lea si, estudiantes
    add si, ax ;SI apunta a la posicion correcta

    ;copiar nombre del buffer al array
    lea di, buffer + 2 ;DI apunta al inicio del nombre ingresado
    mov cl, [buffer+1] ;CL = longitud del nombre
    mov ch, 0

    cmp cl, 0
    je fin_copia

    ;Limpiar la posicion actual primero
    push cx
    push di
    mov cx, 20
    mov al, '$'
    mov di, si
    rep stosb
    pop di
    pop cx

copiar_caracter:
    mov al, [di]
    mov [si], al
    inc di
    inc si
    loop copiar_caracter

fin_copia:
    pop cx
    popa
    ret
guardar_nombre endp

end main
     