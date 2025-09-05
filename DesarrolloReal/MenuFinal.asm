.model small
.stack 100h

.data
    ; Mensajes del menú principal
    mostrarMenu db 'Tecnologico de Costa Rica',13,10
                    db 'Paradigmas de programacion',13,10
                    db 'Sistema de Registro de notas - RegistroCE',13,10
                    db '-.-.MENU.-.-',13,10,13,10
                    db '1. Ingresar Calificaciones',13,10
                    db '2. Mostrar estadisticas',13,10
                    db '3. Buscar estudiante por posicion(indice)',13,10 
                    db '4. Ordernar calificaciones(Desc/Asce)',13,10
                    db '5. Salir',13,10,13,10
                    db 'Seleccione una Opcion$'

    ; Mensajes para opción 1
    miNombre db 13,10,'Por favor ingrese sus estudiantes o presione ESC para volver al menu',13,10
             db 'Formato: Nombre Apellido1 Apellido2 (en una linea)',13,10
             db 'Luego ingrese la nota por separado',13,10
             db 'Ejemplo: Juan Perez Garcia',13,10
             db 'Nota: 85.50',13,10,13,10,'$'

    ; Mensajes para ingreso de datos
    msg_ingresar_nombre_completo db 13,10,'Ingrese nombre y apellidos: $'
    msg_ingresar_nota db 13,10,'Ingrese la nota (0-100): $'
    msg_contador db 13,10,13,10,'Estudiante $'
    msg_total db ' /15: $'
    msg_completado db 13,10,10, 'Se han guardado 15 estudiantes.$'
    msg_error db 13,10, 'Error: Nota debe estar entre 0 y 100',13,10,'$'
    msg_guardado db 13,10,'Guardado: $'
    msg_con_nota db ' con nota: $'
    
    ; Buffer para entrada de datos
    buffer db 50
            db ?
            db 50 dup('$')

    ; Arrays para almacenar datos
    nombres db 15 dup(20 dup('$'))
    apellidos1 db 15 dup(20 dup('$'))
    apellidos2 db 15 dup(20 dup('$'))
    notas db 15 dup(0)
    notas_decimales db 15 dup(0)
    
    ; Variables de control
    contador db 0
    nueva_linea db 13,10,'$'
    
    ; Para conversión de números
    temp_num dw 0
    temp_buffer db 6 dup('$')
        
    ; Para estadísticas
    msg_sin_datos db 13,10,'No hay datos de estudiantes. Presione cualquier tecla para continuar.$'
    msg_promedio db 13,10,'Promedio: $'
    msg_suma db 13,10,'Suma total: $'
    msg_maxima db 13,10,'Nota maxima: $'
    msg_minima db 13,10,'Nota minima: $'
    
    ; Variables para estadísticas
    suma_entera dw 0
    suma_decimal dw 0
    promedio_entera db 0
    promedio_decimal db 0
    maxima_entera db 0
    maxima_decimal db 0
    minima_entera db 100
    minima_decimal db 0   
    
    ; Para estadísticas de aprobados/reprobados
    msg_aprobados db 13,10,'Estudiantes aprobados (>=70): $'
    msg_reprobados db 13,10,'Estudiantes reprobados (<70): $'
    aprobados db 0
    reprobados db 0

    ; Para opción 2 - estadísticas
    estadisticas db 'Estadisticas generales del conjunto de estudiantes:',13,10,13,10,
            db 'precione ESC para volver a menu$'

    ; Para opción 3 - buscar
    buscar db 'Buscar estudiante por indice, Que estudiante desea mostrar? ingrese el indice(posicion)',13,10,13,10,
            db 'precione ESC para volver a menu$',13,10,'$'

    ; Para opción 4 - ordenar
    Ordenar db 'Ordenar notas, Como desea ordenarlas?',13,10,
            db 'Precione (1) Ascendente',13,10,
            db '         (2) Descendente ',13,10,13,10,
            db 'precione ESC para volver a menu$',13,10,'$'

