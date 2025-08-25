org 100h

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
    
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27 ;ASCII 27 = ESC
    je Menu
    
    miNombre db 'Precionado opcion 1: Ingresar calificaciones ',13,10,13,10
            db 'precione ESC para volver a menu$'
        
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
    
    estadisticas db 'Precionaste opcion 2: mostrar estadisticas',13,10,13,10
            db 'precione ESC para volver a menu$'

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
    
    buscar db 'Precionado opcion 3: Buscar estudiante por indice ',13,10,13,10
            db 'precione ESC para volver a menu$'

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
    
    Ordenar db 'Precionado opcion 4: Ordenar ',13,10,13,10
            db 'precione ESC para volver a menu$'

op5: ;salida
    mov ax,4c00h
    int 21h
    