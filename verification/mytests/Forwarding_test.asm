lbi  r0, 1
lbi  r1, 1
slbi r1, 1
//EX-EX Forwarding
add  r2, r0, r0  //r2=2
add  r3, r2, r0  //r3=3
add  r4, r2, r0  //r4=3
add  r3, r3, r0  //r3=4

st   r3, r4, 0   //r3=4

//MEM-EX Forwarding
ld   r5, r4, 0   //r5=4
add  r3, r5, r0  //r3=5

//MEM-MEM Forwarding
ld   r6, r4, 0   //r6=4
st   r6, r4, 4   //r6=4

halt