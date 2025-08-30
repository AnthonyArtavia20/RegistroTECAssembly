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
    msg_ingresar db 'ingrese datos (Formato: Nombre-Apellido1-Apellido2-Nota): $'
    msg_formato db 13,10, 'Ejemplo: Juan-Perez-Garcia-85',13,10,'$'
    msg_contador db 13,10, 'Estudiante $'
    msg_total db ' /15: $'
    msg_completado db 13,10,10, 'Se han guardado 15 estudiantes.$'
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

        ;Nueva linea
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

    ; Configurar segmentos
    PUSH DS
    MOV AX, data
    MOV DS, AX
    MOV ES, AX

    ;----------Codigo principal del desarrollo aqui:----------------------------

    ;Se neesitan hacer comparacion e intercambio de posiciones
    
    ;Ciclo externo: Tantas veces como cantidad de estudiantes -1
    MOV AX, 0  ;Limpiar AX
    MOV AL, contador ; tamaño de la lista = numero de estudiantes
    CMP AL,0
    JE Menu ;Si no hay estudiantes en la lista, regresa al menu
    MOV AH, 0 ;Limpiar la parte alta de AX
    MOV CX, AX ; CX = numero de estudiantes -1
    DEC CX ; porque el bubbleSort externo hace comparaciones hasta n-1
    
    ; validar CX para evitar underflow
    CMP CX,0
    JL Menu       ; si CX < 0, volver al menu

    CICLO1:
    PUSH CX ;Pone en la pila el valor de CX, guardar contador externo
    LEA SI, notas ; SI apunta al inicio del arreglo
    MOV DI,SI ;Luego pasarla a D1, Variable temporal, porque nesesitamos otro indice para comparar el siguiente. 

    ; Ciclo interno: comparaciones por pasada
    MOV DX, AX           ; DX = total de estudiantes
    DEC DX               ; DX = estudiantes - 1 (comparaciones)

    CICLO2:       
    INC DI ;Para poder incrementarle 1 a esa segunda variable y así poder comparar.
    MOV AL, [SI] ;Pasar ek valor que se encuentra en la dirección de SI a AL
    CMP AL, [DI] ;se compara con DI puesto que esta es la que apunta al siguiente indice, se le habia incrementado 1
    JA INTERCAMBIO ;Salta a la etiqueta si es mayor
    JB MENOR ;Short Jump si el primer operando esta por debajo del segundo operando, sin signo.

    INTERCAMBIO:
    MOV AH, [DI] ; Mueve el valor que se encuentra en DI a AH
    MOV [DI], AL ;Swap mueve el segundo numero para donde esta el primero
    MOV [SI], AH ;Pasa el valor de AH a la posicion de SI

    MENOR:
    INC SI
    DEC DX
    JNZ CICLO2           ; ciclo interno

    POP CX               ; restaurar externo
    DEC CX
    JNZ CICLO1           ; ciclo externo
    ;Esto de arriba es como un ciclo anidado 
    ;------------------------------------------------
    MOV AX, 4C00h
    
    ;---- Imprimir notas ordenadas ----
    MOV SI, offset notas   ; apuntar al inicio del arreglo de notas
    MOV AL, contador       ; n�mero de estudiantes
    MOV CL, AL             ; contador de bucle

    imprimir_notas_loop:
        MOV AL, [SI]   ; nota (0-99)
        MOV AH, 0
        MOV BL, 10
        DIV BL         ; AL = cociente (decenas), AH = residuo (unidades)
        ADD AL, '0'
        MOV DL, AL
        MOV AH, 02h
        INT 21h        ; imprime decena
        MOV DL, AH
        ADD DL, '0'
        MOV AH, 02h
        INT 21h        ; imprime unidad

        ; imprimir espacio
        MOV DL, ' '
        MOV AH, 02h
        INT 21h
    
        INC SI
        LOOP imprimir_notas_loop 
;--------Fin impresion de notas----
        
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



end main ; Indica al ensamblador donde arrancar a ejecutar procedimientos(funciones)