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
    
    ;Buffer para entrada de nombre
    buffer db 128 ;maximo 50 caracteres + enter
            db ? ;espacio para longitud real
            db 128 dup('$') ;espacio para el nombre se aumentó la capacidad

    ;Array para almacenar los 15 nobres
    nombres db 15 dup(20 dup('$'))  ;Nombres
    apellidos1 db 15 dup(20 dup('$')) ;Apellidos 1
    apellidos2 db 15 dup(20 dup('$')) ;Apellidos 2
    notas dd 15 dup(0) ; cada nota sera 32 bits (4 bytes) 
    
    enteros   dw 15 dup(0)    ; parte entera de cada estudiante
    decimales dw 15 dup(0)    ; parte decimal de cada estudiante (5 decimales, multiplicado por 100000)

    
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
    ; Limpiar pantalla
    mov ax,0600h
    mov bh,0fh        ; fondo negro, letra blanca
    mov cx,0000h
    mov dx,184Fh
    int 10h
    
    ; Mover cursor a (0,0)
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h
    
    ; Mostrar mensaje de instrucción
    mov dx, offset miNombre
    mov ah,09
    int 21h

    mov bx,15 ; cantidad de estudiantes a ingresar
ingresar_dato_op1Loop:
    ; Mostrar mensaje con contador
    mov ah, 09h
    lea dx, msg_contador
    int 21h
    call mostrar_numero

    ; Mostrar "/15"
    mov ah, 09h
    lea dx, msg_total
    int 21h

    ; Mostrar formato de ingreso
    mov ah,09
    lea dx, msg_formato
    int 21h

    ; Pedir datos
    mov ah, 0Ah
    lea dx, buffer
    int 21h

    ; Revisar si presionó ESC
    mov al, [buffer+2]
    cmp al, 27
    je Menu

    ; Limpiar ENTER al final de la cadena
    mov si, offset buffer
    mov cl, [si+1]
    mov byte ptr [si+2+cx], '$'

    ; Separar nombres y apellidos
    call separar_datos_nombres

    ; Extraer nota (llenar enteros y decimales)
    lea si, buffer
    add si, 2           ; saltar longitud
    call extraer_nota_5dec_seg

    ; Mostrar inmediatamente la nota en XX.YYYYY
    call print_nota_seg

    ; Salto de línea
    mov dl,13
    mov ah,02h
    int 21h
    mov dl,10
    int 21h

    ; Incrementar contador
    inc contador

    ; Salto de línea
    mov ah,09h
    lea dx,nueva_linea
    int 21h

    dec bx
    jnz ingresar_dato_op1Loop

; Mostrar mensaje de completado
mov ah,09
lea dx,msg_completado
int 21h

jmp Menu


op2:
    ; Limpiar pantalla
    mov ax,0600h
    mov bh,1eh        ; fondo azul, letra amarilla
    mov cx,0000h
    mov dx,184Fh
    int 10h

    ; Mover cursor a (0,0)
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h

    ; Mostrar encabezado de estadísticas
    mov dx, offset estadisticas
    mov ah,09
    int 21h

    ; Verificar si hay estudiantes
    mov al, contador
    cmp al, 0
    je fin_op2      ; si no hay datos, saltar

    ; Mostrar notas
    lea si, notas       ; SI apunta al inicio del array de notas
    mov cl, contador    ; cantidad de estudiantes

imprimir_notas_op2:
    ; Llamar a la función corregida para imprimir con decimales
    call print_decimal5_fixed

    ; imprimir un espacio entre notas
    mov dl, ' '
    mov ah, 02h
    int 21h

    add si, 4         ; avanzar al siguiente entero de 32 bits
    dec cl
    jnz imprimir_notas_op2

