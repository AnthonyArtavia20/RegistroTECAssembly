## RegistroCE

## 📥 Requisitos

- Compilador Ensamblador **8086** (MASM o TASM)  
- **DOSBox**, **EMU8086** o emulador equivalente para ejecutar el programa  
- Sistema operativo con soporte de emulación DOS (Windows, Linux o macOS con DOSBox)  

### ¿Cómo usar?

##### Se deben descargar el archivo del proyecto y compilarlo con un ensamblador 8086 (MASM/TASM).  
Posterior a ello, se debe ejecutar el programa resultante (`MenuFinal.asm`) dentro de preferencia **Emu8086** o un emulador compatible.  

El sistema mostrará un menú principal en pantalla con las opciones disponibles, y a partir de ahí se interactúa usando el teclado.

---

## ¿Cómo funciona este programa?

##### Este programa está hecho en lenguaje **Ensamblador 8086**, utilizando interrupciones de **DOS (INT 21h)** para manejar la entrada de teclado y la impresión en pantalla.  
El proyecto consiste en la implementación de un sistema de **registro de calificaciones** para hasta 15 estudiantes, almacenando su **nombre, apellidos y nota** (con un máximo de 5 decimales).  

El sistema permite al usuario ingresar calificaciones, calcular estadísticas generales, buscar estudiantes por índice y ordenar las notas en orden ascendente o descendente mediante el algoritmo de **Burbuja (Bubble Sort)**.  

Este programa refuerza los conceptos fundamentales de programación de bajo nivel: **uso de registros, manejo de memoria, modularidad con subrutinas (CALL y RET), validación de entradas y control de flujo con ciclos y comparaciones.**

---

##### Características importantes:
+ **Ingreso de calificaciones:** Permite registrar hasta 15 estudiantes, validando nombres (solo letras y espacios) y notas (números en rango 0–100 con un solo punto decimal).  

+ **Estadísticas:** Calcula promedio general, nota máxima, nota mínima, cantidad y porcentaje de estudiantes **aprobados** (≥70) y **reprobados** (<70).  

+ **Búsqueda por índice:** Permite consultar cualquier estudiante almacenado según su posición en la lista.  

+ **Ordenamiento de calificaciones:** Implementación del algoritmo **Burbuja (Bubble Sort)** para organizar las notas en **ascendente o descendente**.  

+ **Manejo de errores:** El sistema detecta notas fuera de rango, índices inválidos y entradas incorrectas, mostrando mensajes claros al usuario.  
