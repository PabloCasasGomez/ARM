.include "src/defs.s"

// Funcion que interpreta un comando
// In: r0 --> cadena a interpretar
// Devuelve: r0 == 0 --> comando ok
//  ERR_NON_VALID error en la instruccion
//  ERR_PARSE error en el parseo de una expresion
.global interpreta
interpreta:
        stmdb sp!, {r4-r10, lr}           // Para poder modificar registros --> salvaguardamos todos!
        sub sp,sp, #TAM_STRING            // Reservamos espacio en la pila para una variable auxilar tipo cadena de tamaño TAM_STRING 
        mov r10, #0          // r10 tiene el codigo de error. Antes de salir de la función lo copiaremos a r0 para retornar dicho valor

        bl ignora_espacios        
        mov r4, r0     		// r4 tiene el comando a interpretar sin espacios al principio

        bl strlen
        cmp r0,#0
        beq f_interpr // Si la cadena está vacía, retornamos

        // Para facilitar interpretacion de evaluacion de registros --> guardamos el puntero a los registros en una var global
comprueba_help:


        // Comparamos con los comandos llamando a starts_with o strcmp (ver utils.s y auxiliar.c, respectivamente)

        // Ejemplo strcmp
        mov r0, r4
        ldr r1, =cmd_help	//primero vemos si es help
        bl strcmp
        cmp r0, #0		// r0=0 es que las cadenas son identicas
        beq ej_help

        // Ejemplo starts with
        @ mov r0, r4
        @ ldr r1, =cmd_help	//primero vemos si es help
        @ bl starts_with
        @ cmp r0, #1		// r0=1 es que empieza por help
        @ beq ej_help
            
        // TODO: Implementa los demas comandos!!!
        
        /* Comprobamos "set r" */
        mov r0,r4               //Empleamos el mismo formato que tenemos en el código ya aportado
        ldr r1,=cmd_set_r
        bl starts_with          //Usamos la funcion de C ya aportada para comprobar si tenemos el mismo inicio de sentencia
        cmp r0,#1               //La funcion nos devuelve un 1 si empiezan igual o un 0 si no
        beq ej_set_r            //Para el caso de que se empiece de la misma forma vamos a ej_set_r

        /* Comprobamos si es un "list_reg" */
        mov r0,r4
        ldr r1,=cmd_lista_reg
        bl starts_with
        cmp r0,#1
        beq ej_list_reg

        /* Comprobamos si es un "print" */
        mov r0,r4
        ldr r1,=cmd_print
        bl starts_with
        cmp r0,#1
        beq comprobacion_print

        /* Comprobamos si es "input" */
        mov r0,r4
        ldr r1,=cmd_input
        bl starts_with
        cmp r0,#1
        beq ej_input

        /* Comprobamos si es "set %" */
        mov r0,r4
        ldr r1,=cmd_set_int
        bl starts_with
        cmp r0,#1
        beq ej_set_int

        /* Comprobamos si es "lis %" */
        mov r0,r4
        ldr r1,=cmd_lista_int
        bl starts_with
        cmp r0,#1
        beq ej_list_int

        /* Comprobamos si es "pause" */
        mov r0,r4
        ldr r1,=cmd_pause
        bl starts_with
        cmp r0,#1
        beq ej_pause

        b error_cmd   // Si no hemos podido interpretar el comando --> devolvemos código de error


/* -------------------INICIO DE PROCESOS DE EJECUCION-------------------- */
ej_help:
        ldr r0, =mensaje_ayuda
        bl printString
        b f_interpr


        /*Ejecutamos el comando set R */
