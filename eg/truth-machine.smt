  MOV R3, 3
  MOV R0, TTY
  MOV R1, R0
  SUB R0, 48
  NOT R0             ; 1 if input was '0', 0 otherwise
  MUL R0, 3          ; now 3 if input was '0', 0 otherwise
  COR +1, +5, R0
  NOP
  NOP
  NOP
  COR +1, -3, R3     ; zero out the next three instructions
  MOV R0, 48         ; print zero and halt
  MOV TTY, R0
  STOP
  MOV R2, 49
  SUB R1, 49
  NOT R1             ; 1 if input was '1', 0 otherwise
  MUL R1, 2
  MOV TTY, R2
  COR +1, -1, R1
