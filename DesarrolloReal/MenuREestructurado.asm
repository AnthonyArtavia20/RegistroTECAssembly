.model small
.stack 100h

.data
    ; aquí van TODAS las variables y mensajes (db, dw, etc.)
    mostrarMenu db 'Tecnologico de Costa Rica',13,10
                    db 'Paradigmas de programacion',13,
                    db 'Sistema de Registro de notas - RegistroCE',13,10
                    db '-.-.MENU.-.-',13,10,13,10
                    db '1. Ingresar Calificaciones',13,10
                    db '2. Mostrar estadisticas',13,10
                    db '3. Buscar estudiante por posicion(indice)',13,10 
                    db '4. Ordernar calificaciones(Desc/Asce)',13,10
                    db '5. Salir',13,10,13,10
                    db 'Seleccione una Opcion$',13,10


    ; Mensajes para usuario en el apartado dentro de opcion1
    miNombre db 'Por favor ingrese su estudiante o precione ESC para volver a menu',13,10,
                db 'formato de entrada: -Nombre Apellido1 Apellido2 Nota-',13,10,13,10,'$'

    ;logica de Alexs para el ingresado de datos ---start---
    msg_ingresar db 'ingrese datos (Formato: Nombre Apellido1 Apellido2 Nota): $'
    msg_formato db 13,10, 'Ejemplo: Juan Perez Garcia 85',13,10,'$'
    msg_contador db 13,10, 'Estudiante $'
    msg_total db ' /15: $'
    msg_completado db 13,10,10, 'Se han guardado 15 estudiantes.$'
    msg_continuar db 13,10, 'Presione cualquier tecla para continuar...$'
    msg_error db 13,10, 'Error: Use formato Nombre-Apellido1-Apellido2-Nota',13,10,'$'
    
    ; Mensajes para las validaciones
    msg_err_campos db 13,10, 'Error: Debe ingresar 4 campos (Nombre Apellido1 Apellido2 Nota).' ,13,10, '$'
    msg_err_letras db 13,10, 'Error: Nombre/Apellidos solo deben contener letras (A-Z).' ,13,10, '$'
    msg_err_nota db 13,10, 'Error: La nota debe ser numerica entre 0 y 100.' ,13,10, '$'
    msg_err_largo db 13,10, 'Error: Un campo excede el tamaño permitido.' ,13,10, '$'
    msg_err_extra db 13,10, 'Error: Hay campos de mas. Solo 4 campos son permitidos.' ,13,10, '$'

    ; Bandera general para rutinas (0 = ok /  != 0 error )
    flag_error db 0

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

    ;logica de Alexs para el ingresado de datos ---END---

    ; Para el apartado de estadisticas(opcion 2), mensajes por consola
    estadisticas db 'Estadisticas generales del conjunto de estudiantes:',13,10,13,10,
            db 'precione ESC para volver a menu$',13,10,'$'

    ; Apartado opcion 3, buscado de estudiantes por indice
    buscar db 'Buscar estudiante por indice, Que estudiante desea mostrar? ingrese el indice(posicion)',13,10,13,10,
            db 'precione ESC para volver a menu$',13,10,'$'

    ; Ordenamiento de notas, bubblesort
    Ordenar db 'Ordenar notas, Como desea ordenarlas?',13,10,
            db 'Precione (1) Ascendente',13,10,
            db '         (2) Descendente ',13,10,13,10,
            db 'precione ESC para volver a menu$',13,10,'$'
.code
    main proc
    mov ax, @data 
    mov ds, ax

Menu:
    mov ah,0
        mov al,3h ;Modo texto
        int 10h

        mov ax,0600h ;Limpiar pantalla
        mov bh,0fh; 0 Color de fondo negro, f color de letra color blanco
        mov cx,0000h
        mov dx,184Fh
        int 10h

        mov ah,02h
        mov bh,00
        mov dh,00
        mov dl,00
        int 10h

        mov dx, offset mostrarMenu ;nombre del mensaje
        mov ah,09
        int 21h

        mov ah,08 ;pausa hasta que el usuario escriba algo y captura de datos
        int 21h

        cmp al,49 ;compara con opcion 1 Ingresar calificaciones, compara en ASCII, 49 es 1
        je op1  ; salto condicional, salta .

        cmp al,50 ;compara con opcion 2 mostrar estadisticas
        je op2

        cmp al,51 ;compara con opcion 3 buscar estudiante por indice
        je op3

        cmp al,52 ;compara con opcion 4 ordenar calificaciones(desc/asce)
        je op4

        cmp al,53 ;compara con opcion 5 salir
        je op5

