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
             db 'Nota: 85.50000',13,10,13,10,'$'

    ; Mensajes para ingreso de datos
    msg_ingresar_nombre_completo db 13,10,'Ingrese nombre y apellidos: $'
    msg_ingresar_nota db 13,10,'Ingrese la nota (0-100): $'
    msg_contador db 13,10,13,10,'Estudiante $'
    msg_total db ' /15: $'
    msg_completado db 13,10,10, 'Se han guardado 15 estudiantes.$'
    msg_error db 13,10, 'Error: Nota debe estar entre 0 y 100',13,10,'$'
    msg_guardado db 13,10,'Guardado: $'
    msg_con_nota db ' con nota: $'
    
    msg_indice_invalido db 13,10,'Error: Indice invalido. Debe ser entre 1 y $'
    msg_indice_pedido db 13,10,'Ingrese el indice (1-'
    msg_indice_cerrar db '): $'
    msg_estudiante_indice db 13,10,10,'Estudiante en posicion $'
    msg_dos_puntos db ': $'

    ; Buffer para entrada de datos
    buffer db 50
            db ?
            db 50 dup('$')

    ; Arrays para almacenar datos - MODIFICADO para 5 decimales
    estudiante_size equ 65  ; 20(nom) + 20(ape1) + 20(ape2) + 1(nota_ent) + 4(5 decimales)
    estudiantes db 15 * estudiante_size dup('$') 
    
    ; Variables de control
    contador db 0
    nueva_linea db 13,10,'$'
    
    ; Para conversión de números
    temp_num dw 0
    temp_buffer db 6 dup('$')
        
    ; Para estadísticas - MODIFICADO para 5 decimales
    msg_sin_datos db 13,10,'No hay datos de estudiantes. Presione cualquier tecla para continuar.$'
    msg_promedio db 13,10,'Promedio: $'
    msg_suma db 13,10,'Suma total: $'
    msg_maxima db 13,10,'Nota maxima: $'
    msg_minima db 13,10,'Nota minima: $'
    
    ; Variables para estadísticas - MODIFICADO para 5 decimales
    suma_entera dw 0
    suma_decimal dw 0      ; Ahora almacena 5 decimales (0-99999)
    promedio_entera db 0
    promedio_decimal dw 0  ; Ahora almacena 5 decimales
    maxima_entera db 0
    maxima_decimal dw 0    ; Ahora almacena 5 decimales
    minima_entera db 100
    minima_decimal dw 0    ; Ahora almacena 5 decimales   
    
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
    ; Verificar si ya se han procesado 15 estudiantes
    mov al, contador
    cmp al, 15
    jae completado_op1  ; Si ya hay 15, saltar a completado

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

    ; Procesar nota con estructura optimizada
    call procesar_nota_5_decimales

    ; Mostrar estudiante guardado
    call mostrar_estudiante_5_decimales

    ; Incrementar contador
    inc contador

    mov ah, 09h
    lea dx, nueva_linea
    int 21h

    ; Loop principal
    dec bx
    jnz ingresar_dato_op1Loop

completado_op1:
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
    call calcular_estadisticas_5_decimales
    
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
    
    ; Verificar si hay estudiantes registrados
    mov al, contador
    cmp al, 0
    je no_estudiantes_op3
    
    ; Pedir índice al usuario
    call pedir_indice_mejorado
    cmp ax, 0FFFFh        ; ¿Presionó ESC?
    je Menu
    
    ; Validar índice (debe estar entre 1 y contador)
    cmp ax, 1
    jb indice_invalido_op3
    cmp al, contador
    ja indice_invalido_op3
    
    ; Mostrar estudiante
    call mostrar_estudiante_por_indice_5_decimales
    jmp esperar_tecla_op3
    
no_estudiantes_op3:
    mov dx, offset msg_sin_datos
    mov ah, 09h
    int 21h
    jmp esperar_tecla_op3
    
indice_invalido_op3:
    mov dx, offset msg_indice_invalido
    mov ah, 09h
    int 21h
    
    ; Mostrar el rango válido
    mov al, contador
    call print_decimal
    
    mov dl, ')'
    mov ah, 02h
    int 21h
    
esperar_tecla_op3:
    mov ah, 08h
    int 21h
    cmp al, 27
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
    call comparar_estudiantes_5_decimales
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
    jmp mostrar_notas_ordenadas_5_decimales

intercambiar_estudiantes proc
    push ax 
    push bx 
    push cx 
    push dx 
    push si 
    push di
    
    ; Intercambiar los 65 bytes completos
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

