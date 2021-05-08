.include "src/defs.s"

.text

.globl main
main:           
        ldr r0, =bienvenido   	// Mostramos mensaje bienvenida (solo 1 vez)
		bl printString
			
//bucle externo se encarga de la linea de comandos
bucle_ext:	
        ldr r0, =pregunta     	// Mostramos simbolo de pregunta ' > '
        bl printString
        ldr r4, =buffer_comando // Con r4 iremos rellenando el buffer del comando actual
        mov r5,#0   // La posicion de la cadena es el 0
            
//bucle interno se encarga de los comandos
bucle_intro:		
		bl read_uart
		cmp r0, #'\n'
        beq fin_intro
		cmp r0, #'\r'
        beq fin_intro // Pulso ENTER --> interpretamos comando
		strb r0, [r4,r5]    	// Guardamos el caracter en el buffer
		bl write_uart
		add r5,r5,#1
        b bucle_intro
                                  	// linea siguiente
fin_intro:                        
        mov r0, #0    		// Sustituimos el \r por un terminador de cadena
        strb r0, [r4, r5]
        
        mov r0, #'\n'
        bl write_uart         	// Escribimos un retorno del carro para pasar a la siguiente linea
        mov r5,#0   // Sets the cursor in first place
        
        // Llamamos a interpretar el comando
        ldr r0, =buffer_comando
        bl interpreta
        cmp r0,#ERR_NON_VALID
		ldreq r0, =error_comando // Comando no reconocido --> muestra mensaje error
        bleq printString
        cmp r0,#ERR_PARSE
		ldreq r0, =str_error_numero // Mostramos error de parseo si es igual
        bleq printString
        
	b bucle_ext // Esperamos el siguiente comando
		
.end
