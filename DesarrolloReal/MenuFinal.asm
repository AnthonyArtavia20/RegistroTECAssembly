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
    miNombre db 'Por favor ingrese su estudiante o precione ESC para volver a menu$',13,10,
                db 'formato de entrada: -Nombre Apellido1 Apellido2 Nota-',13,10,13,10,'$'

    ;logica de Alexs para el ingresado de datos ---start---
    msg_ingresar db 'ingrese datos (Formato: Nombre Apellido1 Apellido2 Nota): $'
    msg_formato db 13,10, 'Ejemplo: Juan Perez Garcia 85',13,10,'$'
    msg_contador db 13,10, 'Estudiante $'
    msg_total db ' /15: $'
    msg_completado db 13,10,10, 'Se han guardado 15 estudiantes.$'
    msg_error db 13,10, 'Error: Use formato Nombre-Apellido1-Apellido2-Nota',13,10,'$'
    
    debug_msg db 13,10,'DEBUG - Nota guardada: $'
    
    ;Buffer para entrada de nombre
    buffer db 128 ;maximo 50 caracteres + enter
            db ? ;espacio para longitud real
            db 128 dup('$') ;espacio para el nombre se aumentó la capacidad

    ;Array para almacenar los 15 nobres
    nombres db 15 dup(20 dup('$'))  ;Nombres
    apellidos1 db 15 dup(20 dup('$')) ;Apellidos 1
    apellidos2 db 15 dup(20 dup('$')) ;Apellidos 2
    notas db 15 dup(0) ;Notas 0-100, 1 bytes por nota 
    notas_decimales db 15 dup(0)
    
    ;variables de control
    contador db 0
    nueva_linea db 13,10,'$'
    temp db 0    
    
    msg_punto db '.$'            
    
    ; Variables para conversión de números
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

PILA SEGMENT
    DB 64 DUP(0)
PILA ENDS

