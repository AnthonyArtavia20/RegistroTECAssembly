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

    msg_error_indice db 13,10,'Error: Indice invalido.',13,10,'$'
    msg_sin_datos db 13,10,'No hay estudiantes registrados.',13,10,'$'
    msg_rango_valido db 'Rango valido: 1 a $'
    msg_presione_tecla db 'Presione cualquier tecla para continuar...$'
    debug_contador db 'DEBUG - Contador actual: $'
    debug_indice db 'DEBUG - Indice ingresado: $'
    
    ;variables de control
    contador db 0
    nueva_linea db 13,10,'$'
    temp db 0    
    
    msg_punto db '.$'

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
    
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27 ;ASCII 27 = ESC
    je Menu

    jmp Menu

op3: 
    ; Limpiar pantalla
    mov ax, 0600h
    mov bh, 1eh
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    
    ; Posicionar cursor
    mov ah, 02h
    mov bh, 00
    mov dh, 00
    mov dl, 00
    int 10h
    
    ; Mostrar mensaje
    mov dx, offset buscar
    mov ah, 09
    int 21h
    
    ; Verificar si hay estudiantes registrados
    mov al, contador
    cmp al, 0
    je op3_sin_datos
    
    ; DEBUG: Mostrar el contador actual
    mov dx, offset debug_contador
    mov ah, 09h
    int 21h
    mov al, contador
    call print_decimal
    mov ah, 09h
    lea dx, nueva_linea
    int 21h
    
    ; Leer entrada del usuario
    mov dx, offset buffer
    mov ah, 0Ah
    int 21h
    
    ; Verificar si presionó ESC (primer carácter)
    cmp byte ptr [buffer+2], 27
    je Menu
    
    ; Limpiar el ENTER del buffer CORRECTAMENTE
    mov si, offset buffer
    mov cl, [si+1]              ; longitud real en CL
    cmp cl, 0                   ; ¿No hay entrada?
    je op3_invalido

    ; Terminar la cadena en la posición correcta
    xor ch, ch                  ; CX = longitud real
    mov si, offset buffer + 2   ; Apuntar al inicio de los datos reales
    add si, cx                  ; SI apunta después del último carácter
    mov byte ptr [si], '$'      ; Colocar terminador

    ; Convertir entrada a número
    mov si, offset buffer + 2
    call atoi
    mov bl, al  ; Guardar el número en BL
    
    ; GUARDAR BL INMEDIATAMENTE para evitar corrupción
    push bx     ; Guardar BX en la pila
    
    ; DEBUG: Mostrar el índice convertido
    mov dx, offset debug_indice
    mov ah, 09h
    int 21h
    mov al, bl
    call print_decimal
    mov ah, 09h
    lea dx, nueva_linea
    int 21h
    
    ; Nueva línea
    mov ah, 09h
    lea dx, nueva_linea
    int 21h
    
    ; RECUPERAR BL antes de la validación
    pop bx      ; Recuperar BX de la pila
    
    ; Validar el índice - SIN MÁS DEBUG que pueda corromper registros
    cmp bl, 1
    jb op3_invalido      ; Si BL < 1, inválido
    
    cmp bl, 15           ; Máximo absoluto
    ja op3_invalido      ; Si BL > 15, inválido
    
    ; Verificar que no exceda el contador actual
    mov al, contador
    cmp bl, al
    ja op3_invalido      ; Si BL > contador, inválido
    
    ; Si llegamos aquí, es válido
    jmp indice_valido

    mov al, contador
    cmp bl, al           ; Comparar índice con contador
    jbe indice_valido    ; Si BL <= contador, es válido
    jmp op3_invalido     ; Si BL > contador, inválido

indice_valido:
    ; Mostrar estudiante (convertir a base 0 para el procedimiento)
    mov al, bl
    dec al  ; Convertir de índice base 1 a base 0
    call mostrar_estudiante_por_indice
    jmp op3_espera_tecla

op3_sin_datos:
    ; Mostrar mensaje cuando no hay datos
    mov dx, offset msg_sin_datos
    mov ah, 09h
    int 21h
    jmp op3_espera_tecla

