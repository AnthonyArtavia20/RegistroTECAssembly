.model small
.stack 100h

.data 
    ; Mensajes para usuario
    msg_ingresar db 'ingrese datos (Formato: Nombre-Apellido1-Apellido2-Nota): $'
    msg_formato db 13,10, 'Ejemplo: Juan-Perez-Garcia-85',13,10,'$'
    msg_contador db 13,10, 'Estudiante $'
    msg_total db ' /15: $'
    msg_completado db 13,10,10, 'Se han guardado 15 estudiantes.$'
    msg_continuar db 13,10, 'Presione cualquier tecla para continuar...$'
    msg_error db 13,10, 'Error: Use formato Nombre-Apellido1-Apellido2-Nota',13,10,'$'

    ;Buffer para entrada de nombre
    buffer db 51 ;maximo 50 caracteres + enter
            db ? ;espacio para longitud real
            db 51 dup('$') ;espacio para el nombre

    ;Array para almacenar los 15 nobres
    nombres db 15 dup(20 dup('$'))  ;Nombres
    apellidos1 db 15 dup(20 dup('$')) ;Apellidos 1
    apellidos2 db 15 dup(20 dup('$')) ;Apellidos 2
    notas db 15 dup(3 dup('$')) ;Notas 0-100
    
    ;variables de control
    contador db 0
    nueva_linea db 13,10,'$'
    temp db 0

.code
main proc 
    mov ax, @data
    mov ds, ax
    mov es, ax

    mov bx, 15 ; pedir 15 estudiantes

ingresar_datos:
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

    ;Mostar mensaje de formato
    mov ah, 09h
    lea dx, msg_formato
    int 21h

    ;Mostrar mensaje para ingresar datos
    mov ah, 09h
    lea dx, msg_ingresar
    int 21h

    ;Pedir datos
    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; Separar y guardar datos
    call separar_datos

    ;Incrementar contador
    inc contador

    ;Nueva linea
    mov ah, 09h
    lea dx, nueva_linea
    int 21h

    ;Loop principal
    dec bx
    jnz ingresar_datos

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

;Procedimiento para separar los datos
separar_datos proc
    push ax
    push bx
    push cx
    push si
    push di

    lea si, buffer + 2 ; SI apunta al inicio de los datos

    ; 1. Extraer nombre hasta la primer coma
    lea di, nombres
    mov al, contador
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    ; 2. Extraer Apellido 1
    lea di, apellidos1
    mov al, contador
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    ; 3.Extraer Apellidos 2
    lea di, apellidos2
    mov al, contador
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    ; 4.Extraer Nota
    lea di, notas
    mov al, contador
    mov bl, 3
    mul bl
    add di, ax
    call extraer_campo

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
separar_datos endp

; Proceso para extraer campo
extraer_campo proc
    push ax
    push cx
    push si
    push di

    mov cx, 0 ;contador de caracteres

extraer_caracter:
    mov al, [si]
    cmp al, ',' ; es coma?
    je fin_campo
    cmp al, 13 ; es enter?
    je fin_campo
    cmp al, '$'
    je fin_campo

    mov [di], al ;copiar caracter
    inc si
    inc di
    inc cx
    jmp extraer_caracter

fin_campo:
    inc si ;saltar la coma
    pop di
    pop si
    pop cx
    pop ax
    ret
extraer_campo endp

;Procedimiento para mostrar numero
mostrar_numero proc
    push ax
    push bx
    push dx
    
    mov bl, contador
    add bl, 1     ; numero actual (1-15)
    
    ; Para números de un dígito
    cmp bl, 10
    jb un_digito
    
    ; Para números de dos dígitos - método directo
    cmp bl, 10
    je mostrar_10
    cmp bl, 11
    je mostrar_11
    cmp bl, 12
    je mostrar_12
    cmp bl, 13
    je mostrar_13
    cmp bl, 14
    je mostrar_14
    cmp bl, 15
    je mostrar_15
    
un_digito:
    mov dl, bl
    add dl, 30h
    mov ah, 02h
    int 21h
    jmp fin_mostrar

mostrar_10:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '0'
    int 21h
    jmp fin_mostrar

mostrar_11:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '1'
    int 21h
    jmp fin_mostrar

mostrar_12:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '2'
    int 21h
    jmp fin_mostrar

mostrar_13:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '3'
    int 21h
    jmp fin_mostrar

mostrar_14:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '4'
    int 21h
    jmp fin_mostrar

mostrar_15:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '5'
    int 21h

fin_mostrar:
    pop dx
    pop bx
    pop ax
    ret
mostrar_numero endp

end main
     