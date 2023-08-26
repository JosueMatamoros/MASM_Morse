include Irvine32.inc

.data
;------------------------------------------------------------------------------------------------------------------------
    menuTitle db "Morse-Chat Menu", 0
    option1 db '1. Recibir Mensajes', 0
    option2 db '2. Salir', 0
    invalidOption db 'Opción inválida', 0
;------------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------------------
    archivo db "C:\MASM_Morse\chatTemp.txt",0  ; Cambia esta ruta a la ubicación correcta
    buffer db 255 dup(0) ; Buffer para almacenar el mensaje
;------------------------------------------------------------------------------------------------------------------------

.code

receiveMessages PROC
    ; Abrir el archivo en modo de lectura y escritura
    invoke CreateFile, ADDR archivo, GENERIC_READ or GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov ebx, eax  ; Guardar el identificador del archivo en ebx
    cmp ebx, INVALID_HANDLE_VALUE ; Comprobar si hubo un error al abrir el archivo
    je NoNuevoMensaje

    ; Leer el contenido del archivo
    invoke ReadFile, ebx, ADDR buffer, 255, NULL, NULL

    ; Cerrar el archivo
    invoke CloseHandle, ebx

    cmp byte ptr [buffer], 0 ; Comprobar si el archivo no estaba vacío
    je NoNuevoMensaje

    ; Mostrar el mensaje en la terminal
    mov edx, OFFSET buffer
    call WriteString

    ; Abrir el archivo en modo de escritura para borrar su contenido
    invoke CreateFile, ADDR archivo, GENERIC_WRITE, 0, NULL, TRUNCATE_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov ebx, eax
    cmp ebx, INVALID_HANDLE_VALUE
    je NoNuevoMensaje

    ; Escribir una cadena vacía en el archivo (para limpiarlo)
    mov edx, OFFSET buffer
    invoke WriteFile, ebx, edx, 1, ADDR buffer, NULL

    ; Cerrar el archivo nuevamente
    invoke CloseHandle, ebx

NoNuevoMensaje:
    jmp receiveMessages ; Volver a verificar infinitamente

receiveMessages ENDP

main PROC
    call clrscr ; Limpia la pantalla

    mov edx, offset menuTitle
    call WriteString
    call Crlf
    mov edx, offset option1
    call WriteString
    call Crlf
    mov edx, offset option2
    call WriteString
    call Crlf

    call ReadInt  ; Lee la opción ingresada por el usuario
        
    ; if (opcion == 1) runReceiveMessages();
    cmp eax, 1
    je runReceiveMessages

    ; if (opcion == 2) runExitProgram();
    cmp eax, 2
    je runExitProgram

    ; else runInvalidOption();
    jmp runInvalidOption

    runReceiveMessages:
		call clrscr ; Limpia la pantalla
        call receiveMessages
		jmp main

    runExitProgram:
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