comparar_estudiantes_5_decimales proc
    push ax
    push bx
    push dx
    
    ; Comparar parte entera primero
    mov al, [si + 60]      ; Nota entera estudiante 1
    mov dl, [di + 60]      ; Nota entera estudiante 2
    cmp al, dl
    jg mayor_5
    jl menor_5
    
    ; Si partes enteras son iguales, comparar decimales (5 dígitos)
    mov ax, [si + 61]      ; Nota decimal estudiante 1
    mov dx, [di + 61]      ; Nota decimal estudiante 2
    mov bx, [si + 63]      ; Continuación decimal estudiante 1
    mov cx, [di + 63]      ; Continuación decimal estudiante 2
    
    cmp ax, dx
    jg mayor_5
    jl menor_5
    
    cmp bx, cx
    jg mayor_5
    jl menor_5
    
    ; Son iguales
    clc                    ; CF = 0, no intercambiar
    jmp fin_comparar_5
    
mayor_5:
    stc                    ; CF = 1, intercambiar
    jmp fin_comparar_5
    
menor_5:
    clc                    ; CF = 0, no intercambiar

fin_comparar_5:
    pop dx
    pop bx
    pop ax
    ret
comparar_estudiantes_5_decimales endp

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
    call comparar_estudiantes_5_decimales
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
    jmp mostrar_notas_ordenadas_5_decimales

mostrar_notas_ordenadas_5_decimales:
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h

    mov cl, contador
    jcxz fin_impresion_5

    mov si, offset estudiantes

imprimir_notas_loop_5:
    ; Imprimir parte entera (offset 60)
    mov al, [si + 60]
    call print_decimal
    
    ; Imprimir punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Imprimir parte decimal (5 dígitos)
    call mostrar_5_decimales

    ; Espacio entre notas
    mov dl, ' '
    mov ah, 02h
    int 21h

    add si, estudiante_size    ; Siguiente estudiante
    loop imprimir_notas_loop_5

fin_impresion_5:
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

procesar_nota_5_decimales proc
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
    
    ; Inicializar decimales a 0
    mov word ptr [bx + 1], 0
    mov word ptr [bx + 3], 0
    
    mov di, 0               ; Contador de decimales
    
convertir_loop_5:
    mov cl, [si]
    cmp cl, '.'             ; ¿es punto decimal?
    je punto_decimal_5
    cmp cl, 13              ; ¿es enter?
    je fin_conversion_5
    cmp cl, ' '             ; ¿es espacio?
    je fin_conversion_5
    cmp cl, '$'             ; ¿es terminador?
    je fin_conversion_5
    
    sub cl, '0'             ; convertir a número
    mov ch, 0
    
    cmp dx, 0
    jne es_decimal_5
    
    ; Parte entera: acumular * 10 + dígito
    mov dx, 10
    mul dx
    add ax, cx
    jmp siguiente_digito_5
    
es_decimal_5:
    ; Para decimales, procesar 5 dígitos
    cmp di, 5
    jae siguiente_digito_5  ; Si ya tenemos 5 decimales, ignorar el resto
    
    ; Multiplicar decimal actual por 10 y sumar nuevo dígito
    push ax
    mov ax, [bx + 1]        ; Cargar parte baja de decimales
    mov dx, [bx + 3]        ; Cargar parte alta de decimales
    
    ; Multiplicar por 10 (DX:AX * 10)
    mov cx, 10
    mul cx                  ; Multiplicar parte baja
    xchg ax, dx
    mul cx                  ; Multiplicar parte alta
    xchg ax, dx
    
    add ax, cx              ; Sumar nuevo dígito
    adc dx, 0
    
    mov [bx + 1], ax        ; Guardar parte baja
    mov [bx + 3], dx        ; Guardar parte alta
    
    pop ax
    inc di
    
siguiente_digito_5:
    inc si
    jmp convertir_loop_5
    
punto_decimal_5:
    mov dx, 1               ; activar modo decimal
    mov [bx], al            ; guardar parte entera
    xor ax, ax              ; resetear acumulador
    
    ; Ajustar decimales para 5 dígitos (multiplicar por 10^(5-di))
    mov di, 0               ; Inicializar contador de decimales
    jmp siguiente_digito_5
    
fin_conversion_5:
    cmp dx, 0
    jne ya_guardado_5
    mov [bx], al            ; guardar parte entera si no había decimal
    
ya_guardado_5:
    ; Asegurar que tenemos exactamente 5 decimales
    cmp di, 5
    jae conversion_completa_5
    
    ; Completar con ceros si faltan decimales
    mov cx, 5
    sub cx, di