fin_op2:
    ; Salto de línea final
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h

    ; Pausa hasta tecla
    mov ah,08h
    int 21h
    cmp al,27         ; ESC para volver al menú
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
        PUSH DS ;se guarda el valor del registro de segmento de datos en la pila, para preservar el estado antes de moficarlo.
        MOV AX, @data ;todo el segmento de datos cargado en AX
        MOV DS, AX ;DS = segmento de datos
        MOV ES, AX  ;para copias

        ; Ciclo externo
        mov cl, contador ;Se aprovecha que el contador se actualizó con la cantidad de ingresos que hubieron, entonces esas van a ser la cantidad de comparaciones que haga.
        dec cl ;cl-1, es decir numero de pasadas necesarias.
        jz fin_sort ;Si no hay elementos, salta al final. (tremendo error pegaba esto)

        CICLO_EXTERNO:
            lea si, notas ;Pasa la dirección base de memoria de las notas, o la array donde están las notas
            mov ch, 0 ; CH = 0 deja limpio el registro.
            mov bl, cl ;Ciclo interno, cantidad de compraciones por pasada dadas por el contador.

        CICLO_INTERNO:
            mov al, [si] ;Se pasa el valor del indice que se encuentra en la direccion de la lista notas.
            mov dl, [si+1] ;Se incremeneta 1 a la actual para que así pueda comparar con el siguiente.
            cmp al, dl ;aca es cuando se compara y se decide.
            JBE NO_SWAP ;Si AL <= DL entonces no se haec swap...
            mov [si], dl ; Si AL >= DL entonces en nota[i] se pone el valor mayor
            mov [si+1], al ; y en nota[i+1] pones el valor menor.
        NO_SWAP:
            inc si ;Como no hay que hacer swap avanzamos SI a lsiguiente indice
            dec bl ;y se decrementa BL para hacer una compración menos
            jnz CICLO_INTERNO ; Si BL distinto de 0, sigue comparando.

            dec cl ;una pasada menos
            jnz CICLO_EXTERNO ;si aun faltan pasadas, repite.
        fin_sort:

            jmp salir ;Para que no siga con el codigo de Descendente

    BubbleDescendente:
        ; Configurar segmentos
        PUSH DS
        MOV AX, @data ;todo el segmento de datos cargado en AX
        MOV DS, AX ;DS = segmento de datos
        MOV ES, AX  ;para copias

        ; Ciclo externo
        mov cl, contador ;Se aprovecha que el contador se actualizó con la cantidad de ingresos que hubieron, entonces esas van a ser la cantidad de comparaciones que haga.
        dec cl ;cl-1, es decir numero de pasadas necesarias.
        jz fin_sortDescen ;Si no hay elementos, salta al final. (tremendo error pegaba esto)

        CICLO_EXTERNODescen:
            lea si, notas ;Pasa la dirección base de memoria de las notas, o la array donde están las notas
            mov ch, 0 ; CH = 0 deja limpio el registro.
            mov bl, cl ;Ciclo interno, cantidad de compraciones por pasada dadas por el contador.

        CICLO_INTERNODescen:
            mov al, [si] ;Se pasa el valor del indice que se encuentra en la direccion de la lista notas.
            mov dl, [si+1] ;Se incremeneta 1 a la actual para que así pueda comparar con el siguiente.
            cmp al, dl ;aca es cuando se compara y se decide.
            JAE NO_SWAPDescen ;“Jump if Above or Equal” = si AL = DL entonces ya está en orden descendente ? no swap..
            mov [si], dl ; Si AL < DL ? sí hay swap, porque en descendente queremos que el mayor quede primero.
            mov [si+1], al ; y en nota[i+1] pones el valor menor.
        NO_SWAPDescen:
            inc si ;Como no hay que hacer swap avanzamos SI a lsiguiente indice
            dec bl ;y se decrementa BL para hacer una compración menos
            jnz CICLO_INTERNODescen ; Si BL distinto de 0, sigue comparando.

            dec cl ;una pasada menos
            jnz CICLO_EXTERNODescen ;si aun faltan pasadas, repite.
        fin_sortDescen:

        salir: ;para que pueda seguir con la impresión de notas, simplemente un lugar donde saltar, brincadose todo el proceso de por medio, es como un return controlado.
;--------Inicio impresion de notas----
    ; Salto de línea antes de imprimir notas
    mov dl, 13       ; Carriage return
    mov ah, 02h
    int 21h
    mov dl, 10       ; Line feed
    mov ah, 02h
    int 21h

    mov cl, contador     ; cantidad de notas
    jcxz fin_impresion   ; si contador = 0, no hay nada que imprimir

    mov si, offset notas ; SI apunta al inicio del arreglo

imprimir_notas_loop:
    mov al, [si]         ; AL = nota actual
    call print_decimal16   ; imprime la nota

    ; imprimir un espacio entre notas
    mov dl, ' '
    mov ah, 02h
    int 21h

    inc si ; Se asegura de avanzar al siguiente valor en la array
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
    cmp al,27            ; ASCII 27 = ESC
    je Menu
    jmp Menu
;--------Fin impresion de notas----

op5: ;salida
    mov ax,4c00h
    int 21h

    main endp ; Con este cierra el procedimiento(funcion) principal, o loop principal.

