/*------- */
.global fun_comprobador
fun_comprobador:
                /*r0-> Puntero lugar de comprobacion */
                /*r1-> Nº de variables */
                
                stmdb sp!,{r1-r10,lr}           //No salvaguardamos el r0 puesto que vamos a usarlo como devolucion

                mov r7,r0                       //Copio el puntero de comprobacion a r7
                mov r6,r1                       //Copiamos el valor de nº variables a r5
                mov r8,#0
bucle:				
                
                cmp r6,r8                       //Comparamos contador con el nº de variables
                beq no_encontrado               //En caso de acabar con todas vamos a devolver r0->-1
				ldr r1,=buffer_comprobador      //Puntero de memoria donde hemos guardado el nombre de la actual
                lsl r8,#4                       //Multiplicamos por 16 para sumar a la posicion incial del buffer
				add r7,r7,r8                    //Sumamos al buffer las posiciones necesarias
                lsr r8,#4                       //Dividimos entre 16 para recuperar valor original del contador
				bl strcmp                       //Comprobamos si las dos cadenas son la misma o no 
				cmp r0,#0                       //¿Son iguales?
				beq se_encontro                //Devolvemos un r0-> <numero de variable>
				add r8,#1                       //En caso de no encontrar sumamos 1 al contador
				cmp r8,r6                       //Comprobamos si nos hemos pasado
				beq f_comprobacion              //En caso de llegar al final y no encontrado r0->-1
				b bucle                         //Repetimos

no_encontrado:
                mov r0,#-1
                ldmia sp!,{r1-r10,pc}           //No hace falta ^ puesto que ya estamos cambiando de modo user/sys etc

se_encontro:
                mov r0,r8
                ldmia sp!,{r1-r10,pc}           //Recuperamos todos menos r0 que es lo que devolvemos