.code
main proc
    mov ax, @data 
    mov ds, ax

Menu:
    ; Limpiar pantalla y mostrar menú
    mov ax, 0600h
    mov bh, 0fh
    mov cx, 0000h
    mov dx, 184Fh
    int 10h

    mov ah, 02h
    mov bh, 00
    mov dh, 00
    mov dl, 00
    int 10h

    mov dx, offset mostrarMenu
    mov ah, 09
    int 21h

    mov ah, 08
    int 21h

    cmp al, '1'
    je op1
    cmp al, '2'
    je op2
    cmp al, '3'
    je op3
    cmp al, '4'
    je op4
    cmp al, '5'
    je op5
    jmp Menu

op1:
    ; Limpiar pantalla
    mov ax, 0600h
    mov bh, 0fh
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    
    mov ah, 02h
    mov bh, 00
    mov dh, 00
    mov dl, 00
    int 10h
    
    mov dx, offset miNombre
    mov ah, 09
    int 21h

    mov bx, 15
ingresar_dato_op1Loop:
    ; Mostrar contador
    mov ah, 09h
    lea dx, msg_contador
    int 21h

    call mostrar_numero

    mov ah, 09h
    lea dx, msg_total
    int 21h

    ; Pedir nombre completo (nombre + apellidos)
    mov ah, 09h
    lea dx, msg_ingresar_nombre_completo
    int 21h

    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; Verificar si se presionó ESC
    mov al, [buffer+2]
    cmp al, 27
    je Menu

    ; Procesar nombre completo
    call separar_nombre_apellidos

    ; Pedir nota
    mov ah, 09h
    lea dx, msg_ingresar_nota
    int 21h

    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; Procesar nota
    call procesar_nota

    ; Mostrar lo que se guardó
    call mostrar_estudiante_guardado

    ; Incrementar contador
    inc contador

    mov ah, 09h
    lea dx, nueva_linea
    int 21h

    ; Loop principal
    dec bx
    jnz ingresar_dato_op1Loop

    mov ah, 09h
    lea dx, msg_completado
    int 21h

    jmp Menu

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
    
    ; Check if there are any students
    mov al, contador
    cmp al, 0
    je no_data_op2
    
    ; Calculate statistics
    call calcular_estadisticas
    
    jmp wait_esc_op2
    
no_data_op2:
    mov dx, offset msg_sin_datos
    mov ah, 09h
    int 21h
    
wait_esc_op2:
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27 ;ASCII 27 = ESC
    je Menu
    jmp wait_esc_op2

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
    jmp op3

op4:
    mov ah,0
    mov al,3h ;Modo texto
    int 10h

    mov ax,0600h
    mov bh, 1eh
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

    ; Verificar si contador == 0
    mov al, contador
    cmp al, 0
    je Menu

    ; Determinar orden
elegir_orden:
    mov ah, 08h
    int 21h
    cmp al, 27
    je Menu  
    cmp al, '1'
    je BubbleAscendente
    cmp al, '2'
    je BubbleDescendente
    jmp elegir_orden

BubbleAscendente:
    ; Configurar segmentos
    PUSH DS
    MOV AX, @data
    MOV DS, AX
    MOV ES, AX

    ; Ciclo externo
    mov cl, contador
    dec cl
    jz fin_sort

CICLO_EXTERNO:
    lea si, notas
    lea di, notas_decimales
    mov ch, 0
    mov bl, cl

CICLO_INTERNO:
    push bx
    push si
    push di
    
    mov al, [si]
    mov dl, [si+1]
    
    cmp al, dl
    JBE NO_SWAP
    
    mov [si], dl
    mov [si+1], al
    
    mov al, [di]
    mov dl, [di+1]
    mov [di], dl
    mov [di+1], al
    
NO_SWAP:
    pop di
    pop si
    pop bx
    
    inc si
    inc di
    dec bl
    jnz CICLO_INTERNO

    dec cl
    jnz CICLO_EXTERNO

