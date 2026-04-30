# The Forte Programming Language


## Introduction

Forte is an esoteric programming language. Rather than a typical syntax, Forte programs use
chords on a musical score to represent executable instructions. The series of chords is treated as
executable instructions. The instruction set supports arithmetic, conditionals, functions, loops,
and output.

A Forte program is a staff containing a sequence of chords. Each chord consists of a sequence of notes. 
Notes are written using Scientific Pitch Notation (SPN). All notes within a chord must fall
within the range of a typical piano keyboard (A0-C8), so there are 88 available pitches in total.



## Forte Grammar

The grammar for Forte is defined as follows.

```
program ::= staff ...
staff ::= (staff chord ...)
chord ::= (chord note ...)
note ::= all standard SPN notes for an 88-key keyboard (A0-C8)
```

Forte supports multiple staves; thi provides cleaner score output that more accurately matches how scores are written on paper and how they are read.
However, contrary to how musical scores are played, multiple staves are not executed in parallel.
They are executed sequentially, so there is no processing benefit to splitting a hand-written Forte program onto a second staff.



## Code and Documentation

The source code of the Forte language is avaiable at the [impl](https://github.com/chenxiao2402/AFP-Spring26/tree/main/final/impl) folder.

The reader is also encouraged to explore more details about Forte in this [document](https://github.com/chenxiao2402/AFP-Spring26/blob/main/final/Forte-Document.pdf).