.code
    main proc
    mov ax, @data 
    mov ds, ax
    ASSUME CS:code, DS:data, SS:PILA

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
        mov ah, 0Ah ;pausa y captura de dato
        lea dx, buffer
        int 21h

        ; Revisar si el primer caracter ingresado fue ESC (27) para poder salir del bucle en cualquier momento
        mov al, [buffer+2]   ; el primer caracter real
        cmp al, 27
        je Menu              ; si fue ESC, saltar al menú
        
        ; --- limpiar el ENTER (0Dh) que el usuario implicitamente escribe al ingresar el nombre---
        mov si, offset buffer
        mov cl, [si+1]              ; longitud real
        mov byte ptr [si+2+cx], '$' ; sustituir el Enter por fin de cadena

        ;Separar y guardar datos
        call separar_datos

        ;Incrementar contador
        inc contador

        mov ah, 09h
        lea dx, nueva_linea
        int 21h

        ;Loop principal
        dec bx
        jnz ingresar_dato_op1Loop

        ;Mostrar mensaje de completado
        mov ah, 09h
        lea dx, msg_completado
        int 21h

        jmp Menu; Sin esto caería a la opcion 2 al terminar.s

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
    mov ah,0
    mov al,3h ;Modo texto
    int 10h

    mov ax,0600h ;Función 06h de int 10 - limpiar pantalla con desplazamiento para arriba
    mov bh, 1eh ;1 fondo azul, e color de letra amarilla
    mov cx,0000h ;Coordenada superior izquierda, Fila,columna (0,0)
    mov dx,184Fh ;Coordenada inferior derecha (24,79)
    int 10h ;Llamada a BIOS para limpiar pantalla
    
    mov ah,02h        ; Función 02h de int 10h: mover cursor.
    mov bh,00         ; Página de video = 0.
    mov dh,00         ; Fila = 0.
    mov dl,00         ; Columna = 0.
    int 10h           ; Llama BIOS ? coloca cursor arriba a la izquierda.
    
    mov dx, offset Ordenar ;SE pasa a DX la dirección del mensaje del segmento .data de "ordenar"
    mov ah,09 ;Función 09h de int 21h: Imprimir strings por pantalla, byte a byte
    int 21h ;se muestra el mensajes

    ; Verificar si contador == 0
    mov al, contador
    cmp al, 0
    je Menu   ; si no hay datos, regresar al menú

    ;determinar si se va a ordenar ascente o ascendente, primero obtener la eleccion del usuario por consola
    elegir_orden:
        mov ah, 08h
        int 21h
        cmp al, 27 ; ASCII 27 = ESC
        je Menu  
        cmp al, 49 ;Compara con 1
        je BubbleAscendente
        cmp al, 50 ;Compara con 2
        je BubbleDescendente
        jmp elegir_orden

        ;----------Codigo principal del BubbleSort aqui:----------------------------
    ;Se neesitan hacer comparacion e intercambio de posiciones
    
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
        lea si, notas ; Parte entera
        lea di, notas_decimales ; Parte decimal
        mov ch, 0
        mov bl, cl ; Ciclo interno

    CICLO_INTERNO:
        ; Preservar registros
        push bx
        push si
        push di
        
        mov al, [si] ; Nota entera actual
        mov dl, [si+1] ; Nota entera siguiente
        
        ; Comparar partes enteras
        cmp al, dl
        JBE NO_SWAP ; Si AL <= DL, no intercambiar
        
        ; INTERCAMBIAR partes enteras
        mov [si], dl
        mov [si+1], al
        
        ; INTERCAMBIAR partes decimales correspondientes
        mov al, [di] ; Decimal actual
        mov dl, [di+1] ; Decimal siguiente
        mov [di], dl
        mov [di+1], al
        
    NO_SWAP:
        ; Recuperar registros
        pop di
        pop si
        pop bx
        
        inc si ; Siguiente posición en array de enteras
        inc di ; Siguiente posición en array de decimales
        dec bl
        jnz CICLO_INTERNO

        dec cl
        jnz CICLO_EXTERNO
    fin_sort:
        jmp salir ;Para que no siga con el codigo de Descendente

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
        lea si, notas ; Parte entera
        lea di, notas_decimales ; Parte decimal
        mov ch, 0
        mov bl, cl ; Ciclo interno

    CICLO_INTERNODescen:
        ; Preservar registros
        push bx
        push si
        push di
        
        mov al, [si] ; Nota entera actual
        mov dl, [si+1] ; Nota entera siguiente
        
        ; Comparar partes enteras (orden descendente)
        cmp al, dl
        JAE NO_SWAPDescen ; Si AL >= DL, no intercambiar (descendente)
        
        ; INTERCAMBIAR partes enteras
        mov [si], dl
        mov [si+1], al
        
        ; INTERCAMBIAR partes decimales correspondientes
        mov al, [di] ; Decimal actual
        mov dl, [di+1] ; Decimal siguiente
        mov [di], dl
        mov [di+1], al
        
    NO_SWAPDescen:
        ; Recuperar registros
        pop di
        pop si
        pop bx
        
        inc si ; Siguiente posición en array de enteras
        inc di ; Siguiente posición en array de decimales
        dec bl
        jnz CICLO_INTERNODescen

        dec cl
        jnz CICLO_EXTERNODescen
        
    fin_sortDescen:

        salir: ;para que pueda seguir con la impresión de notas, simplemente un lugar donde saltar, brincadose todo el proceso de por medio, es como un return controlado.
;--------Inicio impresion de notas----
; Salto de línea antes de imprimir notas
mov dl, 13
mov ah, 02h
int 21h
mov dl, 10
mov ah, 02h
int 21h

mov cl, contador
jcxz fin_impresion

mov si, offset notas ; Parte entera
mov di, offset notas_decimales ; Parte decimal

