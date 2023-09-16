include Irvine32.inc

.data
;-------------------------------CONFIGURACION DE USUARIO-----------------------------------------------------
    nombre          db 8 DUP(?)         ; Aquí almacenamos el nombre de usuario (6 caracteres para incluir el byte nulo)
    longitud        dd ?                ; Variable para almacenar la longitud
    mensaje         db "Ingrese un usuario de 5 caracteres: ", 0
    mensaje_error   db "El usuario debe tener exactamente 5 caracteres.", 0
;----------------------------------------MENU----------------------------------------------------------------
    menuTitle db ' ',0ah,0dh
    db '==============================================================',0ah,0dh
    db '|                                                            |',0ah,0dh
    db '|                      CHAT EN CODIGO MORSE                  |',0ah,0dh
    db '|                                                            |',0ah,0dh
	db '==============================================================',0ah,0dh,0
    option1 db ' ',0ah,0dh
    db '===================',0ah,0dh
    db '> Recibir Mensaje |',0ah,0dh 
    db '===================',0ah,0dh,0
    option2 db ' ',0ah,0dh
    db '===================',0ah,0dh
	db '> Enviar Mensaje  |',0ah,0dh
    db '===================',0ah,0dh,0
    option3 db ' ',0ah,0dh
    db '===================',0ah,0dh
    db '> Salir           |',0ah,0dh
    db '===================',0ah,0dh,0
    invalidOption db 'Opcinn invalida', 0
;---------------------------------------LISTENER-------------------------------------------------------------
    archivo db "C:\MASM_Morse\chatTemp.txt",0  
    archivoChat db "C:\MASM_Morse\chat.txt",0
    buffer db 255 dup(0) ; Buffer para almacenar el mensaje
    VK_ESCAPE EQU 27 ; Valor virtual de la tecla Esc
    instruccione2 db ' ',0ah,0dh
    db '=======================================',0ah,0dh
    db '| Presione ESC para volver al menu    |',0ah,0dh
    db '=======================================',0ah,0dh,0
;----------------------------------------MENSAJE-------------------------------------------------------------
    hStdIn dd 0 
    nRead dd 0

    _INPUT_RECORD STRUCT
    EventType WORD ?
    WORD ? ; For alignment
    UNION
    KeyEvent              KEY_EVENT_RECORD          <>
    MouseEvent            MOUSE_EVENT_RECORD        <>
    WindowBufferSizeEvent WINDOW_BUFFER_SIZE_RECORD <>
    MenuEvent             MENU_EVENT_RECORD         <>
    FocusEvent            FOCUS_EVENT_RECORD        <>
    ENDS
    _INPUT_RECORD ENDS

    InputRecord _INPUT_RECORD <>

    ConsoleMode dd 0
    contador dd 0   
    guion db "-", 0
    punto db ".", 0
    espacio db " ", 0
    codigoMorse db 100 dup(?)  ; Buffer para almacenar el mensaje en codigo morse
    
    instrucciones1 db ' ',0ah,0dh
db '=======================================',0ah,0dh
db '| Ingrese su mensaje en codigo morse: |',0ah,0dh
db '=======================================',0ah,0dh,0
    MAX EQU 100
;---------------------------------------ENVIAR MENSAJE-------------------------------------------------------
    identificador db '@', 0
    fileName BYTE "C:\MASM_Morse\morse.txt",0
    fileHandle HANDLE 0
;-----------------------------------------CHECK COORDS--------------------------------------------------------
    BufferInfo CONSOLE_SCREEN_BUFFER_INFO <>

