! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.data arrays byte-arrays compiler.units
destructors io kernel libc math quotations sequences
sequences.private stack-checker system tr vocabs words ;
IN: tools.disassembler

GENERIC: disassemble ( obj -- )

<PRIVATE

SYMBOL: disassembler-backend

HOOK: disassemble* disassembler-backend ( from to -- )

GENERIC: convert-address ( object -- n )

M: integer convert-address ;

M: alien convert-address alien-address ;

PRIVATE>

M: byte-array disassemble
    [
        [ malloc-byte-array &free alien-address dup ]
        [ length + ] bi 2array disassemble
    ] with-destructors ;

M: pair disassemble
    first2-unsafe [ convert-address ] bi@ disassemble* ;

M: word disassemble word-code 2array disassemble ;

M: callable disassemble
    [ dup infer define-temp ] with-compilation-unit disassemble ;

cpu x86?
"tools.disassembler.udis"
"tools.disassembler.gdb" ?
require
