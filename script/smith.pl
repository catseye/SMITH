#!/usr/bin/env perl

### smith.pl ###

# SMITH - Self Modifying Indecent Turing Hack, v2.1-2012.0916

# Copyright (c)2000-2012, Chris Pressey, Cat's Eye Technologies.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notices, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notices, this list of conditions, and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#  3. Neither the names of the copyright holders nor the names of their
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
# COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

### SMITH Interpreter v2.1-2012.0916 ###

  ##############################################################
  # "'Look outside,' I said.                                   #
  #  'Why?'                                                    #
  #  'There's a big... machine in the sky,... some kind of     #
  #   electric snake... coming straight at us.'                #
  #  'Shoot it,' said my attorney.                             #
  #  'Not yet,' I said, 'I want to study its habits.'"         #
  #    -- Hunter S. Thompson, _Fear and Loathing in Las Vegas_ #
  ##############################################################

# Usage:   [perl] smith[.pl] [-c] [-d] [-g] [-p] [-q] [-x] [-y] program.smt
# Options: -c       Continue (Don't Break program on Error)
#          -d       Run in Debugging Mode
#          -g       Use v2-compatible "goofy copy"
#          -p       Pause (in conjunction with -d)
#          -q       Quiet (Don't display messages)
#          -x       Expand * even in strings (pre-2012 compat)
#          -y       Use pre-2012-compatible "goofy string literals"

# Changes in SMITH v2.1-2012.0916:
# - Fixed a bug reported by Keymaker: creating a string literal
#   where one of the characters of the string is written into
#   the same register used in the indirect register reference, e.g.
#     MOV R0, 0
#     MOV R[R0], "hi"
#   was... goofy; it would take the character written into R0 as the
#   new reference, and typically jump ahead many registers.  This
#   has been fixed, but the behaviour can be re-enabled with the
#   -y option (although why you would need this behaviour is beyond me.)
# - Fixed a bug not reported by Keymaker, but which would have
#   affected his example if it had got that far: the * "macro"
#   was being expanded to the source line number, even in string
#   literals.  This has been turned off, but can be re-enabled
#   with the -x option.
# Changes in SMITH v2007.0722:
# - Copying instructions over other instructions is now defined
#   by the language.  Previous implementation of interpreter had
#   "goofy" behaviour (like some memcpy(3) implementations, as
#   opposed to memmove(3)) when doing overlapping copies.  This
#   interpreter implements a non-surprising, non-destructive,
#   non-goofy overlapping copy.  This behaviour was pointed out by
#   Nathan Thern, and the fix is based on a patch provided by him.
# - Canonicalized BSD license language (no "REGENTS" plz kthx)
# - Alphabetized switches
# Changes in smith.pl v2.0L (July 11 2000):
# - Changed license to BSD license.
# Changes in SMITH Interpreter v2 (June 25 2000):
# - Added NOP instruction
# - Added BLA imm, OPCODE, reg instruction
# - Added mode to MUL: MUL reg, reg
# - Added mode to MOV: MOV reg, PC
# - Added mode to MOV: MOV [reg], "string"
# - Added mode to MOV: MOV TTY, [reg]
# - Added mode to MOV: MOV reg, TTY
# - Added mode to MOV: MOV [reg], TTY
# - Added mode to MOV: MOV [reg], reg
# - Added mode to MOV: MOV reg, [reg]
# - Added REP xxx OPCODE syntax (for putting in many NOPs, etc)
# - Added ; Comment line parsing to input file
# - Added command-line option for debug, continue, quiet, pause
# - Improved the comments
# - Corrected the above quotation
# - Corrected many errors in the web page
# - Nothing else (100% backwards-compatible with original)

### GLOBALS ###

# $mem is a reference to an array which contains all program
# instructions. The 1st instruction is stored as text in $mem->[0].
$mem = [];

# $reg is a reference to an array which contains all machine
# registers. The value of R0 is stored in $reg->[0].
$reg = [];

# flag to continue after error
$cont = 0;

# $debug is a flag indicating whether we want debugging messages
# to appear during loadtime and runtime.  By default off, it can
# be turned on by giving the command line option -d or -debug.
$debug = 0;

# flag to enable v2-compatible "goofy copy" behaviour
$goofycopy = 0;

# flag to enable expanding * in string constants (pre-2012 behaviour)
$starstr = 0;

# flag to enable pre-2012 compatible "goofy string literal" behaviour
$goofystr = 0;

# flag to pause during debugging
# only works when input is from terminal! :-)
$pause = 0;

# flag to be quiet
$quiet = 0;

### SUBROUTINES ###