completar_ceros_5:
    push cx
    mov ax, [bx + 1]        ; Cargar parte baja de decimales
    mov dx, [bx + 3]        ; Cargar parte alta de decimales
    
    ; Multiplicar por 10
    mov cx, 10
    mul cx                  ; Multiplicar parte baja
    xchg ax, dx
    mul cx                  ; Multiplicar parte alta
    xchg ax, dx
    
    mov [bx + 1], ax        ; Guardar parte baja
    mov [bx + 3], dx        ; Guardar parte alta
    
    pop cx
    loop completar_ceros_5
    
conversion_completa_5:
    pop di 
    pop si 
    pop dx 
    pop cx 
    pop bx 
    pop ax
    ret
procesar_nota_5_decimales endp

mostrar_estudiante_5_decimales proc
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
    
    ; Parte decimal (5 dígitos)
    call mostrar_5_decimales
    
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
mostrar_estudiante_5_decimales endp

mostrar_5_decimales proc
    push ax
    push bx
    push cx
    push dx
    
    ; Cargar los 5 decimales (almacenados como número de 0-99999)
    mov ax, [bx + 61]      ; Parte baja
    mov dx, [bx + 63]      ; Parte alta
    
    ; Mostrar como 5 dígitos con ceros a la izquierda
    mov cx, 10000         ; Divisor para primer dígito
    call mostrar_digito_decimal
    
    mov cx, 1000          ; Divisor para segundo dígito
    call mostrar_digito_decimal
    
    mov cx, 100           ; Divisor para tercer dígito
    call mostrar_digito_decimal
    
    mov cx, 10            ; Divisor para cuarto dígito
    call mostrar_digito_decimal
    
    mov cx, 1             ; Divisor para quinto dígito
    call mostrar_digito_decimal
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_5_decimales endp

mostrar_digito_decimal proc
    push ax
    push bx
    push dx
    
    ; Dividir DX:AX por CX
    mov bx, cx
    xor cx, cx
    
divide_loop:
    cmp dx, 0
    jne divide_high
    cmp ax, bx
    jb divide_done
    
divide_high:
    sub ax, bx
    sbb dx, 0
    inc cx
    jmp divide_loop
    
divide_done:
    ; Mostrar dígito
    mov dl, cl
    add dl, '0'
    mov ah, 02h
    int 21h
    
    ; Restaurar resto
    mov ax, ax
    mov dx, dx
    
    pop dx
    pop bx
    pop ax
    ret
mostrar_digito_decimal endp

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

; Procedimiento para calcular estadísticas con 5 decimales
; Procedimiento para calcular estadísticas con 5 decimales
calcular_estadisticas_5_decimales proc
    push ax 
    push bx 
    push cx 
    push dx 
    push si 
    push di
    
    ; Initialize variables
    mov suma_entera, 0
    mov suma_decimal, 0
    mov suma_decimal + 2, 0  ; Inicializar parte alta también
    mov aprobados, 0
    mov reprobados, 0
    mov maxima_entera, 0
    mov maxima_decimal, 0
    mov maxima_decimal + 2, 0
    mov minima_entera, 100
    mov minima_decimal, 0
    mov minima_decimal + 2, 0
    
    ; Set up pointer to estudiantes array
    mov si, offset estudiantes
    mov cl, contador
    mov ch, 0
    jcxz fin_calculo_5           ; Salir si no hay estudiantes
    
calcular_loop_5:
    ; Obtener nota entera (offset 60)
    mov al, [si + 60]
    mov ah, 0
    add suma_entera, ax
    
    ; Obtener nota decimal (offset 61-64) - CORREGIDO
    mov ax, [si + 61]      ; Parte baja
    mov dx, [si + 63]      ; Parte alta
    add word ptr suma_decimal, ax
    adc word ptr suma_decimal + 2, dx
    
    ; Check for carry-over from decimal part (100000 = 0x186A0)
    cmp word ptr suma_decimal + 2, 1      ; Comparar parte alta
    jb no_carry_5
    ja hacer_carry_5
    cmp word ptr suma_decimal, 86A0h      ; Comparar parte baja
    jb no_carry_5
    
hacer_carry_5:
    sub word ptr suma_decimal, 86A0h
    sbb word ptr suma_decimal + 2, 1
    inc suma_entera
    jmp no_carry_5
    
no_carry_5:
    ; Check if student passed (nota >= 70)
    mov al, [si + 60]          ; Parte entera
    cmp al, 70
    jb estudiante_reprobado_5
    
    ; If integer part is exactly 70, check decimal part
    jne estudiante_aprobado_5
    mov ax, [si + 61]          ; Parte decimal
    mov dx, [si + 63]
    or ax, dx                  ; Combinar ambas partes
    jnz estudiante_aprobado_5  ; Si no es cero, aprobado

