.data
	mat_revelada: .ascii "  #   #     (   (        &          %           &  %             =    !     /      ~~  @= @  / !    "
	mat_mapa: .space 100, 0x3f	// Codigo ascii del caracter "?"

	cords_x: .ascii "  0 1 2 3 4 5 6 7 8 9"	// Eje de las x para imprimir.

	cr: .ascii "\n"		// Carriage return, guardamos el salto de linea.
	spc: .ascii " "		// Espacio para imprimir.
	c_y: .ascii "0"		// Lo usamos para imprimir la coordenada y.

	separador: .ascii "\n~~~~~~~~~~~~~~~~~~~~~\n"	// Separador para imprimir.
	
	/*estadisticas del jugador*/
	// En forma númerica:
	aciertos: .byte 0
	errores: .byte 0
	nulos: .byte 0
	// En forma de string:
	m_aciertos: .ascii "Nº de aciertos: "
	sAciertos: .ascii "00\n"
	.equ TMA, 16+4			// Tamaño del mensaje.
	
	m_errores: .ascii "Nº de errores: "
	sErrores: .ascii "00\n"
	.equ TME, 15+4			// Tamaño del mensaje.
	
	m_intentos: .ascii "Nº de intentos: "
	sIntentos: .ascii "00\n"
	.equ TMI, 16+4			// Tamaño del mensaje.
	
	m_vidas: .ascii "Nº de vidas: "
	sVidas: .ascii "15\n"
	.equ TMV, 13+4

	//Para pedirCoordenadas 

	input_x:.space 2
	input_y: .space 2
	mensaje_x: .ascii "Ingrese el valor de la coordenada x: "
	mensaje_y: .ascii "Ingrese el valor de la coordenada y: "

	// Indices de las figuras que fueron dadas vuelta.
	figura_1: .byte 1
	figura_2: .byte 1
	
	// Mensajes de acierto, fallo, victoria y derrota.
	m_acierto: .ascii "Acertaste!\n"

	.equ T_MENSAJE_VICTORIA, 22
	m_victoria: .ascii "Felicidades, ganaste!\n"

	.equ T_MENSAJE_DERROTA, 10
	m_derrota: .ascii "PERDISTE.\n"

	.equ T_MENSAJE_REINICIO, 39
	m_reinicio: .ascii "¿Quiere iniciar un nuevo juego? (Y/n): "
	reinicio_respuesta: .ascii "  "

	// Constantes:
	.equ APV, 5		// Aciertos para victoria.
	.equ EPD, 15	// Errores para derrota.
	.equ INM, 5		// Intentos nulos maximos.

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
		r0: indice de la figura.
	outputs: - */
	darVuelta:
		.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}

		// Buscamos la figura en el indice indicado.
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
		
	/* Compara dos caracteres y devuelve 1 si son iguales.
	inputs:
		r1: caracter a.
		r2: caracter b.
	outputs:
		r0: 1 si son iguales, 0 si no. */
	comparar_caracter:
		.fnstart
		push {r1,r2,lr}

		/*r1 almancena el caracter uno, r2 almacena el caracter dos*/
		cmp r1,r2
		beq verdadero
		
		mov r0,#0
		bl sale
		
		verdadero:
            mov r0,#1
			
        sale:
			pop {r1,r2,lr}
			bx lr
		.fnend
       
	
	/* Suma 1 a un byte en la memoria.
	input: r0: direccion de memoria del byte.
	outputs: - */
	incrementar_y_guardar:
		.fnstart
		push {lr}

		ldrb r1,[r0]  /*se almacena el byte en r0*/
		add r1,#1    /*se suma en una unidad el valor-*/
		strb r1,[r0] /*envio a memoria el nuevo valor*/
					
		pop {lr}
		bx lr
		.fnend


	 /* Guarda la coordenada y luego obtiene el valor de la misma
		input= r1 <- direccion de memoria donde guardar la coordenada.
		output= r1 <- valor de la coordenada */
		obtenerCoordenada:
			.fnstart
			push { r0, r2, r3, r4, r5, r6, r7, lr }

			//guardo la direccion de la coordenada ascii en r1
			mov r7,#3
			mov r0,#0
			mov r2,#2
			//ldr r1,=coordenada
			swi 0
			
			//rescato el valor (en ascii), y obtengo su valor
			ldrb r1,[r1]
			sub r1,#0x30	// Convertimos de caracter ascii a digito.
			pop { r0, r2, r3, r4, r5, r6, r7, lr }
			bx lr
			.fnend

		/* Solicita coordenada (x,y)  y obtiene el valor de cada coordenada
		input= -
		output= en r2 coordenada x , en r3 coordenada y
		*/
		pedirCoordenadaX:
			.fnstart
				push {r0, r1, r3, r4, r5, r6, r7, lr}
				
				// Ingresamos mensaje para x.
				ldr r1,=mensaje_x
				mov r2,#37
				bl imprStr

				// Pedimos la coordenada Y.
				ldr r1, =input_x
				bl obtenerCoordenada

				mov r2,r1 // En r2 queda la coordenada x.
				pop {r0, r1, r3, r4, r5, r6, r7, lr}
				bx lr
			.fnend
			
		pedirCoordenadaY:
			.fnstart
				push {r0, r1, r2, r4, r5, r6, r7, lr}
			
				// Ingresamos mensaje para y.
				mov r2,#37
				ldr r1,=mensaje_y
				bl imprStr
				
				// Pedimos la coordenada Y.
				ldr r1, =input_y
				bl obtenerCoordenada
				mov r3,r1 //en r3 queda la coordenada y.

				pop {r0, r1, r2, r4, r5, r6, r7, lr}
				bx lr
			.fnend


		/* Controla si se acabo el juego o si debe continuar.
			input: -
			output: r0: -1 si perdío por falta de vidas, 0 si continua, 1 si ganó. */
		controlar_estado:
			.fnstart
				push {r1, r2, r3, r4, r5, r6, r7, lr}
				ldr r1, =aciertos
				ldrb r1, [r1]
				ldr r2, =errores
				ldrb r2, [r2]
				
				mov r0, #0
				
				// Controlamos si gano.
				cmp r1, #APV
				beq WIN
				// Controlamos si perdío.
				cmp r2, #EPD
				beq LOSS
				bal TCE
				
				WIN:
					mov r0, #1
					bal TCE
				LOSS:
					mov r0, #-1
					bal TCE
				
				// Termina controlar_estado.
				TCE:
				pop {r1, r2, r3, r4, r5, r6, r7, lr}
				bx lr
			.fnend


		/* Controla lo que pasa cuando el jugador descubre 2 casillas vacías.
		El jugador tiene un máximo de 5 intentos "nulos". Una vez que se hayan 
		acabado estos cuentan como un error.
		Los intentos nulos nunca son considerados aciertos.
		input: -
		output: -
		*/
		controlar_nulo:
			.fnstart
				push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
				ldr r0, =nulos
				
				// Comparamos no pasó del máximo.
				ldrb r1, [r0]
				cmp r1, #INM
				bge ein
				
				// Como no se paso aumentamos la cantidad de intentos nulos.
				bl incrementar_y_guardar
				bal tcn
				
				// Excedio intentos nulos.
				ein:
				// Como se pasó del máximo le sumamos un error.
				ldr r0, =errores
				bl incrementar_y_guardar

				// Termina controlar nulo.
				tcn:
				pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
				bx lr
			.fnend
		
		
		/* Reemplaza una casilla del mapa por un '?'.
		input: r0 - indice de la casilla.
		output: - */
		ocultar_casilla:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			// Carga la matriz.
			ldr r1, =mat_mapa
			
			// Guarda el '?'.
			mov r2, #'?'
			strb r2, [r1, r0]
			pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			bx lr
		.fnend
		
		
		/* Muestra los valores de vida e intentos.
		input: -
		output: - */
		actualizar_informar_valores:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			// Cargamos las posiciones con los mensajes.
			ldr r3, =m_intentos
			ldr r4, =m_aciertos
			ldr r5, =m_errores
			ldr r6, =m_vidas
			
			// Actualizamos los mensajes para mostrar los valores.
			bl actualizar_mensajes
			
			// Imprimimos los mensajes.
			// Intentos.
			mov r1, r3
			mov r2, #TMI
			bl imprStr
			// Aciertos.
			mov r1, r4
			mov r2, #TMA
			bl imprStr
			// Errores.
			mov r1, r5
			mov r2, #TME
			bl imprStr
			// Vidas.
			mov r1, r6
			mov r2, #TMV
			bl imprStr
			
			pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			bx lr
		.fnend

		/* Actualiza los mensajes de intentos, aciertos, fallos y vidas para
		mostrar los valores actuales.
		input: -
		output: - */
		actualizar_mensajes:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, r7, r8, lr}
			// Cargamos los valores actuales y los mensajes.
			ldr r2, =aciertos
			ldrb r2, [r2]
			ldr r3, =sAciertos
			
			ldr r4, =errores
			ldrb r4, [r4]
			ldr r5, =sErrores
			
			ldr r6, =nulos
			ldrb r6, [r6]
			
			ldr r7, =sIntentos
			
			ldr r8, =sVidas
			
			// Actualizamos aciertos.
			mov r0, r2
			mov r1, r3
			bl num_a_ascii
			
			// Actualizamos errores.
			mov r0, r4
			mov r1, r5
			bl num_a_ascii
			
			// Actualizamos intentos.
			// Cantidad de intentos = aciertos + errores + intentos nulos.
			mov r0, r2
			add r0,	r4
			add r0, r6
			mov r1, r7
			bl num_a_ascii
			
			// Actualizamos vidas.
			// Vidas = errores para derrota - errores.
			mov r0, #EPD
			sub r0, r4
			mov r1, r8
			bl num_a_ascii
			
			pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, lr}
			bx lr
		.fnend

		/* Traduce un número de dos cifras a una cadena ASCII y lo guarda en
		la posición de memoria indicada.
		inputs: r0 - número a traducir.
				r1 - posición donde guardar la cadena (se guardaran 2 bytes).
		outputs: - */
		num_a_ascii:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			mov r2, #0x30	// Guarda las decenas. Empieza en el valor ascii de "0".
			
			// Ciclo para calcular las decenas del número.
			calcular_decenas:
				cmp r0, #10
				blt TCD		// Si el número en r0 es menor a 10, no hay que calcular más decenas.
				
				sub r0, #10
				add r2, #1
				bal calcular_decenas
			
			// Termino calculo de decenas.
			TCD:
				// Guardamos las decenas en la posición más significativa.
				strb r2, [r1]
				
				// Traducimos las unidades a su caracter ascii.
				add r0, #0x30
				// Guardamos las unidades en la posición menos significativa.
				strb r0, [r1, #1]
			
			pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			bx lr
		.fnend

		
		/* Muestra un mensaje al jugador cuando gana o pierde.
		input: r0 - 1 si ganó.
		output: -
		*/
		informar_resultado:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			ldr r3, =m_victoria
			ldr r4, =m_derrota

			cmp r0, #1
			beq gano
			
			perdio:
				// Mostrar mensaje de derrota.
				mov r1, r4
				mov r2, #T_MENSAJE_DERROTA
				bl imprStr
				bal termina_i_r

			gano:
				// Mostrar mensaje de victoria.
				mov r1, r3
				mov r2, #T_MENSAJE_VICTORIA
				bl imprStr
			
			termina_i_r:
			pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			bx lr
		.fnend


	/* Pregunta al usuario si quiere reiniciar el juego.
	input: -
	output: r0 - 1 si hay que reiniciar el juego, 0 si hay que salir.
	*/
	consultar_reinicio:
	.fnstart
		push {r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r3, =m_reinicio
		ldr r4, =reinicio_respuesta
		
		// Muestra consulta de reinicio:
		mov r1, r3
		mov r2, #T_MENSAJE_REINICIO
		bl imprStr
		
		// Pide input:
		mov r7, #3
		mov r0, #0
		mov r2, #2
		mov r1, r4
		swi 0
		
		// Ve si la respuesta es afirmativa.
		ldrb r1, [r4]
		cmp r1, #'Y'
		beq reinicio_afirmativo
		
			mov r0, #0
			bal termina_consultar
	
		reinicio_afirmativo:
			mov r0, #1
		
		termina_consultar:
		pop {r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend

	.global main
	main:
		INICIO_JUEGO:
			// Preparar todo para un nuevo juego.
			
		INICIO_TURNO:
			bl imprMapa
			bl actualizar_informar_valores
			
			/* ~~~~~~~~~~ Primera figura del ciclo ~~~~~~~~~~ */
			// Pedimos las coordenadas:
			bl pedirCoordenadaX
			bl pedirCoordenadaY
			
			bl calcNum		// Calculamos el indice de la figura.
			ldr r5, =figura_1
			strb r0, [r5]	// Guardamos el indice de la primer figura en figura_1.
			
			bl darVuelta
			bl imprMapa
			
			/* ~~~~~~~~~~ Segunda figura del ciclo ~~~~~~~~~~ */
			bl pedirCoordenadaX
			bl pedirCoordenadaY
			
			
			bl calcNum	// Calculamos el indice de la figura.
			
			ldr r6, =figura_2
			strb r0, [r6]	// Guardamos el indice de la segunda figura en figura_2.
			
			bl darVuelta
			bl imprMapa
			
			// Comparamos las figuras.
			ldr r5, =figura_1
			ldrb r0, [r5]	// Indice figura 1.
			bl buscarFig	// Buscamos el caracter en sí.
			push {r1}		// Guardamos el caracter temporalmente.

			ldr r6, =figura_2
			ldrb r0, [r6]	// Indice figura 2.
			bl buscarFig
			
			mov r2, r1		// Movemos la figura 2 a r2.
			pop {r1}		// Recuperamos la figura 1.
			
			// Comparamos los caracteres.
			bl comparar_caracter
			// Vemos si son iguales.
			cmp r0, #1
			beq acierto
			
			fallo:
				// Incrementamos la cantidad de errores.
				ldr r0, =errores
				bl incrementar_y_guardar
				
				// Ocultamos las casillas que selecciono el usuario.
				ldr r0, =figura_1
				ldrb r0, [r0]
				bl ocultar_casilla
				
				ldr r0, =figura_2
				ldrb r0, [r0]
				bl ocultar_casilla
				
				bal controlar_fin
			
			acierto:
				// Controlamos que el jugador haya tenido un intento nulo.
				cmp r1, #' '
				beq nulo
				
				// Incrementamos la cantidad de aciertos.
				ldr r0, =aciertos
				bl incrementar_y_guardar
				
				bal controlar_fin
			
			nulo:
				bl controlar_nulo
			
			controlar_fin:
				bl controlar_estado
				
				// Si es 0 debemos pasar a el siguiente ciclo.
				cmp r0, #0
				beq INICIO_TURNO
				
				// TERMINO EL JUEGO:
				bl informar_resultado
				
				bl consultar_reinicio
				cmp r0, #1
				beq INICIO_JUEGO
		salir:
			mov r7, #1
			swi 0
