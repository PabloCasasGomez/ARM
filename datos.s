.data
.include "src/defs.s"

.global bienvenido
bienvenido:   .asciz "Bienvenido a MiniOS (2020). Introduzca comandos a continuacion.\nUse el comando help para ayuda.\n"

.global pregunta
pregunta: .asciz " > "

.global error_comando
error_comando: .asciz "Comando no reconocido\n"
.global str_error_numero
str_error_numero: .asciz "Error: no se pudo parsear expresion\n"

.global cmd_set_r
cmd_set_r: .asciz "set r"
.global cmd_set_int
cmd_set_int: .asciz "set %"
.global cmd_help
cmd_help: .asciz "help"
.global cmd_lista_int
cmd_lista_int: .asciz "lista_int"
.global cmd_lista_reg
cmd_lista_reg: .asciz "list_reg"
.global cmd_print
cmd_print: .asciz "print"
.global cmd_if
cmd_if: .asciz "if"
.global cmd_input
cmd_input: .asciz "input"
.global cmd_pause
cmd_pause: .asciz "pause"

.global mensaje_vars_int
mensaje_vars_int: .asciz "Numero de variables enteras: "
.global mensaje_pausa
mensaje_pausa: .asciz "Press any key to continue... "
.global mensaje_registro
mensaje_registro:   .asciz "Se imprimiran el listado de registro completo\n"
.global mensaje_puntos_espacio
mensaje_puntos_espacio:   .asciz ":   "
.align
/*Añadida para indicar que el nombre de la variable es de mas de 11 caracteres */
.global error_limite_mem
error_limite_mem:   .asciz "El nombre de la variable no puede superar los 11 caracteres"
.align

.global registros_virtuales    // Algunas funciones en utils.s deben tener acceso
registros_virtuales:
.space 40

.global buffer_int         // Algunas funciones en utils.s deben tener acceso
buffer_int:
.space TAM_BUFFER_VARS

.global buffer_string      // Algunas funciones en utils.s deben tener acceso
buffer_string:
.space TAM_BUFFER_VARS

.global buffer_comprobador      // Buffer para comprobar nuestro valor introducido, solo guardará un string cada vez y no tenemos espacio optimizado
buffer_comprobador:
.space TAM_BUFFER_VARS

.global buffer_comando     // Almacena el comando a ejecutar
buffer_comando:
.space TAM_STRING

.global buffer_input         // Algunas funciones en utils.s deben tener acceso
buffer_input:
.space TAM_BUFFER_VARS

.global buffer_tipo     // Tenemos acceso desde utils.s
buffer_tipo:
.space 400

.global contador    // Tenemos acceso desde utils.s
contador:
.word 0           

.global n_vars_int
n_vars_int:
.word 0

.global historico

.global mensaje_ayuda
mensaje_ayuda:  .ascii "Lista de comandos:\n"

                .ascii "Comandos basicos: \n"
                .ascii "help\t\t\t-->\tMuestra esta lista de comandos.\n"
                .ascii "print <expresion>\t-->\tMuestra una expresion en pantalla. Ej: print r2 ; print \"Hola caracola\"\n"
                .ascii "set r<n>=<valor>\t-->\tModifica el contenido del registro indicado (0-9) (ej: set r1=r1+2)\n"
                .ascii "input r<n>\t\t-->\tHace que el usuario introduzca el valor del registro r<n> (ej: input r2)\n"
                .ascii "\n"
                .ascii "------------ Comandos de listado -------------------\n\n"
                .ascii "list_int\t\t-->\tMuestra una lista de variables enteras definidas.\n"
                .ascii "list_reg\t\t-->\tMuestra una lista con los registros disponibles.\n"
                .ascii "\n------------ Variables de entorno -------------------\n\n"
                .ascii "set %<var_name>=<valor>\t-->\tModifica o crea una variable entera. Ej: set %a=%a+2\n"
                .ascii "\n"
                .ascii "------------ Comandos de ejecucion -------------------\n\n"
                .ascii "if <cond.> <comando>\t-->\tEjecuta una instruccion si se cumple una condicion (ej if r1>0 print \"r1 mayor que cero\")\n"
                .ascii "\n------------ PARA SALIR DE LA CONSOLA -------------------\n\n"
                .ascii "CTRL+A x\t\t-->\tSale de la emulacion (QEMU, Linux)\n"
                .asciz "CTRL+C\t\t\t-->\tSale de la emulacion (QEMU, Windows)\n"
.end
