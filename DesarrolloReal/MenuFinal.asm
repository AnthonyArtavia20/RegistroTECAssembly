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
    estudiante_size equ 62  ; 20(nom) + 20(ape1) + 20(ape2) + 1(nota_ent) + 1(nota_dec)
    estudiantes db 15 * estudiante_size dup('$') 
    
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
            db 'precione ESC para volver a menu$',13,10

    ; Para opción 4 - ordenar
    Ordenar db 'Ordenar notas, Como desea ordenarlas?',13,10,
            db 'Precione (1) Ascendente',13,10,
            db '         (2) Descendente ',13,10,13,10,
            db 'precione ESC para volver a menu$',13,10,'$'

.code
main proc
    mov ax, @data 
    mov ds, ax
    mov es, ax

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

    mov byte ptr buffer+1, 0
    mov byte ptr buffer+2, 0

    mov cx, 50
    lea di, buffer+2
    mov al, '$'
    rep stosb

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
    call separar_datos_optimizado

    ; Pedir nota
    mov ah, 09h
    lea dx, msg_ingresar_nota
    int 21h

    mov byte ptr buffer+1, 0
    mov byte ptr buffer+2, 0

    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; NUEVO: Procesar nota con estructura optimizada
    call procesar_nota_optimizado

    ; Mostrar estudiante guardado
    call mostrar_estudiante_optimizado

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
    mov cl, contador
    dec cl
    jz fin_sort

CICLO_EXTERNO_ASC:
    mov si, offset estudiantes
    mov bl, cl

CICLO_INTERNO_ASC:
    push bx
    push si
    
    ; DI apunta al siguiente estudiante
    mov di, si
    add di, estudiante_size
    
    ; Comparar los dos estudiantes
    call comparar_estudiantes
    jnc NO_SWAP_ASC        ; Si CF=0, no intercambiar
    
    ; Intercambiar estudiantes
    call intercambiar_estudiantes
    
NO_SWAP_ASC:
    pop si
    pop bx
    
    add si, estudiante_size    ; Siguiente estudiante
    dec bl
    jnz CICLO_INTERNO_ASC

    dec cl
    jnz CICLO_EXTERNO_ASC

fin_sort:
    jmp mostrar_notas_ordenadas

intercambiar_estudiantes proc
    push ax 
    push bx 
    push cx 
    push dx 
    push si 
    push di
    
    ; Intercambiar los 62 bytes completos
    mov cx, estudiante_size
intercambio_loop:
    mov al, [si]
    mov dl, [di]
    mov [si], dl
    mov [di], al
    inc si
    inc di
    loop intercambio_loop
    
    pop di 
    pop si 
    pop dx 
    pop cx 
    pop bx 
    pop ax
    ret
intercambiar_estudiantes endp

comparar_estudiantes proc
    push ax
    push dx
    
    ; Comparar parte entera primero
    mov al, [si + 60]      ; Nota entera estudiante 1
    mov dl, [di + 60]      ; Nota entera estudiante 2
    cmp al, dl
    jg mayor
    jl menor
    
    ; Si partes enteras son iguales, comparar decimales
    mov al, [si + 61]      ; Nota decimal estudiante 1
    mov dl, [di + 61]      ; Nota decimal estudiante 2
    cmp al, dl
    jg mayor
    jl menor
    
    ; Son iguales
    clc                    ; CF = 0, no intercambiar
    jmp fin_comparar
    
mayor:
    stc                    ; CF = 1, intercambiar
    jmp fin_comparar
    
menor:
    clc                    ; CF = 0, no intercambiar

fin_comparar:
    pop dx
    pop ax
    ret
comparar_estudiantes endp

BubbleDescendente:
    mov cl, contador
    dec cl
    jz fin_sortDescen

CICLO_EXTERNO_DESC:
    mov si, offset estudiantes
    mov bl, cl

CICLO_INTERNO_DESC:
    push bx
    push si
    
    ; DI apunta al siguiente estudiante
    mov di, si
    add di, estudiante_size
    
    ; Comparar los dos estudiantes (orden inverso para descendente)
    call comparar_estudiantes
    jc NO_SWAP_DESC        ; Si CF=1, no intercambiar (para descendente)
    
    ; Intercambiar estudiantes
    call intercambiar_estudiantes
    
NO_SWAP_DESC:
    pop si
    pop bx
    
    add si, estudiante_size    ; Siguiente estudiante
    dec bl
    jnz CICLO_INTERNO_DESC

    dec cl
    jnz CICLO_EXTERNO_DESC
    
fin_sortDescen:
    jmp mostrar_notas_ordenadas

