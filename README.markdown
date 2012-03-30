SMITH
=====

**S**elf-**M**odifying **I**ndecent **T**uring **H**ack

Version 2.1-2011.0922. ©2000-2011 Cat's Eye Technologies. All rights
reserved.

* * * * *

> "This space intentionally left blank."
>
> — MIT's *Dungeon* (later Infocom's *Zork I*)

> "The only thing that really worried me was the ether. There is nothing
> in the world more helpless and irresponsible and depraved than a man
> in the depths of an ether binge. And I knew we'd get into that rotten
> stuff pretty soon."
>
> — Hunter S. Thompson, *Fear and Loathing in Las Vegas*

What is SMITH?
--------------

SMITH, the successor to [SMETANA][], is a programming language that goes
one better than [Bullfrog][]. Not only are there no conditional jumps,
there are no jumps **whatsoever**. The program counter can *only* be
incremented, and *only* instruction by instruction.

[SMETANA]:  http://catseye.tc/projects/smetana/
[Bullfrog]: http://esolangs.org/wiki/Bullfrog

### What the...???

*But*, you ask, *how can such an ungodly beast be Turing-Complete?
Surely this goes against all that is decent and good and sane in the
world we know.* (OK, maybe you won't put it exactly that way - I forgive
you.)

Well, there's actually a relatively straightforward answer. Instead of
jumping back into code to repeat and/or recheck something, you must
instead copy blocks of code forward, where they will be checked in the
near future.

And if the code copied forward includes the instruction that *caused*
the copy in the first place, that will happen again (and again and
again) when the copy executes. A loop, but not by means of iteration or
recursion but instead by *self-propogation*.

Otherwise, SMITH is basically a small generic imperative CISC-ish
virtual machine with only the most basic arithmetic operations, loosely
modelled on the "[imaginary] register machine that is representative of
several minicomputers" described in section 9.2 of the Dragon Book.

And when I say loosely modelled, I mean it. Differences between this and
the 'Dragon' machine include the fact that this has no `ADD`
instruction, and that here, the destination is specified *before* the
source (not after;) also, the `#` before an immediate (literal) is
allowed but not required here, and the indirection syntax is completely
different (there's only indirect references to registers, not memory,
anyway.)

Overview
--------

Consider the SMITH machine to have an unlimited number of registers.
These are called `R0` to `Rn` where no arbitrary limit is imposed on
`n`. In some instructions, they may be referenced indirectly, and in
that case they are called `R[R0]` to `R[Rn]`.

An indirect reference like `R[R0]` refers to 'the register whose number
is the number stored in register zero.' If `R0` contained 7, then
`R[R0]` would be synonymous with `R7`.

Each instruction has the general form:

      OPCODE [destination[, source[, length]]]

(Here, the square breackets denote "may be omitted", not indirect
references.)

`destination` is either the name of a register or an immediate offset
from the current program counter. `source` is either a register, an
immediate offset from the current program counter, or an immediate
integer. `length`, if present, is the name of a register. All integers
are notated in decimal. `#` may precede immediate integers if the
programmer desires. However, it may not precede offsets (they should be
preceded by either `+` or `-`.)

Instructions
------------

The basic instructions (available in the original version) are:

      MOV register, immediate       e.g.  MOV R0, 0
      MOV register, register              MOV R1, R0

      SUB register, immediate             SUB R1, 1
      SUB register, register              SUB R0, R1

      MUL register, immediate             MUL R0, 2

      NOT register                        NOT R0

      COR offset, offset, register        COR +1, -5, R0

      STOP                                STOP

