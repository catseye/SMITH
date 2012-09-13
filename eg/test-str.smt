; Test for bug reported by Keymaker:
; should output a *, not a NUL.
MOV R0, 0
MOV R[R0], "a*b"
MOV TTY, R1
MOV R10, 10
MOV TTY, R10

