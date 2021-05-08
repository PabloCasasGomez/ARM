.include "src/defs.s"

.text

.globl _start
_start:     		ldr pc,reset_handler_d		// Exception vector
					ldr pc,undefined_handler_d
					ldr pc,swi_handler_d
					ldr pc,prefetch_handler_d
					ldr pc,data_handler_d
					ldr pc,unused_handler_d
					ldr pc,irq_handler_d
					ldr pc,fiq_handler_d

reset_handler_d:    .word reset_handler
undefined_handler_d:.word hang
swi_handler_d:      .word swi_handler
prefetch_handler_d: .word hang
data_handler_d:     .word hang
unused_handler_d:   .word hang
irq_handler_d:      .word hang
fiq_handler_d:      .word hang

// SWI handler routine.............................................
reset_handler:		
                    mov r0,#0x10000				// Copy exception vector
					mov r1,#0x00000
					ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
					stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
					ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
					stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
					msr cpsr_c,#0xD1			// FIQ 110 10001
					ldr sp,=FIQ_STACK_TOP
					msr cpsr_c,#0xD2			// IRQ 110 10010
					ldr sp,=IRQ_STACK_TOP
					msr cpsr_c,#0xD3			// SVC 110 10011
					ldr sp,=SVC_STACK_TOP
					msr cpsr_c,#0xD7			// ABT 110 10111
					ldr sp,=ABT_STACK_TOP
					msr cpsr_c,#0xDB			// UND 110 11011
					ldr sp,=UND_STACK_TOP
					msr cpsr_c,#0xD0			// USER 110 10000
					ldr sp,=SYS_STACK_TOP
					b main						// start main
    
.global hang
hang:				b hang
				
// declaracion de punteros a cadenas.............................

str_swi:			.asciz "swi "
msg_error:			.asciz "Parametro Desconocido"	//de C3
msg_spsr:			.asciz "Contenido spsr: "
msg_irq_on:			.asciz "Se habilita irq.\t"
msg_irq_off:		.asciz "Se deshabilita irq.\t"
msg_fiq_on:			.asciz "Se habilita fiq.\t"
msg_fiq_off:		.asciz "Se deshabilita fiq.\t"
                                
.align

// SWI handler routine...........................................

swi_handler: 		stmfd sp!,{r0-r9,lr}		
					ldr r5,[lr,#-4]		//direccion de swi
					bic r5,r5,#0xff000000	//lee el codigo de swi (campo de datos, borramos codigo operacion)

				//imprime en pantalla "swi"
					ldr r0,=str_swi		
					bl printString
					mov r0,r5		//imprime en pantalla el swi code
					bl printInt
					mov r0,#'\n'		//imprime en pantalla enter
					bl write_uart

				// TODO: Añadir aqui el codigo de C3

				//TODO: añadir codigo de C4 (para parte opcional 8)

swi_error:		
					ldr r0,=msg_error	//pone el mensaje de error
					bl printString
					mov r0,#'\n'		//enter
					bl write_uart
					b fin_swi_handler

	
fin_swi_handler:			ldmfd sp!,{r0-r9,pc}^	//C3 modifico para recuperar todos

muestra_spsr:		stmfd sp!,{lr}
					ldr r0,=msg_spsr
					bl printString
					mrs r0,spsr
					bl printHex
					mov r0,#'\ '		//enter
					bl write_uart
					mrs r0,spsr
					bl printBin
					mov r0,#'\n'		//enter
					bl write_uart
					ldmfd sp!,{pc}

/*.global muestra_registros
muestra_registros:
					// Mostramos un elemento de un array de words
					// Por r0 pasamos la base del array
					// Por r1 pasamos el numero del registro, la posición del array
					stmdb sp!,{r4-r8,lr}
					ldr r5,[r7,+r8,lsl #2]       /*guardamos en r0 la posicion de la pila +rn y desplazamos con lsl ,las veces que nos indica r5
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
					b muestra_registros
					ldmfd sp!,{r4-r8,pc}
*/

.global bucle_cadena
bucle_cadena: 		/* Funcion para obtener la cadena de caracteres comprendida entre dos valores*/
					/*R0 puntero de la cadena */
					/*R1 valor final de la cadena */
					ldrb r0,[r0,r6]
					bl write_uart
					add r6,r6,#1
					cmp r1,r6
					beq fin
					b bucle_cadena


.global imprime_intro
imprime_intro:	
					mov r0,#'\n'
					bl write_uart
					b f_interpr

fin:				bx lr


.end
