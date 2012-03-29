; Print ASCII table in descending order in SMITH v1
; (relatively easy)

  MOV R0, 126       ; Initialize register with top character
  MOV TTY, R0       ; -> Print character to terminal
  SUB R0, 1         ; -> Decrement character
  MOV R1, R0        ; -> Is character zero?
  NOT R1            ; -> Boolean NOT it twice to find out
  NOT R1            ; -> Result is 1 if true, 0 if false
  MUL R1, 7         ; -> Multiply result by seven instructions
  COR +1, -6, R1    ; -> Copy that many instructions forward
