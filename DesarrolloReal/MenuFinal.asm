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
    msg_error db 13,10, 'Error: La nota debe estar entre 0 y 100',13,10,'$'
    msg_guardado db 13,10,'Guardado: $'
    msg_con_nota db ' con nota: $'
    
    msg_indice_invalido db 13,10,'Error: Indice invalido. Debe ser entre 1 y $'
    msg_indice_pedido db 13,10,'Ingrese el indice (1-'
    msg_indice_cerrar db '): $'
    msg_estudiante_indice db 13,10,10,'Estudiante en posicion $'
    msg_dos_puntos db ': $'

    ;Mensajes de depuración y verificación para la entrada de datos
    msg_error_nombre db 13,10,'Error: El nombre solo puede contener letras y espacios',13,10,'$'
    msg_error_nota db 13,10,'Error: La nota solo puede contener números y un punto decimal',13,10,'$'
    msg_debug_char db 13,10,'DEBUG: Caracter leido: $'
    msg_debug_ascii db ' ASCII: $'
    msg_debug_valid db ' ES VALIDO',13,10,'$'
    msg_debug_invalid db ' ES INVALIDO',13,10,'$'


    ; Buffer para entrada de datos
    buffer db 50
            db ?
            db 50 dup('$')

    ; Arrays para almacenar datos
    estudiante_size equ 67  ; 20(nom) + 20(ape1) + 20(ape2) + 1(nota_ent) + 1(nota_dec)
    estudiantes db 15 * estudiante_size dup('$')  
    
    ; Variables de control
    contador db 0
    nueva_linea db 13,10,'$'
    
    ; Para conversión de números
    temp_num db 0
    temp_buffer db 6 dup('$')

   ; Variables para estadísticas - ACTUALIZADO para 5 decimales
   
    suma_total dw 0         ; Suma total de notas enteras
    promedio db 0           ; Promedio (entero)
    maxima db 0             ; Máxima nota (entero)
    minima db 100           ; Mínima nota (entero)
    aprobados db 0
    reprobados db 0 

    ; Para estadísticas y todo el debug para que el usuario sepa lo calculado
    msg_sin_datos db 13,10,'No hay datos de estudiantes. Presione cualquier tecla para continuar.$'
    msg_promedio db 13,10,'Promedio: $'
    msg_suma db 13,10,'Suma total: $'
    msg_maxima db 13,10,'Nota maxima: $'
    msg_minima db 13,10,'Nota minima: $'
    msg_aprobados db 13,10,'Estudiantes aprobados (>=70): $'
    msg_reprobados db 13,10,'Estudiantes reprobados (<70): $'
    msg_presione_tecla db 13,10,10,'Presione cualquier tecla para continuar...$'

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

ingresar_nombre_valido:
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

    ; Validar nombre completo (solo letras y espacios)
    call validar_nombre_completo
    jc nombre_invalido
    
    ; Procesar nombre completo 
    call separar_datos_optimizado
    jmp ingresar_nota_valida

nombre_invalido:
    mov dx, offset msg_error_nombre
    mov ah, 09h
    int 21h
    jmp ingresar_nombre_valido

ingresar_nota_valida:
    ; Pedir nota
    mov ah, 09h
    lea dx, msg_ingresar_nota
    int 21h

    mov byte ptr buffer+1, 0
    mov byte ptr buffer+2, 0

    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; Validar nota (solo números y un punto decimal)
    call validar_nota
    jc nota_invalida

    ; Procesar nota con 5 decimales
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
    jmp completado_op1

nota_invalida:
    mov dx, offset msg_error_nota
    mov ah, 09h
    int 21h
    jmp ingresar_nota_valida

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
    call mostrar_estudiante_por_indice
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
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Comparar parte entera primero
    mov ax, [si + 60]      ; Nota entera estudiante 1 (word)
    mov dx, [di + 60]      ; Nota entera estudiante 2 (word)
    cmp ax, dx
    jg mayor
    jl menor
    
    ; Si partes enteras son iguales, comparar decimales
    mov cx, 5
    mov bx, 0
