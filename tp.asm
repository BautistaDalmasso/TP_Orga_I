.data
	mat_revelada: .ascii "  #   #     (   (        &          %           &  %             =    !     /      ~~  @= @  / !    "
	mat_mapa: .space 100, 0x3f	// Codigo ascii del caracter "?"
	
	figuras: .ascii "##((&&%%==!!//~~@@))"

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

	vidas: .byte 15
	.equ VIDAS_BASE, 15

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

	m_puntaje_actual: .ascii "Puntos: "
	sPuntaje: .ascii "00\n"
	.equ T_MENSAJE_PUNTOS_ACTUALES, 8+3

	//Para pedirCoordenadas 

	input_x:.space 2
	input_y: .space 2
	mensaje_x: .ascii "Ingrese el valor de la coordenada x: "
	mensaje_y: .ascii "Ingrese el valor de la coordenada y: "

	// Indices de las figuras que fueron dadas vuelta.
	figura_1: .byte 1
	figura_2: .byte 1
	
	// Mensajes de acierto, fallo, victoria y derrota.
	m_acierto: .ascii "Acertaste! +5 puntos.\n"
	.equ T_MENSAJE_ACIERTO, 22
	
	m_fallo: .ascii "Fallaste. -1 punto.\n"
	.equ T_MENSAJE_FALLO, 20

	.equ T_MENSAJE_VICTORIA, 22
	m_victoria: .ascii "Felicidades, ganaste!\n"
	
	.equ T_MENSAJE_RECORD, 26
	m_record: .ascii "Nuevo record de puntaje!.\n"

	.equ T_MENSAJE_DERROTA, 10
	m_derrota: .ascii "PERDISTE.\n"

	.equ T_MENSAJE_VIDA_EXTRA,31
	m_vida_extra: .ascii "Cerca! Te damos una vida extra\n"
	
	.equ T_MENSAJE_R_CORRECTA, 11
	m_respuesta_correcta: .ascii "Acertaste!\n"
	
	.equ T_MENSAJE_R_INCORRECTA, 13
	m_respuesta_incorrecta: .ascii "Ni de cerca!\n"

	.equ T_MENSAJE_REINICIO, 39
	m_reinicio: .ascii "¿Quiere iniciar un nuevo juego? (Y/n): "
	reinicio_respuesta: .ascii "  "

	// Puntajes:
	/* Utilizamos un string con los puntajes para poder mostrarlos al usuario.
	Utilizamos un vector númerico con puntajes para poder comparar puntajes entre sí.*/
	
	// Guarda los últimos 5 puntajes, cada puntaje tiene 2 digitos.
	m_puntajes: .ascii "Ultimos 5 puntajes: "
	puntajes_viejos: .ascii "(00), (00), (00), (00), (00).\n"
	.equ T_MENSAJE_PUNTAJES, 20+30
	pointer_puntaje: .byte 1					// Guarda el inicio del último puntaje en ser cargado.
	
	// Guarda los puntajes de forma númerica (en un vector).
	vector_puntajes: .zero 5
	.equ T_VECTOR_PUNTAJES, 5
	ptr_vector_puntaje: .byte 0					// Puntero del último puntaje en ser cargado.
	
	.equ DISTANCIA_ENTRE_PUNTAJES, 6
	.equ INDICE_MAXIMO_PUNTAJE, 25				// El valor maximo del puntero.
	
	puntaje_actual: .byte 15					// Puntaje de la ronda actual.
	.equ PUNTAJE_BASE, 15						// El puntaje con el que se inicia es 15.
	
	.equ PUNTOS_POR_ACIERTO, 5
	.equ PENALIZACION_POR_ERROR, 1
	
	.equ PUNTOS_POR_PREGUNTA_ACERTADA, 15
	.equ PUNTOS_POR_PREGUNTA_APROXIMADA, 1

	// Constantes:
	.equ APV, 5		// Aciertos para victoria.
	.equ EPD, 15	// Errores para derrota.
	.equ INM, 5		// Intentos nulos maximos.

	//Pregunta para vida o ganar el juego
	m_pregunta: .ascii "Si acertas la pregunta ganas, si te aproximas tenes una oportunidad más:\n"
	.equ T_MENSAJE_EXPLICACION, 74
	pregunta_1: .ascii "¿En qué año se publico el codigo Hamming?: "
	.equ T_MENSAJE_PREGUNTA, 45
	respuesta_1: .hword 1950
	resp_usuario: .ascii "0000\n"

	.equ RANGO_DE_ERROR, 75


	// Variables para generación de números random.
	seed: .word 1
	const1: .word 1103515245
	const2: .word 12345
	numero: .word 0

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
		ciclo_y_d:
			ldr r1, =cr
			bl imprChar	// Imprimimos un salto de línea.

			// Cargamos el valor ascii de la coordenada y en c_y.
			strb r3, [r5]
			// Imprimimos el número de la coordenada y.
			mov r1, r5
			bl imprChar

			// Ciclo para imprimir caracteres individuales por columna.
			mov r6, #0		// Guardamos la cantidad de caracteres que imprimimos esta fila.
			ciclo_x_d:
				ldr r1, =spc
				bl imprChar	// Imprimimos un espacio.

				mov r1, r4	// Imprimimos el caracter del mapa que sigue:
				bl imprChar

				add r6, #1
				add r4, #1	// Avanzamos al siguiente valor del mapa.

				// Si imprimimos menos de 10 caracteres continuamos con el ciclo.
				cmp r6, #10
				blt ciclo_x_d

			add r3, #0x1 // Pasamos al siguiente valor de Y.

			// Si no imprimimos los números del 0 al 9, repetimos el ciclo.
			cmp r3, #0x3a
			blt ciclo_y_d

		// Imprime un separador.
		ldr r1, =separador
		mov r2, #23
		bl imprStr

		pop {r0, r1, r2, r3, r4, r5, r7, lr}
		bx lr
		.fnend

	/* Imprime el mapa revelado completamente. Solo para debugear.
	inputs: -
	outputs: - */
	imprimir_mapa_debugueable:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r7, lr}
		/* Guardamos las posiciones de memoria de todos los caracteres que vamos a imprimir. */
		ldr r5, =c_y	// Posición de la coordenada y para imprimir.
		ldr r4, =mat_revelada // Posición del caracter del mapa a imprimir.

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
		push {r0, r1, lr}

		ldrb r1,[r0]  /*se almacena el byte en r0*/
		add r1,#1    /*se suma en una unidad el valor-*/
		strb r1,[r0] /*envio a memoria el nuevo valor*/
					
		pop {r0, r1, lr}
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
				ldr r2, =vidas
				ldrb r2, [r2]
				
				mov r0, #0
				
				// Controlamos si gano.
				cmp r1, #APV
				beq WIN
				// Controlamos si perdío.
				cmp r2, #0
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
		
		/* Oculta todas las casillas del mapa.
		input: -
		output: - */
		ocultar_mapa:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			mov r0, #0		// Primera casilla.
			
			ocultar_casillas:
				bl ocultar_casilla
				
				add r0, #1	// Pasamos a la siguiente casilla.

				// Si no ocultamos las 100 casillas del mapa, continuamos el ciclo.
				cmp r0, #100
				blt ocultar_casilla
			
			pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			bx lr
		.fnend
		
		/* Reinicia los valores de vidas, errores, etc.
		input: -
		output: - */
		reiniciar_estadisticas:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			// Cargamos la posición de las estadisticas.
			ldr r0, =aciertos
			ldr r1, =errores
			ldr r2, =nulos
			ldr r4, =puntaje_actual
			ldr r5, =vidas
		
			// Las reiniciamos a sus valores originales.
			mov r3, #0
			strb r3, [r0]
			
			strb r3, [r1]
			
			strb r3, [r2]
			
			// Reiniciamos el puntaje actual.
			mov r3, #PUNTAJE_BASE
			strb r3, [r4]

			// Reiniciamos las vidas.
			mov r3, #VIDAS_BASE
			strb r3, [r5]
	
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
			ldr r7, =m_puntaje_actual
			
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
			// Puntos
			mov r1, r7
			mov r2, #T_MENSAJE_PUNTOS_ACTUALES
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
			push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
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
			ldr r9, =vidas
			
			ldr r10, =sPuntaje
			ldr r11, =puntaje_actual
			ldrb r11, [r11]
			
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
			ldrb r0, [r9]
			mov r1, r8
			bl num_a_ascii
			
			// Actualizamos puntaje.
			mov r0, r11
			mov r1, r10
			bl num_a_ascii
			
			pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, lr}
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

		/* ----------------------- Control de aciertos, fallos, victorias, etc. ----------------------- */
		/* Muestra un mensaje al jugador cuando gana o pierde.
		input: r0 - 1 si ganó.
		output: -
		*/
		informar_resultado:
		.fnstart
			push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
			ldr r3, =m_victoria
			ldr r4, =m_derrota

			bl informar_record

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


	/* Informa al usuario que obtuvo un nuevo record de ser necesario.
	input: -
	output: - */
	informar_record:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r1, =m_record
		
		// Chequeamos si hubo un record.
		bl chequear_record
		
		// De no haberlo, salimos.
		cmp r0, #0
		beq termina_informar_record
			// Como lo hubo, mostramos el mensaje.
			mov r2, #T_MENSAJE_RECORD
			bl imprStr
		
		termina_informar_record:
		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend
	/* Chequea si el usuario alcanzo un nuevo record de puntaje.
	input: -
	output: r0 - 1 si alcanzo un record, 0 si no. */
	chequear_record:
	.fnstart
		push {r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r1, =vector_puntajes
		// Cargamos el puntaje actual.
		ldr r2, =puntaje_actual
		ldrb r2, [r2]
		
		mov r3, #0		// Indice que esta siendo recorrido.
		recorrido_vector:
			// Si recorrimos todo el vector sin encontrar ninguno mayor
			// es porque el record actual es mayor.
			cmp r3, #T_VECTOR_PUNTAJES
			bge es_record
			
			// Cargamos el siguiente valor.
			ldrb r4, [r1, r3]
			
			// Aumentamos el contador de indice.
			add r3, #1
			
			// Si el puntaje actual es mayor al cargado, seguimos recorriendo.
			cmp r2, r4
			bgt recorrido_vector
			
		no_es_record:
			mov r0, #0
			bal fin_chequeo
		
		es_record:
			mov r0, #1
		
		fin_chequeo:
		pop {r1, r2, r3, r4, r5, r6, r7, lr}
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
			
			bl mostrar_puntajes		// También mostramos los puntajes.
		
		termina_consultar:
		pop {r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend
	
	
	/* Controla lo que sucede cuando un usuario acierta.
	input: -
	output: - */
	controlar_acierto:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r0, =aciertos
		ldr r1, =puntaje_actual
		ldr r3, =m_acierto
		
		// Incrementamos la cantidad de aciertos.
		bl incrementar_y_guardar
		
		// Aumentamos el puntaje actual.
		ldrb r2, [r1]
		add r2, #PUNTOS_POR_ACIERTO
		strb r2, [r1]
		
		// Mostramos un mensaje por el acierto.
		mov r1, r3
		mov r2, #T_MENSAJE_ACIERTO
		bl imprStr
		
		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend

	/* Controla lo que sucede cuando un usuario falla.
	input: -
	output: - */
	controlar_fallo:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r1, =errores
		ldr r2, =figura_1
		ldr r3, =figura_2
		ldr r4, =puntaje_actual
		ldr r5, =vidas
		ldr r7, =m_fallo
		
		// Incrementamos la cantidad de errores.
		mov r0, r1
		bl incrementar_y_guardar
		
		// Ocultamos las casillas que selecciono el usuario.
		ldrb r0, [r2]
		bl ocultar_casilla
		
		ldrb r0, [r3]
		bl ocultar_casilla
		
		// Penalizamos el puntaje del usuario.
		ldrb r0, [r4]
		sub r0, #PENALIZACION_POR_ERROR
		strb r0, [r4]
		
		// Le restamos una vida.
		ldrb r6, [r5]
		sub r6, #1
		strb r6, [r5]
		

		// Mostramos un mensaje por el fallo.
		mov r1, r7
		mov r2, #T_MENSAJE_FALLO
		bl imprStr
		
		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend

	
	/* Controla el uso de una pregunta al rescate.
	input: -
	output: r0 -> -1 perdió, 0 tiene otra vida, 1 ganó. */
	controlar_pregunta:
	.fnstart
		push {r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r3, =vidas
		ldr r4, =m_vida_extra
		ldr r5, =m_respuesta_correcta
		ldr r6, =m_respuesta_incorrecta
		ldr r8, =puntaje_actual
		
		// Hacemos la pregunta.
		bl pregunta_Al_Rescate
		
		cmp r7, #1
		beq gano_por_pregunta
		
		cmp r7, #0
		beq dar_vida_extra
			// Le decimos que falló.
			mov r1, r6
			mov r2, #T_MENSAJE_R_INCORRECTA
			bl imprStr
			
			bal termina_controlar_pregunta
		
		gano_por_pregunta:
			// Lo felicitamos por acertar.
			mov r1, r5
			mov r2, #T_MENSAJE_R_CORRECTA
			bl imprStr
			
			// Le sumamos puntos.
			ldrb r1, [r8]
			add r1, #PUNTOS_POR_PREGUNTA_ACERTADA
			strb r1, [r8]
			
			bal termina_controlar_pregunta
	
		dar_vida_extra:
			// Le damos otra vida.
			mov r0, r3
			bl incrementar_y_guardar
			
			// Le informamos que estuvo cerca.
			mov r1, r4
			mov r2, #T_MENSAJE_VIDA_EXTRA
			bl imprStr
			
			// Le sumamos puntos.
			ldrb r1, [r8]
			add r1, #PUNTOS_POR_PREGUNTA_APROXIMADA
			strb r1, [r8]
	
		termina_controlar_pregunta:
		mov r0, r7
		pop {r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend


	/* ------------------- PUNTAJES ------------------- */
	/* Guarda el puntaje actual en el vec de puntajes.
	input: -
	output: - */
	guardar_puntaje:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r0, =puntaje_actual
		ldr r1, =puntajes_viejos
		ldr r2, =pointer_puntaje
		ldr r5, =vector_puntajes
		ldr r6, =ptr_vector_puntaje
		
		ldrb r3, [r2]
		/* Si el pointer puntaje se pasó del máximo, empezamos a sobreescribir
		puntajes. */
		cmp r3, #INDICE_MAXIMO_PUNTAJE
		ble continuar_guardado				// Si no se paso continuamos.
			// Se paso del máximo así que reiniciamos los punteros.
			// Puntero del vector.
			mov r3, #0
			strb r3, [r6]
			// Puntero del string.
			mov r3, #1
			strb r3, [r2]
		
		continuar_guardado:
			// Convertimos el puntaje a ascii y lo guardamos donde indique el puntero.
			ldrb r0, [r0]
			add r1, r3
			bl num_a_ascii
		
			// Guardamos el puntaje en el vector.
			ldrb r7, [r6]
			strb r0, [r5, r7]
		
			// Aumentamos el valor de los punteros.
			add r3, #DISTANCIA_ENTRE_PUNTAJES
			strb r3, [r2]
			
			add r7, #1
			strb r7, [r6]
		
		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend
	/* Muestra los últimos 5 puntajes.
	input: -
	output: - */
	mostrar_puntajes:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}

		ldr r1, =m_puntajes
		mov r2, #T_MENSAJE_PUNTAJES
		bl imprStr
		
		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend

	//PREGUNTA PARA: GANAR EL JUEGO, GANAR VIDA O PERDER DEFINITIVAMENTE 

	/* Esta funcion pasa un ascii de 4 caracteres a numero
    input= r1 <-- direccion del numero ascii en memoria
    output= r3 <-- numero */
    deAscii_A_Num:
	.fnstart
    	push { r0, r1, r2, r4, r5, r6, r7, lr}
    	mov r3,#0					// Acumulador con el resultado.
		
		mov r4, #0					// Contador del digito siendo guardado.

		// Guardamos los digitos en el stack desde el más significativo al menos.
		guardar_digitos:
			// Vemos si terminamos de guardar 4 digitos.
			cmp r4, #4
			bge aplicar_tdn
		
			// Cargamos el digito en ascii.
			ldrb r5, [r1, r4]
			// Lo convertimos a su valor numerico.
			sub r5, #0x30
			// Lo guardamos temporalmente en el stack.
			push {r5}
			
			add r4, #1				// Avanzamos al siguiente valor.
			bal guardar_digitos		// Continuamos con el ciclo.
		
		aplicar_tdn:
		mov r4, #0					// Contador de iteraciones.
		mov r6, #1					// Coeficiente por el que se debe multiplicar el digito.
		mov r7, #10					// En cada iteración el coeficiente se multiplica por 10.
		ciclo_tdn:
		// Ahora mediante el stack recuperamos los digitos del menos significativo hacia el más.
			// Vemos si terminamos de acumular los 4 digitos.
			cmp r4, #4
			bge termina_aan
			
			// Recuperamos el digito.
			pop {r5}
			// Lo multiplicamos por su coeficiente asociado.
			mul r5, r6
			// Lo agregamos al acumulador de resultado.
			add r3, r5
			
			// Pasamos al siguiente coeficiente.
			mul r6, r7
			add r4, #1
			
			bal ciclo_tdn
			
		termina_aan:
		pop { r0, r1, r2, r4, r5, r6, r7, lr}
		bx lr
	.fnend

	/* Realiza el proceso de pregunta-respuesta que salva al jugador. 
	Si acierta precisamente el jugador gana, si se encuentra en un intervalo
	la respuesta, se le otorga una vida mas
	input: -
	output: r7 <-- -1: incorrecto, 0: se aproximo, 1: correcto */
	pregunta_Al_Rescate:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, lr}

		//Mensaje que introduce la pregunta
		ldr r1,=m_pregunta
		mov r2, #T_MENSAJE_EXPLICACION
		bl imprStr
				
		//Presentamos la pregunta
		ldr r1,=pregunta_1
		mov r2, #T_MENSAJE_PREGUNTA
		bl imprStr 

		//Guardamos la respuesta del usuario 
		mov r7,#3
		mov r0,#0
		mov r2,#5
		ldr r1,=resp_usuario
		swi 0 

		//Traemos de memoria la respuesta del usuario y la convertimos en numero
		ldr r1,=resp_usuario
		bl deAscii_A_Num

		// Traemos la respuesta real de memoria para compararla
		ldr r2,=respuesta_1
	   	ldrh r2,[r2]

		// Restamos los valores para comparar la diferencia más facilmente.
		subs r3, r2
		
		// Si la resta dió 0 es porque acertó,
		cmp r3, #0
		beq correcto
		
		// La distancia es: abs(respuestaUsr-respuestaReal)
		// Valor absoluto quiere decir que la resta debe estar en el intervalo:
		// -RANGO_DE_ERROR < resta < RANGO_DE_ERROR
		cmp r3, #-RANGO_DE_ERROR
		blt incorrecto
		cmp r3, #RANGO_DE_ERROR
		bgt incorrecto

		//Respuesta cumple el rango
		enRango:
			mov r7,#0
			bal salir_pregunta

		//Respondio correcta
		correcto: 
			mov r7,#1
			bal salir_pregunta

		//Respuesta incorrecta
		incorrecto:
			mov r7,#-1

		salir_pregunta:
		pop {r0, r1, r2, r3, r4, r5, r6, lr}
		bx lr

		.fnend


	/* ------------------------ GENERACIÓN NÚMEROS RANDOM ------------------------ */
	/* Devuelve un número aleatorio.
	input: -
	output: r0 -> número aleatorio. */
	myrand:
	.fnstart
		push {r1, r2, r3, lr}
		ldr r1, =seed @ leo puntero a semilla
		ldr r0, [ r1 ] @ leo valor de semilla
        ldr r2, =const1
		ldr r2, [ r2 ] @ leo const1 en r2
		mul r3, r0, r2 @ r3= seed * 1103515245
		ldr r0, =const2
		ldr r0, [ r0 ] @ leo const2 en r0
		add r0, r0, r3 @ r0= r3+ 12345
		str r0, [ r1 ] @ guardo en variable seed
		/* Estas dos líneas devuelven "seed > >16 & 0x7fff ".
		Con un peque ñotruco evitamos el uso del AND */
		LSL r0, # 1
		LSR r0, # 17
		pop {r1, r2, r3, lr}
		bx lr
	.fnend
	/* Carga una semilla para generar números aleatorios.
	input: r0 <- semilla.
	output: - */
	mysrand:
	.fnstart
		push {r0, r1, lr}
		ldr r1, =seed
		str r0, [ r1 ]
		pop {r0, r1, lr}
		bx lr
	.fnend

	/* Devuelve un número aleatorio en el rango 0-99.
	input: -
	output: r0 <- número aleatorio. */
	rand_99:
	.fnstart
		push {r1, r2, r3, lr}
		bl myrand

		// Realizamos restas sucesivas en un número random
		// para obtener el resto de dividir por 100.
		restar_100:
			cmp r0, #100
			blt terminar_rand

			sub r0, #100
			bal restar_100

		terminar_rand:
		pop {r1, r2, r3, lr}
		bx lr
	.fnend
	/* ------------------- GENERACIÓN DE MAPA RANDOM ------------------- */
	/* "Limpia" la matriz revelada, dejandola solo con ' '
	input: -
	output: - */
	limpiar_figuras:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r0, =mat_revelada
		
		mov r1, #' '	// Caracter con el que vamos a llenar la matriz.
		mov r2, #0		// Contador de indice.
		ciclo_limpiador:
			// Vemos si recorrimos toda la matriz.
			cmp r2, #100
			bge termina_limpieza
			
			// Guardamos ' ' en el caracter actual.
			strb r1, [r0, r2]
			
			// Aumentamos el contador.
			add r2, #1
			
			bal ciclo_limpiador
			
		termina_limpieza:
		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend
	
	/* Llena la matriz revelada con 20 figuras (10 pares)
	input: -
	output: - */
	generar_mapa:
	.fnstart
		push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		ldr r2, =mat_revelada
		ldr r3, =figuras

		bl limpiar_figuras	// Dejamos la matriz vacía antes de llenarla.
		
		mov r4, #0			// Contador de figura actual.
		ciclo_llenador:
			cmp r4, #20
			bge termina_generar
			
			ldrb r5, [r3, r4]	// Cargamos la figura que tiene que ser insertada.

			bl rand_99			// Generamos un indice para la figura.
			
			ldrb r6, [r2, r0]	// Cargamos el caracter que esté en el indice generado.
			
			cmp r6, #' '
			bne ciclo_llenador	// Si la posición no esta vacia debemos generar otra.
				strb r5, [r2, r0]	// Como estaba vacía, cargamos la figura.
				add r4, #1			// Pasamos a la siguiente figura.
				bal ciclo_llenador	// Continuamos cargando.

		
		termina_generar:
		pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
		bx lr
	.fnend

	.global main
	main:
		// Ingresamos una semilla para generación random.
		mov r0, #59
		bl mysrand
	
		/* Nos salteamos la preparación del juego la primera vez que se
		ejecuta el programa (para hacer más facil el debugeo). */
		bal INICIO_TURNO
	
		INICIO_JUEGO:
			// Preparar todo para un nuevo juego.
			bl ocultar_mapa
			
			// Cambiamos la semilla del mapa (si no se generaria siempre el mismo).
			ldr r0, =seed
			ldrb r1, [r0]
			add r1, #31
			strb r1, [r0]
			// Generamos un nuevo mapa aleatorio.
			bl generar_mapa

			bl reiniciar_estadisticas
			
			// PARA DEBUGEAR:
			// bl imprimir_mapa_debugueable

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
				bl controlar_fallo
				
				bal controlar_fin
			
			acierto:
				// Controlamos que el jugador haya tenido un intento nulo.
				cmp r1, #' '
				beq nulo
				
				bl controlar_acierto
				
				bal controlar_fin
			
			nulo:
				bl controlar_nulo
			
			controlar_fin:
				bl controlar_estado
				
				// Si es 0 debemos pasar a el siguiente ciclo.
				cmp r0, #0
				beq INICIO_TURNO
				
				// Si es 1, el jugador ganó y nos salteamos la pregunta.
				cmp r0, #1
				beq fin_juego

					// Como perdió, le hacemos la pregunta de rescate.
					bl controlar_pregunta
					// Si el resultado es 0, el jugador tiene una nueva vida así que vamos al siguiente turno.
					cmp r0, #0
					beq INICIO_TURNO
				
				// TERMINO EL JUEGO:
				fin_juego:
					bl informar_resultado
					
					bl guardar_puntaje
					
					bl consultar_reinicio
					cmp r0, #1
					beq INICIO_JUEGO
		salir:
			mov r7, #1
			swi 0