op1:
    mov ax,0600h ;limpiar pantalla
    mov bh,0fh ;0 color de fondo negro, f color de letra blanco
    mov cx,0000h
    mov dx, 184Fh
    int 10h
    
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h
    
    mov dx, offset miNombre
    mov ah,09
    int 21h

    ;Codigo de Alex de ingresado y guardado de datos:
    mov bx, 15 ; pedir 15 estudiantes
    ingresar_dato_op1Loop:
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
        mov ah, 0Ah ;pausa y captura de datos
        lea dx, buffer
        int 21h
        
        ; --- limpiar el ENTER (0Dh) que el usuario implicitamente escribe al ingresar el nombre---
        mov si, offset buffer
        mov cl, [si+1]              ; longitud real

        cmp cl, 0
        je volver_menu_op1

        xor ch, ch

        mov byte ptr [si+2+cx], '$' ; sustituir el Enter por fin de cadena

       ;ESC permitico con o sin espacios iniciales
       lea si, buffer+2
       call saltar_espacios
       mov al, [si]
       cmp al, 27
       je volver_menu_op1

       ; Validar y guardar
       call validar_y_guardar
       cmp flag_error, 0
       jne entrada_invalida

       ; Si todo esta bien, avanzamos con el siguiente estudiante
       inc contador        

        ;Nueva linea
        mov ah, 09h
        lea dx, nueva_linea
        int 21h

        ;Loop principal
        dec bx
        jnz ingresar_dato_op1Loop
        jmp fin_captura_op1

    entrada_invalida:
        ;Mostrar "Presoine cualquier tecla..." y reintentar mismo indiceestudiante

        ;Esperar tecla para continuar
        mov ah, 09h
        lea dx, msg_continuar
        int 21h
        mov ah, 01h
        int 21h

        ;Nueva linea
        mov ah, 09h
        lea dx, nueva_linea
        int 21h

        jmp ingresar_dato_op1Loop

    volver_menu_op1:
     jmp Menu

    fin_captura_op1:
        ;Mostrar mensaje de completado
        mov ah, 09h
        lea dx, msg_completado
        int 21h


    cmp al,27 ;ASCII 27 = ESC
    je Menu

    jmp Menu ;Furza el regreso al menú siempre

op2:
    mov ax,0600h ;limpiar pantalla
    mov bh, 1eh ;1 fondo azul, e color de letra amarilla
    mov cx,0000h
    mov dx,184Fh
    int 10h
    
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h
    
    mov dx, offset estadisticas
    mov ah,09
    int 21h
    
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27 ;ASCII 27 = ESC
    je Menu

    jmp Menu

op3: 
    
    mov ax,0600h ;limpiar pantalla
    mov bh, 1eh ;1 fondo azul, e color de letra amarilla
    mov cx,0000h
    mov dx,184Fh
    int 10h
    
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h
    
    mov dx, offset buscar
    mov ah,09
    int 21h
    
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27 ;ASCII 27 = ESC
    je Menu

    jmp Menu

op4:
    mov ax,0600h ;limpiar pantalla
    mov bh, 1eh ;1 fondo azul, e color de letra amarilla
    mov cx,0000h
    mov dx,184Fh
    int 10h
    
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h
    
    mov dx, offset Ordenar
    mov ah,09
    int 21h
    
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27 ;ASCII 27 = ESC
    je Menu

    jmp Menu
    
op5: ;salida
    mov ax,4c00h
    int 21h

    main endp ; Con este cierra el procedimiento(funcion) principal, o loop principal.

;Apartir de aca se ponen los procedimientos auxiliares o funciones auxiliares.

saltar_espacios proc
    push ax

saltar_espacios_loop:
    mov al, [si]
    cmp al, ' '
    jne saltar_espacios_salir
    inc si
    jmp saltar_espacios_loop

saltar_espacios_salir:
    pop ax
    ret

saltar_espacios endp

checar_letra proc ;Revisamos si el caracter es A/Z o minus
    push ax
    mov ah, al
    ; 'A'..'Z'
    cmp al, 'A'
    jb no_mayus
    cmp al, 'Z'
    jbe checar_letra_true