comparar_decimales:
    mov al, [si + 62 + bx] ; Decimal estudiante 1
    mov dl, [di + 62 + bx] ; Decimal estudiante 2
    cmp al, dl
    jg mayor
    jl menor
    inc bx
    loop comparar_decimales
    
    ; Son iguales
    clc
    jmp fin_comparar
    
mayor:
    stc
    jmp fin_comparar
    
menor:
    clc

fin_comparar:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
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
    ; Parte entera
    mov ax, [si + 60]
    call print_decimal_word
    
    ; Punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; 5 decimales
    lea si, [si + 62]
    call mostrar_5_decimales
    
    ; Restaurar SI y avanzar
    sub si, 62
    add si, estudiante_size

    ; Espacio entre notas
    mov dl, ' '
    mov ah, 02h
    int 21h

    loop imprimir_notas_loop

fin_impresion:
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h

    mov ah, 08h
    int 21h
    cmp al, 27
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
    
    ; Calcular offset base
    mov bx, offset estudiantes
    mov al, contador
    mov cl, estudiante_size
    mul cl
    add bx, ax
    
    lea si, buffer + 2
    
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
    mov cx, 19
copiar_loop:
    mov al, [si]
    cmp al, ' '
    je fin_campo
    cmp al, 13
    je fin_campo
    cmp al, '$'
    je fin_campo
    
    mov [di], al
    inc si
    inc di
    loop copiar_loop
    
fin_campo:
    mov byte ptr [di], '$'
    cmp byte ptr [si], ' '
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
    mov di, 0               ; Contador de decimales
    
convertir_loop_5dec:
    mov cl, [si]
    cmp cl, '.'             ; ¿es punto decimal?
    je punto_decimal_5dec
    cmp cl, 13              ; ¿es enter?
    je fin_conversion_5dec
    cmp cl, ' '             ; ¿es espacio?
    je fin_conversion_5dec
    cmp cl, '$'             ; ¿es terminador?
    je fin_conversion_5dec
    
    ; Validar que sea dígito
    cmp cl, '0'
    jb error_digito
    cmp cl, '9'
    ja error_digito
    
    sub cl, '0'             ; convertir a número
    mov ch, 0
    
    cmp dx, 0
    jne es_decimal_5dec
    
    ; Parte entera: acumular * 10 + dígito
    mov dx, 10
    mul dx
    add ax, cx
    jmp siguiente_digito_5dec
    
es_decimal_5dec:
    ; Almacenar decimales (máximo 5)
    cmp di, 5
    jae saltar_decimal_exceso
    
    mov [bx + 2 + di], cl   ; guardar decimal (offset 62-66)
    inc di
    
saltar_decimal_exceso:
    jmp siguiente_digito_5dec
    
punto_decimal_5dec:
    mov dx, 1               ; activar modo decimal
    mov [bx], ax            ; guardar parte entera (word)
    xor ax, ax              ; resetear acumulador
    
siguiente_digito_5dec:
    inc si
    jmp convertir_loop_5dec
    
error_digito:
    ; Carácter inválido, saltarlo
    inc si
    jmp convertir_loop_5dec
    
fin_conversion_5dec:
    cmp dx, 0
    jne ya_guardado_5dec
    mov [bx], ax            ; guardar parte entera si no había decimal
    
ya_guardado_5dec:
    ; Rellenar decimales restantes con 0 si es necesario
    cmp di, 5
    jae fin_proceso_5dec
    mov cx, 5
    sub cx, di
rellenar_ceros:
    mov byte ptr [bx + 2 + di], 0
    inc di
    loop rellenar_ceros
    
fin_proceso_5dec:
    pop di 
    pop si 
    pop dx 
    pop cx 
    pop bx 
    pop ax
    ret
procesar_nota_5_decimales endp

mostrar_5_decimales proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; SI debe apuntar al primer decimal
    mov cx, 5
    mov bx, 0
    