;--------------------------------------MENU CONFIGURACION---------------------------------------------------------------
    tituloConfiguracion db ' ',0ah,0dh
    db '==============================================================',0ah,0dh
    db '|                                                            |',0ah,0dh
    db '|                          CONFIGURACION                     |',0ah,0dh
    db '|                                                            |',0ah,0dh
	db '==============================================================',0ah,0dh
    db 'Seleccione una configuacion ',0ah,0dh,0

    configuracion db ' ',0ah,0dh
    db '===================',0ah,0dh
    db '> Fondo Amarillo  |',0ah,0dh
    db '===================',0ah,0dh
    db '> Fondo celeste   |',0ah,0dh
    db '===================',0ah,0dh
    db '> Modo Oscuro     |',0ah,0dh
    db '===================',0ah,0dh
    db '> Modo Claro      |',0ah,0dh
    db '===================',0ah,0dh
    db '> Modo Programador|',0ah,0dh
	db '===================',0ah,0dh
    db '> Iniciar Chat    |',0ah,0dh
	db '===================',0ah,0dh,0

    menuFlag dd 1 ; Flag para ejecutar el menu de configuracion

;-------------------------------TRADUCTOR-------------------------------------------------------------------------------
    tamanoMaximo = 5000
    persona db 255 dup(0)
    mensajeMorse db 255 dup(0)
    traduccionEspanol BYTE tamanoMaximo DUP(?)
    bufferTraduccion BYTE tamanoMaximo DUP(?)

    ; Definición de las letras en Morse y sus traducciones en español
    letraA BYTE ".-",0
    letraB BYTE "-...",0
    letraC BYTE "-.-.",0
    letraD BYTE "-..",0
    letraE BYTE ".",0
    letraF BYTE "..-.",0
    letraG BYTE "--.",0
    letraH BYTE "....",0
    letraI BYTE "..",0
    letraJ BYTE ".---",0
    letraK BYTE "-.-",0
    letraL BYTE ".-..",0
    letraM BYTE "--",0
    letraN BYTE "-.",0
    letraO BYTE "---",0
    letraP BYTE ".--.",0
    letraQ BYTE "--.-",0
    letraR BYTE ".-.",0
    letraS BYTE "...",0
    letraT BYTE "-",0
    letraU BYTE "..-",0
    letraV BYTE "...-",0
    letraW BYTE ".--",0
    letraX BYTE "-..-",0
    letraY BYTE "-.--",0
    letraZ BYTE "--..",0

.code

login PROC
    call clrscr                         ; Limpia la pantalla
    
inputLoop:
    mov edx, OFFSET mensaje             ; Muestra el mensaje
    call WriteString

    mov edx, OFFSET nombre             ; Dirección de la variable de nombre
    call LeerUsuario                   ; Llama a la función para leer el nombre de usuario

    mov esi, OFFSET nombre             ; Cargar la dirección de la cadena en esi
    call ContarLongitud                ; Llama a la función para contar la longitud de la cadena

    cmp dword ptr [longitud], 5        ; Compara la longitud con 5
    jne muestraError                   ; Si no es igual a 5, muestra un mensaje de error

    call WriteString
    call CRLF                           ; Salto de línea
    jmp exitProgram

muestraError:
    call CRLF
    mov edx, OFFSET mensaje_error       ; Muestra un mensaje de error
    call WriteString
    call CRLF
    jmp inputLoop

exitProgram:
    ret

LeerUsuario PROC
    mov edx, OFFSET nombre             ; Dirección de destino
    mov ecx, 8                         ; Número máximo de caracteres a leer (8 incluyendo el byte nulo)
    call ReadString
    ret
LeerUsuario ENDP

ContarLongitud PROC
    xor ecx, ecx                        ; Inicializar contador a cero

    contarLoop:
        mov al, [esi]                   ; Cargar el byte actual en AL
        cmp al, 0                       ; ¿Es el byte nulo?
        je finConteo                     ; Si es nulo, termina el bucle
        inc esi                         ; Mover al siguiente byte de la cadena
        inc ecx                         ; Incrementar el contador de caracteres
        jmp contarLoop                  ; Repetir el bucle

    finConteo:
        mov [longitud], ecx             ; Almacenar la longitud en la variable longitud
        ret
ContarLongitud ENDP

login ENDP

menuPrincipal PROC
    ; Mostrar titulo de la configuracion
    mov edx, offset tituloConfiguracion
    call WriteString

	; Mostrar opciones de configuracion
    mov edx, offset configuracion
    call writeString


	
menuPrincipal ENDP

