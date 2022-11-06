.data
	mat_revelada: .ascii "  #   #     (   )        &          %           &  %             =    !     /      ~~  @= @  / !    "
	mat_mapa: .space 100, 0x3f	// Codigo ascii del caracter "?"

	cords_x: .ascii "  0 1 2 3 4 5 6 7 8 9"	// Eje de las x para imprimir.

	cr: .ascii "\n"		// Carriage return, guardamos el salto de linea.
	spc: .ascii " "		// Espacio para imprimir.
	c_y: .ascii "0"		// Lo usamos para imprimir la coordenada y.

	separador: .ascii "\n~~~~~~~~~~~~~~~~~~~~~\n"	// Separador para imprimir.
	
	/*estadisticas del jugador*/
        aciertos: .byte 0
        errores: .byte 0
        


//Para pedirCoordenadas 

	coordenada:.ascii " "
	mensaje_x: .ascii "Ingrese el valor de la coordenada x: "
	mensaje_y: .ascii "Ingrese el valor de la coordenada y: "


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

		// Imprimir eje x.
		ldr r1, =cords_x // Lista de coordenadas x para imprimir.
		mov r2, #21		 // Tamaño de la cadena.
		bl imprStr

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

		// Imprime un separador.
		ldr r1, =separador
		mov r2, #23
		bl imprStr

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

	/* Imprime una cadena.
	inputs:
		r1: posición en memoria de la cadena a imprimir.
		r2: tamaño de la cadena.
	outputs: - */
	imprStr:
		.fnstart
		push {r0, r1, r2, r7, lr}

		mov r7, #4
		mov r0, #1
		// r2 -> tamaño por input.
		// r1 -> pos en memoria por input.
		swi 0

		pop {r0, r1, r2, r7, lr}
		bx lr
		.fnend



	/* Da vuelta una figura en el mapa.
   	inputs:
		r2: posición x de la figura.
		r3: posición y de la figura.
	outputs: - */
	darVuelta:
		.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}

		// Calculamos el indice de figura a dar vuelta.
		bl calcNum

		// Buscamos la figura en el indice calculado.
		bl buscarFig
		// Reemplazamos esa figura en el mapa.
		bl cambiarMapa

		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
		.fnend

	/* Busca una figura en memoria y devuelve el caracter correspondiente.
	inputs:
		r0: indice de la figura.
	outputs:
		r1: caracter ascii de la figura. */
	buscarFig:
		.fnstart
		push {r0, r2, r3, r4, r5, r6, r7, lr}

		ldr r4, =mat_revelada	// Matriz donde buscaremos la figura.
		ldrb r1, [r4, r0]		// Obtenemos el caracter.

		pop {r0, r2, r3, r4, r5, r6, r7, lr}
		bx lr
		.fnend

	/* Cambia al caracter deseado en el mapa.
	inputs:
		r0: indice del caracter.
		r1: caracter ascii al que se quiere cambiar.
	outputs: - */
	cambiarMapa:
		.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}

		ldr r4, =mat_mapa		// Matriz que queremos cambiar.
		strb r1, [r4, r0]		// Guardamos el caracter en la posición.

		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
		.fnend


	/* Calcula el número (indice) de figura en las matrices dada una posición x e y.
	inputs:
		r2: posición x de la figura.
		r3: posición y de la figura.
	outputs:
		r0: número de la figura. */
	calcNum:
		.fnstart
		push {r1, r2, r3, r4, r5, r6, r7, lr}

		// FORMULA: x + 10*y
		mov r0, #10
		// 10*y
		mul r0, r3
		// sumamos x:
		add r0, r2

		pop {r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
		.fnend
		
	comparar_caracter:
                .fnstart
                push {r1,r2,r8,lr}

                /*r1 almancena el caracter uno, r2 almacena el caracter dos*/
                cmp r1,r2
                beq verdadero
                mov r8,#0
                bl sale
        verdadero:
                mov r8,#1
        sale:
                pop {r1,r2,r8,lr}
                bx lr
                .fnend
       
	
        /*suma la cantidad de intentos
        input: -
        outputs: r10 ->almacena la cantidad de intentos que hizo */
        sumar_aciertos:
                .fnstart
                push {r5,r10,lr}

				ldr r5,=aciertos /*direccion de acierto*/
                ldrb r10,[r5]  /*se almacena el elemento en r10*/
                add r10,#1    /*se suma en una unidad el valor de aciertos*/
                strb r10,[r5] /*envio a memoria el nuevo valor*/
							
                pop {r5,r10,lr}
                bx lr
                .fnend

        /*suma la cantidad de errores
        input: -
        outputs: r10 ->almacena la cantidad de errores que hizo */
        sumar_errores:
                .fnstart
                push {r5,r10,lr}
                ldr r5,=errores /*direccion de errores*/
                ldrb r10,[r5]  /*se almacena el elemento en r10*/
                add r10,#1    /*se suma en una unidad el valor de errores*/
                strb r10,[r5] /*envio a memoria el nuevo valor*/
                pop {r5,r10,lr}
                bx lr
                .fnend

	 /* Guarda la coordenada y luego obtiene el valor de la misma
		input= -
		output= r1 <- valor de la coordenada */
		obtenerCoordenada:
			.fnstart
			push { r0, r2, r3, r4, r5, r6, r7, lr }

			//guardo la direccion de la coordenada ascii en r1
			mov r7,#3
			mov r0,#0
			mov r2,#1
			ldr r1,=coordenada
			swi 0

			//rescato el valor (en ascii), y obtengo su valor
			ldrb r1,[r1]
			mov r0, #0x30
			sub r1,r0
			pop { r0, r2, r3, r4, r5, r6, r7, lr }
			bx lr
			.fnend

		/* Solicita coordenada (x,y)  y obtiene el valor de cada coordenada
		input= -
		output= en r2 coordenada x , en r3 coordenada y
		*/
		pedirCoordenadas:
			.fnstart
			push {r0, r1, r4, r7, lr}
			ldr r1,=mensaje_x
			mov r2,#37
			bl imprStr

			bl obtenerCoordenada

			mov r6,r1 //en r6 queda el valor que tiene que ir en  r2


			//Ingresamos mensaje para y
			mov r2,#37
			ldr r1,=mensaje_y
			bl imprStr

			bl obtenerCoordenada
			mov r5,r1 //en r5 queda el valor de r3

			pop {r0, r1, r4, r7, lr}
			bx lr
		.fnend


	.global main
	main:
		bl imprMapa
		
	//Con esto se hace el pedido y se pasa a r2 y r3 las coordenadas x e y en valores
	//bl  pedirCoordenadas
        //mov r2,r6
        //mov r3,r5
	

		salir:
			mov r7, #1
			swi 0