estudiante_aprobado_5:
    inc aprobados
    jmp check_max_min_5
    
estudiante_reprobado_5:
    inc reprobados
    
check_max_min_5:
    ; Check for maximum grade
    mov al, [si + 60]
    cmp al, maxima_entera
    jb check_minima_5
    ja new_maxima_5
    
    ; Si partes enteras son iguales, comparar decimales
    mov ax, [si + 61]
    mov dx, [si + 63]
    cmp dx, word ptr maxima_decimal + 2  ; Comparar parte alta primero
    ja new_maxima_5
    jb check_minima_5
    cmp ax, word ptr maxima_decimal      ; Luego parte baja
    ja new_maxima_5
    jbe check_minima_5
    
new_maxima_5:
    mov al, [si + 60]
    mov maxima_entera, al
    mov ax, [si + 61]
    mov dx, [si + 63]
    mov word ptr maxima_decimal, ax
    mov word ptr maxima_decimal + 2, dx
    jmp check_minima_5
    
check_minima_5:
    ; Check for minimum grade
    mov al, [si + 60]
    cmp al, minima_entera
    ja next_student_5
    jb new_minima_5
    
    ; Si partes enteras son iguales, comparar decimales
    mov ax, [si + 61]
    mov dx, [si + 63]
    cmp dx, word ptr minima_decimal + 2  ; Comparar parte alta primero
    jb new_minima_5
    ja next_student_5
    cmp ax, word ptr minima_decimal      ; Luego parte baja
    jb new_minima_5
    jae next_student_5
    
new_minima_5:
    mov al, [si + 60]
    mov minima_entera, al
    mov ax, [si + 61]
    mov dx, [si + 63]
    mov word ptr minima_decimal, ax
    mov word ptr minima_decimal + 2, dx
    
next_student_5:
    add si, estudiante_size    ; Avanzar al siguiente estudiante
    loop calcular_loop_5
    
    ; Calculate average - CORREGIDO para evitar overflow
    mov ax, suma_entera
    mov bl, contador
    div bl
    mov promedio_entera, al
    
    ; Calcular promedio de decimales (simplificado)
    mov ax, word ptr suma_decimal
    mov dx, word ptr suma_decimal + 2
    mov bl, contador
    mov bh, 0
    
    ; Dividir DX:AX por BX
    div bx
    mov word ptr promedio_decimal, ax
    mov word ptr promedio_decimal + 2, dx
    
    ; Display results
    call mostrar_estadisticas_5_decimales
    
fin_calculo_5:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
calcular_estadisticas_5_decimales endp

; Procedimiento para mostrar estadísticas con 5 decimales
mostrar_estadisticas_5_decimales proc
    push ax
    push dx
    push bx
    
    ; Show sum
    call mostrar_suma_corregida_5
    
    ; Show average
    mov dx, offset msg_promedio
    mov ah, 09h
    int 21h
    
    mov al, promedio_entera
    call print_decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar 5 decimales del promedio
    mov bx, offset promedio_decimal
    call mostrar_5_decimales_stat
    
    ; Show maximum grade
    mov dx, offset msg_maxima
    mov ah, 09h
    int 21h
    
    mov al, maxima_entera
    call print_decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar 5 decimales de la máxima
    mov bx, offset maxima_decimal
    call mostrar_5_decimales_stat
    
    ; Show minimum grade
    mov dx, offset msg_minima
    mov ah, 09h
    int 21h
    
    mov al, minima_entera
    call print_decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar 5 decimales de la mínima
    mov bx, offset minima_decimal
    call mostrar_5_decimales_stat
    
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
    
    pop bx
    pop dx
    pop ax
    ret
mostrar_estadisticas_5_decimales endp

; Procedimiento especial para mostrar 5 decimales de estadísticas
mostrar_5_decimales_stat proc
    push ax
    push bx
    push cx
    push dx
    
    ; Cargar los 5 decimales (almacenados como número de 0-99999)
    mov ax, [bx]      ; Parte baja
    mov dx, [bx + 2]  ; Parte alta
    
    ; Mostrar como 5 dígitos con ceros a la izquierda
    mov cx, 10000         ; Divisor para primer dígito
    call mostrar_digito_decimal_stat
    
    mov cx, 1000          ; Divisor para segundo dígito
    call mostrar_digito_decimal_stat
    
    mov cx, 100           ; Divisor para tercer dígito
    call mostrar_digito_decimal_stat
    
    mov cx, 10            ; Divisor para cuarto dígito
    call mostrar_digito_decimal_stat
    
    mov cx, 1             ; Divisor para quinto dígito
    call mostrar_digito_decimal_stat
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_5_decimales_stat endp