checkCoordsConfiguracion PROC
    invoke GetStdHandle, STD_INPUT_HANDLE  ; Obtener el identificador de entrada estándar
    mov hStdIn, eax

    invoke GetConsoleMode, hStdIn, ADDR ConsoleMode ; Obtener el modo de consola
    mov eax, 0090h          ; ENABLE_MOUSE_INPUT  ; Habilitar la entrada de ratón
    invoke SetConsoleMode, hStdIn, eax ; Establecer el modo de consola

    .WHILE TRUE
        invoke ReadConsoleInput, hStdIn, ADDR InputRecord, 1, ADDR nRead
        movzx eax, InputRecord.EventType
        cmp eax, MOUSE_EVENT
        jne skipMouseEvent

        ; Verificar si se trata de un evento de clic izquierdo (BUTTON1_PRESSED)
        cmp InputRecord.MouseEvent.dwButtonState, 1
        jne skipMouseEvent

        ; Procesar evento de clic izquierdo
        movzx ebx, InputRecord.MouseEvent.dwMousePosition.Y

        ; Comprobar si la coordenada Y es igual a 9, 11, 13, 15 

        cmp ebx, 9
        je fondoAmariilo
        cmp ebx, 11
		je fondoCeleste
        cmp ebx, 13
		je modoOscuro
        cmp ebx, 15
        je modoClaro
        cmp ebx, 17
        je modoProgramador
        cmp ebx, 19
		je runChat

        skipMouseEvent:
    .ENDW

    done:
        ret
checkCoordsConfiguracion ENDP

fondoCeleste:
		mov eax, black(cyan*16)
		jmp setTheme

fondoAmariilo:
		mov eax, black(yellow*16)
		jmp setTheme

modoOscuro:
		mov eax, white(black*16)
		jmp setTheme

modoClaro:
		mov eax, black(white*16)
		jmp setTheme
modoProgramador:
		mov eax, green(black*16)
		jmp setTheme

setTheme:
		call clrscr
		call SetTextColor
		call clrscr
		call menuPrincipal

runChat:
		call clrscr
		ret
    
checkCoords1 PROC
    invoke GetStdHandle,STD_INPUT_HANDLE  ;Get the handle to the console input (storaged in hStdIn via eax)
    mov hStdIn, eax

    invoke GetConsoleMode, hStdIn, ADDR ConsoleMode  ;Get the console mode
    mov eax, 0090h          ; ENABLE_MOUSE_INPUT
    invoke SetConsoleMode, hStdIn, eax  ;Set the console mode

    .WHILE InputRecord.KeyEvent.wVirtualKeyCode != VK_ESCAPE
        
        mov esi, 0

        checkClick:
        invoke ReadConsoleInput, hStdIn, ADDR InputRecord, 1, ADDR nRead
        movzx  eax, InputRecord.EventType
        cmp InputRecord.MouseEvent.dwButtonState, 0001h ;COMPARES WITH LEFT BUTTON
        je clicked
        jmp checkClick

        clicked:
            movzx eax, InputRecord.MouseEvent.dwMousePosition.X
            call WriteDec
            call Crlf
            movzx eax, InputRecord.MouseEvent.dwMousePosition.Y
            call WriteDec

    done:
        ret
        .ENDW
checkCoords1 ENDP