mostrar_decimal_loop:
    mov al, [si + bx]
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    inc bx
    loop mostrar_decimal_loop
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_5_decimales endp

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
    
    ; Mostrar nota con 5 decimales
    mov ah, 09h
    lea dx, msg_con_nota
    int 21h
    
    ; Parte entera (word)
    mov ax, [bx + 60]
    call print_decimal_word
    
    ; Punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Parte decimal (5 dígitos)
    lea si, [bx + 62]      ; Apuntar a decimales
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


print_decimal_word proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, 10
    xor cx, cx
    mov dx, ax
    
    ; Caso especial para 0
    test ax, ax
    jnz convert_loop
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp done_word
    
convert_loop: 
    xor dx, dx     ; Limpiar DX para usarlo como registro de resto
    div bx    ; Dividir AX entre BX (base 10), resultado en AX, resto en DX
    push dx        ; Guardar el resto (dígito actual) en la pila
    inc cx       ; Incrementar el contador de dígitos
    test ax, ax      ; Verificar si AX es 0 (ya no hay más dígitos por procesar)
    jnz convert_loop   ; Si no es 0, continuar el bucle para procesar el siguiente dígito
    
print_loop:
    pop dx ;acceder al dígito almacenado en la pila stacl
    add dl, '0' ;convertir el número es ASCII
    mov ah, 02h ;Función propia para imprimir caracteres
    int 21h ;Se interrumpe el flujo para imprimir un caracter
    loop print_loop ;repetir hasta que se haya procesado tod
    
done_word:
    pop dx ;En este sector lo que se hace es restaurar cada valor original de cada registro, osea antes de regresar al procedimiento que lo llama
    pop cx
    pop bx
    pop ax
    ret
print_decimal_word endp

; Procedimiento para mostrar número
mostrar_numero proc
    push ax
    push bx
    push dx
    
    mov al, contador
    inc al                 ; al = número actual (1-15)
    
    ; Solución fuerza bruta - usar una tabla de búsqueda, se tuvo que hacer así porque no se encontró otra forma de hacerlo
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

mostrar_1: ;se comienza a mostrar por dígito cada función.
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

; Procedimiento para calcular estadisticas operación correspondiente del menoi
calcular_estadisticas proc
    push ax 
    push bx 
    push cx 
    push dx 
    push si 
    push di
    
    ; Reinicializar variables
    mov suma_total, 0
    mov aprobados, 0
    mov reprobados, 0
    mov maxima, 0
    mov minima, 100
    
    ; Verificar si hay estudiantes
    mov cl, contador
    mov ch, 0
    jcxz fin_calculo_sin_estudiantes  ; Cambiamos esto para saltar a un nuevo punto
    
    mov si, offset estudiantes
    
calcular_loop:
    ; Convertir la nota a entero redondeado (85.50000 ? 86, 85.49999 ? 85)
    call redondear_nota_a_entero
    ; AL = nota redondeada (0-100)
    
    ; Sumar al total
    mov ah, 0
    add suma_total, ax
    
    ; Verificar si está aprobado (>= 70)
    cmp al, 70
    jb estudiante_reprobado
    inc aprobados
    jmp check_max_min
    
estudiante_reprobado:
    inc reprobados
    
check_max_min:
    ; Verificar máxima
    cmp al, maxima
    jbe check_minima
    mov maxima, al
    
check_minima:
    ; Verificar mínima
    cmp al, minima
    jae next_student
    mov minima, al
    
next_student:
    add si, estudiante_size
    loop calcular_loop
    
    ; Calcular promedio (suma_total / contador)
    mov al, contador
    cmp al, 0
    je fin_calculo_sin_estudiantes  ; Evitar división por cero
    
    mov ax, suma_total
    mov bl, contador
    mov bh, 0
    div bl
    mov promedio, al
    
    ; Mostrar resultados
    call mostrar_estadisticas_simplificado
    jmp fin_calculo
    
fin_calculo_sin_estudiantes:
    ; Mostrar mensaje de que no hay estudiantes
    mov dx, offset msg_sin_datos
    mov ah, 09h
    int 21h
    