;Apartir de aca se ponen los procedimientos auxiliares o funciones auxiliares.
;--------------------------------------
; PROCEDIMIENTO: separar_datos
;--------------------------------------
separar_datos proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    lea si, buffer + 2     ; inicio de cadena
    ;----------------------------------
    ; 1. Extraer Nombre
    lea di, nombres
    xor ax, ax
    mov al, contador       ; AL = contador (0..14)
    mov ah, 0
    mov bx, 20             ; tamaño fijo de cada nombre
    mul bx                 ; AX = contador*20
    add di, ax
    call extraer_campo

    ;----------------------------------
    ; 2. Extraer Apellido1
    lea di, apellidos1
    xor ax, ax
    mov al, contador
    mov ah, 0
    mov bx, 20
    mul bx
    add di, ax
    call extraer_campo

    ;----------------------------------
    ; 3. Extraer Apellido2
    lea di, apellidos2
    xor ax, ax
    mov al, contador
    mov ah, 0
    mov bx, 20
    mul bx
    add di, ax
    call extraer_campo

    ;----------------------------------
    ; 4. Extraer Nota (32 bits)
    lea di, notas
    xor ax, ax
    mov al, contador
    mov ah, 0
    shl ax, 2              ; cada nota = 4 bytes
    add di, ax
    call extraer_nota_5dec_seg

    pop di
    pop si
    pop dx
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
                    
;------------------------------------------------------




;--------------------------------------------------------
; print_nota_seg - FIXED VERSION
;--------------------------------------------------------
print_nota_seg proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Get integer part
    mov bl, contador
    mov bh, 0
    shl bx, 1
    mov si, offset enteros
    add si, bx
    mov ax, [si]      ; AX = integer part

    call print_decimal16 ; print integer part

    ; Print decimal point
    mov dl, '.'
    mov ah, 02h
    int 21h

    ; Get decimal part (×100000)
    mov si, offset decimales
    add si, bx
    mov ax, [si]      ; AX = decimal part × 100000

    ; Print exactly 5 decimal digits
    mov cx, 5
    mov bx, 10000     ; initial divisor
    
print_decimal:
    xor dx, dx
    div bx             ; AX = digit, DX = remainder
    
    add al, '0'        ; convert to ASCII
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Prepare for next digit
    mov ax, dx         ; remainder becomes new dividend
    push ax
    mov ax, bx
    mov bx, 10
    xor dx, dx
    div bx             ; BX = BX / 10
    mov bx, ax
    pop ax
    
    loop print_decimal

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_nota_seg endp

     

;--------------------------------------------------------
; extraer_nota_5dec_seg - WORKING VERSION (FIXED DUPLICATE LABEL)
;--------------------------------------------------------
extraer_nota_5dec_seg proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Encontrar inicio de la nota (después del segundo apellido)
    call encontrar_inicio_nota
    
    ; Inicializar variables
    xor ax, ax       ; AX = parte entera
    xor bx, bx       ; BX = parte decimal
    mov cx, 0        ; 0 = entero, 1 = decimal
    mov dx, 0        ; contador de dígitos decimales

procesar_caracter:
    mov dl, [si]     ; Leer carácter (usamos DL en lugar de BL)
    cmp dl, 13       ; Enter
    je finalizar
    cmp dl, '$'      ; Fin de cadena
    je finalizar
    cmp dl, ' '      ; Espacio
    je finalizar
    cmp dl, '.'      ; Punto decimal
    je punto_decimal
    
    ; Es un dígito - convertir de ASCII a número
    sub dl, '0'
    
    cmp cx, 0
    jne procesar_decimal

procesar_entero:
    ; AX = AX * 10 + DL
    push dx
    mov dx, 10
    mul dx
    pop dx
    add ax, dx
    jmp siguiente_caracter

procesar_decimal:
    ; Solo procesar hasta 5 dígitos decimales
    cmp dx, 5
    jge siguiente_caracter
    
    ; BX = BX * 10 + DL (parte decimal)
    push ax
    push dx
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    pop dx
    pop ax
    add bx, dx       ; Agregar el dígito convertido
    inc dx           ; Incrementar contador de decimales
    jmp siguiente_caracter

punto_decimal:
    mov cx, 1        ; Activar modo decimal
    xor dx, dx       ; Reiniciar contador de decimales
    jmp siguiente_caracter

siguiente_caracter:
    inc si
    jmp procesar_caracter

finalizar:
    ; Rellenar con ceros si tenemos menos de 5 dígitos decimales
    mov cx, 5
    sub cx, dx
    jle guardar_valores
    
rellenar_ceros_decimal:    ; <-- CHANGED LABEL NAME HERE
    push ax
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    pop ax
    loop rellenar_ceros_decimal    ; <-- CHANGED LABEL NAME HERE

