// seed 115
lbi r0, 80 // icount 0
slbi r0, 199 // icount 1
lbi r1, 4 // icount 2
slbi r1, 103 // icount 3
lbi r2, 55 // icount 4
slbi r2, 159 // icount 5
lbi r3, 169 // icount 6
slbi r3, 220 // icount 7
lbi r4, 174 // icount 8
slbi r4, 46 // icount 9
lbi r5, 138 // icount 10
slbi r5, 156 // icount 11
lbi r6, 188 // icount 12
slbi r6, 182 // icount 13
lbi r7, 102 // icount 14
slbi r7, 26 // icount 15
j 8 // icount 16
nop // icount 17
nop // icount 18
nop // icount 19
nop // icount 20
lbi r4, 0 // icount 21
lbi r5, 0 // icount 22
bltz r4, 12 // icount 23
slt r6, r4, r5 // icount 24
nop // to align meminst icount 25
andni r4, r4, 1 // icount 26
st r5, r4, 12 // icount 27
sll r4, r4, r6 // icount 28
nop // to align meminst icount 29
andni r5, r5, 1 // icount 30
ld r0, r5, 2 // icount 31
add r3, r6, r5 // icount 32
andn r0, r3, r6 // icount 33
srl r2, r7, r7 // icount 34
roli r6, r3, 1 // icount 35
andni r3, r2, 8 // icount 36
andni r5, r2, 13 // icount 37
slt r1, r6, r7 // icount 38
nop // to align meminst icount 39
andni r0, r0, 1 // icount 40
st r4, r0, 0 // icount 41
j 18 // icount 42
nop // icount 43
nop // icount 44
nop // icount 45
nop // icount 46
nop // icount 47
nop // icount 48
nop // icount 49
nop // icount 50
nop // icount 51
j 8 // icount 52
nop // icount 53
nop // icount 54
nop // icount 55
nop // icount 56
lbi r4, 0 // icount 57
lbi r5, 0 // icount 58
beqz r5, 16 // icount 59
lbi r2, 6 // icount 60
rol r2, r6, r7 // icount 61
xori r5, r1, 1 // icount 62
slt r6, r2, r5 // icount 63
ror r5, r5, r2 // icount 64
add r0, r1, r5 // icount 65
sle r1, r0, r7 // icount 66
rori r7, r3, 13 // icount 67
xor r1, r6, r6 // icount 68
halt // icount 1638