mostrar_notas_ordenadas:
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h

    mov cl, contador
    jcxz fin_impresion

    mov si, offset estudiantes

imprimir_notas_loop:
    ; Imprimir parte entera (offset 60)
    mov al, [si + 60]
    call print_decimal
    
    ; Imprimir punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Imprimir parte decimal (offset 61)
    mov al, [si + 61]
    call mostrar_decimal

    ; Espacio entre notas
    mov dl, ' '
    mov ah, 02h
    int 21h

    add si, estudiante_size    ; Siguiente estudiante
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


separar_datos_optimizado proc
    push ax 
    push bx 
    push cx 
    push si 
    push di
    
    ; Calcular offset base UNA sola vez
    mov bx, offset estudiantes
    mov al, contador
    mov cl, estudiante_size
    mul cl
    add bx, ax              ; BX = inicio del registro actual
    
    lea si, buffer + 2      ; SI apunta a los datos de entrada
    
    ; Limpiar el registro actual
    mov di, bx
    mov cx, estudiante_size
    mov al, '$'
    rep stosb
    
    ; Procesar NOMBRE (primeros 20 bytes)
    mov di, bx
    call copiar_campo
    
    ; Procesar APELLIDO1 (siguientes 20 bytes)
    mov di, bx
    add di, 20
    call copiar_campo
    
    ; Procesar APELLIDO2 (siguientes 20 bytes)
    mov di, bx
    add di, 40
    call copiar_campo
    
    pop di 
    pop si 
    pop cx 
    pop bx 
    pop ax
    ret

copiar_campo:
    push cx
    mov cx, 19              ; máximo 19 caracteres por campo
copiar_loop:
    mov al, [si]
    cmp al, ' '             ; fin por espacio
    je fin_campo
    cmp al, 13              ; fin por enter
    je fin_campo
    cmp al, '$'             ; fin por terminador
    je fin_campo
    
    mov [di], al            ; COPIAR carácter
    inc si
    inc di
    loop copiar_loop
    
fin_campo:
    mov byte ptr [di], '$'  ; terminar cadena
    cmp byte ptr [si], ' '  ; si hay espacio, saltarlo
    jne no_saltar
    inc si
no_saltar:
    pop cx
    ret
separar_datos_optimizado endp

procesar_nota_optimizado proc
    push ax 
    push bx 
    push cx 
    push dx 
    push si 
    push di
    
    ; Calcular offset al campo de nota
    mov bx, offset estudiantes
    mov al, contador
    mov cl, estudiante_size
    mul cl
    add bx, ax
    add bx, 60              ; BX apunta a nota_entera (offset 60)
    
    lea si, buffer + 2
    xor dx, dx              ; DX = 0 (parte entera), 1 (decimal)
    xor ax, ax              ; AX = valor acumulado
    
convertir_loop:
    mov cl, [si]
    cmp cl, '.'             ; ¿es punto decimal?
    je punto_decimal
    cmp cl, 13              ; ¿es enter?
    je fin_conversion
    cmp cl, ' '             ; ¿es espacio?
    je fin_conversion
    cmp cl, '$'             ; ¿es terminador?
    je fin_conversion
    
    sub cl, '0'             ; convertir a número
    mov ch, 0
    
    cmp dx, 0
    jne es_decimal
    
    ; Parte entera: acumular * 10 + dígito
    mov dx, 10
    mul dx
    add ax, cx
    jmp siguiente_digito
    
es_decimal:
    ; Para decimales, manejamos diferente
    mov [bx + 1], cl        ; guardar decimal directamente
    jmp siguiente_digito
    
punto_decimal:
    mov dx, 1               ; activar modo decimal
    mov [bx], al            ; guardar parte entera
    xor ax, ax              ; resetear acumulador
    
siguiente_digito:
    inc si
    jmp convertir_loop
    
fin_conversion:
    cmp dx, 0
    jne ya_guardado
    mov [bx], al            ; guardar parte entera si no había decimal
    
ya_guardado:
    pop di 
    pop si 
    pop dx 
    pop cx 
    pop bx 
    pop ax
    ret
procesar_nota_optimizado endp

mostrar_estudiante_optimizado proc
    push ax 
    push bx 
    push cx 
    push dx 
    push si 
    push di
    
    ; Calcular offset
    mov bx, offset estudiantes
    mov al, contador
    mov cl, estudiante_size
    mul cl
    add bx, ax
    
    ; Mostrar mensaje
    mov ah, 09h
    lea dx, msg_guardado
    int 21h
    
    ; Mostrar nombre
    mov dx, bx
    mov ah, 09h
    int 21h
    
    ; Espacio
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Mostrar apellido1
    mov dx, bx
    add dx, 20
    mov ah, 09h
    int 21h
    
    ; Espacio
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Mostrar apellido2
    mov dx, bx
    add dx, 40
    mov ah, 09h
    int 21h
    
    ; Mostrar nota
    mov ah, 09h
    lea dx, msg_con_nota
    int 21h
    
    ; Parte entera
    mov al, [bx + 60]
    call print_decimal
    
    ; Punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Parte decimal
    mov al, [bx + 61]
    call mostrar_decimal
    
    ; Nueva línea
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
mostrar_estudiante_optimizado endp

