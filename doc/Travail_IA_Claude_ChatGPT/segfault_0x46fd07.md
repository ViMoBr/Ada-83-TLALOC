 
#INSTRUCTION SEGFAULT 0x46df97
 <pre>
 (gdb) x/16i $rip-48
   0x46fcd7:    lea    -0x8(%rbp),%ebp
   0x46fcda:    mov    0x0(%rbp),%rax
   0x46fcde:    lea    -0x8(%rbp),%rbp
   0x46fce2:    cqto
   0x46fce4:    idiv   %rbx
   0x46fce7:    mov    %rax,0x8(%rbp)
   0x46fceb:    lea    0x8(%rbp),%rbp
   0x46fcef:    mov    0x18(%r15),%rax
   0x46fcf3:    mov    -0x8(%rax),%rax
   0x46fcf7:    mov    %rax,0x8(%rbp)
   0x46fcfb:    lea    0x8(%rbp),%rbp
   0x46fcff:    mov    0x0(%rbp),%rax
   0x46fd03:    lea    -0x8(%rbp),%rbp
=> 0x46fd07:    mov    (%rax),%rax
   0x46fd0a:    mov    %rax,0x8(%rbp)
   0x46fd0e:    lea    0x8(%rbp),%rbp

</pre>

#REGISTRES AU SEGFAULT
<pre>
rax            0x18                24                 rbx            0x8                 8                  │
│rcx            0x7                 7                  rdx            0x0                 0                  │
│rsi            0x7fffffc06afc      140737484188412    rdi            0x7fffffc06ae4      140737484188388    │
│rbp            0x7fffffc06c18      0x7fffffc06c18     rsp            0x7fffffbfdad0      0x7fffffbfdad0     │
│r8             0xffffffffffffffff  -1                 r9             0x0                 0                  │
│r10            0x22                34                 r11            0x246               582                │
│r12            0x7ffff7df3800      140737351989248    r13            0xd8c500            14206208           │
│r14            0xd8c508            14206216           r15            0x7fffffbfdaf0      140737484151536    │
│rip            0x46fd07            0x46fd07           eflags         0x10206             [ PF IF RF ]       │
</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc06bd8: 0x00007ffff7df9ae8      0x0000000000d8c4c0
0x7fffffc06be8: 0x000000000000001d      0x00007fffffc06ba0
0x7fffffc06bf8: 0x0000000000000018      0x00007fffffc06938
0x7fffffc06c08: 0x00007fffffc06a18      0x0000000000d8c4e0
0x7fffffc06c18: 0x000000000000001d      0x0000000000000018
0x7fffffc06c28: 0x0000000000000004      0x00007ffff7df98e8
0x7fffffc06c38: 0x00000000000000e8      0x0000000000000004
0x7fffffc06c48: 0x0000000000000008      0x0000000000000004
</pre>

#BACKTRACE ET MAP
<pre>
(gdb) bt
#0  0x000000000046fd07 in ?? ()
PRINT_NAME_L25 0x000000000046EE76
var elab TR 0x000000000046EE97
 disp 0x0000000000000008
var elab TXT_HDR 0x000000000046F20E
 disp 0x0000000000000008
var elab START 0x000000000046F39F
 disp 0x0000000000000034
var elab NB_TREES 0x000000000046F4BB
 disp 0x0000000000000035
var elab NB_CARS 0x000000000046F637
 disp 0x0000000000000038

TO_CHN_L187 0x000000000046FC6F
#####  ICI  #####
var elab THE_CHN 0x000000000046FD4D
 disp 0x00000000000000C8

#1  0x000000000046ff98 in ?? ()
var elab THE_CHN 0x000000000046FD4D
 disp 0x00000000000000C8
PRINT_NUM_L26 0x000000000047091F

#2  0x0000000000655c7d in ?? ()
var elab COL 0x00000000006557B9
 disp 0x000000000000001C
including sub body IDL-ERR_PHASE.FINC
WRITE_LIB_L13 0x0000000000656011

#3  0x0000000000d33074 in ?? ()
#4  0x0000000000d33afa in ?? ()

</pre>

#SOURCE ADA 83 SECTION IDL
<pre>
 
</pre>

#SECTION LLIR XXX.FINC
<pre>

 </pre>

#PASSAGES
<pre>

</pre>

#INSCRIPTION AU LIEU UTILISE POUR RSI

<pre>

</pre>