no_mayus:
    mov al, ah
    cmp al, 'a'
    jb checar_letra_false
    cmp al, 'z'
    jbe checar_letra_true

checar_letra_false:
    mov al, 1
    pop ax
    ret

checar_letra_true:
    mov al, ah
    cmp al, al ;Comparamos a AL consigo mismo
    pop ax
    ret

checar_letra endp

imprimir_mensaje proc near
    mov ah, 09h
    int 21h
    ret
imprimir_mensaje endp

agregar_dolar proc ; Rellena hasta longitud fija con '$'
    push ax

    agregar_dolar_loop:
    cmp cx, 0
    je agregar_dolar_salir
    mov byte ptr [di], '$'
    inc di
    dec cx
    jmp agregar_dolar_loop

agregar_dolar_salir:
    pop ax
    ret

agregar_dolar endp

; Convierte AX a ASCII EN DI, max 3 chars, rellena con '$' si sobra 

cambio_de_nota_a_ascii proc
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx

    cmp ax, 0
    jne CNAA_no_es_cero
    mov byte ptr [di], '0'
    inc di
    mov cx, 1
    jmp CNAA_nota_checada

    CNAA_no_es_cero:

    CNAA_loop_division:
        xor dx, dx
        div bx
        push dx
        inc cx
        cmp ax, 0
        jne CNAA_loop_division
        ;volcar en orden

    CNAA_pop_loop:
        pop dx
        add dl, '0'
        mov [di], dl
        inc di
        loop CNAA_pop_loop

    CNAA_nota_checada:
     ; Rellenamos con '$' hasta 3
     mov bx, 3
     sub bx, cx
     mov cx, bx

    CNAA_pad:
    cmp cx, 0
    je CNAA_salir
    mov byte ptr [di], '$'
    inc di
    dec cx
    jmp CNAA_pad

    CNAA_salir:
        pop dx
        pop cx
        pop bx
        pop ax
        ret

cambio_de_nota_a_ascii endp

;Comprobamos palabras

leer_palabra_validada proc
    push ax
    push bx
    push cx
    push di

    mov flag_error, 0
    call saltar_espacios

    xor cx, cx ;longitud

leer_palabra_validada_loop:
    mov al, [si]
    cmp al, ' '
    je leer_palabra_validada_fin
    cmp al, 13
    je leer_palabra_validada_fin
    cmp al, '$'
    je leer_palabra_validada_fin

    ; Validamos la letra
    push ax
    call checar_letra
    jz leer_palabra_validada_okchar

    ; no es letra
    lea dx, msg_err_letras
    call imprimir_mensaje
    mov flag_error, 1
    pop ax
    jmp leer_palabra_validada_error

leer_palabra_validada_okchar:
    pop ax

    ;Longitud max
    cmp cx, bx
    jb leer_palabra_validada_guardada

    ;excede
    lea dx, msg_err_largo
    call imprimir_mensaje
    mov flag_error, 1
    jmp leer_palabra_validada_error

leer_palabra_validada_guardada:
    mov [di], al
    inc di
    inc si
    inc cx
    jmp leer_palabra_validada_loop

leer_palabra_validada_fin:
    ; No vacio?
    cmp cx, 0
    jne leer_palabra_validada_pad
    lea dx, msg_err_campos
    call imprimir_mensaje
    mov flag_error, 1
    jmp leer_palabra_validada_error


leer_palabra_validada_pad:
    ;Rellnamos con '$' hasta BL
    mov ax, bx
    sub ax, cx
    mov cx, ax
    call agregar_dolar

leer_palabra_validada_salir:
    pop di
    pop cx
    pop bx
    pop ax
    ret

leer_palabra_validada_error:
    ;Saltar restos hasta espacio o fin para no trabajarse
    mov al, [si]
    cmp al, ' '
    je leer_palabra_validada_salir
    cmp al, 13
    je leer_palabra_validada_salir
    cmp al, '$'
    je leer_palabra_validada_salir
    inc si
    jmp leer_palabra_validada_error

leer_palabra_validada endp

leer_nota_validada proc
    push ax
    push bx
    push cx
    push di

    mov flag_error, 0
    call saltar_espacios

    xor cx, cx
    xor ax, ax

