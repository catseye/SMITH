; Check input file for matching brackets in SMITH!
; Prints nothing if there was an error or 'OK' if brackets match.
; R0 -> stack pointer (starts at R32)
; R1 -> work register
; R2 -> -1
; R3 -> input char
; R4 -> scratch temp copy of PC
; R5 -> scratch temp copy of *
; R6 -> scratch for PC/* arithmetic
; R7 -> 2
; R8 -> 9
; R9 -> scratch char
; R10 -> 15
; R11 -> 1

; set up stack

  MOV R0, 32
  MOV R2, 0
  SUB R2, 1
  MOV R8, 9
  MOV R7, 2
  MOV R10, 15
  MOV R11, 1

; push 'S'

  MOV R[R0], "S"
  SUB R0, R2

; LABEL MainLoop
  
; read char

  MOV R3, TTY
 
; if char == '{' push

  MOV R1, R3
  MOV R[R8], "{"
  SUB R1, R9
  NOT R1
  MUL R1, 2      ; LENGTH PushLeftBrace

  MOV R4, PC     ; R4 = PC
  MOV R5, *
  MOV R6, 0
  SUB R6, 10048; bytes between here and PushLeftBrace
  SUB R5, R6     ; R5 = PushLeftBrace
  SUB R5, R4     ; R5 = PushLeftBrace - PC

  BLA +2, NOP, R7

  COR +1, R5, R1

  NOP
  NOP
  
; if char == '}' pop

  MOV R1, R3
  MOV R[R8], "}"
  SUB R1, R9
  NOT R1
  MUL R1, 15     ; LENGTH PopLeftBrace

  MOV R4, PC     ; R4 = PC
  MOV R5, *
  MOV R6, 0
  SUB R6, 10035; bytes between here and PopLeftBrace
  SUB R5, R6     ; R5 = PopLeftBrace
  SUB R5, R4     ; R5 = PopLeftBrace - PC

  BLA +2, NOP, R10
  
  COR +1, R5, R1

  REP 15 NOP
  
; if char != 0 goto MainLoop

  MOV R1, R3
  NOT R1
  NOT R1
  MUL R1, 49     ; LENGTH MainLoop + 1
  
; LENGTH MainLoop
  
  COR +1, -48, R1

  REP 10000 NOP                ; This space intentionally left blank

; x = pop

  SUB R0, 1
  MOV R1, R[R0]

; if x != 'S' stop

  MOV R[R8], "S"
  SUB R1, R9
  NOT R1
  NOT R1
		
  COR +1, +6, R1

  NOP

; print 'OK'

  MOV R[R8], "O"
  MOV TTY, R9
  MOV R[R8], "K"
  MOV TTY, R9
 
  STOP
  
; LABEL PushLeftBrace

; push '{'

  MOV R[R0], "{"
  SUB R0, R2
    
; LENGTH PushLeftBrace == 2
  
; LABEL PopLeftBrace

; x = pop;

  SUB R0, 1
  MOV R1, R[R0]

; if x != "{" stop

  MOV R[R8], "{"
  SUB R1, R9
  NOT R1
  NOT R1

  MOV R4, PC     ; R4 = PC
  MOV R5, *
  MOV R6, 0
  SUB R6, 1      ; bytes between here and Halt
  SUB R5, R6     ; R5 = Halt
  SUB R5, R4     ; R5 = Halt - PC
  
  BLA +2, NOP, R11
  
  COR +1, R5, R1

  NOP

; LENGTH PopLeftBrace == 15

; LABEL Halt

  STOP

; LENGTH Halt == 1
  
