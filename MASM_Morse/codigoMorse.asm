include Irvine32.inc

.data
;-------------------------------Configuracion Usuario--------------------------------------------------------
    nombre db "Josue Matamoros", 0

;----------------------------------------MENU----------------------------------------------------------------
    menuTitle db "Morse-Chat Menu", 0
    option1 db '1. Recibir Mensajes', 0
    option2 db '2. Enviar Mensaje', 0
    option3 db '3. Salir', 0
    invalidOption db 'Opci�n inv�lida', 0
;---------------------------------------LISTENER-------------------------------------------------------------
    archivo db "C:\MASM_Morse\chatTemp.txt",0  
    buffer db 255 dup(0) ; Buffer para almacenar el mensaje
    VK_ESCAPE EQU 27 ; Valor virtual de la tecla Esc
;----------------------------------------Mensaje-------------------------------------------------------------
    instrucciones1 BYTE "Ingrese su mensaje en codigo Morse.", 0
    MAX = 80                ; Máximo número de caracteres a leer
    morse_mensaje BYTE MAX+1 DUP (?) ; Espacio para almacenar la cadena (incluyendo el byte nulo)
;-----------------------------------Manejo de archivos-------------------------------------------------------
    fileName BYTE "C:\MASM_Morse\morse.txt",0
    fileHandle HANDLE 0

.code

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

    ; Leer el mensaje del usuario
    mov edx, OFFSET morse_mensaje
    mov ecx, MAX
    call ReadString

    ret
newMessages ENDP

sendMessages PROC
    ; Crear el archivo 
    mov edx, OFFSET fileName
    call CreateOutputFile
    mov fileHandle, eax

    ; Escribir el mensaje del usuario
	mov eax, fileHandle
	mov edx, OFFSET morse_mensaje
    mov ecx, MAX
    call WriteToFile

    ; Cerrar el archivo
    invoke CloseHandle, fileHandle
    ret
sendMessages ENDP

main PROC
	; Mostrar el men�
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

    call ReadInt  ; Lee la opci�n ingresada por el usuario
        
    ; if (opcion == 1) runReceiveMessages();
    cmp eax, 1
    je runReceiveMessages

    ; if (opcion == 2) runSendMessage();
	cmp eax, 2
    je runSendMessage

    ; if (opcion == 3) runSalirProgram();
    cmp eax, 3
    je runSalirProgram

    ; else runInvalidOption();
    jmp runInvalidOption

    runReceiveMessages:
		call clrscr ; Limpia la pantalla
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
		
	runInvalidOption:
        call clrscr ; Limpia la pantalla
        mov edx, offset invalidOption
        call WriteString
        call Crlf
        jmp main

    		
main ENDP

end main