; Procedimiento para mostrar número
mostrar_numero proc
    push ax
    push bx
    push dx
    
    mov al, contador
    inc al                 ; al = número actual (1-15)
    
    ; Solución fuerza bruta - usar una tabla de búsqueda
    cmp al, 1
    je mostrar_1
    cmp al, 2
    je mostrar_2
    cmp al, 3
    je mostrar_3
    cmp al, 4
    je mostrar_4
    cmp al, 5
    je mostrar_5
    cmp al, 6
    je mostrar_6
    cmp al, 7
    je mostrar_7
    cmp al, 8
    je mostrar_8
    cmp al, 9
    je mostrar_9
    cmp al, 10
    je mostrar_10
    cmp al, 11
    je mostrar_11
    cmp al, 12
    je mostrar_12
    cmp al, 13
    je mostrar_13
    cmp al, 14
    je mostrar_14
    cmp al, 15
    je mostrar_15

mostrar_1:
    mov dl, '1'
    jmp mostrar_digito

mostrar_2:
    mov dl, '2'
    jmp mostrar_digito

mostrar_3:
    mov dl, '3'
    jmp mostrar_digito

mostrar_4:
    mov dl, '4'
    jmp mostrar_digito

mostrar_5:
    mov dl, '5'
    jmp mostrar_digito

mostrar_6:
    mov dl, '6'
    jmp mostrar_digito

mostrar_7:
    mov dl, '7'
    jmp mostrar_digito

mostrar_8:
    mov dl, '8'
    jmp mostrar_digito

mostrar_9:
    mov dl, '9'
    jmp mostrar_digito

mostrar_10:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '0'
    jmp mostrar_digito

mostrar_11:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '1'
    jmp mostrar_digito

mostrar_12:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '2'
    jmp mostrar_digito

mostrar_13:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '3'
    jmp mostrar_digito

mostrar_14:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '4'
    jmp mostrar_digito

mostrar_15:
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '5'

mostrar_digito:
    mov ah, 02h
    int 21h

fin_mostrar_numero:
    pop dx
    pop bx
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
    
    ; Set up pointer to estudiantes array
    mov si, offset estudiantes
    mov cl, contador
    mov ch, 0
    jcxz fin_calculo           ; Salir si no hay estudiantes
    
calcular_loop:
    ; Obtener nota entera (offset 60)
    mov al, [si + 60]
    mov ah, 0
    add suma_entera, ax
    
    ; Obtener nota decimal (offset 61)  
    mov al, [si + 61]
    mov ah, 0
    add suma_decimal, ax
    
    ; Check for carry-over from decimal part
    cmp suma_decimal, 100
    jb no_carry
    sub suma_decimal, 100
    inc suma_entera
    
no_carry:
    ; Check if student passed (nota >= 70)
    mov al, [si + 60]          ; Parte entera
    cmp al, 70
    jb estudiante_reprobado
    
    ; If integer part is exactly 70, check decimal part
    jne estudiante_aprobado
    mov al, [si + 61]          ; Parte decimal
    cmp al, 0
    je estudiante_aprobado

estudiante_aprobado:
    inc aprobados
    jmp check_max_min
    
estudiante_reprobado:
    inc reprobados
    
check_max_min:
    ; Check for maximum grade
    mov al, [si + 60]
    cmp al, maxima_entera
    jb check_minima
    ja new_maxima
    mov al, [si + 61]
    cmp al, maxima_decimal
    jbe check_minima
    
new_maxima:
    mov al, [si + 60]
    mov maxima_entera, al
    mov al, [si + 61]
    mov maxima_decimal, al
    
check_minima:
    ; Check for minimum grade
    mov al, [si + 60]
    cmp al, minima_entera
    ja next_student
    jb new_minima
    mov al, [si + 61]
    cmp al, minima_decimal
    jae next_student
    
new_minima:
    mov al, [si + 60]
    mov minima_entera, al
    mov al, [si + 61]
    mov minima_decimal, al
    
next_student:
    add si, estudiante_size    ; Avanzar al siguiente estudiante
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
    
fin_calculo:                   ; ? ETIQUETA AÑADIDA
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

main endp