ej_set_r:
        #mov r0,#'F'             //Para comprobar yo si funciona mi codigo
        #bl write_uart
        mov r5,r4               //Movemos el valor de r4 a r5 para no modificar el original
        ldrb r6,[r5,#5]         //Se supone que siempre que tengamos un "set r" la posicion 6 de la cadena es la que incluye el valor numerico
        sub r6,r6,#48           //Como vimos en clase al quitarle 48 al caracter ascii lo convertimos en un numero
        add r0,r5,#7            //El numero del set rx=numero esta despues del = por tanto en la posicion 7
        bl atoi
        ldr r7,=registros_virtuales
        str r0,[r7,+r6,lsl #2]  //Lo guardo en la posicion concreta del buffer reservado 

        b f_interpr


/*----------------------------------------------------------------------------------------------------------------------------------------------- */
ej_set_int:
					/*Mismo proceso que el original */
					add r5,r4,#5
					mov r0,#'='                     //Busco en la cadena la posicion de "=" que indica que acabo el nombre de la variable
        			        mov r1,r5                       //R1 es el puntero que paso a la funcion find
        			        bl find
					mov r9,r0                       //Me devuelve en r0 el valor de la posicion donde esta el "="
					bl printInt                     //Debugger
                                        cmp r9,#11                      //Si el valor de = es mayor de 11 imprimos un error por pasarse del límite de memoria
					bgt error_mem           
					ldr r0,=buffer_comprobador    	//Apuntamos a la posicion en la que vamos a guardar la String
					mov r1,r5                       //Volvemos a cargar el valor de puntero de inicio en r1 porque puede haberse usado en alguna funcion 
					mov r2,r9                       //Cargamos la posicion donde hemos encontrado el "=" en el r2
					bl strncpy                      //Usamos la funcion de C que nos han aportado para copiar la String en la zona de memoria que queremos

                                        ldr r0,=buffer_comprobador      //Debugger
                                        bl printString                  //Debugger

					ldr r7,=n_vars_int
					ldr r7,[r7]
                                        mov r0,r7
                                        bl printInt                     //Debugger
					mov r8,#0

bucle:				
                                        cmp r7,r8
                                        beq f_comprobacion
					ldr r0,=buffer_string
					ldr r1,=buffer_comprobador
                                        lsl r8,#4
					add r0,r0,r8
                                        lsr r8,#4 
					bl strcmp
					cmp r0,#0
					beq modifica_reg
					add r8,#1
					cmp r8,r7
					beq f_comprobacion
					b bucle

modifica_reg:
                                        add r9,#1
					add r0,r5,r9					//R5 esta apuntando a justo despues de % y le sumamos r9 que indica donde acaba el = y empieza el num
					bl atoi

					ldr r1,=buffer_int				//Cargamos el buffer de datos
					str r0,[r1,r8, lsl #2]			        //Guardamos el valor obtenido de b atoi en la direccion de memoria que tenemos de r1.
					b f_interpr




mess_compro_completa:		.asciz "Comprobacion completa, la variable no esta descrita y se va a guardar la nueva variable\n"
			        .align
f_comprobacion:
					ldr r0,=mess_compro_completa
					bl printString
					ldr r0,=buffer_string
					ldr r1,=n_vars_int
					ldr r1,[r1]
					lsl r1,#4//Así multiplicamos el r1 (nº variables)*16
					add r0,r1
					mov r1,r5//Cargamos el puntero de la frase a partir de %
					mov r2,r9//Cargamos la posicion donde hemos encontrado el "=" en el r2
					bl strncpy//Usamos la funcion de C que nos han aportado para copiar la String en la zona de memoria que queremos

                                        add r9,#1                       //Sumamos 1 al puntero porque la cuenta se inicia en 0 en lugar de 1
                                        add r0,r5,r9
                                        bl atoi

					ldr r1,=buffer_int				//Cargamos el buffer de datos
					str r0,[r1,r8, lsl #2]			        //Guardamos el valor obtenido de b atoi en la direccion de memoria que tenemos de r1.

					ldr r0,=n_vars_int
                                        ldr r0,[r0]
					add r0,r0,#1
					ldr r1,=n_vars_int              //Cargamos el puntero al numero de variables que tenemos
					str r0,[r1]                     //Aumentamos en 1 el numero de variables

                                        ldr r0,=n_vars_int
                                        ldr r0,[r0]
                                        bl printInt

					b f_interpr
/*------------------------------------------------------------------------------------------------------------------------------------------------------------ */

message_list_int:       .asciz "Lista de variables de entorno\n"
                        .align

ej_list_int:
        mov r0,#'\n'
        bl write_uart
        ldr r0,=message_list_int
        bl printString
        ldr r7,=buffer_string
        mov r8,#0
        ldr r9,=n_vars_int
        ldr r9,[r9]

bucle_lista_VIR:
        lsl r8,#4
        add r5,r7,r8
        lsr r8,#4               //Dividimos y volvemos al valor original de r8
        #mov r0,r8
        #bl printInt             //Debugger para ver como se incrementa el valor de r8
        mov r0,r5
        bl printString

/* Parte donde leemos e imprimos el valor numerico guardado en el buffer */
bucle2:
        ldr r0,=mensaje_puntos_espacio
        bl printString
        ldr r6,=buffer_int
        lsl r8,#2
        ldr r5,[r6,+r8]
        mov r0,r5
        bl printInt
        mov r0,#'\n'
        bl write_uart
        lsr r8,#2               //Recupero el valor de r8 original haciendo la operacion opuesta a lsl #2
        add r8,r8,#1
        cmp r8,r9
        beq f_interpr
        b bucle_lista_VIR
/*FIN DEL MODO DE PRUEBA */
       
ej_list_reg:
        ldr r0,=mensaje_registro
        bl printString
        ldr r7,=registros_virtuales
        mov r8,#0

bucle_lista:
        ldr r5,[r7,+r8,lsl #2]
        mov r0,#'R'
        bl write_uart
        mov r0,r8
        bl printInt
        ldr r0,=mensaje_puntos_espacio
        bl printString
        mov r0,r5
        bl printInt
        mov r0,#'\n'
        bl write_uart
        add r8,r8,#1
        cmp r8,#10   
        beq f_interpr
        b bucle_lista

        /*Comprobamos si tenemos un print r o un print "" */
comprobacion_print:
        mov r0,r4
        ldrb r0,[r0,#6]
        mov r1,#'"'
        cmp r0,r1
        beq ej_print_1
        mov r1,#'r'
        cmp r0,r1
        beq ej_print_2
        mov r1,#'%'
        cmp r0,r1
        beq ej_print_3
        b error_cmd

ej_print_1:   
        mov r0,#'"'             //Introducimos el caracter que buscamos   
        mov r1,r4               //Cargamos el puntero de la instruccion a r1
        bl find                 
        mov r8,r0
        bl printInt             //Imprimimos por pantalla la posicion donde se encuentra " a modo de comprobacion 
        mov r0,#'\n'
        bl write_uart
        mov r1,r4               //Volvemos a cargar el puntero porque no sabemos si r1 se ha mantenido igual o no
        add r8,r8,#1            //Sumamos 1 al resultado puesto que empieza en 0 en lugar de 1
        add r1,r1,r8
        mov r9,r1               //Guardamos el puntero de la frase en r9, este puntero ya empieza justo despues del primer "
        mov r0,#'"'             //Introducimos el caracter que buscamos
        bl find
        mov r8,r0               //Salvaguardamos el resultado
        bl printInt             //Imprimos el valor de Find a modo de debuguer

        mov r0,#'\n'
        bl write_uart
        mov r6,#0

        /*Funcion que recibe un String y lee hasta un valor limite */
bucl_lec:
        ldrb r0,[r9,r6]
        bl write_uart
        add r6,r6,#1
        cmp r6,r8
        beq imprime_intro       //Estamos usando una funcion propia global que se encuentra en startup
        b bucl_lec

ej_print_2:
        mov r5,r4               //Movemos el valor de r4 a r5 para no modificar el original
        ldrb r6,[r5,#7]         //Se supone que siempre que tengamos un "print rx" la posicion 7 de la cadena es la que incluye el valor numerico
        sub r6,r6,#48           //Como vimos en clase al quitarle 48 al caracter ascii lo convertimos en un numero
        ldr r7,=registros_virtuales
        ldr r0,[r7,+r6,lsl #2]  //Lo guardo en la posicion concreta del buffer reservado 
        bl printInt


ej_print_3:
        mov r5,r4
        add r5,r5,#7
        mov r0,#'='
        mov r1,r5
        bl find
        mov r8,r0
        bl printInt
        add r8,r8,#1
        add r5,r5,r8
        mov r9,r5
        bl bucl_lec
        

        ldr r0,=n_vars_int
        ldr r0,[r0]
        
        mov r5,r4
        

ej_input:
        mov r5,r4               //Movemos el valor de r4 a r5 para no modificar el original
        ldrb r6,[r5,#7]         //Se supone que siempre que tengamos un "input rx" la posicion 7 de la cadena es la que incluye el valor numerico
        sub r6,r6,#48           //Como vimos en clase al quitarle 48 al caracter ascii lo convertimos en un numero
        #mov r0,#'K'
        #bl write_uart
        ldr r4, =buffer_input // Con r4 iremos rellenando el buffer del comando actual
        mov r5,#0   // La posicion de la cadena es el 0

bucle_intro:		
	bl read_uart
	cmp r0, #'\n'
        beq input_lectura
	cmp r0, #'\r'
        beq input_lectura       // Pulso ENTER --> interpretamos comando
	strb r0, [r4,r5]        // Guardamos el caracter en el buffer
	bl write_uart
	add r5,r5,#1
        b bucle_intro

input_lectura:
        mov r0,r4
        bl atoi
        ldr r7,=registros_virtuales
        str r0,[r7,+r6,lsl #2]  //Lo guardo en la posicion concreta del buffer reservado 
        #bl printInt            //Debugger para comprobar si funciona correctamente
        mov r0,#'\n'            //Metemos un salto de carro para separar la entrada del numero y la nueva pregunta de instruccion 
        bl write_uart           //Imprimimos el salto de carro
        b f_interpr


ej_pause:
        ldr r0,=mensaje_pausa
        bl printString
	bl read_uart
        mov r0,#'\n'
        bl write_uart
        b f_interpr

error_mem:
        ldr r0, =error_limite_mem
        bl printString
        b f_interpr

error_cmd:
        mov r10, #ERR_NON_VALID
        b f_interpr

.global f_interpr        
f_interpr:
        mov r0, r10                  // Copiamos el codigo de error en r0, que guarda el valor de retorno
        add sp, #TAM_STRING         // Liberamos la variable auxiliar
        ldmia sp!, {r4-r10, pc}

.end
