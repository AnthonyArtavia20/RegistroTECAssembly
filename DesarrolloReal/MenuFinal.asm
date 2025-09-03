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
    mov ax,0600h          ; Limpiar pantalla
    mov bh, 1eh           ; Fondo azul, letra amarilla
    mov cx,0000
    mov dx,184Fh
    int 10h

    mov ah,02h             ; mover cursor a (0,0)
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h

    mov dx, offset estadisticas
    mov ah,09
    int 21h

    ; ----------------------
    ; Imprimir notas de 32 bits
    ; ----------------------
    mov cl, contador       ; cantidad de estudiantes ingresados
    jcxz fin_op2           ; si no hay, saltar

    mov si, offset notas   ; apuntar al inicio del array de notas (32 bits por estudiante)

imprimir_notas_op2:
    ; Cargar la nota simulada de 32 bits en DX:AX
    mov ax, [si]           ; 16 bits bajos
    mov dx, [si+2]         ; 16 bits altos
    call print_decimal32    ; imprimir nota
    ; imprimir espacio
    mov dl, ' '
    mov ah, 02h
    int 21h

    add si, 4              ; avanzar al siguiente entero de 32 bits
    loop imprimir_notas_op2

fin_op2:
    ; salto de línea final
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h

    ; pausa hasta tecla
    mov ah,08h
    int 21h
    cmp al,27              ; ESC para volver al menú
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
    call print_decimal32   ; imprime la nota

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
separar_datos proc ;Para el ingresado de datos, por separarlos para que las distintas funciones puedan saber como interpretar los notas extraidas por ejemplo
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

; Entrada: buffer contiene la cadena "80.63421"
; Salida: DX:AX = entero simulado 8063421
extraer_nota proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    lea si, buffer + 2      ; inicio de la cadena real
    xor dx, dx              ; parte alta del entero
    xor ax, ax              ; parte baja del entero
    xor bx, bx              ; acumulador temporal
    xor cx, cx              ; contador de dígitos procesados

extraer_digito:
    mov bl, [si]            ; tomar caracter
    cmp bl, 13              ; fin de cadena
    je fin_nota
    cmp bl, '$'
    je fin_nota
    cmp bl, '.'             ; ignorar el punto decimal
    je siguiente_caracter

    sub bl, '0'             ; convertir ASCII -> dígito 0-9

    ; Multiplicar entero actual DX:AX por 10
    mov cx, ax
    shl dx, 1               ; dx:ax * 2
    rol ax, 1
    shl dx, 3               ; dx:ax * 8 (total *10)
    add ax, cx
    adc dx, 0

    add ax, bx              ; sumamos el dígito actual
    adc dx, 0

    inc cx                  ; contador de dígitos

siguiente_caracter:
    inc si
    jmp extraer_digito

fin_nota:
    ; DX:AX tiene el entero simulado
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

; ------------------------------------------------------
; print_decimal32: imprime DX:AX como número decimal
; Entrada: DX:AX = entero 32 bits
; Sale: número impreso en pantalla
; ------------------------------------------------------
print_decimal32 proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Reservar buffer temporal para dígitos
    lea si, buffer          ; usar buffer para almacenar dígitos
    mov di, si              ; DI apunta al inicio del buffer
    add di, 128             ; empezar desde el final del buffer
    mov cx, 0               ; contador de dígitos

    mov bx, 10              ; divisor para decimal

convert_loop:
    ; DX:AX / 10
    xor dx, dx              ; preparar DX para DIV
    div bx                  ; AX / 10 -> AL=quotient, AH=remainder?   
                            ; En modo 16 bits: necesitamos simular 32-bit, así que hacemos manual
    ; Para 32-bit simulados:
    ; Implementación simplificada usando DX:AX
    ; AH = residuo
    ; Guardar residuo
    push dx                 ; residuo
    inc cx
    ; Actualizar DX:AX -> siguiente división
    ; (implementar manual si quieres precisión de 32-bit)
    
    cmp ax, 0
    jne convert_loop

print_loop:
    pop dx                  ; residuo
    add dl, '0'             ; convertir a ASCII
    mov ah, 02h
    mov dl, dl
    int 21h
    loop print_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_decimal32 endp


end main ; Indica al ensamblador donde arrancar a ejecutar procedimientos(funciones)git