fin_sort:
    jmp mostrar_notas_ordenadas

BubbleDescendente:
    ; Configurar segmentos
    PUSH DS
    MOV AX, @data
    MOV DS, AX
    MOV ES, AX

    ; Ciclo externo
    mov cl, contador
    dec cl
    jz fin_sortDescen

CICLO_EXTERNODescen:
    lea si, notas
    lea di, notas_decimales
    mov ch, 0
    mov bl, cl

CICLO_INTERNODescen:
    push bx
    push si
    push di
    
    mov al, [si]
    mov dl, [si+1]
    
    cmp al, dl
    JAE NO_SWAPDescen
    
    mov [si], dl
    mov [si+1], al
    
    mov al, [di]
    mov dl, [di+1]
    mov [di], dl
    mov [di+1], al
    
NO_SWAPDescen:
    pop di
    pop si
    pop bx
    
    inc si
    inc di
    dec bl
    jnz CICLO_INTERNODescen

    dec cl
    jnz CICLO_EXTERNODescen
    
fin_sortDescen:
    jmp mostrar_notas_ordenadas

mostrar_notas_ordenadas:
    ; Salto de línea
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h

    mov cl, contador
    jcxz fin_impresion

    mov si, offset notas
    mov di, offset notas_decimales

imprimir_notas_loop:
    ; Imprimir parte entera
    mov al, [si]
    call print_decimal
    
    ; Imprimir punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Imprimir parte decimal
    mov al, [di]
    call mostrar_decimal

    ; Espacio entre notas
    mov dl, ' '
    mov ah, 02h
    int 21h

    inc si
    inc di
    loop imprimir_notas_loop

fin_impresion:
    ; Salto de línea final
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h

    ; Esperar tecla
    mov ah,08h
    int 21h
    cmp al,27
    je Menu
    jmp Menu

op5:
    mov ax,4c00h
    int 21h

main endp

; NUEVO PROCEDIMIENTO: Mostrar estudiante guardado
mostrar_estudiante_guardado proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Mostrar mensaje "Guardado: "
    mov ah, 09h
    lea dx, msg_guardado
    int 21h
    
    ; Mostrar nombre
    lea si, nombres
    mov al, contador
    mov bl, 20
    mul bl
    add si, ax
    mov dx, si
    mov ah, 09h
    int 21h
    
    ; Mostrar espacio
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Mostrar primer apellido
    lea si, apellidos1
    mov al, contador
    mov bl, 20
    mul bl
    add si, ax
    mov dx, si
    mov ah, 09h
    int 21h
    
    ; Mostrar espacio
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Mostrar segundo apellido
    lea si, apellidos2
    mov al, contador
    mov bl, 20
    mul bl
    add si, ax
    mov dx, si
    mov ah, 09h
    int 21h
    
    ; Mostrar " con nota: "
    mov ah, 09h
    lea dx, msg_con_nota
    int 21h
    
    ; Mostrar parte entera de la nota
    lea si, notas
    mov al, contador
    xor ah, ah
    add si, ax
    mov al, [si]
    call print_decimal
    
    ; Mostrar punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar parte decimal de la nota
    lea si, notas_decimales
    mov al, contador
    xor ah, ah
    add si, ax
    mov al, [si]
    call mostrar_decimal
    
    ; Salto de línea
    mov ah, 09h
    lea dx, nueva_linea
    int 21h
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_estudiante_guardado endp

; Procedimiento para separar nombre y apellidos
; Procedimiento para separar nombre y apellidos - CORREGIDO
separar_nombre_apellidos proc
    push ax
    push bx
    push cx
    push si
    push di

    lea si, buffer + 2

    ; 1. Extraer nombre (primer campo)
    lea di, nombres
    mov al, contador
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    ; 2. Extraer primer apellido (segundo campo)
    lea di, apellidos1
    mov al, contador
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    ; 3. Extraer segundo apellido (tercer campo)
    lea di, apellidos2
    mov al, contador
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
separar_nombre_apellidos endp