op3_invalido:
    ; Mostrar mensaje de error con rango válido
    mov dx, offset msg_error_indice
    mov ah, 09h
    int 21h
    
    ; Mostrar rango válido
    mov dx, offset msg_rango_valido
    mov ah, 09h
    int 21h
    
    ; Mostrar número de estudiantes registrados
    mov al, contador
    call print_decimal
    
    mov dx, offset msg_punto
    mov ah, 09h
    int 21h

op3_espera_tecla:
    ; Nueva línea
    mov ah, 09h
    lea dx, nueva_linea
    int 21h
    
    ; Mostrar mensaje para continuar
    mov dx, offset msg_presione_tecla
    mov ah, 09h
    int 21h
    
    ; Esperar tecla
    mov ah, 08h
    int 21h
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

;Apartir de aca se ponen los procedimientos auxiliares o funciones auxiliares.
separar_datos proc
    push ax
    push bx
    push cx
    push si
    push di

    lea si, buffer + 2 ; SI apunta al inicio de los datos

    ; DEBUG: Mostrar buffer completo
    mov ah, 09h
    lea dx, buffer+2
    int 21h
    mov ah, 02h
    mov dl, '|'
    int 21h

    ; USAR contador ACTUAL (antes de incrementar) para calcular posiciones
    mov al, contador    ; posición actual (0-14)

    ; 1. Extraer nombre
    lea di, nombres
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    ; DEBUG: Mostrar nombre extraído
    push si
    lea si, nombres
    mov al, contador
    mov bl, 20
    mul bl
    add si, ax
    mov dx, si
    mov ah, 09h
    int 21h
    mov ah, 02h
    mov dl, '|'
    int 21h
    pop si

    ; 2. Extraer Apellido 1
    mov al, contador    ; recuperar posición actual
    lea di, apellidos1
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    ; DEBUG: Mostrar apellido1 extraído
    push si
    lea si, apellidos1
    mov al, contador
    mov bl, 20
    mul bl
    add si, ax
    mov dx, si
    mov ah, 09h
    int 21h
    mov ah, 02h
    mov dl, '|'
    int 21h
    pop si

    ; 3. Extraer Apellido 2
    mov al, contador    ; recuperar posición actual
    lea di, apellidos2
    mov bl, 20
    mul bl
    add di, ax
    call extraer_campo

    ; DEBUG: Mostrar apellido2 extraído
    push si
    lea si, apellidos2
    mov al, contador
    mov bl, 20
    mul bl
    add si, ax
    mov dx, si
    mov ah, 09h
    int 21h
    mov ah, 02h
    mov dl, '|'
    int 21h
    pop si

    ; 4. Extraer Nota
    mov al, contador    ; recuperar posición actual
    lea di, notas
    xor ah, ah
    add di, ax
    call extraer_nota

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

    mov cx, 0 ; contador de caracteres

; Saltar espacios iniciales
saltar_espacios_inicio:
    cmp byte ptr [si], ' '
    jne extraer_caracter
    inc si
    jmp saltar_espacios_inicio

extraer_caracter:
    mov al, [si]
    ; DEBUG: Mostrar caracter actual
    mov dl, al
    mov ah, 02h
    int 21h

    cmp al, ' ' ; ¿es espacio?
    je fin_campo
    cmp al, 13 ; ¿es enter?
    je fin_campo
    cmp al, '$' ; ¿fin de cadena?
    je fin_campo
    cmp al, 0   ; ¿null?
    je fin_campo

    mov [di], al ; copiar caracter
    inc si
    inc di
    inc cx
    cmp cx, 19   ; límite de 19 caracteres
    jae fin_campo
    jmp extraer_caracter

fin_campo:
    mov byte ptr [di], '$' ; terminador

    ; DEBUG: Mostrar fin de campo
    mov dl, '['
    mov ah, 02h
    int 21h
    mov dl, ']'
    int 21h

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

atoi proc
    push bx
    push cx
    push dx
    push si
    
    xor ax, ax      ; Limpiar resultado (AX = 0)
    xor bx, bx      ; Usar BX como acumulador temporal
    
