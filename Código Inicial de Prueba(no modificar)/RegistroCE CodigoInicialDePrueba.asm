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
    
    cmp al,49 ;compara con opcion 2 apellido,compara en ASCII, 49 es 1
    je op1  ; salto condicional, salta .
    
    cmp al,50 ;compara con opcion 2 apellido
    je op2
    
    cmp al,51 ;compara con opcion 3 carne
    je op3
    
    cmp al,52 ;compara con opcion 4 salir
    je op4
    
    mostrarMenu db 'Universidad',13,10
                db 'Paradigmas de programacion',13,10
                db '-.-.MENU.-.-',13,10,13,10
                db '1. Ver Nombre',13,10,13,10
                db '2. Ver Apellido',13,10
                db '3. Ver Carne',13,10
                db '4. Salir',13,10,13,10
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
    
    mov ah,0
    mov al,13h ; Modo de video
    int 10h
    
    mov ah,0ch
    mov al,04h ;color del pixel
    mov bh,00 ;numero de pagina
    mov cx,10 ;pos x 10
    mov dx,10 ;pos y 10
    int 10h     
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,10 
    mov dx,11 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,10 
    mov dx,12 
    int 10h  
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,10 
    mov dx,13 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,10 
    mov dx,14 
    int 10h
    
    ;-09876543
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,11 
    mov dx,10 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,12 
    mov dx,11 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,14 
    mov dx,13 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,15 
    mov dx,14 
    int 10h 
    ;***************
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,15 
    mov dx,10 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,15 
    mov dx,11 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,15 
    mov dx,12 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,15 
    mov dx,13 
    int 10h
    ;***************
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,17 
    mov dx,10 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,17 
    mov dx,11 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,17 
    mov dx,12 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,17 
    mov dx,13 
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,17 
    mov dx,14 
    int 10h
    ;fin de N
    ;*************** inicio o
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,18 
    mov dx,10
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,19 
    mov dx,10
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,20 
    mov dx,10
    int 10h
;***************
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,21 
    mov dx,10
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,21 
    mov dx,11
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,21 
    mov dx,13
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,21 
    mov dx,14
    int 10h
    ;***************
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,18 
    mov dx,14
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,19 
    mov dx,14
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,20 
    mov dx,14
    int 10h
    ;fin de O
    ;inicio de R
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,23 
    mov dx,10
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,23 
    mov dx,11
    int 10h
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,23 
    mov dx,12
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,23 
    mov dx,13
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,23 
    mov dx,14
    int 10h
    ;***************
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,24 
    mov dx,10
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,25 
    mov dx,10
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,26 
    mov dx,10
    int 10h
    ;***************
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,26 
    mov dx,11
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,26 
    mov dx,12
    int 10h
    ;***************
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,25 
    mov dx,12
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,24 
    mov dx,12
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,23 
    mov dx,12
    int 10h
    ;***************
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,23 
    mov dx,12
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,25 
    mov dx,13
    int 10h
    
    mov ah,0ch
    mov al,04h 
    mov bh,00 
    mov cx,26 
    mov dx,14
    int 10h
    ;fin de R
    
    mov dx, offset volver
    mov ah,09
    int 21h
    
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27
    je Menu
    
    volver db ' ',13,10,13,10
        db 'presione "ESC" para volver a menu$'
        
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
    
    mov dx, offset miNombre
    mov ah,09
    int 21h
    
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27 ;ASCII 27 = ESC
    je Menu
    
    miNombre db 'Amezquita',13,10,13,10
             db 'precione ESC para volver a menu$'

op3: ;carne
    
    mov ax,0600h ;limpiar pantalla
    mov bh,0Fh ; 0 fondo negro, f letra blanca
    mov cx,0000h
    mov dx,184Fh
    int 10h
    
    mov ah,02h
    mov bh,00
    mov dh,00
    mov dl,00
    int 10h
    
    mov ah,0
    mov al,13h ;modo de video
    int 10h
    
    mov ah,0eh
    mov al, "2" ;texto a mostrar
    mov bl,0fh; color de la letra a mostrar en pantalla
    int 10h
    
    mov al, "0"
    mov bl,0eh
    int 10h
    
    mov al, "6"
    mov bl,0ch
    int 10h
    
    mov al, "3"
    mov bl,0bh
    int 10h
    
    mov al, "0"
    mov bl,0ah
    int 10h
    
    mov al, "5"
    mov bl,9
    int 10h
    
    mov al, "3"
    mov bl,8
    int 10h
    
    mov al, "4"
    mov bl,7
    int 10h
    
    mov dx, offset esc
    mov ah,09
    int 21h
    
    mov ah,08 ;pausa y captura de datos
    int 21h
    cmp al,27
    je Menu
    
    esc db ' ', 13,10,13,10
        db 'precione ESC para volver a menu$'
    
    mov ax,4c00h
    int 21h

op4: ;salida
    mov ax,4c00h
    int 21h
    
           