imprimir_notas_loop:
    ; Imprimir parte entera
    mov al, [si]
    call print_decimal
    
    ; Imprimir punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Imprimir parte decimal - MÉTODO CORREGIDO
    mov al, [di]         ; Cargar parte decimal (ej: 12, 13, etc.)
    
    ; LIMPIAR COMPLETAMENTE AX antes de la división
    xor ah, ah           ; Limpiar AH (IMPORTANTE!)
    mov bl, 10
    div bl               ; AL = decenas, AH = unidades
    
    ; Imprimir decenas
    add al, '0'          ; Convertir a ASCII
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Imprimir unidades
    mov dl, ah
    add dl, '0'          ; Convertir a ASCII
    mov ah, 02h
    int 21h

    ; imprimir un espacio entre notas
    mov dl, ' '
    mov ah, 02h
    int 21h

    inc si ; Siguiente nota entera
    inc di ; Siguiente nota decimal
    loop imprimir_notas_loop

fin_impresion:
; salto de línea final
mov dl, 13
mov ah, 02h
int 21h
mov dl, 10
int 21h

; pausa (esperar tecla)
mov ah,08h
int 21h
cmp al,27
je Menu
jmp Menu
;--------Fin impresion de notas----

op5: ;salida
    mov ax,4c00h
    int 21h

    main endp ; Con este cierra el procedimiento(funcion) principal, o loop principal.

;Apartir de aca se ponen los procedimientos auxiliares o funciones auxiliares.
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
    xor ax, ax
    mov al, contador
    add di, ax        ; cada nota ocupa 1 byte
    call extraer_nota ; convertimos ASCII a número y guardamos en [di]   
    
    ; DEBUG: Mostrar lo que se guardó (PARTE ENTERA Y DECIMAL)
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Mensaje de debug
    mov ah, 09h
    lea dx, debug_msg
    int 21h
    
    ; Mostrar parte entera
    mov si, di
    mov al, [si]
    call print_decimal
    
    ; Mostrar punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar parte decimal (CORREGIDO)
    lea si, notas_decimales
    mov al, contador
    xor ah, ah
    add si, ax
    mov al, [si]        ; AL = valor decimal (ej: 12 para 0.12)
    
    ; Mostrar como dos dígitos decimales
    xor ah, ah
    mov bl, 10
    div bl              ; AL = decenas, AH = unidades
    
    ; Mostrar decenas
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Mostrar unidades
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    
    ; Nueva línea
    mov ah, 09h
    lea dx, nueva_linea
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

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
    cmp al, ' ' ; es -?
    je fin_campo
    cmp al, 13 ; es enter?
    je fin_campo
    cmp al, '$' ;es el indicador de fin?
    je fin_campo

    mov [di], al ;copiar caracter
    inc si
    inc di
    inc cx
    jmp extraer_caracter

fin_campo:
    inc si 

saltar_espacios:
    cmp byte ptr [si], ' '
    jne fin_skip_spaces
    inc si
    jmp saltar_espacios

fin_skip_spaces:

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

extraer_nota proc 
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Encontrar el último espacio en la cadena
    lea si, buffer + 2
    mov cl, [buffer+1]   ; longitud de la cadena
    mov ch, 0
    add si, cx
    dec si                ; apuntar al último caracter

    ; Buscar hacia atrás hasta encontrar un espacio
buscar_ultimo_espacio:
    cmp byte ptr [si], ' '
    je encontro_espacio
    dec si
    jmp buscar_ultimo_espacio

encontro_espacio:
    inc si               ; moverse al primer caracter de la nota

    ; Inicializar variables
    xor bx, bx           ; bx = parte entera (0-100)
    xor cx, cx           ; cx = parte decimal (0-99)
    mov dx, 0            ; dx = bandera (0=entera, 1=decimal)