fin_calculo: ;se recuperan los valores originales de cada registro, volviendo a recuperar el estado antes de ser llamados.
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
calcular_estadisticas endp

redondear_nota_a_entero proc
    ; Convierte nota de estudiante a entero redondeado
    ; Entrada: SI apunta al estudiante
    ; Salida: AL = nota redondeada (0-100)
    
    push bx
    push cx
    
    ; 1. Obtener parte entera
    mov al, byte ptr [si + 60]  ; Parte entera (byte)
    cmp al, 100
    jbe entera_valida
    mov al, 100                 ; Limitar a 100 si es mayor
    
entera_valida:
    ; 2. Verificar decimal para redondeo
    ; Si el primer decimal es >= 5, redondear hacia arriba
    mov bl, [si + 62]          ; Primer decimal
    cmp bl, 5
    jb fin_redondeo
    
    ; Redondear hacia arriba
    inc al
    cmp al, 100
    jbe fin_redondeo
    mov al, 100                ; Limitar a 100
    
fin_redondeo:
    pop cx
    pop bx
    ret
redondear_nota_a_entero endp

mostrar_estadisticas_simplificado proc ;se procedio a simplificar porque la gran cantidad de debug daba errores.
    push ax
    push dx
    
    ; Mostrar encabezado
    mov dx, offset nueva_linea ;Imprime una nueva linea con el procedimiento dedicado
    mov ah, 09h
    int 21h
    
    ; Mostrar suma total
    mov dx, offset msg_suma
    mov ah, 09h
    int 21h
    mov ax, suma_total ;carga la suma total calculada al registro
    call print_decimal_word ;Imprime el valor de la suma total
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    
    ; Mostrar promedio 
    mov dx, offset msg_promedio ;se realiza la misma lógica comentada anteriormente solo que con los procedimientos dedicados a cada parte
    mov ah, 09h
    int 21h
    mov al, promedio
    mov ah, 0
    call print_decimal_word
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    
    ; Mostrar máxima
    mov dx, offset msg_maxima
    mov ah, 09h
    int 21h
    mov al, maxima
    mov ah, 0
    call print_decimal_word
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    
    ; Mostrar mínima
    mov dx, offset msg_minima
    mov ah, 09h
    int 21h
    mov al, minima
    mov ah, 0
    call print_decimal_word
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    
    ; Mostrar aprobados/reprobados
    mov dx, offset msg_aprobados
    mov ah, 09h
    int 21h
    mov al, aprobados
    call print_decimal
    
    mov dx, offset msg_reprobados
    mov ah, 09h
    int 21h
    mov al, reprobados
    call print_decimal
    
    ; Mensaje para continuar
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    mov dx, offset msg_presione_tecla
    int 21h
    
    pop dx
    pop ax
    ret
mostrar_estadisticas_simplificado endp


; Procedimiento para mostrar números decimales
mostrar_decimal proc
    push ax ;Se guardan los valores actuales de cada registro en la pila, anteriormente acá no se guardaban
    push bx;los valores correctos, causando un salto incorrecto al momento de mostrar los decimales
    push dx
    
    xor ah, ah ;Con xor limpiamos el registro AH 
    mov bl, 10 ;Se carga 10 como divisor para los calculos
    div bl ;dividimos AX entre 10, Resultado: AL = cociente, AH = residuo
    
    add al, '0' ;Convertir el cociente, la parte alta, a su equivalente ASCII
    mov dl, al ;Se guarda el caracter convertido al registro DL
    mov ah, 02h ;se imprime con la funcion propia de DOS
    int 21h ;interrumpimos para mostrar
    
    mov dl, ah ;Se muev la parte baja, osea el residuo, al registro DL
    add dl, '0' ;Se convvierte el residuo a ASCII
    mov ah, 02h ;Se imprime con la funcion de DOS
    int 21h ;Interrumpe para imrpimr
    
    pop dx ;Recuperamos los valores originales de los registros.
    pop bx
    pop ax
    ret