# load_program loads the program (given at standard input) into
# the $mem array.  The only directive it currently has to handle
# is the REP directive, which will repeat an opcode a constant
# number of times.
sub load_program
{
  my $filename = shift;
  my $line = '';
  my $i = 0;
  open INPUTFILE, $filename;
  while(defined($line = <INPUTFILE>))
  {
    $line = $' if $line =~ /^\s*/;
    $line = $` if $line =~ /\s*$/;
    $line =~ s/\s*;.*?$//;
    if ($starstr or $line !~ /\"(.*?)\"/) {
      $line =~ s/\*/$i/ge;
    }    
    if ($line =~ /^\S+/)
    {
      my $reps = 1; my $j;
      if ($line =~ /^REP\s*(\d+)\s*/)
      {
        $line = $';
        $reps = $1;
      }
      for($j = 0; $j < $reps; $j++)
      {
        $mem->[$i] = $line;
        # print "Load $i = $mem->[$i]\n" if $showload;
        $i++;
      }
    }
  }
  close INPUTFILE;
}

# run_program interprets the program stored in $mem using the
# registers stored in $reg to handle values.
#
# This subroutine contains a 'fetch-execute' cycle, which reads
# the current instruction from $mem, executes the instruction,
# then makes the next instruction the current instruction.
#
# (The instructions are stored as text in the elements of the
#  array which $mem references.  This is not a high-performance
#  approach.  It's more for program readability.)
sub run_program
{
  my $pc = 0;
  while($mem->[$pc] ne 'STOP')
  {
    if ($debug)
    {
      print "Registers: ";
      for ($ggg = 0; $ggg <= 100; $ggg++)
      {
        if (defined $reg->[$ggg])
        {
          print "R$ggg = " . $reg->[$ggg] . "   ";
        }
      }
      print "\nExecute $pc = $mem->[$pc]\n";
      <STDIN> if $pause;
    }

    if ($mem->[$pc] =~
    /^MOV\s*R(\d+)\s*,\s*\#?(\d+)$/)                # MOV reg, imm
    {
      $reg->[$1] = $2;
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*R(\d+)\s*,\s*R(\d+)$/)                  # MOV reg, reg
    {
      $reg->[$1] = $reg->[$2];
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*R\[R(\d+)\]\s*,\s*R(\d+)$/)            ## MOV [reg], reg
    {
      $reg->[$reg->[$1]] = $reg->[$2];
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*R(\d+)\s*,\s*R\[R(\d+)\]$/)            ## MOV reg, [reg]
    {
      $reg->[$1] = $reg->[$reg->[$2]];
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*R\[R(\d+)\]\s*,\s*\"(.*?)\"$/)         ## MOV [reg], "string"
    {
      my $i = $reg->[$1];
      my $s = $2;
      if ($goofystr) {
        while ($i < ($reg->[$1] + length($s)))
        {
          $reg->[$i] = ord(substr($s, ($i-$reg->[$1]), 1)); $i++;
        }
      } else {
        my $j = $i;
        while ($i < $j + length($s))
        {
          $reg->[$i] = ord(substr($s, ($i-$j), 1)); $i++;
        }
      }
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*R(\d+)\s*,\s*PC$/)                     ## MOV reg, PC
    {
      $reg->[$1] = $pc;
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*TTY\s*,\s*R(\d+)$/)                     # MOV TTY, reg
    {
      print chr($reg->[$1]);
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*TTY\s*,\s*R\[R(\d+)\]$/)               ## MOV TTY, [reg]
    {
      print chr($reg->[$reg->[$1]]);
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*R(\d+)\s*,\s*TTY$/)                    ## MOV reg, TTY
    {
      if (read STDIN, $reg->[$1], 1)
      {
        $reg->[$1] = ord($reg->[$1]);		      
      } else
      {
        # print "<<EOF>>";
        # $debug = 1; $pause = 1;
        $reg->[$1] = 0;
      }
    }
    elsif ($mem->[$pc] =~
    /^MOV\s*R\[R(\d+)\]\s*,\s*TTY$/)               ## MOV [reg], TTY
    {
      if (read STDIN, $reg->[$reg->[$1]], 1)
      {
        $reg->[$reg->[$1]] = ord($reg->[$reg->[$1]]);
      } else
      {
        # print "<<EOF>>";
        # $debug = 1; $pause = 1;
        $reg->[$reg->[$1]] = 0;
      }
    }
    elsif ($mem->[$pc] =~
    /^SUB\s*R(\d+)\s*,\s*\#?(\d+)$/)                # SUB reg, imm
    {
      $reg->[$1] -= $2;
    }
    elsif ($mem->[$pc] =~
    /^SUB\s*R(\d+)\s*,\s*R(\d+)$/)                  # SUB reg, reg
    {
      $reg->[$1] -= $reg->[$2];
    }
    elsif ($mem->[$pc] =~
    /^MUL\s*R(\d+)\s*,\s*\#?(\d+)$/)                # MUL reg, imm
    {
      $reg->[$1] *= $2;
    }
    elsif ($mem->[$pc] =~
    /^MUL\s*R(\d+)\s*,\s*R(\d+)$/)                 ## MUL reg, reg
    {
      $reg->[$1] *= $reg->[$2];
    }
    elsif ($mem->[$pc] =~
    /^NOT\s*R(\d+)$/)                               # NOT reg
    {
      if($reg->[$1] != 0)
      {
        $reg->[$1] = 0;
      } else
      {
        $reg->[$1] = 1;
      }
    }
    elsif ($mem->[$pc] =~                           # COR imm, imm, reg
    /^COR\s*([-+]\d+)\s*,\s*([-+]\d+)\s*,\s*R(\d+)\s*$/)
    {
      my $dst = 0+$pc+$1;
      my $src = 0+$pc+$2;
      my $lrg = 0+$3;
      my @instructions = @{$mem}[$src .. ($src + $reg->[$lrg] - 1)];
      print "Copy $reg->[$lrg] Instructions from $src to $dst\n" if $debug;
      <STDIN> if $debug and $pause;
      my $i;
      {
        for ($i = 0; $i < $reg->[$lrg]; $i++)
        {
          $mem->[$dst+$i] = $goofycopy ? $mem->[$src+$i] : $instructions[$i];
          $ggg = $dst + $i;
          $hhh = $src + $i;
          print "  $ggg = $hhh = $mem->[$ggg]\n" if $debug;
          <STDIN> if $debug and $pause;
        }
      }
    }
    elsif ($mem->[$pc] =~                           # COR imm, reg, reg
    /^COR\s*([-+]\d+)\s*,\s*R(\d+)\s*,\s*R(\d+)\s*$/)
    {
      my $dst = 0+$pc+$1;
      my $src = 0+$pc+$reg->[$2];
      my $lrg = 0+$3;
      my @instructions = @{$mem}[$src .. ($src + $reg->[$lrg] - 1)];
      print "Copy $reg->[$lrg] Instructions from $src to $dst\n" if $debug;
      <STDIN> if $debug and $pause;
      my $i;
      {
        for ($i = 0; $i < $reg->[$lrg]; $i++)
        {
          $mem->[$dst+$i] = $goofycopy ? $mem->[$src+$i] : $instructions[$i];
          $ggg = $dst + $i;
          $hhh = $src + $i;
          print "  $ggg = $hhh = $mem->[$ggg]\n" if $debug;
          <STDIN> if $debug and $pause;
        }
      }
    }
    elsif ($mem->[$pc] =~                           # BLA imm, OPC, reg
    /^BLA\s*([-+]\d+)\s*,\s*(\w+)\s*,\s*R(\d+)\s*$/)
    {
      my $dst = 0+$pc+$1;
      my $src = $2;
      my $lrg = 0+$3;
      print "Copy $reg->[$lrg] $src Instructions into $dst\n" if $debug;
      <STDIN> if $debug and $pause;
      my $i;
      {
        for ($i = 0; $i < $reg->[$lrg]; $i++)
        {
          $mem->[$dst+$i] = $src;
          $ggg = $dst + $i;
          print "  $ggg = $mem->[$ggg]\n" if $debug;
          <STDIN> if $debug and $pause;
        }
      }
    }
    elsif ($mem->[$pc] =~ /^NOP$/)                 ## NOP
    {
      # Nothing happens here.
    }
    else
    {
      print "Invalid instruction $mem->[$pc]!\n";
      $pc = $#{$mem} + 1 if not $cont;
    }
    $pc++;
    $mem->[$pc] = 'STOP' if $pc > $#{$mem};
  }
}

### MAIN ###

while(defined($ARGV[0]) and $ARGV[0] =~ /^\-(\S+)/)
{                       # retrieve any command-line options
  if ($1 eq 'c' or $1 eq 'continue')
  {
    $cont = 1;
  }
  elsif ($1 eq 'd' or $1 eq 'debug')
  {
    $debug = 1;
  }
  elsif ($1 eq 'g' or $1 eq 'goofycopy')
  {
    $goofycopy = 1;
  }
  elsif ($1 eq 'p' or $1 eq 'pause')
  {
    $pause = 1;
  }
  elsif ($1 eq 'q' or $1 eq 'quiet')
  {
    $quiet = 1;
  }
  elsif ($1 eq 'x' or $1 eq 'starstr')
  {
    $starstr = 1;
  }
  elsif ($1 eq 'y' or $1 eq 'goofystr')
  {
    $goofystr = 1;
  }
  else
  {
    print "Unknown command-line option $ARGV[0]\n";
  }
  shift @ARGV;
}

### START ###

print "SMITH Interpreter v2.1-2012.0916\n" if not $quiet;

die "No program filename given" if !defined($ARGV[0]) or $ARGV[0] eq '';
die "Can't find/read file '$ARGV[0]'" if not -r $ARGV[0];

print "Loading $ARGV[0]..." if not $quiet;
load_program($ARGV[0]);       # load the program then
print "\nRunning...\n" if not $quiet;
run_program();                # run it... and that's all!

### END of smith.pl ###