receiveMessages PROC
	; Verificar si se presiono la tecla ESC
    call ReadKey
    cmp al, VK_ESCAPE
    je volverMain

    ; Abrir el archivo en modo de lectura y escritura
    invoke CreateFile, ADDR archivo, GENERIC_READ or GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov ebx, eax  ; Guardar el identificador del archivo en ebx
    cmp ebx, INVALID_HANDLE_VALUE ; Comprobar si hubo un error al abrir el archivo
    je NoNuevoMensaje

    ; Leer el contenido del archivo
    invoke ReadFile, ebx, ADDR buffer, 255, NULL, NULL

    ; Cerrar el archivo
    invoke CloseHandle, ebx

    ; Comprobar si el archivo no estaba vacio
    cmp byte ptr [buffer], 0 
    je NoNuevoMensaje

    
    mov esi, OFFSET buffer         ; Puntero al comienzo del buffer
    mov edi, OFFSET persona        ; Puntero al comienzo de la variable persona
    
    mov ecx, 255                   ; Longitud máxima a copiar
    xor al, al                     ; Inicializar al con 0 (byte nulo)
    
    buscarArroba:
        movzx ebx, byte ptr [esi]      ; Cargar el siguiente byte desde buffer en ebx
        cmp ebx, 0                     ; ¿Hemos llegado al final de la cadena?
        je fin                         ; Si es así, terminar
    
        movzx ecx, byte ptr [identificador] ; Cargar el identificador "@" en ecx
        cmp ebx, ecx                   ; ¿Es el byte igual al identificador "@"?
        je encontradoArroba            ; Si es "@" lo encontramos
    
        movsb                          ; Copiar un byte de buffer a persona
        jmp buscarArroba               ; Seguir buscando
    
    encontradoArroba:
        mov byte ptr [edi], 0          ; Terminar la cadena persona con un byte nulo
    
        ; Ahora, copiemos lo que está después de "@" a mensajeMorse
        inc esi                        ; Avanzar un byte después del "@"
        mov edi, OFFSET mensajeMorse   ; Puntero al comienzo de mensajeMorse
    
    copiarMensajeMorse:
        mov al, [esi]                  ; Cargar el siguiente byte desde buffer
        cmp al, 0                      ; ¿Hemos llegado al final de la cadena?
        je fin                         ; Si es así, terminar
        mov [edi], al                  ; Copiar el byte a mensajeMorse
        inc esi                        ; Avanzar el puntero de origen
        inc edi                        ; Avanzar el puntero de destino
        jmp copiarMensajeMorse         ; Repetir el proceso
    
    fin:
        mov byte ptr [edi], 0          ; Terminar la cadena mensajeMorse con un byte nulo
    
        ; Imprimir las cadenas resultantes
        mov edx, OFFSET persona
        call WriteString
        call Crlf
    
        mov edx, OFFSET mensajeMorse
        call WriteString
        call Crlf
    

    ; Abrir el archivo en modo de escritura para borrar su contenido
    invoke CreateFile, ADDR archivo, GENERIC_WRITE, 0, NULL, TRUNCATE_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov ebx, eax
    cmp ebx, INVALID_HANDLE_VALUE
    je NoNuevoMensaje

    ; Escribir una cadena vacia en el archivo (para limpiarlo)
    mov edx, OFFSET buffer
    invoke WriteFile, ebx, edx, 1, ADDR buffer, NULL

    ; Cerrar el archivo nuevamente
    invoke CloseHandle, ebx

    call traducirMorseEspanol

NoNuevoMensaje:
    jmp receiveMessages ; Volver a verificar infinitamente

volverMain:
	ret

receiveMessages ENDP

newMessages PROC
    ; Mostrar instrucciones al usuario
    mov edx, OFFSET instrucciones1
    call WriteString
    call Crlf

    invoke GetStdHandle, STD_INPUT_HANDLE
    mov hStdIn, eax

    invoke GetConsoleMode, hStdIn, ADDR ConsoleMode
    mov eax, 0090h; ENABLE_MOUSE_INPUT | DISABLE_QUICK_EDIT_MODE | ENABLE_EXTENDED_FLAGS
    invoke SetConsoleMode, hStdIn, eax

    .WHILE InputRecord.KeyEvent.wVirtualKeyCode != VK_ESCAPE

    mov esi, 0

    mouseLoop:
    invoke ReadConsoleInput, hStdIn, ADDR InputRecord, 1, ADDR nRead
    movzx eax, InputRecord.EventType
    cmp InputRecord.MouseEvent.dwButtonState, 1
    je clickIzquierdo
    cmp InputRecord.MouseEvent.dwButtonState, 2 
    je clickDercho
    cmp InputRecord.MouseEvent.dwButtonState, 4 
    je clickCentral
    jmp mouseLoop

    clickIzquierdo:
    mov eax, 0 
    mov al, guion 
    mov codigoMorse[esi], al ; Guardar el guion en el array
    inc esi					 ; Incrementar el indice del array
    mov edx, OFFSET guion    ; Imprimir el guion
    call WriteString
    mov contador, 0          ; Reiniciar el contador
    jmp mouseLoop

    clickDercho:
    mov eax, 0
    mov al, punto           
    mov codigoMorse[esi], al ; Guardar el punto en el array
    inc esi				     ; Incrementar el indice del array
    mov edx, OFFSET punto	 ; Imprimir el punto
    call WriteString
    mov contador, 0 ; Reiniciar el contador
    jmp mouseLoop

    clickCentral:
    inc contador			 ; Incrementar el contador
    mov al, espacio			
    mov codigoMorse[esi], al ; Guardar el espacio en el array
    inc esi					 ; Incrementar el indice del array
    mov edx, OFFSET espacio	 ; Imprimir el espacio
    call WriteString
    cmp contador, 3			 ; Si el contador es igual a 3
    je done					 ; Salir de la funcion
    jmp mouseLoop

    done:
        ret
        call sendMessages
        
    .ENDW