leer_nota_validada_loop:
    mov bl, [si]
    cmp bl, '0'
    jb leer_nota_validada_fin
    cmp bl, '9'
    ja leer_nota_validada_fin

    ;es digito
    cmp cx, 3
    jb leer_nota_validada_accum

    ;demasiados digitos
    lea dx, msg_err_nota
    call imprimir_mensaje
    mov flag_error, 1
    jmp leer_nota_validada_error

leer_nota_validada_accum:
    ; valor = valor*10 + (bl- '0')
    mov bx, 10
    mul bx
    mov dl, [si]
    sub dl, '0'
    xor dh, dh
    add ax, dx

    inc si
    inc cx
    jmp leer_nota_validada_loop

leer_nota_validada_fin:
    ; no se leyo ningun dato?
    cmp cx, 0
    jne leer_nota_validada_rango
    lea dx, msg_err_nota
    call imprimir_mensaje
    mov flag_error, 1
    jmp leer_nota_validada_error

leer_nota_validada_rango:
    cmp ax, 100
    jbe leer_nota_validada_escribir
    lea dx, msg_err_nota
    call imprimir_mensaje
    mov flag_error, 1
    jmp leer_nota_validada_error

leer_nota_validada_escribir:
    ;AX a ascii en DI + padding '$'
    call cambio_de_nota_a_ascii
    jmp leer_nota_validada_salir

leer_nota_validada_error:
    ;limpiar destino
    mov cx, 3
    call agregar_dolar

leer_nota_validada_salir:
    pop di
    pop cx
    pop bx
    pop ax
    ret

leer_nota_validada endp

;Guardado de datos con validacion

validar_y_guardar proc
    push ax
    push bx
    push si
    push di

    mov flag_error, 0

    ; 1) Nombre 
    lea di, nombres
    mov al, contador
    mov bl, 20  
    mul bl
    add di, ax
    mov bx, 20
    call leer_palabra_validada
    cmp flag_error, 0
    jne validar_y_guardar_fallo

    ; 2) Apellido1
    lea di, apellidos1
    mov al, contador
    mov bl, 20
    mul bl
    add di, ax
    mov bx, 20
    call leer_palabra_validada
    cmp flag_error, 0
    jne validar_y_guardar_fallo

    ; 3) Apellido2
    lea di, apellidos2
    mov al, contador
    mov bl, 20
    mul bl
    add di, ax
    mov bx, 20
    call leer_palabra_validada
    cmp flag_error, 0
    jne validar_y_guardar_fallo

    ; 4) Nota
    lea di, notas
    mov al, contador
    mov bl, 3
    mul bl
    add di, ax
    mov bx, 3
    call leer_nota_validada
    cmp flag_error, 0
    jne validar_y_guardar_fallo

    ;Verificar que no haya campos extra
    call saltar_espacios
    mov al, [si]
    cmp al, 13
    je validar_y_guardar_ok
    cmp al, '$'
    je validar_y_guardar_ok

    ;hay mas texto? = error
    lea dx, msg_err_extra
    call imprimir_mensaje
    mov flag_error, 1
    jmp validar_y_guardar_fallo

    validar_y_guardar_ok:
    ;todo ok
    pop di
    pop si
    pop bx
    pop ax
    ret

    validar_y_guardar_fallo:
    ;Si falto algo por si acaso
    pop di
    pop si
    pop bx
    pop ax
    ret

validar_y_guardar endp

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
;#######################################################################################################################
; Cuenta tokens (palabras separadas por espacios) hasta 13 o '$'
; ENTRADA: SI = puntero a inicio del texto (buffer+2)
; SALIDA:  AL = cantidad de tokens (0..n), SI queda al final del scan
contar_campos proc
    push cx
    push dx

    xor al, al                ; contador = 0
    call saltar_espacios

cc_loop:
    mov dl, [si]
    cmp dl, '$'
    je  cc_ret
    cmp dl, 13
    je  cc_ret
    ; estamos al inicio de un token
    inc al
    ; saltar token hasta espacio/fin
cc_tok:
    mov dl, [si]
    cmp dl, ' '
    je  cc_skip
    cmp dl, 13
    je  cc_ret
    cmp dl, '$'
    je  cc_ret
    inc si
    jmp cc_tok

cc_skip:
    call saltar_espacios
    jmp cc_loop

cc_ret:
    pop dx
    pop cx
    ret
contar_campos endp


end main ; Indica al ensamblador donde arrancar a ejecutar procedimientos(funciones)