mostrar_decimal endp

; Procedimiento para imprimir número decimal
print_decimal proc
    push ax ;Guardamos el valor actual de los registros
    push dx
    push cx
    
    cmp al, 100 ;Se compara el valor del registro, con 100 para simplemente printearlo o no
    jne not_hundred

    mov dl, '1' ;Si encontramos que es un 100, simplemente se printea "1","0","0"
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
    xor ah, ah ;Limmpia el registro AH
    mov bl, 10 ;Carga el divisor (10) en BL
    div bl ;dividir AX entre 10. Resultado: AL = cociente, AH = residuo
    
    mov cl, ah ;Se guarda el residuo (decenas) en CL
    
    cmp al, 0 ;Verifica si el cociente es 0
    je print_unit ;Si es 0, salta a imprimir las unidades

    add al, '0' ; Convertimos el cociente(decenas) en ASCII
    mov dl, al; una vez convertido se guarda en DL
    mov ah, 02h ;Imprimimos
    int 21h ;interrumpimos para imprimr

print_unit:
    mov dl, cl ;Mueve el residuo(unidades) al registro DL
    add dl, '0' ;Convertir el residuo a su equivalente ASCII
    mov ah, 02h ;Función DOS para imprimir
    int 21h ;interumpe para imprimir

done:
    pop cx ;Se restauran  todos los valores
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
    mov byte ptr buffer, 3        ; tamaño máximo de entrada. Máximo 2 dígitos + Enter
    mov dx, offset buffer ;Carga la dirección del buffer en DX
    mov ah, 0Ah ;Función DOS para leer entradas de buffer
    int 21h ;interumpe para capturar la entrada del usuario
    
    ; Verificar si se presionó ESC (primer carácter)
    mov si, offset buffer + 2 ;Apunta al primer caracter ingresado en el buffer
    mov al, [si] ;Cargar el primer caracter en Al
    cmp al, 27 ;Compara el codigo ASCII para ESC
    je presiono_esc ;Si es ESC, salta a la etiqueta
    
    ; Convertir la cadena a número
    xor ax, ax ;limpia el Acumulador AX para el numero convertido
    xor cx, cx ;Lo mismo pero con CX, contador de longitud de la candena
    mov cl, buffer + 1           ; Longitud de la entrada
    jcxz fin_pedir_indice_error  ; Si no se ingresó nadam longitrud 0, salta a error
    
    mov di, 10                   ; Base decimal
    mov si, offset buffer + 2    ; apunta al inicio de la cadenaa en el bufer
    
convertir_cadena:
    mov bl, [si] ;carga el caracter actual en la cadena en BL
    cmp bl, 13                   ; compara con la tecla enter
    je fin_conversion1 ;diversas coparacioenes
    cmp bl, '0'
    jb fin_pedir_indice_error
    cmp bl, '9'
    ja fin_pedir_indice_error
    
    sub bl, '0'     ; Convertir a su valor numerico
    mul di                ; ax = ax * 10, multiplica AX por la base (10)
    add ax, bx       ; ax = ax + dígito, Suma el digito convertido al acumulador
    inc si        ;Avanza al siguiente caracter a la cadena para procesarlo
    loop convertir_cadena ;repite mientras CX(contador) no sea 0
    
fin_conversion1:
    jmp fin_pedir_indice ;salta el final del procedimiento
    
presiono_esc:
    mov ax, 0FFFFh ;retornar valor especial para indicar el precionado de ESC
    jmp fin_pedir_indice ;salta
    
fin_pedir_indice_error:
    mov ax, 0                    ; Retornar 0 para indicar error en la conversion
    
fin_pedir_indice: ;Restaura el valor original de los registros al anterior antes de entrar a este proceso
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
pedir_indice_mejorado endp