newMessages ENDP

sendMessages PROC
    ; Crear el archivo 
    mov edx, OFFSET fileName
    call CreateOutputFile
    mov fileHandle, eax

    ; Escribir el nombre del usuario
	mov eax, fileHandle
	mov edx, OFFSET nombre
    mov ecx, 5
    call WriteToFile
    
    ; Escribir el identificador del usuario
    mov eax, fileHandle
	mov edx, OFFSET identificador
    mov ecx, 1
    call WriteToFile


    ; Escribir el mensaje del usuario
	mov eax, fileHandle
	mov edx, OFFSET codigoMorse
    mov ecx, MAX
    call WriteToFile

    ; Cerrar el archivo
    invoke CloseHandle, fileHandle
    ret

sendMessages ENDP

checkCoords PROC
    invoke GetStdHandle, STD_INPUT_HANDLE  ; Obtener el identificador de entrada estándar
    mov hStdIn, eax

    invoke GetConsoleMode, hStdIn, ADDR ConsoleMode ; Obtener el modo de consola
    mov eax, 0090h          ; ENABLE_MOUSE_INPUT  ; Habilitar la entrada de ratón
    invoke SetConsoleMode, hStdIn, eax ; Establecer el modo de consola

    .WHILE TRUE
        invoke ReadConsoleInput, hStdIn, ADDR InputRecord, 1, ADDR nRead
        movzx eax, InputRecord.EventType
        cmp eax, MOUSE_EVENT
        jne skipMouseEvent

        ; Verificar si se trata de un evento de clic izquierdo (BUTTON1_PRESSED)
        cmp InputRecord.MouseEvent.dwButtonState, 1
        jne skipMouseEvent

        ; Procesar evento de clic izquierdo
        movzx ebx, InputRecord.MouseEvent.dwMousePosition.Y

        ; Comprobar si la coordenada Y es igual a 9, 14 o 19
        cmp ebx, 9
        je runReceiveMessages
        cmp ebx, 14
        je runSendMessage
        cmp ebx, 19
        je runSalirProgram

        skipMouseEvent:
    .ENDW

    done:
        ret
checkCoords ENDP

runReceiveMessages:
    call clrscr ; Limpia la pantalla
    mov edx, offset instruccione2
    call WriteString
    call receiveMessages
    jmp main

runSendMessage:
    call clrscr ; Limpia la pantalla
    call newMessages
    call sendMessages
    jmp main

runSalirProgram:
    call clrscr ; Limpia la pantalla
    exit