mostrar_digito_decimal_stat proc
    push ax
    push bx
    push dx
    
    ; Dividir DX:AX por CX
    xor bx, bx
    mov bx, cx
    
    ; Para números de 32 bits, necesitamos una división más compleja
    push cx
    mov cx, 32
    xor si, si
    
divide_loop_stat:
    shl ax, 1
    rcl dx, 1
    rcl si, 1
    
    cmp si, bx
    jb no_sub_stat
    
    sub si, bx
    inc ax
    
no_sub_stat:
    loop divide_loop_stat
    pop cx
    
    ; Mostrar dígito (está en AL)
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h
    
    pop dx
    pop bx
    pop ax
    ret
mostrar_digito_decimal_stat endp

; Procedimiento para mostrar suma con 5 decimales
mostrar_suma_corregida_5 proc
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
    
    ; Mostrar 5 decimales de la suma
    mov bx, offset suma_decimal
    call mostrar_5_decimales
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_suma_corregida_5 endp

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

; Procedimiento para pedir índice
pedir_indice_mejorado proc
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Mostrar mensaje con rango válido
    mov dx, offset msg_indice_pedido
    mov ah, 09h
    int 21h
    
    mov al, contador
    call print_decimal
    
    mov dx, offset msg_indice_cerrar
    mov ah, 09h
    int 21h
    
    ; Leer entrada del usuario usando buffer
    mov byte ptr buffer, 3        ; Máximo 2 dígitos + Enter
    mov dx, offset buffer
    mov ah, 0Ah
    int 21h
    
    ; Verificar si se presionó ESC (primer carácter)
    mov si, offset buffer + 2
    mov al, [si]
    cmp al, 27
    je presiono_esc
    
    ; Convertir la cadena a número
    xor ax, ax
    xor cx, cx
    mov cl, buffer + 1           ; Longitud de la entrada
    jcxz fin_pedir_indice_error  ; Si no se ingresó nada
    
    mov di, 10                   ; Base decimal
    mov si, offset buffer + 2    ; Inicio de la cadena
    
convertir_cadena:
    mov bl, [si]
    cmp bl, 13                   ; Fin por Enter
    je fin_conversion1
    cmp bl, '0'
    jb fin_pedir_indice_error
    cmp bl, '9'
    ja fin_pedir_indice_error
    
    sub bl, '0'                  ; Convertir a número
    mul di                       ; ax = ax * 10
    add ax, bx                   ; ax = ax + dígito
    inc si
    loop convertir_cadena
    
fin_conversion1:
    jmp fin_pedir_indice
    
presiono_esc:
    mov ax, 0FFFFh
    jmp fin_pedir_indice
    
fin_pedir_indice_error:
    mov ax, 0                    ; Retornar 0 para indicar error
    
fin_pedir_indice:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
pedir_indice_mejorado endp

; Procedimiento para mostrar estudiante por índice con 5 decimales
mostrar_estudiante_por_indice_5_decimales proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Calcular offset del estudiante (ax ya contiene el índice)
    mov bx, ax                  ; Guardar índice original
    dec ax                      ; Ajustar a índice base 0
    mov cl, estudiante_size
    mul cl
    mov si, offset estudiantes
    add si, ax                  ; SI apunta al estudiante
    
    ; Mostrar encabezado
    mov dx, offset msg_estudiante_indice
    mov ah, 09h
    int 21h
    
    ; Mostrar el índice original (guardado en bx)
    mov al, bl
    call print_decimal
    
    mov dx, offset msg_dos_puntos
    mov ah, 09h
    int 21h
    
    ; Mostrar nombre completo
    mov dx, si
    mov ah, 09h
    int 21h
    
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    mov dx, si
    add dx, 20              ; Apellido1
    mov ah, 09h
    int 21h
    
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    mov dx, si
    add dx, 40              ; Apellido2
    mov ah, 09h
    int 21h
    
    ; Mostrar nota
    mov dx, offset msg_con_nota
    mov ah, 09h
    int 21h
    
    ; Parte entera
    mov al, [si + 60]
    call print_decimal
    
    ; Punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Parte decimal (5 dígitos)
    call mostrar_5_decimales
    
    ; Nueva línea
    mov ah, 09h
    lea dx, nueva_linea
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_estudiante_por_indice_5_decimales endp

end main

main endp