validar_nombre_completo proc
    push ax ;carga los valores actuales en la pila para restaurarlos luego
    push bx
    push cx
    push dx
    push si
    
    mov si, offset buffer + 2 ;apunta al inicio de la entrada del buffer
    mov bl, [buffer + 1]  ; Longitud de la entrada
    mov bh, 0
    cmp bl, 0   ;verifica si la longitud es 0
    jz invalido_nombre  ; Si no hay caracteres, inválido
    
validar_caracteres_nombre:
    mov al, [si] ;carga el caracter actual
    
    ; DEBUG: Mostrar caracter leído
    push ax
    push dx
    mov dx, offset msg_debug_char
    mov ah, 09h
    int 21h
    mov dl, al
    mov ah, 02h
    int 21h
    mov dx, offset msg_debug_ascii
    mov ah, 09h
    int 21h
    pop dx
    pop ax
    
    push ax
    call print_decimal_byte ; Mostrar valor ASCII
    pop ax
    
    cmp al, 13           ; Fin de línea
    je valido_nombre
    cmp al, ' '          ; Espacio permitido
    je caracter_valido
    cmp al, 'A'
    jb caracter_invalido   ; Menor que 'A'
    cmp al, 'Z'
    jbe caracter_valido  ; Entre 'A'-'Z'
    cmp al, 'a'
    jb caracter_invalido   ; Entre 'Z' y 'a'
    cmp al, 'z'
    jbe caracter_valido  ; Entre 'a'-'z'
    ; Caracteres especiales del español
    cmp al, 164          ; ñ minúscula
    je caracter_valido
    cmp al, 165          ; Ñ mayúscula
    je caracter_valido
    cmp al, 160          ; á
    je caracter_valido
    cmp al, 130          ; é
    je caracter_valido
    cmp al, 161          ; í
    je caracter_valido
    cmp al, 162          ; ó
    je caracter_valido
    cmp al, 163          ; ú
    je caracter_valido
    cmp al, 181          ; Á
    je caracter_valido
    cmp al, 144          ; É
    je caracter_valido
    cmp al, 214          ; Í
    je caracter_valido
    cmp al, 224          ; Ó
    je caracter_valido
    cmp al, 233          ; Ú
    je caracter_valido
    
caracter_invalido:
    ; DEBUG: Mostrar que es inválido
    push dx
    mov dx, offset msg_debug_invalid
    mov ah, 09h
    int 21h
    pop dx
    jmp invalido_nombre

caracter_valido:
    ; DEBUG: Mostrar que es válido
    push dx
    mov dx, offset msg_debug_valid
    mov ah, 09h
    int 21h
    pop dx
    
siguiente_caracter_nombre:
    inc si
    dec bl
    jnz validar_caracteres_nombre

valido_nombre:
    ; DEBUG: Mostrar que todo es válido
    push dx
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    mov dx, offset msg_debug_valid
    mov ah, 09h
    int 21h
    pop dx
    
    clc                  ; Limpiar flag de carry = válido
    jmp fin_validar_nombre

invalido_nombre:
    ; DEBUG: Mostrar que es inválido
    push dx
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    mov dx, offset msg_debug_invalid
    mov ah, 09h
    int 21h
    pop dx
    
    stc                  ; Establecer flag de carry = error

fin_validar_nombre: ;se retoman los valores de los registros.
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
validar_nombre_completo endp

validar_nota proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov si, offset buffer + 2
    mov bl, [buffer + 1]  ; Longitud de la entrada
    mov bh, 0
    mov ch, 0             ; Contador de puntos decimales
    cmp bl, 0
    jz invalido_nota    ; Si no hay caracteres, inválido
    
validar_caracteres_nota:
    mov al, [si] ;se carga el caracter actual desde elñ buffer en AL
    
    ; DEBUG: Mostrar caracter leído
    push ax ;Guardar el valor ed AX y DX en la pila
    push dx
    mov dx, offset msg_debug_char ;debug
    mov ah, 09h ;función de DOS para imprimir
    int 21h
    mov dl, al ;carga el caracter leido
    mov ah, 02h  ;imprime
    int 21h
    mov dx, offset msg_debug_ascii ;Cargar el mensaje ASCII
    mov ah, 09h
    int 21h
    pop dx
    pop ax
    
    push ax
    call print_decimal_byte ; Mostrar valor ASCII
    pop ax
    
    cmp al, 13           ; Fin de línea
    je valido_nota_final
    cmp al, '.'          ; Punto decimal
    je verificar_punto
    cmp al, '0'
    jb caracter_invalido_nota     ; Menor que '0'
    cmp al, '9'
    ja caracter_invalido_nota     ; Mayor que '9'
    
