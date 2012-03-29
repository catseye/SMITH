;"99 bottles of beer" in SMITH
; (Graciously submitted by Nathan Thern - thanks Nathan!)

; Make space for moving code fragments back
 REP 108 NOP
; R0 is the primary working register
; R1 contains -1 (for incrementing R0)
 MOV R1, 0
 SUB R1, 1
; R2 is a flag to suppress a leading 0 digit
; R2 will be 6 when on
 MOV R2, 0
; R3 is a flag to suppress the "s" in bottles when appropriate
 MOV R3, 0
; Put string values in registers 10 and on
; R10 contains '0' for comparing to R11 & R12
 MOV R0, 10
 MOV R[R0], "099 bottles of beer on the wall, . Take one down and pass it around, no more"
; R44 is newline
 MOV R44, 10
; move code ahead of us to behind us
 MOV R0, 116
 COR -116, +1, R0
;;;;
; Everything from this point on is copied back to code position 0
; Most of the following the code positions will be overwritten as
;  loop routines are pulled forward
;;;;
; Cont0: Print First phrase
 MOV R0, 11
 MOV R4, 43
 MOV R5, 26
; Routine 1: ends at Cont1
; this routine prints characters
; R0 contains the starting location
; R4 contains the length
; R5 contains the continuation code position
 MOV R6, R0
 SUB R6, 11
 NOT R6
 MUL R6, R2
; suppress a leading 0
; R6 will be set only if R0 is 11 and R2 is set
 BLA +1, NOP, R6
 MOV R6, R0
 SUB R6, 20
 NOT R6
 MUL R6, R3
; suppress the "s"
; R6 will be 1 only if R0 is 20 and R3 is set
 BLA +1, NOP, R6
 MOV TTY, R[R0]
; Copy continuation code forward
 MOV R6, R5
 MOV R7, PC
 SUB R6, R7
 MOV R7, 62
 COR +11, R6, R7
; Overwrite continuation code if loop is incomplete
 SUB R0, R1
 MOV R6, R0
 SUB R6, R4
 NOT R6
 NOT R6
 MUL R6, 26
 MOV R7, 1
 MOV R8, PC
 SUB R7, R8
 COR +1, R7, R6
; Cont1: Print second phrase
; Fill R0, R4 & R5 with start, length & continuation
 MOV R0, 11
 MOV R4, 29
 MOV R5, 34
 MOV R6, 26
 MOV R7, 1
 MOV R8, PC
 SUB R7, R8
 COR +1, R7, R6
; Cont2: Print the third phrase:
; Fill R0, R4 & R5 with start, length & continuation
 MOV R0, 43
 MOV R4, 79
 MOV R5, 42
 MOV R6, 26
 MOV R7, 1
 MOV R8, PC
 SUB R7, R8
 COR +1, R7, R6
; Cont3: Compare the ones digit to 0
 MOV R0, R12
 SUB R0, R10
 NOT R0
 NOT R0
 MUL R0, 11
; The lines preceding Dec1: will be overwritten with blanks
;  if ones digit is not 0
 BLA +1, NOP, R0
; Restore ones digit to 9
 MOV R0, 12
 MOV R[R0], "9"
; Decrement tens digit
 SUB R11, 1
; Compare tens digit to 0
 MOV R0, R11
 SUB R0, R10
 NOT R0
 NOT R0
; R2 will become 6 iff tens digit is 0
 BLA +1, NOP, R0
 MOV R2, 6
; Blank out until XX
 MOV R0, 37
 BLA +1, NOP, R0
; Dec1: Decrement the ones digit
 SUB R12, 1
; compare R2 to 6
 MOV R0, R2
 SUB R0, 6
 NOT R0
 NOT R0
 MUL R0, 30
; Blank up to Cont4: if R2 is not 6
 BLA +1, NOP, R0
; Compare the ones digit to 0
 MOV R0, R12
 SUB R0, R10
 NOT R0
 NOT R0
 MUL R0, 20
; Blank out the final operations unless R2=6 & R12="0"
 BLA +1, NOP, R0
; Final 1: Print "no more"
 MOV R0, 79
 MOV R4, 86
 MOV R5, 80
 MOV R6, 26
 MOV R7, 1
 MOV R8, PC
 SUB R7, R8
 COR +1, R7, R6
; Final 2: Print " Zubbles if bobb in our line"
 MOV R3, 0
 MOV R0, 13
 MOV R4, 41
 MOV R5, 89
 MOV R6, 26
 MOV R7, 1
 MOV R8, PC
 SUB R7, R8
 COR +1, R7, R6
; Final 3: Print a "." and newline and STOP
 MOV TTY, R43
 MOV TTY, R44
 STOP
; Compare the ones digit to "1" & set R3
 MOV R3, R12
 SUB R3, R10
 SUB R3, 1
 NOT R3
; Cont4: Print the 4th phrase
 MOV R0, 11
 MOV R4, 41
 MOV R5, 103
 MOV R6, 26
 MOV R7, 1
 MOV R8, PC
 SUB R7, R8
 COR +1, R7, R6
; Print a . and 2 newlines
 MOV TTY, R43
 MOV TTY, R44
 MOV TTY, R44
; Move on to the next verse
 MOV R6, 29
 MOV R7, 0
 SUB R7, 2
 MOV R8, PC
 SUB R7, R8
 COR +1, R7, R6
