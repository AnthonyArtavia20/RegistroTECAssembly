TITLE BubbleSort

DATOS SEGMENT
;Se declaran las varaibles aqui

ARRAY_DE_NOTAS DB 15, 12, 8, 5, 37, 255, 2, 0 ;8 elementos, 7 comparaciones

;----------------------------------------
DATOS ENDS

PILA SEGMENT
    DB 64 DUP(0)
PILA ENDS

CODIGO SEGMENT
    
ASSUME CS:CODIGO, DS:DATOS, SS:PILA

INICIO PROC FAR

PUSH DS
MOV AX,0
PUSH AX 

MOV AX, DATOS
MOV DS, AX
MOV ES, AX
;----------Codigo principal del desarrollo aqui:----------------------------

;Se neesitan hacer comparacion e intercambio de posiciones
;Para este ejemplo son 7 comparaciones al ser 8 numeros

MOV CX,7 ;Contador de 7.
;se limpian los registros ,indice,destino y fuente por si tienen un valor.
MOV SI,0
MOV DI,0

CICLO1:
PUSH CX ;Pone en la pila el valor de CX
LEA SI, ARRAY_DE_NOTAS ; Pasar la direccion efectiva del arreglo, al SI, va a pasar la direccion.
MOV DI,SI ;Luego pasarla a D1, Variable temporal, porque nesesitamos otro indice para comparar el siguiente. 
MOV CX,7 ;Ciclo interno, 7 comparaciones por pasada

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
INC SI ;Para que SI pueda seguir a analizar el siguiente
LOOP CICLO2 

POP CX
LOOP CICLO1
;Esto de arriba es como un ciclo anidado 


;------------------------------------------------
EXIT: ; Etiqueta que no se usa pero puede quedar aca.
;Para salir de una mejor forma de DOS en EMU8086:
MOV AX, 4C00h
INT 21h
INICIO ENDP
CODIGO ENDS
END INICIO