atoi_loop:
    mov cl, [si]    ; Obtener carácter
    
    ; Verificar fin de cadena
    cmp cl, 13      ; Enter (Carriage Return)
    je atoi_done
    cmp cl, 10      ; Line Feed
    je atoi_done
    cmp cl, '$'     ; Fin de cadena
    je atoi_done
    cmp cl, 0       ; Null
    je atoi_done
    cmp cl, ' '     ; Espacio
    je atoi_done
    
    ; Verificar que es dígito
    cmp cl, '0'
    jb atoi_done
    cmp cl, '9'
    ja atoi_done
    
    ; Convertir ASCII a número
    sub cl, '0'     ; CL = dígito numérico (0-9)
    
    ; Multiplicar resultado actual por 10
    mov ax, bx      ; Mover resultado actual a AX
    mov dx, 10
    mul dx          ; AX = AX * 10
    mov bx, ax      ; Guardar resultado de vuelta en BX
    
    ; Sumar el nuevo dígito
    xor ch, ch      ; Limpiar CH para que CX = CL
    add bx, cx      ; BX = BX + nuevo dígito
    
    inc si          ; Siguiente carácter
    jmp atoi_loop
    
atoi_done:
    ; El resultado está en BX, moverlo a AX
    mov ax, bx
    
    pop si
    pop dx
    pop cx
    pop bx
    ret
atoi endp

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

mostrar_estudiante_por_indice proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Guardar el índice original
    mov bl, al      ; BL = índice (0-14)
    
    ; Calcular desplazamiento en los arrays (cada elemento 20 bytes)
    xor ah, ah      ; Limpiar AH
    mov cl, 20      ; Tamaño de cada elemento
    mul cl          ; AX = AL * 20
    mov si, ax      ; SI = desplazamiento para nombres/apellidos
    
    ; VERIFICAR Y MOSTRAR NOMBRE
    lea di, nombres
    add di, si
    call mostrar_cadena_si_valida
    
    ; Mostrar espacio
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; VERIFICAR Y MOSTRAR APELLIDO1
    lea di, apellidos1
    add di, si
    call mostrar_cadena_si_valida
    
    ; Mostrar espacio
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; VERIFICAR Y MOSTRAR APELLIDO2
    lea di, apellidos2
    add di, si
    call mostrar_cadena_si_valida
    
    ; Mostrar separador
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, '-'
    mov ah, 02h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    
    ; Mostrar nota
    xor bh, bh      ; BX = índice (0-14)
    lea si, notas
    add si, bx
    mov al, [si]    ; Obtener parte entera
    
    call print_decimal
    
    ; Mostrar punto decimal
    mov dl, '.'
    mov ah, 02h
    int 21h
    
    ; Mostrar parte decimal
    lea si, notas_decimales
    add si, bx
    mov al, [si]    ; AL = valor decimal
    
    ; Mostrar como dos dígitos decimales
    xor ah, ah
    mov cl, 10
    div cl          ; AL = decenas, AH = unidades
    
    ; Imprimir decenas
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    ; Imprimir unidades
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    
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
mostrar_estudiante_por_indice endp

; NUEVO PROCEDIMIENTO AUXILIAR: Mostrar cadena solo si es válida
mostrar_cadena_si_valida proc
    push ax
    push dx
    push si
    
    mov si, di
    cmp byte ptr [si], '$'   ; ¿Está vacío?
    je cadena_vacia
    cmp byte ptr [si], 0     ; ¿Es nulo?
    je cadena_vacia
    
    ; Cadena válida - mostrarla
    mov dx, di
    mov ah, 09h
    int 21h
    jmp fin_mostrar_cadena
    
cadena_vacia:
    ; Mostrar indicador de vacío
    mov dl, '?'
    mov ah, 02h
    int 21h
    
fin_mostrar_cadena:
    pop si
    pop dx
    pop ax
    ret
mostrar_cadena_si_valida endp

end main ; Indica al ensamblador donde arrancar a ejecutar procedimientos(funciones)