; Procedimiento para extraer campo individual - CORREGIDO
extraer_campo proc
    push ax
    push cx
    push si
    push di

    mov cx, 0

extraer_caracter:
    mov al, [si]
    cmp al, ' '          ; espacio = fin de campo
    je fin_campo
    cmp al, 13           ; enter = fin de cadena
    je fin_campo
    cmp al, '$'          ; fin de cadena
    je fin_campo
    cmp al, 0            ; null character
    je fin_campo

    mov [di], al         ; copiar caracter al destino
    inc si
    inc di
    inc cx
    jmp extraer_caracter

fin_campo:
    ; AGREGAR TERMINADOR DE CADENA AL FINAL
    mov byte ptr [di], '$'
    
    ; Avanzar SI solo si no hemos llegado al final
    cmp byte ptr [si], ' '
    jne no_mas_espacios
    inc si               ; saltar el espacio para el próximo campo
    
no_mas_espacios:
    pop di
    pop si
    pop cx
    pop ax
    ret
extraer_campo endp

; Procedimiento para procesar nota
procesar_nota proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    lea si, buffer + 2

    ; Convertir nota a número
    xor bx, bx           ; bx = parte entera
    xor cx, cx           ; cx = parte decimal
    mov dx, 0            ; dx = bandera (0=entera, 1=decimal)

convertir_nota:
    mov al, [si]
    cmp al, '.'
    je encontro_punto
    cmp al, 13
    je fin_conversion_nota
    cmp al, ' '
    je fin_conversion_nota
    cmp al, '$'
    je fin_conversion_nota
    
    sub al, '0'
    mov ah, 0
    
    cmp dx, 0
    jne procesar_decimal_nota

procesar_entera_nota:
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    mov al, [si]
    sub al, '0'
    mov ah, 0
    add bx, ax
    mov dx, 0
    jmp continuar_nota

procesar_decimal_nota:
    mov ax, cx
    mov dx, 10
    mul dx
    mov cx, ax
    mov al, [si]
    sub al, '0'
    mov ah, 0
    add cx, ax
    mov dx, 1
    jmp continuar_nota

encontro_punto:
    mov dx, 1
    jmp continuar_nota

continuar_nota:
    inc si
    jmp convertir_nota

fin_conversion_nota:
    ; Guardar parte entera
    lea di, notas
    mov al, contador
    xor ah, ah
    add di, ax
    mov [di], bl
    
    ; Guardar parte decimal
    lea di, notas_decimales
    mov al, contador
    xor ah, ah
    add di, ax
    mov [di], cl

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
procesar_nota endp

; Procedimiento para mostrar número
mostrar_numero proc
    push ax
    push dx
    
    mov al, contador
    add al, 1
    
    cmp al, 10
    jb un_digito
    
    ; Números de two dígitos
    mov dl, '1'
    mov ah, 02h
    int 21h
    sub al, 10
    add al, '0'
    mov dl, al
    int 21h
    jmp fin_mostrar_numero

un_digito:
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

fin_mostrar_numero:
    pop dx
    pop ax
    ret
mostrar_numero endp

; Procedimiento para calcular estadísticas
calcular_estadisticas proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Initialize variables
    mov suma_entera, 0
    mov suma_decimal, 0
    mov aprobados, 0
    mov reprobados, 0
    mov maxima_entera, 0
    mov maxima_decimal, 0
    mov minima_entera, 100
    mov minima_decimal, 0
    
    ; Set up pointers
    mov si, offset notas
    mov di, offset notas_decimales
    mov cl, contador
    mov ch, 0
    
calcular_loop:
    ; Add integer part to sum
    mov al, [si]
    mov ah, 0
    add suma_entera, ax
    
    ; Add decimal part to sum
    mov al, [di]
    mov ah, 0
    add suma_decimal, ax
    
    ; Check for carry-over from decimal part
    cmp suma_decimal, 100
    jb no_carry
    sub suma_decimal, 100
    inc suma_entera
    