traducirMorseEspanol PROC
    mov edi, 0
    push edi
    mov esi, OFFSET mensajeMorse
    mov edi, 0

    tomarPalabra:
        mov al, [esi]
        inc esi
        cmp al, 0
        je traduccionCompleta
        cmp al, " "
        je comparasionTraduccion

        ; Comparar con "?"
        cmp al, 63
        je traducirInterrogacion ; Salto a traducirInterrogacion si es igual a "?"

        mov bufferTraduccion[edi], al
        inc edi
        jmp tomarPalabra


    comparasionTraduccion:
        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraA
        je traducirA

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraB
        je traducirB

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraC
        je traducirC

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraD
        je traducirD

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraE
        je traducirE

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraF
        je traducirF

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraG
        je traducirG

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraH
        je traducirH

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraI
        je traducirI

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraJ
        je traducirJ

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraK
        je traducirK

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraL
        je traducirL

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraM
        je traducirM

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraN
        je traducirN

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraO
        je traducirO

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraP
        je traducirP

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraQ
        je traducirQ

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraR
        je traducirR

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraS
        je traducirS

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraT
        je traducirT

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraU
        je traducirU

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraV
        je traducirV

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraW
        je traducirW

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraX
        je traducirX

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraY
        je traducirY

        INVOKE Str_compare, ADDR bufferTraduccion, ADDR letraZ
        je traducirZ

        

    traducirA:
		mov al, "A"
        pop edi
		mov traduccionEspanol[edi], al
		inc edi
		push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirB:
        mov al, "B"
		pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirC:
        mov al, "C"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirD:
        mov al, "D"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirE:
        mov al, "E"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirF:
        mov al, "F"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirG:
        mov al, "G"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirH:
        mov al, "H"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirI:
        mov al, "I"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirJ:
        mov al, "J"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirK:
        mov al, "K"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirL:
        mov al, "L"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirM:
        mov al, "M"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirN:
        mov al, "N"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirO:
        mov al, "O"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirP:
        mov al, "P"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirQ:
        mov al, "Q"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirR:
        mov al, "R"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirS:
        mov al, "S"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirT:
        mov al, "T"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirU:
        mov al, "U"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirV:
        mov al, "V"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirW:
        mov al, "W"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirX:
        mov al, "X"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirY:
		mov al, "Y"
		pop edi
		mov traduccionEspanol[edi], al
		inc edi
		push edi
		mov edi, 0
		mov al, [esi]
		cmp al, " "
		je traducirEspacio
		jmp limpiarBufferTraduccion

    traducirZ:
        mov al, "Z"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        mov al, [esi]
        cmp al, " "
        je traducirEspacio
        jmp limpiarBufferTraduccion

    traducirEspacio:
        inc esi
        mov al, [esi]
        cmp al, " "
        je traduccionCompleta
        dec esi
        mov al, " "
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        inc esi
        jmp limpiarBufferTraduccion

    traducirInterrogacion:
        mov al, "?"
        pop edi
        mov traduccionEspanol[edi], al
        inc edi
        push edi
        mov edi, 0
        jmp limpiarBufferTraduccion

    limpiarBufferTraduccion:
		mov al, bufferTraduccion[edi]
        cmp al, 0
        je bufferVacio
        mov al, 0
        mov bufferTraduccion[edi], al
        inc edi
        jmp limpiarBufferTraduccion

    bufferVacio:
        mov edi, 0
        jmp tomarPalabra

    traduccionCompleta:
		pop edi
		mov edi, 0
		mov edx, OFFSET traduccionEspanol
        call WriteString

    limpiarTraduccion:
		mov al, traduccionEspanol[edi]
		cmp al, 0
		je finTraduccion
		mov al, 0
		mov traduccionEspanol[edi], al
		inc edi
		jmp limpiarTraduccion
        mov al, 0
        mov traduccionEspanol[edi], al
        inc edi
        jmp limpiarTraduccion

    finTraduccion:
        ret

traducirMorseEspanol ENDP

main PROC
    ; Limpia la pantalla
	 call clrscr 

	; Mostrar el menu de configuracion
    cmp menuFlag, 1
    je ejecutarMenuConfiguracion

	; Mostrar el menu
    mov edx, offset menuTitle
    call WriteString
    call Crlf
    mov edx, offset option1
    call WriteString
    call Crlf
    mov edx, offset option2
    call WriteString
    call Crlf
    mov edx, offset option3
    call WriteString
	call Crlf
    
    call checkCoords	
    
    ejecutarMenuConfiguracion:
        call clrscr
        call login
        call clrscr
        call menuPrincipal
        mov menuFlag, 0
        jmp main
       

main ENDP

END main
```
