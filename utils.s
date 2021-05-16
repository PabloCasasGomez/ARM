.include "src/defs.s"

.text

//write_uart y 	read_uart para escribir caracter en consola y leer caracter de teclado (espera activa)

UARTDR:				.word 0x101f1000			// UART data register address
UARTFR:				.word 0x101f1018			// UART flag register address

/*--------------------------------------------------------------------------------------------------------------------------------     INICIO FUNCION COMPROBADOR*/
.global fun_comprobador
fun_comprobador:
                /*r0-> Puntero lugar de comprobacion */
                /*r1-> Nº de variables */
                
                stmdb sp!,{r4-r10,lr}           //No salvaguardamos el r0 puesto que vamos a usarlo como devolucion

                mov r7,r0                       //Copio el puntero de comprobacion a r7
                mov r6,r1                       //Copiamos el valor de nº variables a r6
                mov r8,#0
fc_bucle:				
                
                cmp r6,r8                       //Comparamos contador con el nº de variables
                beq fc_no_encontrado               //En caso de acabar con todas vamos a devolver r0->-1
                mov r0,r7                       //Recargamos el valor de r7 en r0 que es el puntero de lo que comprobamos
                ldr r1,=buffer_comprobador      //Puntero de memoria donde hemos guardado el nombre de la actual
                lsl r8,#4                       //Multiplicamos por 16 para sumar a la posicion incial del buffer
                add r0,r0,r8                    //Sumamos al buffer las posiciones necesarias
                lsr r8,#4                       //Dividimos entre 16 para recuperar valor original del contador
                bl strcmp                       //Comprobamos si las dos cadenas son la misma o no 
                cmp r0,#0                       //¿Son iguales?
                beq fc_se_encontro                 //Devolvemos un r0-> <numero de variable>
                add r8,#1                       //En caso de no encontrar sumamos 1 al contador
                cmp r8,r6                       //Comprobamos si nos hemos pasado
                beq fc_no_encontrado              //En caso de llegar al final y no encontrado r0->-1
                b fc_bucle                         //Repetimos

fc_no_encontrado:
                mov r0,#-1
                b fc_fin


fc_se_encontro:
                mov r0,r8
                
fc_fin:
                ldmia sp!,{r4-r10,pc}           //Recuperamos todos menos r0 que es lo que devolvemos

/*--------*/
/*--------------------------------------------------------------------------------------------------------------------------------     FIN FUNCION COMPROBADOR*/

.globl write_uart
write_uart:			stmdb sp!,{r4}
					ldr r4,UARTDR
					strb r0,[r4]
					ldmia sp!,{r4}
					bx lr			

.globl read_uart
read_uart:			stmdb sp!,{r4,r5}
					ldr r4,UARTFR
wait_data:			ldr r5,[r4]
 	 				and r5,r5,#0x00000040
 	 				cmp r5,#0
 					beq wait_data
					ldr r4,UARTDR
					ldrb r0,[r4]
					ldmia sp!,{r4,r5}
					bx lr

// Funcion starts_with
// Param in : r0 --> cadena 1 la que yo escribo
//            r1 --> cadena 2 la del sistema (por la que debe empezar)
// Param out : r0 --> 1 si cadena 1 empieza por cadena 2
.global starts_with
starts_with: 	
        ldrb r3, [r1],#1	//r3 cadena del sistema
        cmp r3,#0
        beq sw_yes
        ldrb r2, [r0],#1	//r2 cadena del usuario
        cmp r2, r3
        beq starts_with

sw_no:      	
        mov r0, #0
        b sw_fin
sw_yes: 
        mov r0, #1
sw_fin:     
        bx lr

// Debug function: shows the string and its length
// Al ser de depuracion, salvaguardamos todos los registros para evitar cambios no previstos
.global pintaInfoString
pintaInfoString:
    stmdb sp!, {r0-r4,lr}
    mov r4, r0
    mov r0,#'\"'
    bl write_uart
    mov r0, r4
    bl printString
    mov r0,#'\"'
    bl write_uart
    mov r0,#'\t'
    bl write_uart
    mov r0,r4
    bl strlen
    bl printInt
    mov r0,#'\n'
    bl write_uart
    ldmia sp!, {r0-r4,pc}

// Funcion is space --> devuelve true (1) si es espacio, tab o \n
.global is_space
is_space:
    mov r3,#0
    cmp r0,#32
    moveq r3,#1
    cmp r0,#'\t'
    moveq r3,#1
    cmp r0,#'\n'
    moveq r3,#1
    cmp r0,#'\r'
    moveq r3,#1
    mov r0,r3
    bx lr

// Ignora los espacios al principio de la cadena
.global ignora_espacios
ignora_espacios:
    stmdb sp!,{r4,lr}
    mov r4,r0
    
buc_ignora_esp:
    ldrb r0,[r4]
    bl is_space
    cmp r0,#0
    beq f_ignora_espacios
    add r4,#1
    b buc_ignora_esp
    
f_ignora_espacios:
    mov r0,r4
    ldmia sp!,{r4,pc}

.global quita_espacios
// Copia la cadena de r1 en r0 quitando espacios al principio y al final
quita_espacios:
    stmdb sp!,{r4,r5,r6,lr}
    mov r4, r0
    mov r0, r1
    bl ignora_espacios    // Quitamos los espacios del principio
    mov r5, r0  // r5 apunta al comienzo donde queremos copiar
    bl strlen
    mov r6, r0  // r6 es la posicion del final de la cadena 
buc_encuentra_espacio:
    subs r6, #1
    movlt r6,#0
    blt f_buc_ee     // Si r6 es menor que cero --> no copiamos nada
    ldrb r0, [r5, r6]
    swi #0
    bl is_space
    cmp r0,#1
    swi #0
    beq buc_encuentra_espacio
    add r6,#1          // Tendremos que copiar uno mas que la posicion de la ultima letra
    swi #6
f_buc_ee:
    mov r2,r6
    mov r1,r5
    mov r0,r4
    bl strncpy
    ldmia sp!,{r4,r5,r6,pc}

.end
