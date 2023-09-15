include Irvine32.inc

.data
;-------------------------------CONFIGURACION DE USUARIO-----------------------------------------------------
    nombre db 'Josue Matamoros', 0
    largoNombre BYTE 0
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
    db 'Selecione una configuacion ',0ah,0dh,0

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

.code
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

    ; Comprobar si el archivo no estaba vac�o
    cmp byte ptr [buffer], 0 
    je NoNuevoMensaje

    ; Mostrar el mensaje en la terminal
    mov edx, OFFSET buffer
    call WriteString

    ; Abrir el archivo en modo de escritura para borrar su contenido
    invoke CreateFile, ADDR archivo, GENERIC_WRITE, 0, NULL, TRUNCATE_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov ebx, eax
    cmp ebx, INVALID_HANDLE_VALUE
    je NoNuevoMensaje

    ; Escribir una cadena vac�a en el archivo (para limpiarlo)
    mov edx, OFFSET buffer
    invoke WriteFile, ebx, edx, 1, ADDR buffer, NULL

    ; Cerrar el archivo nuevamente
    invoke CloseHandle, ebx

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
    mov ecx, 15
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
        call menuPrincipal
        mov menuFlag, 0
        jmp main
       

main ENDP

END main
```