caracter_valido_nota:
    ; DEBUG: Mostrar que es válido
    push dx
    mov dx, offset msg_debug_valid
    mov ah, 09h
    int 21h
    pop dx
    jmp siguiente_caracter_nota

verificar_punto:
    inc ch               ; Incrementar contador de puntos
    cmp ch, 1            ; Solo debe haber un punto
    ja caracter_invalido_nota     ; Si hay más de uno, inválido
    
    ; DEBUG: Mostrar que es válido (punto)
    push dx ; Guarda el valor de DX
    mov dx, offset msg_debug_valid ;carga el mensaje
    mov ah, 09h ;Interrumpe
    int 21h ;imprime
    pop dx;Restaura el valor original de DX
    jmp siguiente_caracter_nota ;Salta a procesar el siguiente caracter

caracter_invalido_nota:
    ; DEBUG: Mostrar que es inválido
    push dx ;guardar el valor de DX en pila
    mov dx, offset msg_debug_invalid ;debug
    mov ah, 09h ;Funcion para imprimir
    int 21h
    pop dx
    jmp invalido_nota

siguiente_caracter_nota:
    inc si ;Avanza al siguiente caracter en el buffer
    dec bl ;decrementa el contador de caracteres restantes
    jnz validar_caracteres_nota

valido_nota_final:
    ; DEBUG: Mostrar que llegó al final
    push dx ;guardar el valor de DX en el buffer
    mov dx, offset nueva_linea ;Cargar elk mensaje de nueva linea
    mov ah, 09h ;  Funcion DOS para imprimir cadena
    int 21h ;Interrumpe y muestra
    mov dx, offset msg_debug_valid ;debug
    mov ah, 09h
    int 21h
    pop dx
    
    ; Validar rango numérico (0-100)
    call convertir_nota_a_numero
    jc invalido_nota_rango
    
    clc                  ; Limpiar flag de carry = válido
    jmp fin_validar_nota

invalido_nota_rango:
    ; DEBUG: Mostrar que está fuera de rango
    push dx
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    mov dx, offset msg_debug_invalid
    mov ah, 09h
    int 21h
    mov dx, offset msg_error_nota
    int 21h
    pop dx
    
invalido_nota:
    stc                  ; Establecer flag de carry = error

fin_validar_nota:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
validar_nota endp

convertir_nota_a_numero proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov si, offset buffer + 2 ;apunta al inicio de la entreada en el buffer
    xor ax, ax           ; AX = resultado, inicializa AX en 0
    xor cx, cx           ; CX = contador de decimales, inicializa CX en 0
    xor dx, dx           ; DX = flag de punto decimal: 0 = entero, 1 = decimal), inicializa DX en 0
    mov bx, 10           ; Base 10
    
    ; DEBUG: Inicio de conversión
    push dx
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    mov dx, offset msg_debug_char
    int 21h
    mov dx, offset buffer + 2
    int 21h
    pop dx
    
convertir_digito:
    mov al, [si]
    cmp al, 13           ; Fin de línea
    je verificar_rango
    cmp al, '.'          ; Punto decimal
    je punto_encontrado
    sub al, '0'          ; Convertir a número
    mov ah, 0
    
    ; Multiplicar y sumar
    xchg ax, bx
    mul dx               ; Multiplicar por 10
    xchg ax, bx
    add bx, ax           ; Sumar dígito actual
    
    jmp siguiente_digito_conv

punto_encontrado:
    mov dx, 1            ; Activar flag de decimales
    mov cx, 0            ; Iniciar contador de decimales