no_carry:
    ; Check if student passed (nota >= 70)
    mov al, [si]
    cmp al, 70
    jb estudiante_reprobado
    
    ; If integer part is exactly 70, check decimal part
    jne estudiante_aprobado
    mov al, [di]
    cmp al, 0
    je estudiante_aprobado

estudiante_aprobado:
    inc aprobados
    jmp check_max_min
    
estudiante_reprobado:
    inc reprobados
    
check_max_min:
    ; Check for maximum grade
    mov al, [si]
    cmp al, maxima_entera
    jb check_minima
    ja new_maxima
    mov al, [di]
    cmp al, maxima_decimal
    jbe check_minima
    
new_maxima:
    mov al, [si]
    mov maxima_entera, al
    mov al, [di]
    mov maxima_decimal, al
    jmp check_minima
    
check_minima:
    ; Check for minimum grade
    mov al, [si]
    cmp al, minima_entera
    ja next_student
    jb new_minima
    mov al, [di]
    cmp al, minima_decimal
    jae next_student
    
new_minima:
    mov al, [si]
    mov minima_entera, al
    mov al, [di]
    mov minima_decimal, al
    
next_student:
    inc si
    inc di
    loop calcular_loop
    
    ; Calculate average
    mov ax, suma_entera
    mov bl, contador
    div bl
    mov promedio_entera, al
    
    mov ax, suma_decimal
    mov bl, contador
    div bl
    mov promedio_decimal, al
    
    ; Display results
    call mostrar_estadisticas
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
calcular_estadisticas endp

; Procedimiento para mostrar estadísticas
mostrar_estadisticas proc
    push ax
    push dx
    
    ; Show sum
    call mostrar_suma_corregida
    
    ; Show average
    mov dx, offset msg_promedio
    mov ah, 09h
    int 21h
    
    mov al, promedio_entera
    call print_decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    mov al, promedio_decimal
    call mostrar_decimal
    
    ; Show maximum grade
    mov dx, offset msg_maxima
    mov ah, 09h
    int 21h
    
    mov al, maxima_entera
    call print_decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    mov al, maxima_decimal
    call mostrar_decimal
    
    ; Show minimum grade
    mov dx, offset msg_minima
    mov ah, 09h
    int 21h
    
    mov al, minima_entera
    call print_decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    mov al, minima_decimal
    call mostrar_decimal
    
    ; Show approved students count
    mov dx, offset msg_aprobados
    mov ah, 09h
    int 21h
    
    mov al, aprobados
    call print_decimal
    
    ; Show failed students count
    mov dx, offset msg_reprobados
    mov ah, 09h
    int 21h
    
    mov al, reprobados
    call print_decimal
    
    pop dx
    pop ax
    ret
mostrar_estadisticas endp

; Procedimiento para mostrar números decimales
mostrar_decimal proc
    push ax
    push bx
    push dx
    
    xor ah, ah
    mov bl, 10
    div bl
    
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    
    pop dx
    pop bx
    pop ax
    ret
mostrar_decimal endp

; Procedimiento para mostrar suma
mostrar_suma_corregida proc
    push ax
    push bx
    push cx
    push dx
    
    mov dx, offset msg_suma
    mov ah, 09h
    int 21h
    
    mov ax, suma_entera
    call print_decimal
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    mov al, byte ptr suma_decimal
    call mostrar_decimal
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_suma_corregida endp

; Procedimiento para imprimir número decimal
print_decimal proc
    push ax
    push dx
    push cx
    
    cmp al, 100
    jne not_hundred

    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '0'
    mov ah, 02h
    int 21h
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp done

not_hundred:
    xor ah, ah
    mov bl, 10
    div bl
    
    mov cl, ah
    
    cmp al, 0
    je print_unit

    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

print_unit:
    mov dl, cl
    add dl, '0'
    mov ah, 02h
    int 21h

done:
    pop cx
    pop dx
    pop ax
    ret
print_decimal endp

end main