convertir_numero:
    mov al, [si]
    
    ; Si encontramos un punto, cambiar a parte decimal
    cmp al, '.'
    je encontro_punto
    
    ; Si encontramos el final, terminamos
    cmp al, 13          ; enter
    je fin_conversion
    cmp al, ' '         ; espacio
    je fin_conversion
    cmp al, '$'         ; fin de cadena
    je fin_conversion
    
    ; Verificar que es un dígito
    cmp al, '0'
    jb fin_conversion
    cmp al, '9'
    ja fin_conversion
    
    ; Convertir dígito ASCII a número
    sub al, '0'
    mov ah, 0
    
    ; ¿Estamos procesando parte entera o decimal?
    cmp dx, 0
    jne procesar_decimal

    ; Procesar parte entera: bx = bx * 10 + ax
    procesar_entera:
        mov ax, bx
        mov dx, 10
        mul dx           ; dx:ax = ax * 10
        mov bx, ax
        mov al, [si]
        sub al, '0'
        mov ah, 0
        add bx, ax
        mov dx, 0        ; restaurar bandera
        jmp continuar

    ; Procesar parte decimal: cx = cx * 10 + ax
    procesar_decimal:
        mov ax, cx
        mov dx, 10
        mul dx           ; dx:ax = ax * 10
        mov cx, ax
        mov al, [si]
        sub al, '0'
        mov ah, 0
        add cx, ax
        mov dx, 1        ; mantener bandera decimal
        jmp continuar

    encontro_punto:
        mov dx, 1        ; activar bandera de parte decimal
        jmp continuar

    continuar:
        inc si
        jmp convertir_numero

fin_conversion:
    ; Guardar parte entera en el array original
    mov [di], bl
    
    ; Guardar parte decimal en el nuevo array
    push di
    lea di, notas_decimales
    mov al, contador
    xor ah, ah
    add di, ax
    mov [di], cl
    pop di

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
extraer_nota endp

; Entrada: AL = número 0–99, no soporta un 100 por ejemplo.
; Sale: imprime el número en pantalla
; Update de correción: Se preservan los registros porque sino peta 

print_decimal proc
    push ax
    push dx
    push cx ;PReserva el CX porque LOOP usa cx/cl, anteriormente al printear las notas lo hacía bien pero terminaba en bucle imprimiendo 
    ;basura porque el contador se modificaba aquí adentro.

    cmp al, 100
    jne not_hundred

    ; Caso especial: 100
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
    div bl          ; AL = decenas, AH = unidades(residuo)

    mov cl, ah      ; Guarda las unidades antes de que AX sea sobreescrito

    cmp al, 0
    je print_unit ;Sino hay decenas, imprimir solo la unidad.

    add al, '0' ;Convertir las descenas a ASCII
    mov dl, al
    mov ah, 02h
    int 21h ;imprimir decena

print_unit:
    mov dl,ch ;traer la unidad guardada
    add cl, '0' ;ASCII unidad
    mov dl, cl
    mov ah, 02h
    int 21h ; imprimir unidad

done:
    pop cx
    pop dx
    pop ax
    ret
print_decimal endp

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
    je estudiante_aprobado  ; 70.00 is passing
    
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
    ; If integer parts are equal, check decimal parts
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
    ; If integer parts are equal, check decimal parts
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
    div bl              ; AL = average integer part
    mov promedio_entera, al
    
    ; Calculate decimal average
    mov ax, suma_decimal
    mov bl, contador
    div bl              ; AL = average decimal part
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

; Procedimiento para mostrar números decimales de 2 dígitos correctamente
mostrar_decimal proc
    push ax
    push bx
    push dx
    
    ; Mostrar como dos dígitos decimales
    xor ah, ah
    mov bl, 10
    div bl              ; AL = decenas, AH = unidades
    
    ; Mostrar decenas
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Mostrar unidades
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    
    pop dx
    pop bx
    pop ax
    ret
mostrar_decimal endp

mostrar_suma_corregida proc
    push ax
    push bx
    push cx
    push dx
    
    ; Mostrar mensaje de suma
    mov dx, offset msg_suma
    mov ah, 09h
    int 21h
    
    ; Mostrar parte entera de la suma
    mov ax, suma_entera
    call print_decimal
    
    ; Mostrar punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar parte decimal de la suma correctamente
    mov al, byte ptr suma_decimal
    call mostrar_decimal
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mostrar_suma_corregida endp

end main ; Indica al ensamblador donde arrancar a ejecutar procedimientos(funciones)