siguiente_digito_conv:
    inc si
    jmp convertir_digito

verificar_rango:
    ; DEBUG: Mostrar valor convertido
    push dx
    mov dx, offset nueva_linea
    mov ah, 09h
    int 21h
    mov dx, offset msg_suma
    int 21h
    mov ax, bx
    call print_decimal_word
    pop dx
    
    ; Verificar que la nota esté entre 0 y 10000 (equivalente a 100.00)
    cmp bx, 10000
    ja fuera_de_rango
    
    clc ; limpia el flag de carry para indicar que la conversion salio bien
    jmp fin_convertir ;salta al fin del proceso

fuera_de_rango:
    stc ;establece la flag de carry para indicar que la nota esta fuera de rango

fin_convertir:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
convertir_nota_a_numero endp

; Procedimiento para mostrar estudiante por índice
mostrar_estudiante_por_indice proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Calcular offset del estudiante
    mov bx, ax
    dec ax
    mov cl, estudiante_size
    mul cl
    mov si, offset estudiantes
    add si, ax
    
    ; Mostrar información básica
    mov dx, offset msg_estudiante_indice
    mov ah, 09h
    int 21h
    mov al, bl
    call print_decimal
    mov dx, offset msg_dos_puntos
    mov ah, 09h
    int 21h
    
    ; Mostrar nombre completo
    mov dx, si ;carga la direccion del nombre completo en DX
    mov ah, 09h ;imprime DOS
    int 21h ;interrumpe
    mov dl, ' ' ;Carga un espacio en DL
    mov ah, 02h ;iimprime
    int 21h ;interrumpe
    
    mov dx, si ;lo mismo pero para primer apellido
    add dx, 20
    mov ah, 09h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    mov dx, si  ;lo mismo pero para segundo apellido
    add dx, 40
    mov ah, 09h
    int 21h
    
    ; Mostrar nota con 5 decimales
    mov dx, offset msg_con_nota
    mov ah, 09h
    int 21h
    
    ; Parte entera
    mov ax, [si + 60]
    call print_decimal_word
    
    ; Punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; 5 decimales
    lea si, [si + 62]
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
mostrar_estudiante_por_indice endp

print_decimal_byte proc
    push ax ;guardamos el valor actual de cada registro para luego retomarlo al salir
    push bx
    push cx
    push dx
    
    mov bl, al ;copia el valor de AL en BL
    mov al, bl ;restaura el valor en AL desde BL
    xor ah, ah ;limpia el registro AHY
    mov cl, 100 ;Carga el divisor 100 en CL
    div cl ;Divide entre 100. Cociente en AL, residuo en AH
    mov ch, ah  ; Guardar resto
    
    cmp al, 0 ;verifica si el cociente (centenas)es 0
    je no_centenas ;salta si si
    add al, '0' ;convierte el cociente a u caracter ASCII
    mov dl, al ;mover el caracter ASCII en Dl
    mov ah, 02h ;printea
    int 21h ;interrumpe
    
no_centenas:
    mov al, ch
    xor ah, ah
    mov cl, 10
    div cl ;divide AX entre 10, cociente en AL, residuo en AH
    mov ch, ah  ; Guardar resto
    
    cmp al, 0
    je no_decenas
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    jmp mostrar_unidades
    
no_decenas:
    ; Si hubo centenas, mostrar 0
    mov al, bl ;Carga el valor original en AL
    cmp al, 100 ;verifica si el valor es menor que 100
    jb mostrar_unidades
    mov dl, '0'
    mov ah, 02h
    int 21h
    
mostrar_unidades:
    mov al, ch ;Carga el residuo(unidades) enAL
    add al, '0' ;Convierte el residuo a su caracter ASCII
    mov dl, al ;Mover el caracter ASCII a DL
    mov ah, 02h ;printea
    int 21h ;interrumpe
    
    pop dx ;se retornar todos los valores guardados en el stack
    pop cx
    pop bx
    pop ax
    ret
print_decimal_byte endp

end main

main endp