guardar_valores:
    ; Guardar valores en arrays
    mov dl, contador
    mov dh, 0
    shl dx, 1
    
    mov di, offset enteros
    add di, dx
    mov [di], ax
    
    mov di, offset decimales
    add di, dx
    mov [di], bx

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

encontrar_inicio_nota:
    ; Buscar el inicio de la nota (después del TERCER espacio)
    mov cx, 3        ; Buscar 3 espacios (nombre + apellido1 + apellido2)  <-- CAMBIAR 2 POR 3
buscar_espacios:
    mov al, [si]
    cmp al, ' '
    jne continuar_busqueda
    dec cx
    jz encontrado
continuar_busqueda:
    inc si
    jmp buscar_espacios
encontrado:
    inc si           ; Saltar el espacio
    ; Ahora estamos después del TERCER espacio, donde comienza la nota
    ret          ; Saltar el espacio

extraer_nota_5dec_seg endp

;--------------------------------------------------------
; debug_print_values - PARA DEPURACIÓN
; Muestra los valores almacenados en enteros y decimales
;--------------------------------------------------------
debug_print_values proc
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov ah, 09h
    lea dx, debug_msg
    int 21h
    
    ; Mostrar parte entera
    mov bl, contador
    mov bh, 0
    shl bx, 1
    mov si, offset enteros
    add si, bx
    mov ax, [si]
    call print_decimal16
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar parte decimal
    mov si, offset decimales
    add si, bx
    mov ax, [si]
    call print_decimal16
    
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

debug_msg db 13,10,'DEBUG: Entero.Decimal = $'
endp





;--------------------------------------------------------
; print_decimal16: imprime un número de 16 bits en AX
; Entrada: AX = número 0–65535
;--------------------------------------------------------
print_decimal16 proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, offset buffer+50 ; apuntar al final del buffer
    mov cx, 0                ; contador de dígitos

convert_loop16:
    xor dx, dx
    mov bx, 10
    div bx                    ; AX / 10 ? AX=cociente, DX=residuo
    add dl, '0'
    dec si
    mov [si], dl
    inc cx
    cmp ax, 0
    jne convert_loop16

print_loop16:
    mov dl, [si]
    mov ah, 02h
    int 21h
    inc si
    loop print_loop16

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_decimal16 endp

 

; Entrada: SI -> dirección de la nota (4 bytes)
print_decimal5_fixed proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, [si]
    mov dx, [si+2]     ; DX:AX = número completo
    mov cx, 0          ; contador de dígitos
    lea di, buffer+50  ; fin del buffer temporal

convert_loop:
    mov bx, 10
    div bx             ; DX:AX / 10
    add dl, '0'
    dec di
    mov [di], dl
    inc cx
    test ax, ax
    jnz convert_loop
    test dx, dx
    jnz convert_loop

    ; insertar punto decimal 5 posiciones desde el final
    mov bx, 5
    cmp cx, bx
    jge tiene_decimales

    ; si hay menos de 5 dígitos, rellenar con ceros
rellenar_ceros:
    dec di
    mov byte ptr [di], '0'
    inc cx
    cmp cx, bx
    jl rellenar_ceros

tiene_decimales:
    sub cx, 5
    mov si, di
    add si, cx
    dec si
    mov dl, '.'
    mov ah, 02h
    int 21h

imprimir_digitos:
    mov dl, [di]
    mov ah, 02h
    int 21h
    inc di
    loop imprimir_digitos

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_decimal5_fixed endp 


;--------------------------------------------------------
; PROCEDIMIENTO: separar_datos_nombres
; Entrada: SI apunta al inicio del buffer del estudiante
;          DI apunta al inicio del arreglo de nombres del estudiante actual
;--------------------------------------------------------
separar_datos_nombres proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ;----------------------------------
    ; 1. Extraer Nombre
    mov bx,20           ; tamaño fijo del campo
    call extraer_campo
    ; DI ya apunta al final del nombre copiado
    ; SI apunta al siguiente carácter en buffer

    ;----------------------------------
    ; 2. Extraer Apellido1
    lea di, apellidos1
    xor ax,ax
    mov al, contador
    mov ah,0
    mul bx              ; offset = contador*20
    add di, ax
    call extraer_campo

    ;----------------------------------
    ; 3. Extraer Apellido2
    lea di, apellidos2
    xor ax,ax
    mov al, contador
    mov ah,0
    mul bx              ; offset = contador*20
    add di, ax
    call extraer_campo

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
separar_datos_nombres endp

end main ; Indica al ensamblador donde arrancar a ejecutar procedimientos(funciones)