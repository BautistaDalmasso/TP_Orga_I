.data
	mat_revelada: .ascii "  #   #     (   )        &          %           &  %             =    !     /      ~~  @= @  / !    "
	mat_mapa: .space 100, 0x3f	// Codigo ascii del caracter "?"

	cords_x: .ascii "  0 1 2 3 4 5 6 7 8 9"

	cr: .ascii "\n"		// Carriage return, guardamos el salto de linea.
	spc: .ascii " "		// Espacio para imprimir.
	c_y: .ascii "0"		// Lo usamos para imprimir la coordenada y.

.text

	/* Imprime la matriz del mapa de manera bonita.
	inputs: mat_mapa
	outputs: - */
	imprMapa:
		.fnstart
		push {r0, r1, r2, r3, r4, r5, r7, lr}
		/* Guardamos las posiciones de memoria de todos los caracteres que vamos a imprimir. */
		ldr r5, =c_y	// Posición de la coordenada y para imprimir.
		ldr r4, =mat_mapa // Posición del caracter del mapa a imprimir.

		ldr r1, =cords_x // Lista de coordenadas x para imprimir.

		// Imprimir cords_x
		mov r7, #4
		mov r0, #1
		mov r2, #21
		swi 0

		mov r3, #0x30	// Coordenada Y en ascii.

		// Ciclo para imprimir filas.
		ciclo_y:
			ldr r1, =cr
			bl imprChar	// Imprimimos un salto de línea.

			// Cargamos el valor ascii de la coordenada y en c_y.
			strb r3, [r5]
			// Imprimimos el número de la coordenada y.
			mov r1, r5
			bl imprChar

			// Ciclo para imprimir caracteres individuales por columna.
			mov r6, #0		// Guardamos la cantidad de caracteres que imprimimos esta fila.
			ciclo_x:
				ldr r1, =spc
				bl imprChar	// Imprimimos un espacio.

				mov r1, r4	// Imprimimos el caracter del mapa que sigue:
				bl imprChar

				add r6, #1
				add r4, #1	// Avanzamos al siguiente valor del mapa.

				// Si imprimimos menos de 10 caracteres continuamos con el ciclo.
				cmp r6, #10
				blt ciclo_x

			add r3, #0x1 // Pasamos al siguiente valor de Y.

			// Si no imprimimos los números del 0 al 9, repetimos el ciclo.
			cmp r3, #0x3a
			blt ciclo_y 

		ldr r1, =cr
		bl imprChar	// Ultimo salto de linea antes de salir del procedimiento.

		pop {r0, r1, r2, r3, r4, r5, r7, lr}
		bx lr
		.fnend

	/* Imprime un unico caracter
	inputs: 
		r1: posición en memoria del caracter a imprimir.
	outputs: - */
	imprChar:
		.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		// mov r1, r1 -> posición en memoria del caracter a imprimir viene por input.

		mov r7, #4
		mov r0, #1
		mov r2, #1
		swi 0

		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
		.fnend

	.global main
	main:
		bl imprMapa


		salir:
			mov r7, #1
			swi 0