The instructions in the following table were made available in SMITH v2
(June 25 2000).

      MOV [register], register            MOV R[R1], R0
      MOV register, [register]            MOV R1, R[R0]

      MOV [register], "string"            MOV R[R0], "nights and weird mornings"

      MOV register, PC                    MOV R303, PC
      MOV register, *                     MOV R304, *

      MOV TTY, register                   MOV TTY, R1
      MOV TTY, [register]                 MOV TTY, R[R65535]
      MOV register, TTY                   MOV R0, TTY
      MOV [register], TTY                 MOV R[R0], TTY

      MUL register, register              MUL R999999999, R123456789

      COR offset, register, register      COR +1, R22, R23

      BLA offset, NOP, register           BLA +2, NOP, R10

      NOP                                 NOP

SMITH v2 also added two directives:

      ; arbitrary text composing a source comment               ; Kilroy was here
      REP int OPCODE [destination[, source[, length]]]          REP 50 STOP

Explanation
-----------

`MOV` will assign a register a value without modifying it.

The `TTY` forms of `MOV` are just a lazy way to refer to some
(potentially complex) system routine for the 'usual' input and output
character streams, so the program can communicate (in some primitive
fashion) with the user.

The `PC` and `*` forms of `MOV` facilitate calculating absolute
addresses of subroutines. Actually, `*` is more like a macro which
expands to the current line number in the source file.

The `"string"` form of `MOV` moves each character of the immediate
string into a successive register. If `R0` contained 7, then
`MOV R[R0], "cat"` would result in `R7 == 'c', R8 == 'a', R9 == 't'`.

`SUB` and `MUL` will subtract or multiply a register by a value,
respectively. `NOT` will boolean-negate a register (false = 0/zero, true
= 1/nonzero.)

`COR` is the truly interesting opcode; it stands for `CO`py by
`R`egister. The value of the length operand (which is always in a
register) is a count of instructions. This many instructions is copied
from the source offset (which may be immediate or in a register) to the
destination offset (which is always immediate), modifying the program
(thus, self-modifying code.)

> Note: prior to version 2007.0722 of the SMITH language, the result of
> actually **overwriting** existing instructions with other instructions
> was not defined. The original idea was that SMITH programs would
> merely **extend** themselves by copying bits of themselves to just
> past the end of the program, like Sylvester chasing Tweety around the
> Christmas tree on a toy train -- and I still think that's all that's
> needed for SMITH to be Turing-complete. However, since the language
> does reasonably claim to be fully "self-modifying" and not just
> "self-extending" (SEITH?!?), it's official: as of version 2007.0722,
> you can overwrite instructions with other instructions using `COR`.
> Even when the source and destination ranges of such a copy overlap,
> the resulting series of instructions at the destination should be an
> exact copy of the series at the source.
>
> > Note note: It seems some of you are having trouble understanding the
> > version system being used for SMITH, which is eminently
> > understandable given that it is completely inconsistent. The first
> > version had no version. The second version, released a scant few
> > days later, containing many new instructions, was "v2". That version
> > was re-christened "version 2.0L" when we added the BSD license to it
> > (because "L" is for "license", y'see?) The third version, released a
> > scant few years later, was "version 2007.0722". This was back when
> > we thought date-based version numbers could substitute entirely for
> > sequence-based version numbers. This version was also known as
> > "version 2.1 revision 2007.0722" when we dropped that idea. The
> > current version, which differs mainly in that its documentation
> > contains this paragraph, is version **2.1-2011.0922**. Your
> > knowledge is now complete. Go home.

`BLA` is kind of a special version of `COR` that makes some programming
a lot easier. It stands for `BLA`nk and as part of it's very special
format it takes an *immediate opcode* as its second argument. It copies
that opcode (which must be either `NOP` or `STOP`) to the offset, and
uses the number found in the length register as a multiplier.

Execution starts at the beginning of the program (well, naturally,) and
stops when the program counter tries to execute beyond the last
instruction specified in the program. A `STOP` instruction will also
serve this purpose, if you choose to use it.

### Huh.

So there you go. Myth debunked. You don't need `if` or `goto` or `while`
or anything so fancy to be Turing-Complete. All you need is to be able
to `memcpy` yourself! Don't that just take the cake?
