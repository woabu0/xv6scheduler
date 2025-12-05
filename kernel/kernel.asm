
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	88010113          	addi	sp,sp,-1920 # 80007880 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda5f>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	28c020ef          	jal	800023a6 <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	0000f517          	auipc	a0,0xf
    80000196:	6ee50513          	addi	a0,a0,1774 # 8000f880 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	6e248493          	addi	s1,s1,1762 # 8000f880 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	0000f917          	auipc	s2,0xf
    800001aa:	77290913          	addi	s2,s2,1906 # 8000f918 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	03d010ef          	jal	800019fa <myproc>
    800001c2:	07c020ef          	jal	8000223e <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	62b010ef          	jal	80001ff6 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	6a270713          	addi	a4,a4,1698 # 8000f880 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	14c020ef          	jal	8000235c <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	65850513          	addi	a0,a0,1624 # 8000f880 <cons>
    80000230:	28d000ef          	jal	80000cbc <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	0000f717          	auipc	a4,0xf
    80000252:	6cf72523          	sw	a5,1738(a4) # 8000f918 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	61c50513          	addi	a0,a0,1564 # 8000f880 <cons>
    8000026c:	251000ef          	jal	80000cbc <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	5c850513          	addi	a0,a0,1480 # 8000f880 <cons>
    800002c0:	169000ef          	jal	80000c28 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	116020ef          	jal	800023f0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	5a250513          	addi	a0,a0,1442 # 8000f880 <cons>
    800002e6:	1d7000ef          	jal	80000cbc <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	58470713          	addi	a4,a4,1412 # 8000f880 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	0000f717          	auipc	a4,0xf
    80000326:	55e70713          	addi	a4,a4,1374 # 8000f880 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	0000f717          	auipc	a4,0xf
    80000350:	5cc72703          	lw	a4,1484(a4) # 8000f918 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	51e70713          	addi	a4,a4,1310 # 8000f880 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	0000f497          	auipc	s1,0xf
    80000376:	50e48493          	addi	s1,s1,1294 # 8000f880 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	0000f717          	auipc	a4,0xf
    800003b8:	4cc70713          	addi	a4,a4,1228 # 8000f880 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	0000f717          	auipc	a4,0xf
    800003ce:	54f72b23          	sw	a5,1366(a4) # 8000f920 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	0000f797          	auipc	a5,0xf
    800003ec:	49878793          	addi	a5,a5,1176 # 8000f880 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	0000f797          	auipc	a5,0xf
    8000040e:	50c7a923          	sw	a2,1298(a5) # 8000f91c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	0000f517          	auipc	a0,0xf
    80000416:	50650513          	addi	a0,a0,1286 # 8000f918 <cons+0x98>
    8000041a:	429010ef          	jal	80002042 <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	0000f517          	auipc	a0,0xf
    80000434:	45050513          	addi	a0,a0,1104 # 8000f880 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	0001f797          	auipc	a5,0x1f
    80000444:	7c878793          	addi	a5,a5,1992 # 8001fc08 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007817          	auipc	a6,0x7
    80000482:	29a80813          	addi	a6,a6,666 # 80007718 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	32c7a783          	lw	a5,812(a5) # 80007844 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	0000f517          	auipc	a0,0xf
    80000562:	3ca50513          	addi	a0,a0,970 # 8000f928 <pr>
    80000566:	6c2000ef          	jal	80000c28 <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	046c8c93          	addi	s9,s9,70 # 80007718 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	00007797          	auipc	a5,0x7
    8000075e:	0ea7a783          	lw	a5,234(a5) # 80007844 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	0000f517          	auipc	a0,0xf
    80000788:	1a450513          	addi	a0,a0,420 # 8000f928 <pr>
    8000078c:	530000ef          	jal	80000cbc <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	00007797          	auipc	a5,0x7
    80000838:	0097a823          	sw	s1,16(a5) # 80007844 <panicking>
  printf("panic: ");
    8000083c:	00006517          	auipc	a0,0x6
    80000840:	7dc50513          	addi	a0,a0,2012 # 80007018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00006517          	auipc	a0,0x6
    8000084e:	7d650513          	addi	a0,a0,2006 # 80007020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	00007797          	auipc	a5,0x7
    8000085a:	fe97a523          	sw	s1,-22(a5) # 80007840 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00006597          	auipc	a1,0x6
    8000086c:	7c058593          	addi	a1,a1,1984 # 80007028 <etext+0x28>
    80000870:	0000f517          	auipc	a0,0xf
    80000874:	0b850513          	addi	a0,a0,184 # 8000f928 <pr>
    80000878:	326000ef          	jal	80000b9e <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00006597          	auipc	a1,0x6
    800008c2:	77258593          	addi	a1,a1,1906 # 80007030 <etext+0x30>
    800008c6:	0000f517          	auipc	a0,0xf
    800008ca:	07a50513          	addi	a0,a0,122 # 8000f940 <tx_lock>
    800008ce:	2d0000ef          	jal	80000b9e <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	0000f517          	auipc	a0,0xf
    800008ee:	05650513          	addi	a0,a0,86 # 8000f940 <tx_lock>
    800008f2:	336000ef          	jal	80000c28 <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	00007497          	auipc	s1,0x7
    8000090c:	f4448493          	addi	s1,s1,-188 # 8000784c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	0000f997          	auipc	s3,0xf
    80000914:	03098993          	addi	s3,s3,48 # 8000f940 <tx_lock>
    80000918:	00007917          	auipc	s2,0x7
    8000091c:	f3090913          	addi	s2,s2,-208 # 80007848 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	6ca010ef          	jal	80001ff6 <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	0000f517          	auipc	a0,0xf
    8000095a:	fea50513          	addi	a0,a0,-22 # 8000f940 <tx_lock>
    8000095e:	35e000ef          	jal	80000cbc <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	00007797          	auipc	a5,0x7
    8000097e:	eca7a783          	lw	a5,-310(a5) # 80007844 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00007797          	auipc	a5,0x7
    80000988:	ebc7a783          	lw	a5,-324(a5) # 80007840 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	00007797          	auipc	a5,0x7
    800009ae:	e9a7a783          	lw	a5,-358(a5) # 80007844 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	226000ef          	jal	80000be4 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2a6000ef          	jal	80000c6c <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	0000f517          	auipc	a0,0xf
    80000a0a:	f3a50513          	addi	a0,a0,-198 # 8000f940 <tx_lock>
    80000a0e:	21a000ef          	jal	80000c28 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	0000f517          	auipc	a0,0xf
    80000a24:	f2050513          	addi	a0,a0,-224 # 8000f940 <tx_lock>
    80000a28:	294000ef          	jal	80000cbc <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	00007797          	auipc	a5,0x7
    80000a40:	e007a823          	sw	zero,-496(a5) # 8000784c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	e0450513          	addi	a0,a0,-508 # 80007848 <tx_chan>
    80000a4c:	5f6010ef          	jal	80002042 <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	00020797          	auipc	a5,0x20
    80000a6c:	33878793          	addi	a5,a5,824 # 80020da0 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	ef95                	bnez	a5,80000abc <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	eb95                	bnez	a5,80000abc <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	26a000ef          	jal	80000cf8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	0000f917          	auipc	s2,0xf
    80000a96:	ec690913          	addi	s2,s2,-314 # 8000f958 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	18c000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	210000ef          	jal	80000cbc <release>
}
    80000ab0:	60e2                	ld	ra,24(sp)
    80000ab2:	6442                	ld	s0,16(sp)
    80000ab4:	64a2                	ld	s1,8(sp)
    80000ab6:	6902                	ld	s2,0(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    panic("kfree");
    80000abc:	00006517          	auipc	a0,0x6
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80007038 <etext+0x38>
    80000ac4:	d61ff0ef          	jal	80000824 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e263          	bltu	a1,s1,80000b06 <freerange+0x3e>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	f67ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	94ce                	add	s1,s1,s3
    80000afc:	fe997be3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <kinit>:
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b18:	00006597          	auipc	a1,0x6
    80000b1c:	52858593          	addi	a1,a1,1320 # 80007040 <etext+0x40>
    80000b20:	0000f517          	auipc	a0,0xf
    80000b24:	e3850513          	addi	a0,a0,-456 # 8000f958 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00020517          	auipc	a0,0x20
    80000b34:	27050513          	addi	a0,a0,624 # 80020da0 <end>
    80000b38:	f91ff0ef          	jal	80000ac8 <freerange>
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret

0000000080000b44 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4e:	0000f517          	auipc	a0,0xf
    80000b52:	e0a50513          	addi	a0,a0,-502 # 8000f958 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	0000f497          	auipc	s1,0xf
    80000b5e:	e164b483          	ld	s1,-490(s1) # 8000f970 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	0000f717          	auipc	a4,0xf
    80000b6a:	e0f73523          	sd	a5,-502(a4) # 8000f970 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	0000f517          	auipc	a0,0xf
    80000b72:	dea50513          	addi	a0,a0,-534 # 8000f958 <kmem>
    80000b76:	146000ef          	jal	80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	178000ef          	jal	80000cf8 <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	0000f517          	auipc	a0,0xf
    80000b94:	dc850513          	addi	a0,a0,-568 # 8000f958 <kmem>
    80000b98:	124000ef          	jal	80000cbc <release>
  if(r)
    80000b9c:	b7e5                	j	80000b84 <kalloc+0x40>

0000000080000b9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9e:	1141                	addi	sp,sp,-16
    80000ba0:	e406                	sd	ra,8(sp)
    80000ba2:	e022                	sd	s0,0(sp)
    80000ba4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bac:	00053823          	sd	zero,16(a0)
}
    80000bb0:	60a2                	ld	ra,8(sp)
    80000bb2:	6402                	ld	s0,0(sp)
    80000bb4:	0141                	addi	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	691c                	ld	a5,16(a0)
    80000bcc:	84be                	mv	s1,a5
    80000bce:	60d000ef          	jal	800019da <mycpu>
    80000bd2:	40a48533          	sub	a0,s1,a0
    80000bd6:	00153513          	seqz	a0,a0
}
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6105                	addi	sp,sp,32
    80000be2:	8082                	ret

0000000080000be4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	5dd000ef          	jal	800019da <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	5d5000ef          	jal	800019da <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	5c1000ef          	jal	800019da <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x22>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb1ff0ef          	jal	80000be4 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f7fff0ef          	jal	80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	58b000ef          	jal	800019da <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00006517          	auipc	a0,0x6
    80000c64:	3e850513          	addi	a0,a0,1000 # 80007048 <etext+0x48>
    80000c68:	bbdff0ef          	jal	80000824 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	567000ef          	jal	800019da <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e39d                	bnez	a5,80000ca4 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05763          	blez	a5,80000cb0 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb89                	bnez	a5,80000c9c <pop_off+0x30>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80007050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00006517          	auipc	a0,0x6
    80000cb4:	3b850513          	addi	a0,a0,952 # 80007068 <etext+0x68>
    80000cb8:	b6dff0ef          	jal	80000824 <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	ef1ff0ef          	jal	80000bb8 <holding>
    80000ccc:	c105                	beqz	a0,80000cec <release+0x30>
  lk->cpu = 0;
    80000cce:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cd6:	0310000f          	fence	rw,w
    80000cda:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cde:	f8fff0ef          	jal	80000c6c <pop_off>
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    panic("release");
    80000cec:	00006517          	auipc	a0,0x6
    80000cf0:	38450513          	addi	a0,a0,900 # 80007070 <etext+0x70>
    80000cf4:	b31ff0ef          	jal	80000824 <panic>

0000000080000cf8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1e>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x14>
  }
  return dst;
}
    80000d16:	60a2                	ld	ra,8(sp)
    80000d18:	6402                	ld	s0,0(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d26:	c61d                	beqz	a2,80000d54 <memcmp+0x36>
    80000d28:	1602                	slli	a2,a2,0x20
    80000d2a:	9201                	srli	a2,a2,0x20
    80000d2c:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x12>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x2e>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	60a2                	ld	ra,8(sp)
    80000d4e:	6402                	ld	s0,0(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfdd                	j	80000d4c <memcmp+0x2e>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d60:	c205                	beqz	a2,80000d80 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d62:	02a5e363          	bltu	a1,a0,80000d88 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d66:	1602                	slli	a2,a2,0x20
    80000d68:	9201                	srli	a2,a2,0x20
    80000d6a:	00c587b3          	add	a5,a1,a2
{
    80000d6e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0705                	addi	a4,a4,1
    80000d74:	fff5c683          	lbu	a3,-1(a1)
    80000d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7c:	feb79ae3          	bne	a5,a1,80000d70 <memmove+0x18>

  return dst;
}
    80000d80:	60a2                	ld	ra,8(sp)
    80000d82:	6402                	ld	s0,0(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
  if(s < d && s + n > d){
    80000d88:	02061693          	slli	a3,a2,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	00d58733          	add	a4,a1,a3
    80000d92:	fce57ae3          	bgeu	a0,a4,80000d66 <memmove+0xe>
    d += n;
    80000d96:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d98:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d9c:	1782                	slli	a5,a5,0x20
    80000d9e:	9381                	srli	a5,a5,0x20
    80000da0:	fff7c793          	not	a5,a5
    80000da4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da6:	177d                	addi	a4,a4,-1
    80000da8:	16fd                	addi	a3,a3,-1
    80000daa:	00074603          	lbu	a2,0(a4)
    80000dae:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db2:	fee79ae3          	bne	a5,a4,80000da6 <memmove+0x4e>
    80000db6:	b7e9                	j	80000d80 <memmove+0x28>

0000000080000db8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e406                	sd	ra,8(sp)
    80000dbc:	e022                	sd	s0,0(sp)
    80000dbe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc0:	f99ff0ef          	jal	80000d58 <memmove>
}
    80000dc4:	60a2                	ld	ra,8(sp)
    80000dc6:	6402                	ld	s0,0(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret

0000000080000dcc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd4:	ce11                	beqz	a2,80000df0 <strncmp+0x24>
    80000dd6:	00054783          	lbu	a5,0(a0)
    80000dda:	cf89                	beqz	a5,80000df4 <strncmp+0x28>
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	00f71a63          	bne	a4,a5,80000df4 <strncmp+0x28>
    n--, p++, q++;
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	0505                	addi	a0,a0,1
    80000de8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dea:	f675                	bnez	a2,80000dd6 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	a801                	j	80000dfe <strncmp+0x32>
    80000df0:	4501                	li	a0,0
    80000df2:	a031                	j	80000dfe <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df4:	00054503          	lbu	a0,0(a0)
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	9d1d                	subw	a0,a0,a5
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	a011                	j	80000e14 <strncpy+0xe>
    80000e12:	8636                	mv	a2,a3
    80000e14:	02c05863          	blez	a2,80000e44 <strncpy+0x3e>
    80000e18:	fff6069b          	addiw	a3,a2,-1
    80000e1c:	8836                	mv	a6,a3
    80000e1e:	0785                	addi	a5,a5,1
    80000e20:	0005c703          	lbu	a4,0(a1)
    80000e24:	fee78fa3          	sb	a4,-1(a5)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f765                	bnez	a4,80000e12 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2c:	873e                	mv	a4,a5
    80000e2e:	01005b63          	blez	a6,80000e44 <strncpy+0x3e>
    80000e32:	9fb1                	addw	a5,a5,a2
    80000e34:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e36:	0705                	addi	a4,a4,1
    80000e38:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3c:	40e786bb          	subw	a3,a5,a4
    80000e40:	fed04be3          	bgtz	a3,80000e36 <strncpy+0x30>
  return os;
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2e>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x2a>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret

0000000080000e82 <strlen>:

int
strlen(const char *s)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8a:	00054783          	lbu	a5,0(a0)
    80000e8e:	cf91                	beqz	a5,80000eaa <strlen+0x28>
    80000e90:	00150793          	addi	a5,a0,1
    80000e94:	86be                	mv	a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	ff65                	bnez	a4,80000e94 <strlen+0x12>
    80000e9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eaa:	4501                	li	a0,0
    80000eac:	bfdd                	j	80000ea2 <strlen+0x20>

0000000080000eae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e406                	sd	ra,8(sp)
    80000eb2:	e022                	sd	s0,0(sp)
    80000eb4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb6:	311000ef          	jal	800019c6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00007717          	auipc	a4,0x7
    80000ebe:	99670713          	addi	a4,a4,-1642 # 80007850 <started>
  if(cpuid() == 0){
    80000ec2:	c51d                	beqz	a0,80000ef0 <main+0x42>
    while(started == 0)
    80000ec4:	431c                	lw	a5,0(a4)
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dff5                	beqz	a5,80000ec4 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	2f9000ef          	jal	800019c6 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	610010ef          	jal	800024f4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	600040ef          	jal	800054e8 <plicinithart>
  }

  scheduler();        
    80000eec:	791000ef          	jal	80001e7c <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	17c50513          	addi	a0,a0,380 # 80007080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	16850513          	addi	a0,a0,360 # 80007078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	1d5000ef          	jal	800018fc <procinit>
    trapinit();      // trap vectors
    80000f2c:	5a4010ef          	jal	800024d0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	5c4010ef          	jal	800024f4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	59a040ef          	jal	800054ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	5b0040ef          	jal	800054e8 <plicinithart>
    binit();         // buffer cache
    80000f3c:	423010ef          	jal	80002b5e <binit>
    iinit();         // inode table
    80000f40:	174020ef          	jal	800030b4 <iinit>
    fileinit();      // file table
    80000f44:	0a0030ef          	jal	80003fe4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	690040ef          	jal	800055d8 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	579000ef          	jal	80001cc4 <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00007717          	auipc	a4,0x7
    80000f5a:	8ef72d23          	sw	a5,-1798(a4) # 80007850 <started>
    80000f5e:	b779                	j	80000eec <main+0x3e>

0000000080000f60 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	00007797          	auipc	a5,0x7
    80000f70:	8ec7b783          	ld	a5,-1812(a5) # 80007858 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f7c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f80:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f84:	60a2                	ld	ra,8(sp)
    80000f86:	6402                	ld	s0,0(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fac:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fae:	04b7e263          	bltu	a5,a1,80000ff2 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb2:	0149d933          	srl	s2,s3,s4
    80000fb6:	1ff97913          	andi	s2,s2,511
    80000fba:	090e                	slli	s2,s2,0x3
    80000fbc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fbe:	00093483          	ld	s1,0(s2)
    80000fc2:	0014f793          	andi	a5,s1,1
    80000fc6:	cf85                	beqz	a5,80000ffe <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc8:	80a9                	srli	s1,s1,0xa
    80000fca:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fcc:	3a5d                	addiw	s4,s4,-9
    80000fce:	ff5a12e3          	bne	s4,s5,80000fb2 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fd2:	00c9d513          	srli	a0,s3,0xc
    80000fd6:	1ff57513          	andi	a0,a0,511
    80000fda:	050e                	slli	a0,a0,0x3
    80000fdc:	9526                	add	a0,a0,s1
}
    80000fde:	70e2                	ld	ra,56(sp)
    80000fe0:	7442                	ld	s0,48(sp)
    80000fe2:	74a2                	ld	s1,40(sp)
    80000fe4:	7902                	ld	s2,32(sp)
    80000fe6:	69e2                	ld	s3,24(sp)
    80000fe8:	6a42                	ld	s4,16(sp)
    80000fea:	6aa2                	ld	s5,8(sp)
    80000fec:	6b02                	ld	s6,0(sp)
    80000fee:	6121                	addi	sp,sp,64
    80000ff0:	8082                	ret
    panic("walk");
    80000ff2:	00006517          	auipc	a0,0x6
    80000ff6:	0be50513          	addi	a0,a0,190 # 800070b0 <etext+0xb0>
    80000ffa:	82bff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	020b0263          	beqz	s6,80001022 <walk+0x96>
    80001002:	b43ff0ef          	jal	80000b44 <kalloc>
    80001006:	84aa                	mv	s1,a0
    80001008:	d979                	beqz	a0,80000fde <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000100a:	6605                	lui	a2,0x1
    8000100c:	4581                	li	a1,0
    8000100e:	cebff0ef          	jal	80000cf8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
    80001020:	b775                	j	80000fcc <walk+0x40>
        return 0;
    80001022:	4501                	li	a0,0
    80001024:	bf6d                	j	80000fde <walk+0x52>

0000000080001026 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	00b7f463          	bgeu	a5,a1,80001032 <walkaddr+0xc>
    return 0;
    8000102e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001030:	8082                	ret
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e406                	sd	ra,8(sp)
    80001036:	e022                	sd	s0,0(sp)
    80001038:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103a:	4601                	li	a2,0
    8000103c:	f51ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    80001040:	c901                	beqz	a0,80001050 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001042:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001044:	0117f693          	andi	a3,a5,17
    80001048:	4745                	li	a4,17
    return 0;
    8000104a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000104c:	00e68663          	beq	a3,a4,80001058 <walkaddr+0x32>
}
    80001050:	60a2                	ld	ra,8(sp)
    80001052:	6402                	ld	s0,0(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret
  pa = PTE2PA(*pte);
    80001058:	83a9                	srli	a5,a5,0xa
    8000105a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000105e:	bfcd                	j	80001050 <walkaddr+0x2a>

0000000080001060 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001060:	715d                	addi	sp,sp,-80
    80001062:	e486                	sd	ra,72(sp)
    80001064:	e0a2                	sd	s0,64(sp)
    80001066:	fc26                	sd	s1,56(sp)
    80001068:	f84a                	sd	s2,48(sp)
    8000106a:	f44e                	sd	s3,40(sp)
    8000106c:	f052                	sd	s4,32(sp)
    8000106e:	ec56                	sd	s5,24(sp)
    80001070:	e85a                	sd	s6,16(sp)
    80001072:	e45e                	sd	s7,8(sp)
    80001074:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001076:	03459793          	slli	a5,a1,0x34
    8000107a:	eba1                	bnez	a5,800010ca <mappages+0x6a>
    8000107c:	8a2a                	mv	s4,a0
    8000107e:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001080:	03461793          	slli	a5,a2,0x34
    80001084:	eba9                	bnez	a5,800010d6 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    80001086:	ce31                	beqz	a2,800010e2 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001088:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000108c:	80060613          	addi	a2,a2,-2048
    80001090:	00b60933          	add	s2,a2,a1
  a = va;
    80001094:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001096:	4b05                	li	s6,1
    80001098:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000109c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109e:	865a                	mv	a2,s6
    800010a0:	85a6                	mv	a1,s1
    800010a2:	8552                	mv	a0,s4
    800010a4:	ee9ff0ef          	jal	80000f8c <walk>
    800010a8:	c929                	beqz	a0,800010fa <mappages+0x9a>
    if(*pte & PTE_V)
    800010aa:	611c                	ld	a5,0(a0)
    800010ac:	8b85                	andi	a5,a5,1
    800010ae:	e3a1                	bnez	a5,800010ee <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b0:	013487b3          	add	a5,s1,s3
    800010b4:	83b1                	srli	a5,a5,0xc
    800010b6:	07aa                	slli	a5,a5,0xa
    800010b8:	0157e7b3          	or	a5,a5,s5
    800010bc:	0017e793          	ori	a5,a5,1
    800010c0:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010c2:	05248863          	beq	s1,s2,80001112 <mappages+0xb2>
    a += PGSIZE;
    800010c6:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c8:	bfd9                	j	8000109e <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ca:	00006517          	auipc	a0,0x6
    800010ce:	fee50513          	addi	a0,a0,-18 # 800070b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00006517          	auipc	a0,0x6
    800010da:	00250513          	addi	a0,a0,2 # 800070d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00006517          	auipc	a0,0x6
    800010e6:	01650513          	addi	a0,a0,22 # 800070f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00006517          	auipc	a0,0x6
    800010f2:	01a50513          	addi	a0,a0,26 # 80007108 <etext+0x108>
    800010f6:	f2eff0ef          	jal	80000824 <panic>
      return -1;
    800010fa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010fc:	60a6                	ld	ra,72(sp)
    800010fe:	6406                	ld	s0,64(sp)
    80001100:	74e2                	ld	s1,56(sp)
    80001102:	7942                	ld	s2,48(sp)
    80001104:	79a2                	ld	s3,40(sp)
    80001106:	7a02                	ld	s4,32(sp)
    80001108:	6ae2                	ld	s5,24(sp)
    8000110a:	6b42                	ld	s6,16(sp)
    8000110c:	6ba2                	ld	s7,8(sp)
    8000110e:	6161                	addi	sp,sp,80
    80001110:	8082                	ret
  return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7e5                	j	800010fc <mappages+0x9c>

0000000080001116 <kvmmap>:
{
    80001116:	1141                	addi	sp,sp,-16
    80001118:	e406                	sd	ra,8(sp)
    8000111a:	e022                	sd	s0,0(sp)
    8000111c:	0800                	addi	s0,sp,16
    8000111e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001120:	86b2                	mv	a3,a2
    80001122:	863e                	mv	a2,a5
    80001124:	f3dff0ef          	jal	80001060 <mappages>
    80001128:	e509                	bnez	a0,80001132 <kvmmap+0x1c>
}
    8000112a:	60a2                	ld	ra,8(sp)
    8000112c:	6402                	ld	s0,0(sp)
    8000112e:	0141                	addi	sp,sp,16
    80001130:	8082                	ret
    panic("kvmmap");
    80001132:	00006517          	auipc	a0,0x6
    80001136:	fe650513          	addi	a0,a0,-26 # 80007118 <etext+0x118>
    8000113a:	eeaff0ef          	jal	80000824 <panic>

000000008000113e <kvmmake>:
{
    8000113e:	1101                	addi	sp,sp,-32
    80001140:	ec06                	sd	ra,24(sp)
    80001142:	e822                	sd	s0,16(sp)
    80001144:	e426                	sd	s1,8(sp)
    80001146:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001148:	9fdff0ef          	jal	80000b44 <kalloc>
    8000114c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000114e:	6605                	lui	a2,0x1
    80001150:	4581                	li	a1,0
    80001152:	ba7ff0ef          	jal	80000cf8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001156:	4719                	li	a4,6
    80001158:	6685                	lui	a3,0x1
    8000115a:	10000637          	lui	a2,0x10000
    8000115e:	85b2                	mv	a1,a2
    80001160:	8526                	mv	a0,s1
    80001162:	fb5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001166:	4719                	li	a4,6
    80001168:	6685                	lui	a3,0x1
    8000116a:	10001637          	lui	a2,0x10001
    8000116e:	85b2                	mv	a1,a2
    80001170:	8526                	mv	a0,s1
    80001172:	fa5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001176:	4719                	li	a4,6
    80001178:	040006b7          	lui	a3,0x4000
    8000117c:	0c000637          	lui	a2,0xc000
    80001180:	85b2                	mv	a1,a2
    80001182:	8526                	mv	a0,s1
    80001184:	f93ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001188:	4729                	li	a4,10
    8000118a:	80006697          	auipc	a3,0x80006
    8000118e:	e7668693          	addi	a3,a3,-394 # 7000 <_entry-0x7fff9000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00006697          	auipc	a3,0x6
    800011a4:	e6068693          	addi	a3,a3,-416 # 80007000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00006617          	auipc	a2,0x6
    800011b4:	e5060613          	addi	a2,a2,-432 # 80007000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00005617          	auipc	a2,0x5
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80006000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	67c000ef          	jal	80001858 <proc_mapstacks>
}
    800011e0:	8526                	mv	a0,s1
    800011e2:	60e2                	ld	ra,24(sp)
    800011e4:	6442                	ld	s0,16(sp)
    800011e6:	64a2                	ld	s1,8(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret

00000000800011ec <kvminit>:
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e406                	sd	ra,8(sp)
    800011f0:	e022                	sd	s0,0(sp)
    800011f2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011f4:	f4bff0ef          	jal	8000113e <kvmmake>
    800011f8:	00006797          	auipc	a5,0x6
    800011fc:	66a7b023          	sd	a0,1632(a5) # 80007858 <kernel_pagetable>
}
    80001200:	60a2                	ld	ra,8(sp)
    80001202:	6402                	ld	s0,0(sp)
    80001204:	0141                	addi	sp,sp,16
    80001206:	8082                	ret

0000000080001208 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001208:	1101                	addi	sp,sp,-32
    8000120a:	ec06                	sd	ra,24(sp)
    8000120c:	e822                	sd	s0,16(sp)
    8000120e:	e426                	sd	s1,8(sp)
    80001210:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001212:	933ff0ef          	jal	80000b44 <kalloc>
    80001216:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001218:	c509                	beqz	a0,80001222 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	adbff0ef          	jal	80000cf8 <memset>
  return pagetable;
}
    80001222:	8526                	mv	a0,s1
    80001224:	60e2                	ld	ra,24(sp)
    80001226:	6442                	ld	s0,16(sp)
    80001228:	64a2                	ld	s1,8(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000122e:	7139                	addi	sp,sp,-64
    80001230:	fc06                	sd	ra,56(sp)
    80001232:	f822                	sd	s0,48(sp)
    80001234:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001236:	03459793          	slli	a5,a1,0x34
    8000123a:	e38d                	bnez	a5,8000125c <uvmunmap+0x2e>
    8000123c:	f04a                	sd	s2,32(sp)
    8000123e:	ec4e                	sd	s3,24(sp)
    80001240:	e852                	sd	s4,16(sp)
    80001242:	e456                	sd	s5,8(sp)
    80001244:	e05a                	sd	s6,0(sp)
    80001246:	8a2a                	mv	s4,a0
    80001248:	892e                	mv	s2,a1
    8000124a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000124c:	0632                	slli	a2,a2,0xc
    8000124e:	00b609b3          	add	s3,a2,a1
    80001252:	6b05                	lui	s6,0x1
    80001254:	0535f963          	bgeu	a1,s3,800012a6 <uvmunmap+0x78>
    80001258:	f426                	sd	s1,40(sp)
    8000125a:	a015                	j	8000127e <uvmunmap+0x50>
    8000125c:	f426                	sd	s1,40(sp)
    8000125e:	f04a                	sd	s2,32(sp)
    80001260:	ec4e                	sd	s3,24(sp)
    80001262:	e852                	sd	s4,16(sp)
    80001264:	e456                	sd	s5,8(sp)
    80001266:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001268:	00006517          	auipc	a0,0x6
    8000126c:	eb850513          	addi	a0,a0,-328 # 80007120 <etext+0x120>
    80001270:	db4ff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001274:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001278:	995a                	add	s2,s2,s6
    8000127a:	03397563          	bgeu	s2,s3,800012a4 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000127e:	4601                	li	a2,0
    80001280:	85ca                	mv	a1,s2
    80001282:	8552                	mv	a0,s4
    80001284:	d09ff0ef          	jal	80000f8c <walk>
    80001288:	84aa                	mv	s1,a0
    8000128a:	d57d                	beqz	a0,80001278 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000128c:	611c                	ld	a5,0(a0)
    8000128e:	0017f713          	andi	a4,a5,1
    80001292:	d37d                	beqz	a4,80001278 <uvmunmap+0x4a>
    if(do_free){
    80001294:	fe0a80e3          	beqz	s5,80001274 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001298:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000129a:	00c79513          	slli	a0,a5,0xc
    8000129e:	fbeff0ef          	jal	80000a5c <kfree>
    800012a2:	bfc9                	j	80001274 <uvmunmap+0x46>
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	7902                	ld	s2,32(sp)
    800012a8:	69e2                	ld	s3,24(sp)
    800012aa:	6a42                	ld	s4,16(sp)
    800012ac:	6aa2                	ld	s5,8(sp)
    800012ae:	6b02                	ld	s6,0(sp)
  }
}
    800012b0:	70e2                	ld	ra,56(sp)
    800012b2:	7442                	ld	s0,48(sp)
    800012b4:	6121                	addi	sp,sp,64
    800012b6:	8082                	ret

00000000800012b8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012c2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012c4:	00b67d63          	bgeu	a2,a1,800012de <uvmdealloc+0x26>
    800012c8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012ca:	6785                	lui	a5,0x1
    800012cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ce:	00f60733          	add	a4,a2,a5
    800012d2:	76fd                	lui	a3,0xfffff
    800012d4:	8f75                	and	a4,a4,a3
    800012d6:	97ae                	add	a5,a5,a1
    800012d8:	8ff5                	and	a5,a5,a3
    800012da:	00f76863          	bltu	a4,a5,800012ea <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012de:	8526                	mv	a0,s1
    800012e0:	60e2                	ld	ra,24(sp)
    800012e2:	6442                	ld	s0,16(sp)
    800012e4:	64a2                	ld	s1,8(sp)
    800012e6:	6105                	addi	sp,sp,32
    800012e8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012ea:	8f99                	sub	a5,a5,a4
    800012ec:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012ee:	4685                	li	a3,1
    800012f0:	0007861b          	sext.w	a2,a5
    800012f4:	85ba                	mv	a1,a4
    800012f6:	f39ff0ef          	jal	8000122e <uvmunmap>
    800012fa:	b7d5                	j	800012de <uvmdealloc+0x26>

00000000800012fc <uvmalloc>:
  if(newsz < oldsz)
    800012fc:	0ab66163          	bltu	a2,a1,8000139e <uvmalloc+0xa2>
{
    80001300:	715d                	addi	sp,sp,-80
    80001302:	e486                	sd	ra,72(sp)
    80001304:	e0a2                	sd	s0,64(sp)
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f052                	sd	s4,32(sp)
    8000130a:	ec56                	sd	s5,24(sp)
    8000130c:	e45e                	sd	s7,8(sp)
    8000130e:	0880                	addi	s0,sp,80
    80001310:	8aaa                	mv	s5,a0
    80001312:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001314:	6785                	lui	a5,0x1
    80001316:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001318:	95be                	add	a1,a1,a5
    8000131a:	77fd                	lui	a5,0xfffff
    8000131c:	00f5f933          	and	s2,a1,a5
    80001320:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001322:	08c97063          	bgeu	s2,a2,800013a2 <uvmalloc+0xa6>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	f44e                	sd	s3,40(sp)
    8000132a:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000132c:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000132e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001332:	813ff0ef          	jal	80000b44 <kalloc>
    80001336:	84aa                	mv	s1,a0
    if(mem == 0){
    80001338:	c50d                	beqz	a0,80001362 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000133a:	864e                	mv	a2,s3
    8000133c:	4581                	li	a1,0
    8000133e:	9bbff0ef          	jal	80000cf8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001342:	875a                	mv	a4,s6
    80001344:	86a6                	mv	a3,s1
    80001346:	864e                	mv	a2,s3
    80001348:	85ca                	mv	a1,s2
    8000134a:	8556                	mv	a0,s5
    8000134c:	d15ff0ef          	jal	80001060 <mappages>
    80001350:	e915                	bnez	a0,80001384 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001352:	994e                	add	s2,s2,s3
    80001354:	fd496fe3          	bltu	s2,s4,80001332 <uvmalloc+0x36>
  return newsz;
    80001358:	8552                	mv	a0,s4
    8000135a:	74e2                	ld	s1,56(sp)
    8000135c:	79a2                	ld	s3,40(sp)
    8000135e:	6b42                	ld	s6,16(sp)
    80001360:	a811                	j	80001374 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001362:	865e                	mv	a2,s7
    80001364:	85ca                	mv	a1,s2
    80001366:	8556                	mv	a0,s5
    80001368:	f51ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    8000136c:	4501                	li	a0,0
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	79a2                	ld	s3,40(sp)
    80001372:	6b42                	ld	s6,16(sp)
}
    80001374:	60a6                	ld	ra,72(sp)
    80001376:	6406                	ld	s0,64(sp)
    80001378:	7942                	ld	s2,48(sp)
    8000137a:	7a02                	ld	s4,32(sp)
    8000137c:	6ae2                	ld	s5,24(sp)
    8000137e:	6ba2                	ld	s7,8(sp)
    80001380:	6161                	addi	sp,sp,80
    80001382:	8082                	ret
      kfree(mem);
    80001384:	8526                	mv	a0,s1
    80001386:	ed6ff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000138a:	865e                	mv	a2,s7
    8000138c:	85ca                	mv	a1,s2
    8000138e:	8556                	mv	a0,s5
    80001390:	f29ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    80001394:	4501                	li	a0,0
    80001396:	74e2                	ld	s1,56(sp)
    80001398:	79a2                	ld	s3,40(sp)
    8000139a:	6b42                	ld	s6,16(sp)
    8000139c:	bfe1                	j	80001374 <uvmalloc+0x78>
    return oldsz;
    8000139e:	852e                	mv	a0,a1
}
    800013a0:	8082                	ret
  return newsz;
    800013a2:	8532                	mv	a0,a2
    800013a4:	bfc1                	j	80001374 <uvmalloc+0x78>

00000000800013a6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013a6:	7179                	addi	sp,sp,-48
    800013a8:	f406                	sd	ra,40(sp)
    800013aa:	f022                	sd	s0,32(sp)
    800013ac:	ec26                	sd	s1,24(sp)
    800013ae:	e84a                	sd	s2,16(sp)
    800013b0:	e44e                	sd	s3,8(sp)
    800013b2:	1800                	addi	s0,sp,48
    800013b4:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013b6:	84aa                	mv	s1,a0
    800013b8:	6905                	lui	s2,0x1
    800013ba:	992a                	add	s2,s2,a0
    800013bc:	a811                	j	800013d0 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013be:	00006517          	auipc	a0,0x6
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80007138 <etext+0x138>
    800013c6:	c5eff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    800013ca:	04a1                	addi	s1,s1,8
    800013cc:	03248163          	beq	s1,s2,800013ee <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013d0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013d2:	0017f713          	andi	a4,a5,1
    800013d6:	db75                	beqz	a4,800013ca <freewalk+0x24>
    800013d8:	00e7f713          	andi	a4,a5,14
    800013dc:	f36d                	bnez	a4,800013be <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013e0:	00c79513          	slli	a0,a5,0xc
    800013e4:	fc3ff0ef          	jal	800013a6 <freewalk>
      pagetable[i] = 0;
    800013e8:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013ec:	bff9                	j	800013ca <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013ee:	854e                	mv	a0,s3
    800013f0:	e6cff0ef          	jal	80000a5c <kfree>
}
    800013f4:	70a2                	ld	ra,40(sp)
    800013f6:	7402                	ld	s0,32(sp)
    800013f8:	64e2                	ld	s1,24(sp)
    800013fa:	6942                	ld	s2,16(sp)
    800013fc:	69a2                	ld	s3,8(sp)
    800013fe:	6145                	addi	sp,sp,48
    80001400:	8082                	ret

0000000080001402 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001402:	1101                	addi	sp,sp,-32
    80001404:	ec06                	sd	ra,24(sp)
    80001406:	e822                	sd	s0,16(sp)
    80001408:	e426                	sd	s1,8(sp)
    8000140a:	1000                	addi	s0,sp,32
    8000140c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000140e:	e989                	bnez	a1,80001420 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001410:	8526                	mv	a0,s1
    80001412:	f95ff0ef          	jal	800013a6 <freewalk>
}
    80001416:	60e2                	ld	ra,24(sp)
    80001418:	6442                	ld	s0,16(sp)
    8000141a:	64a2                	ld	s1,8(sp)
    8000141c:	6105                	addi	sp,sp,32
    8000141e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	4685                	li	a3,1
    80001428:	00c5d613          	srli	a2,a1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	e01ff0ef          	jal	8000122e <uvmunmap>
    80001432:	bff9                	j	80001410 <uvmfree+0xe>

0000000080001434 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001434:	ca59                	beqz	a2,800014ca <uvmcopy+0x96>
{
    80001436:	715d                	addi	sp,sp,-80
    80001438:	e486                	sd	ra,72(sp)
    8000143a:	e0a2                	sd	s0,64(sp)
    8000143c:	fc26                	sd	s1,56(sp)
    8000143e:	f84a                	sd	s2,48(sp)
    80001440:	f44e                	sd	s3,40(sp)
    80001442:	f052                	sd	s4,32(sp)
    80001444:	ec56                	sd	s5,24(sp)
    80001446:	e85a                	sd	s6,16(sp)
    80001448:	e45e                	sd	s7,8(sp)
    8000144a:	0880                	addi	s0,sp,80
    8000144c:	8b2a                	mv	s6,a0
    8000144e:	8bae                	mv	s7,a1
    80001450:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001452:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001454:	6a05                	lui	s4,0x1
    80001456:	a021                	j	8000145e <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001458:	94d2                	add	s1,s1,s4
    8000145a:	0554fc63          	bgeu	s1,s5,800014b2 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000145e:	4601                	li	a2,0
    80001460:	85a6                	mv	a1,s1
    80001462:	855a                	mv	a0,s6
    80001464:	b29ff0ef          	jal	80000f8c <walk>
    80001468:	d965                	beqz	a0,80001458 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    8000146a:	00053983          	ld	s3,0(a0)
    8000146e:	0019f793          	andi	a5,s3,1
    80001472:	d3fd                	beqz	a5,80001458 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001474:	ed0ff0ef          	jal	80000b44 <kalloc>
    80001478:	892a                	mv	s2,a0
    8000147a:	c11d                	beqz	a0,800014a0 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000147c:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001480:	8652                	mv	a2,s4
    80001482:	05b2                	slli	a1,a1,0xc
    80001484:	8d5ff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001488:	3ff9f713          	andi	a4,s3,1023
    8000148c:	86ca                	mv	a3,s2
    8000148e:	8652                	mv	a2,s4
    80001490:	85a6                	mv	a1,s1
    80001492:	855e                	mv	a0,s7
    80001494:	bcdff0ef          	jal	80001060 <mappages>
    80001498:	d161                	beqz	a0,80001458 <uvmcopy+0x24>
      kfree(mem);
    8000149a:	854a                	mv	a0,s2
    8000149c:	dc0ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a0:	4685                	li	a3,1
    800014a2:	00c4d613          	srli	a2,s1,0xc
    800014a6:	4581                	li	a1,0
    800014a8:	855e                	mv	a0,s7
    800014aa:	d85ff0ef          	jal	8000122e <uvmunmap>
  return -1;
    800014ae:	557d                	li	a0,-1
    800014b0:	a011                	j	800014b4 <uvmcopy+0x80>
  return 0;
    800014b2:	4501                	li	a0,0
}
    800014b4:	60a6                	ld	ra,72(sp)
    800014b6:	6406                	ld	s0,64(sp)
    800014b8:	74e2                	ld	s1,56(sp)
    800014ba:	7942                	ld	s2,48(sp)
    800014bc:	79a2                	ld	s3,40(sp)
    800014be:	7a02                	ld	s4,32(sp)
    800014c0:	6ae2                	ld	s5,24(sp)
    800014c2:	6b42                	ld	s6,16(sp)
    800014c4:	6ba2                	ld	s7,8(sp)
    800014c6:	6161                	addi	sp,sp,80
    800014c8:	8082                	ret
  return 0;
    800014ca:	4501                	li	a0,0
}
    800014cc:	8082                	ret

00000000800014ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ce:	1141                	addi	sp,sp,-16
    800014d0:	e406                	sd	ra,8(sp)
    800014d2:	e022                	sd	s0,0(sp)
    800014d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014d6:	4601                	li	a2,0
    800014d8:	ab5ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    800014dc:	c901                	beqz	a0,800014ec <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014de:	611c                	ld	a5,0(a0)
    800014e0:	9bbd                	andi	a5,a5,-17
    800014e2:	e11c                	sd	a5,0(a0)
}
    800014e4:	60a2                	ld	ra,8(sp)
    800014e6:	6402                	ld	s0,0(sp)
    800014e8:	0141                	addi	sp,sp,16
    800014ea:	8082                	ret
    panic("uvmclear");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80007148 <etext+0x148>
    800014f4:	b30ff0ef          	jal	80000824 <panic>

00000000800014f8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014f8:	cac5                	beqz	a3,800015a8 <copyinstr+0xb0>
{
    800014fa:	715d                	addi	sp,sp,-80
    800014fc:	e486                	sd	ra,72(sp)
    800014fe:	e0a2                	sd	s0,64(sp)
    80001500:	fc26                	sd	s1,56(sp)
    80001502:	f84a                	sd	s2,48(sp)
    80001504:	f44e                	sd	s3,40(sp)
    80001506:	f052                	sd	s4,32(sp)
    80001508:	ec56                	sd	s5,24(sp)
    8000150a:	e85a                	sd	s6,16(sp)
    8000150c:	e45e                	sd	s7,8(sp)
    8000150e:	0880                	addi	s0,sp,80
    80001510:	8aaa                	mv	s5,a0
    80001512:	84ae                	mv	s1,a1
    80001514:	8bb2                	mv	s7,a2
    80001516:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001518:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000151a:	6a05                	lui	s4,0x1
    8000151c:	a82d                	j	80001556 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000151e:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001522:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001524:	0017c793          	xori	a5,a5,1
    80001528:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000152c:	60a6                	ld	ra,72(sp)
    8000152e:	6406                	ld	s0,64(sp)
    80001530:	74e2                	ld	s1,56(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	79a2                	ld	s3,40(sp)
    80001536:	7a02                	ld	s4,32(sp)
    80001538:	6ae2                	ld	s5,24(sp)
    8000153a:	6b42                	ld	s6,16(sp)
    8000153c:	6ba2                	ld	s7,8(sp)
    8000153e:	6161                	addi	sp,sp,80
    80001540:	8082                	ret
    80001542:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001546:	9726                	add	a4,a4,s1
      --max;
    80001548:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000154c:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001550:	04e58463          	beq	a1,a4,80001598 <copyinstr+0xa0>
{
    80001554:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001556:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8556                	mv	a0,s5
    8000155e:	ac9ff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0)
    80001562:	cd0d                	beqz	a0,8000159c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001564:	417906b3          	sub	a3,s2,s7
    80001568:	96d2                	add	a3,a3,s4
    if(n > max)
    8000156a:	00d9f363          	bgeu	s3,a3,80001570 <copyinstr+0x78>
    8000156e:	86ce                	mv	a3,s3
    while(n > 0){
    80001570:	ca85                	beqz	a3,800015a0 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001572:	01750633          	add	a2,a0,s7
    80001576:	41260633          	sub	a2,a2,s2
    8000157a:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000157c:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000157e:	96a6                	add	a3,a3,s1
    80001580:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001582:	00f60733          	add	a4,a2,a5
    80001586:	00074703          	lbu	a4,0(a4)
    8000158a:	db51                	beqz	a4,8000151e <copyinstr+0x26>
        *dst = *p;
    8000158c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001590:	0785                	addi	a5,a5,1
    while(n > 0){
    80001592:	fed797e3          	bne	a5,a3,80001580 <copyinstr+0x88>
    80001596:	b775                	j	80001542 <copyinstr+0x4a>
    80001598:	4781                	li	a5,0
    8000159a:	b769                	j	80001524 <copyinstr+0x2c>
      return -1;
    8000159c:	557d                	li	a0,-1
    8000159e:	b779                	j	8000152c <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015a0:	6b85                	lui	s7,0x1
    800015a2:	9bca                	add	s7,s7,s2
    800015a4:	87a6                	mv	a5,s1
    800015a6:	b77d                	j	80001554 <copyinstr+0x5c>
  int got_null = 0;
    800015a8:	4781                	li	a5,0
  if(got_null){
    800015aa:	0017c793          	xori	a5,a5,1
    800015ae:	40f0053b          	negw	a0,a5
}
    800015b2:	8082                	ret

00000000800015b4 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015b4:	1141                	addi	sp,sp,-16
    800015b6:	e406                	sd	ra,8(sp)
    800015b8:	e022                	sd	s0,0(sp)
    800015ba:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015bc:	4601                	li	a2,0
    800015be:	9cfff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    800015c2:	c119                	beqz	a0,800015c8 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015c4:	6108                	ld	a0,0(a0)
    800015c6:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015c8:	60a2                	ld	ra,8(sp)
    800015ca:	6402                	ld	s0,0(sp)
    800015cc:	0141                	addi	sp,sp,16
    800015ce:	8082                	ret

00000000800015d0 <vmfault>:
{
    800015d0:	7179                	addi	sp,sp,-48
    800015d2:	f406                	sd	ra,40(sp)
    800015d4:	f022                	sd	s0,32(sp)
    800015d6:	e84a                	sd	s2,16(sp)
    800015d8:	e44e                	sd	s3,8(sp)
    800015da:	1800                	addi	s0,sp,48
    800015dc:	89aa                	mv	s3,a0
    800015de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015e0:	41a000ef          	jal	800019fa <myproc>
  if (va >= p->sz)
    800015e4:	653c                	ld	a5,72(a0)
    800015e6:	00f96a63          	bltu	s2,a5,800015fa <vmfault+0x2a>
    return 0;
    800015ea:	4981                	li	s3,0
}
    800015ec:	854e                	mv	a0,s3
    800015ee:	70a2                	ld	ra,40(sp)
    800015f0:	7402                	ld	s0,32(sp)
    800015f2:	6942                	ld	s2,16(sp)
    800015f4:	69a2                	ld	s3,8(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret
    800015fa:	ec26                	sd	s1,24(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001600:	77fd                	lui	a5,0xfffff
    80001602:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001606:	85d2                	mv	a1,s4
    80001608:	854e                	mv	a0,s3
    8000160a:	fabff0ef          	jal	800015b4 <ismapped>
    return 0;
    8000160e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001610:	c501                	beqz	a0,80001618 <vmfault+0x48>
    80001612:	64e2                	ld	s1,24(sp)
    80001614:	6a02                	ld	s4,0(sp)
    80001616:	bfd9                	j	800015ec <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001618:	d2cff0ef          	jal	80000b44 <kalloc>
    8000161c:	892a                	mv	s2,a0
  if(mem == 0)
    8000161e:	c905                	beqz	a0,8000164e <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001620:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001622:	6605                	lui	a2,0x1
    80001624:	4581                	li	a1,0
    80001626:	ed2ff0ef          	jal	80000cf8 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000162a:	4759                	li	a4,22
    8000162c:	86ca                	mv	a3,s2
    8000162e:	6605                	lui	a2,0x1
    80001630:	85d2                	mv	a1,s4
    80001632:	68a8                	ld	a0,80(s1)
    80001634:	a2dff0ef          	jal	80001060 <mappages>
    80001638:	e501                	bnez	a0,80001640 <vmfault+0x70>
    8000163a:	64e2                	ld	s1,24(sp)
    8000163c:	6a02                	ld	s4,0(sp)
    8000163e:	b77d                	j	800015ec <vmfault+0x1c>
    kfree((void *)mem);
    80001640:	854a                	mv	a0,s2
    80001642:	c1aff0ef          	jal	80000a5c <kfree>
    return 0;
    80001646:	4981                	li	s3,0
    80001648:	64e2                	ld	s1,24(sp)
    8000164a:	6a02                	ld	s4,0(sp)
    8000164c:	b745                	j	800015ec <vmfault+0x1c>
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6a02                	ld	s4,0(sp)
    80001652:	bf69                	j	800015ec <vmfault+0x1c>

0000000080001654 <copyout>:
  while(len > 0){
    80001654:	cad1                	beqz	a3,800016e8 <copyout+0x94>
{
    80001656:	711d                	addi	sp,sp,-96
    80001658:	ec86                	sd	ra,88(sp)
    8000165a:	e8a2                	sd	s0,80(sp)
    8000165c:	e4a6                	sd	s1,72(sp)
    8000165e:	e0ca                	sd	s2,64(sp)
    80001660:	fc4e                	sd	s3,56(sp)
    80001662:	f852                	sd	s4,48(sp)
    80001664:	f456                	sd	s5,40(sp)
    80001666:	f05a                	sd	s6,32(sp)
    80001668:	ec5e                	sd	s7,24(sp)
    8000166a:	e862                	sd	s8,16(sp)
    8000166c:	e466                	sd	s9,8(sp)
    8000166e:	e06a                	sd	s10,0(sp)
    80001670:	1080                	addi	s0,sp,96
    80001672:	8baa                	mv	s7,a0
    80001674:	8a2e                	mv	s4,a1
    80001676:	8b32                	mv	s6,a2
    80001678:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    8000167c:	5cfd                	li	s9,-1
    8000167e:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001682:	6c05                	lui	s8,0x1
    80001684:	a005                	j	800016a4 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001686:	409a0533          	sub	a0,s4,s1
    8000168a:	0009061b          	sext.w	a2,s2
    8000168e:	85da                	mv	a1,s6
    80001690:	954e                	add	a0,a0,s3
    80001692:	ec6ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001696:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000169a:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000169c:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016a0:	040a8263          	beqz	s5,800016e4 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016a8:	049ce263          	bltu	s9,s1,800016ec <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016ac:	85a6                	mv	a1,s1
    800016ae:	855e                	mv	a0,s7
    800016b0:	977ff0ef          	jal	80001026 <walkaddr>
    800016b4:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016b6:	e901                	bnez	a0,800016c6 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016b8:	4601                	li	a2,0
    800016ba:	85a6                	mv	a1,s1
    800016bc:	855e                	mv	a0,s7
    800016be:	f13ff0ef          	jal	800015d0 <vmfault>
    800016c2:	89aa                	mv	s3,a0
    800016c4:	c139                	beqz	a0,8000170a <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	855e                	mv	a0,s7
    800016cc:	8c1ff0ef          	jal	80000f8c <walk>
    if((*pte & PTE_W) == 0)
    800016d0:	611c                	ld	a5,0(a0)
    800016d2:	8b91                	andi	a5,a5,4
    800016d4:	cf8d                	beqz	a5,8000170e <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016d6:	41448933          	sub	s2,s1,s4
    800016da:	9962                	add	s2,s2,s8
    if(n > len)
    800016dc:	fb2af5e3          	bgeu	s5,s2,80001686 <copyout+0x32>
    800016e0:	8956                	mv	s2,s5
    800016e2:	b755                	j	80001686 <copyout+0x32>
  return 0;
    800016e4:	4501                	li	a0,0
    800016e6:	a021                	j	800016ee <copyout+0x9a>
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret
      return -1;
    800016ec:	557d                	li	a0,-1
}
    800016ee:	60e6                	ld	ra,88(sp)
    800016f0:	6446                	ld	s0,80(sp)
    800016f2:	64a6                	ld	s1,72(sp)
    800016f4:	6906                	ld	s2,64(sp)
    800016f6:	79e2                	ld	s3,56(sp)
    800016f8:	7a42                	ld	s4,48(sp)
    800016fa:	7aa2                	ld	s5,40(sp)
    800016fc:	7b02                	ld	s6,32(sp)
    800016fe:	6be2                	ld	s7,24(sp)
    80001700:	6c42                	ld	s8,16(sp)
    80001702:	6ca2                	ld	s9,8(sp)
    80001704:	6d02                	ld	s10,0(sp)
    80001706:	6125                	addi	sp,sp,96
    80001708:	8082                	ret
        return -1;
    8000170a:	557d                	li	a0,-1
    8000170c:	b7cd                	j	800016ee <copyout+0x9a>
      return -1;
    8000170e:	557d                	li	a0,-1
    80001710:	bff9                	j	800016ee <copyout+0x9a>

0000000080001712 <copyin>:
  while(len > 0){
    80001712:	c6c9                	beqz	a3,8000179c <copyin+0x8a>
{
    80001714:	715d                	addi	sp,sp,-80
    80001716:	e486                	sd	ra,72(sp)
    80001718:	e0a2                	sd	s0,64(sp)
    8000171a:	fc26                	sd	s1,56(sp)
    8000171c:	f84a                	sd	s2,48(sp)
    8000171e:	f44e                	sd	s3,40(sp)
    80001720:	f052                	sd	s4,32(sp)
    80001722:	ec56                	sd	s5,24(sp)
    80001724:	e85a                	sd	s6,16(sp)
    80001726:	e45e                	sd	s7,8(sp)
    80001728:	e062                	sd	s8,0(sp)
    8000172a:	0880                	addi	s0,sp,80
    8000172c:	8baa                	mv	s7,a0
    8000172e:	8aae                	mv	s5,a1
    80001730:	8932                	mv	s2,a2
    80001732:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001734:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001736:	6b05                	lui	s6,0x1
    80001738:	a035                	j	80001764 <copyin+0x52>
    8000173a:	412984b3          	sub	s1,s3,s2
    8000173e:	94da                	add	s1,s1,s6
    if(n > len)
    80001740:	009a7363          	bgeu	s4,s1,80001746 <copyin+0x34>
    80001744:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	413905b3          	sub	a1,s2,s3
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	95aa                	add	a1,a1,a0
    80001750:	8556                	mv	a0,s5
    80001752:	e06ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001756:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000175a:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000175c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001760:	020a0163          	beqz	s4,80001782 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001764:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ce                	mv	a1,s3
    8000176a:	855e                	mv	a0,s7
    8000176c:	8bbff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0) {
    80001770:	f569                	bnez	a0,8000173a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001772:	4601                	li	a2,0
    80001774:	85ce                	mv	a1,s3
    80001776:	855e                	mv	a0,s7
    80001778:	e59ff0ef          	jal	800015d0 <vmfault>
    8000177c:	fd5d                	bnez	a0,8000173a <copyin+0x28>
        return -1;
    8000177e:	557d                	li	a0,-1
    80001780:	a011                	j	80001784 <copyin+0x72>
  return 0;
    80001782:	4501                	li	a0,0
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret
  return 0;
    8000179c:	4501                	li	a0,0
}
    8000179e:	8082                	ret

00000000800017a0 <enqueue_fifo>:
struct proc *fifo_tail = 0;
struct spinlock fifo_lock;

// FIFO enqueue
void enqueue_fifo(struct proc *p)
{
    800017a0:	1101                	addi	sp,sp,-32
    800017a2:	ec06                	sd	ra,24(sp)
    800017a4:	e822                	sd	s0,16(sp)
    800017a6:	e426                	sd	s1,8(sp)
    800017a8:	1000                	addi	s0,sp,32
    800017aa:	84aa                	mv	s1,a0
  acquire(&fifo_lock);
    800017ac:	0000e517          	auipc	a0,0xe
    800017b0:	1cc50513          	addi	a0,a0,460 # 8000f978 <fifo_lock>
    800017b4:	c74ff0ef          	jal	80000c28 <acquire>
  p->next_in_queue = 0;
    800017b8:	1604b423          	sd	zero,360(s1)
  if (fifo_tail == 0)
    800017bc:	00006797          	auipc	a5,0x6
    800017c0:	0a47b783          	ld	a5,164(a5) # 80007860 <fifo_tail>
    800017c4:	c395                	beqz	a5,800017e8 <enqueue_fifo+0x48>
  {
    fifo_head = fifo_tail = p;
  }
  else
  {
    fifo_tail->next_in_queue = p;
    800017c6:	1697b423          	sd	s1,360(a5)
    fifo_tail = p;
    800017ca:	00006797          	auipc	a5,0x6
    800017ce:	0897bb23          	sd	s1,150(a5) # 80007860 <fifo_tail>
  }
  release(&fifo_lock);
    800017d2:	0000e517          	auipc	a0,0xe
    800017d6:	1a650513          	addi	a0,a0,422 # 8000f978 <fifo_lock>
    800017da:	ce2ff0ef          	jal	80000cbc <release>
}
    800017de:	60e2                	ld	ra,24(sp)
    800017e0:	6442                	ld	s0,16(sp)
    800017e2:	64a2                	ld	s1,8(sp)
    800017e4:	6105                	addi	sp,sp,32
    800017e6:	8082                	ret
    fifo_head = fifo_tail = p;
    800017e8:	00006797          	auipc	a5,0x6
    800017ec:	0697bc23          	sd	s1,120(a5) # 80007860 <fifo_tail>
    800017f0:	00006797          	auipc	a5,0x6
    800017f4:	0697bc23          	sd	s1,120(a5) # 80007868 <fifo_head>
    800017f8:	bfe9                	j	800017d2 <enqueue_fifo+0x32>

00000000800017fa <dequeue_fifo>:

// FIFO dequeue
struct proc *dequeue_fifo()
{
    800017fa:	1101                	addi	sp,sp,-32
    800017fc:	ec06                	sd	ra,24(sp)
    800017fe:	e822                	sd	s0,16(sp)
    80001800:	e426                	sd	s1,8(sp)
    80001802:	1000                	addi	s0,sp,32
  acquire(&fifo_lock);
    80001804:	0000e517          	auipc	a0,0xe
    80001808:	17450513          	addi	a0,a0,372 # 8000f978 <fifo_lock>
    8000180c:	c1cff0ef          	jal	80000c28 <acquire>
  if (fifo_head == 0)
    80001810:	00006497          	auipc	s1,0x6
    80001814:	0584b483          	ld	s1,88(s1) # 80007868 <fifo_head>
    80001818:	c485                	beqz	s1,80001840 <dequeue_fifo+0x46>
    release(&fifo_lock);
    return 0;
  }

  struct proc *p = fifo_head;
  fifo_head = fifo_head->next_in_queue;
    8000181a:	1684b783          	ld	a5,360(s1)
    8000181e:	00006717          	auipc	a4,0x6
    80001822:	04f73523          	sd	a5,74(a4) # 80007868 <fifo_head>

  if (fifo_head == 0)
    80001826:	c785                	beqz	a5,8000184e <dequeue_fifo+0x54>
    fifo_tail = 0;

  release(&fifo_lock);
    80001828:	0000e517          	auipc	a0,0xe
    8000182c:	15050513          	addi	a0,a0,336 # 8000f978 <fifo_lock>
    80001830:	c8cff0ef          	jal	80000cbc <release>
  return p;
}
    80001834:	8526                	mv	a0,s1
    80001836:	60e2                	ld	ra,24(sp)
    80001838:	6442                	ld	s0,16(sp)
    8000183a:	64a2                	ld	s1,8(sp)
    8000183c:	6105                	addi	sp,sp,32
    8000183e:	8082                	ret
    release(&fifo_lock);
    80001840:	0000e517          	auipc	a0,0xe
    80001844:	13850513          	addi	a0,a0,312 # 8000f978 <fifo_lock>
    80001848:	c74ff0ef          	jal	80000cbc <release>
    return 0;
    8000184c:	b7e5                	j	80001834 <dequeue_fifo+0x3a>
    fifo_tail = 0;
    8000184e:	00006797          	auipc	a5,0x6
    80001852:	0007b923          	sd	zero,18(a5) # 80007860 <fifo_tail>
    80001856:	bfc9                	j	80001828 <dequeue_fifo+0x2e>

0000000080001858 <proc_mapstacks>:

struct spinlock wait_lock;

void proc_mapstacks(pagetable_t kpgtbl)
{
    80001858:	715d                	addi	sp,sp,-80
    8000185a:	e486                	sd	ra,72(sp)
    8000185c:	e0a2                	sd	s0,64(sp)
    8000185e:	fc26                	sd	s1,56(sp)
    80001860:	f84a                	sd	s2,48(sp)
    80001862:	f44e                	sd	s3,40(sp)
    80001864:	f052                	sd	s4,32(sp)
    80001866:	ec56                	sd	s5,24(sp)
    80001868:	e85a                	sd	s6,16(sp)
    8000186a:	e45e                	sd	s7,8(sp)
    8000186c:	e062                	sd	s8,0(sp)
    8000186e:	0880                	addi	s0,sp,80
    80001870:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001872:	0000e497          	auipc	s1,0xe
    80001876:	54e48493          	addi	s1,s1,1358 # 8000fdc0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000187a:	8c26                	mv	s8,s1
    8000187c:	ff4df937          	lui	s2,0xff4df
    80001880:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc1d>
    80001884:	0936                	slli	s2,s2,0xd
    80001886:	6f590913          	addi	s2,s2,1781
    8000188a:	0936                	slli	s2,s2,0xd
    8000188c:	bd390913          	addi	s2,s2,-1069
    80001890:	0932                	slli	s2,s2,0xc
    80001892:	7a790913          	addi	s2,s2,1959
    80001896:	040009b7          	lui	s3,0x4000
    8000189a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000189c:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000189e:	4b99                	li	s7,6
    800018a0:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++)
    800018a2:	00014a97          	auipc	s5,0x14
    800018a6:	11ea8a93          	addi	s5,s5,286 # 800159c0 <tickslock>
    char *pa = kalloc();
    800018aa:	a9aff0ef          	jal	80000b44 <kalloc>
    800018ae:	862a                	mv	a2,a0
    if (pa == 0)
    800018b0:	c121                	beqz	a0,800018f0 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    800018b2:	418485b3          	sub	a1,s1,s8
    800018b6:	8591                	srai	a1,a1,0x4
    800018b8:	032585b3          	mul	a1,a1,s2
    800018bc:	05b6                	slli	a1,a1,0xd
    800018be:	6789                	lui	a5,0x2
    800018c0:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018c2:	875e                	mv	a4,s7
    800018c4:	86da                	mv	a3,s6
    800018c6:	40b985b3          	sub	a1,s3,a1
    800018ca:	8552                	mv	a0,s4
    800018cc:	84bff0ef          	jal	80001116 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018d0:	17048493          	addi	s1,s1,368
    800018d4:	fd549be3          	bne	s1,s5,800018aa <proc_mapstacks+0x52>
  }
}
    800018d8:	60a6                	ld	ra,72(sp)
    800018da:	6406                	ld	s0,64(sp)
    800018dc:	74e2                	ld	s1,56(sp)
    800018de:	7942                	ld	s2,48(sp)
    800018e0:	79a2                	ld	s3,40(sp)
    800018e2:	7a02                	ld	s4,32(sp)
    800018e4:	6ae2                	ld	s5,24(sp)
    800018e6:	6b42                	ld	s6,16(sp)
    800018e8:	6ba2                	ld	s7,8(sp)
    800018ea:	6c02                	ld	s8,0(sp)
    800018ec:	6161                	addi	sp,sp,80
    800018ee:	8082                	ret
      panic("kalloc");
    800018f0:	00006517          	auipc	a0,0x6
    800018f4:	86850513          	addi	a0,a0,-1944 # 80007158 <etext+0x158>
    800018f8:	f2dfe0ef          	jal	80000824 <panic>

00000000800018fc <procinit>:

void procinit(void)
{
    800018fc:	7139                	addi	sp,sp,-64
    800018fe:	fc06                	sd	ra,56(sp)
    80001900:	f822                	sd	s0,48(sp)
    80001902:	f426                	sd	s1,40(sp)
    80001904:	f04a                	sd	s2,32(sp)
    80001906:	ec4e                	sd	s3,24(sp)
    80001908:	e852                	sd	s4,16(sp)
    8000190a:	e456                	sd	s5,8(sp)
    8000190c:	e05a                	sd	s6,0(sp)
    8000190e:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001910:	00006597          	auipc	a1,0x6
    80001914:	85058593          	addi	a1,a1,-1968 # 80007160 <etext+0x160>
    80001918:	0000e517          	auipc	a0,0xe
    8000191c:	07850513          	addi	a0,a0,120 # 8000f990 <pid_lock>
    80001920:	a7eff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001924:	00006597          	auipc	a1,0x6
    80001928:	84458593          	addi	a1,a1,-1980 # 80007168 <etext+0x168>
    8000192c:	0000e517          	auipc	a0,0xe
    80001930:	07c50513          	addi	a0,a0,124 # 8000f9a8 <wait_lock>
    80001934:	a6aff0ef          	jal	80000b9e <initlock>
  initlock(&fifo_lock, "fifo_lock");
    80001938:	00006597          	auipc	a1,0x6
    8000193c:	84058593          	addi	a1,a1,-1984 # 80007178 <etext+0x178>
    80001940:	0000e517          	auipc	a0,0xe
    80001944:	03850513          	addi	a0,a0,56 # 8000f978 <fifo_lock>
    80001948:	a56ff0ef          	jal	80000b9e <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000194c:	0000e497          	auipc	s1,0xe
    80001950:	47448493          	addi	s1,s1,1140 # 8000fdc0 <proc>
  {
    initlock(&p->lock, "proc");
    80001954:	00006b17          	auipc	s6,0x6
    80001958:	834b0b13          	addi	s6,s6,-1996 # 80007188 <etext+0x188>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000195c:	8aa6                	mv	s5,s1
    8000195e:	ff4df937          	lui	s2,0xff4df
    80001962:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdc1d>
    80001966:	0936                	slli	s2,s2,0xd
    80001968:	6f590913          	addi	s2,s2,1781
    8000196c:	0936                	slli	s2,s2,0xd
    8000196e:	bd390913          	addi	s2,s2,-1069
    80001972:	0932                	slli	s2,s2,0xc
    80001974:	7a790913          	addi	s2,s2,1959
    80001978:	040009b7          	lui	s3,0x4000
    8000197c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000197e:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001980:	00014a17          	auipc	s4,0x14
    80001984:	040a0a13          	addi	s4,s4,64 # 800159c0 <tickslock>
    initlock(&p->lock, "proc");
    80001988:	85da                	mv	a1,s6
    8000198a:	8526                	mv	a0,s1
    8000198c:	a12ff0ef          	jal	80000b9e <initlock>
    p->state = UNUSED;
    80001990:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001994:	415487b3          	sub	a5,s1,s5
    80001998:	8791                	srai	a5,a5,0x4
    8000199a:	032787b3          	mul	a5,a5,s2
    8000199e:	07b6                	slli	a5,a5,0xd
    800019a0:	6709                	lui	a4,0x2
    800019a2:	9fb9                	addw	a5,a5,a4
    800019a4:	40f987b3          	sub	a5,s3,a5
    800019a8:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    800019aa:	17048493          	addi	s1,s1,368
    800019ae:	fd449de3          	bne	s1,s4,80001988 <procinit+0x8c>
  }
}
    800019b2:	70e2                	ld	ra,56(sp)
    800019b4:	7442                	ld	s0,48(sp)
    800019b6:	74a2                	ld	s1,40(sp)
    800019b8:	7902                	ld	s2,32(sp)
    800019ba:	69e2                	ld	s3,24(sp)
    800019bc:	6a42                	ld	s4,16(sp)
    800019be:	6aa2                	ld	s5,8(sp)
    800019c0:	6b02                	ld	s6,0(sp)
    800019c2:	6121                	addi	sp,sp,64
    800019c4:	8082                	ret

00000000800019c6 <cpuid>:

int cpuid()
{
    800019c6:	1141                	addi	sp,sp,-16
    800019c8:	e406                	sd	ra,8(sp)
    800019ca:	e022                	sd	s0,0(sp)
    800019cc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019ce:	8512                	mv	a0,tp
  return r_tp();
}
    800019d0:	2501                	sext.w	a0,a0
    800019d2:	60a2                	ld	ra,8(sp)
    800019d4:	6402                	ld	s0,0(sp)
    800019d6:	0141                	addi	sp,sp,16
    800019d8:	8082                	ret

00000000800019da <mycpu>:

struct cpu *
mycpu(void)
{
    800019da:	1141                	addi	sp,sp,-16
    800019dc:	e406                	sd	ra,8(sp)
    800019de:	e022                	sd	s0,0(sp)
    800019e0:	0800                	addi	s0,sp,16
    800019e2:	8792                	mv	a5,tp
  int id = cpuid();
  return &cpus[id];
    800019e4:	2781                	sext.w	a5,a5
    800019e6:	079e                	slli	a5,a5,0x7
}
    800019e8:	0000e517          	auipc	a0,0xe
    800019ec:	fd850513          	addi	a0,a0,-40 # 8000f9c0 <cpus>
    800019f0:	953e                	add	a0,a0,a5
    800019f2:	60a2                	ld	ra,8(sp)
    800019f4:	6402                	ld	s0,0(sp)
    800019f6:	0141                	addi	sp,sp,16
    800019f8:	8082                	ret

00000000800019fa <myproc>:

struct proc *
myproc(void)
{
    800019fa:	1101                	addi	sp,sp,-32
    800019fc:	ec06                	sd	ra,24(sp)
    800019fe:	e822                	sd	s0,16(sp)
    80001a00:	e426                	sd	s1,8(sp)
    80001a02:	1000                	addi	s0,sp,32
  push_off();
    80001a04:	9e0ff0ef          	jal	80000be4 <push_off>
    80001a08:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a0a:	2781                	sext.w	a5,a5
    80001a0c:	079e                	slli	a5,a5,0x7
    80001a0e:	0000e717          	auipc	a4,0xe
    80001a12:	f6a70713          	addi	a4,a4,-150 # 8000f978 <fifo_lock>
    80001a16:	97ba                	add	a5,a5,a4
    80001a18:	67bc                	ld	a5,72(a5)
    80001a1a:	84be                	mv	s1,a5
  pop_off();
    80001a1c:	a50ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    80001a20:	8526                	mv	a0,s1
    80001a22:	60e2                	ld	ra,24(sp)
    80001a24:	6442                	ld	s0,16(sp)
    80001a26:	64a2                	ld	s1,8(sp)
    80001a28:	6105                	addi	sp,sp,32
    80001a2a:	8082                	ret

0000000080001a2c <forkret>:
  sched();
  release(&p->lock);
}

void forkret(void)
{
    80001a2c:	7179                	addi	sp,sp,-48
    80001a2e:	f406                	sd	ra,40(sp)
    80001a30:	f022                	sd	s0,32(sp)
    80001a32:	ec26                	sd	s1,24(sp)
    80001a34:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001a36:	fc5ff0ef          	jal	800019fa <myproc>
    80001a3a:	84aa                	mv	s1,a0

  release(&p->lock);
    80001a3c:	a80ff0ef          	jal	80000cbc <release>

  if (first)
    80001a40:	00006797          	auipc	a5,0x6
    80001a44:	df07a783          	lw	a5,-528(a5) # 80007830 <first.1>
    80001a48:	cf95                	beqz	a5,80001a84 <forkret+0x58>
  {
    fsinit(ROOTDEV);
    80001a4a:	4505                	li	a0,1
    80001a4c:	325010ef          	jal	80003570 <fsinit>
    first = 0;
    80001a50:	00006797          	auipc	a5,0x6
    80001a54:	de07a023          	sw	zero,-544(a5) # 80007830 <first.1>
    __sync_synchronize();
    80001a58:	0330000f          	fence	rw,rw

    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001a5c:	00005797          	auipc	a5,0x5
    80001a60:	73478793          	addi	a5,a5,1844 # 80007190 <etext+0x190>
    80001a64:	fcf43823          	sd	a5,-48(s0)
    80001a68:	fc043c23          	sd	zero,-40(s0)
    80001a6c:	fd040593          	addi	a1,s0,-48
    80001a70:	853e                	mv	a0,a5
    80001a72:	487020ef          	jal	800046f8 <kexec>
    80001a76:	6cbc                	ld	a5,88(s1)
    80001a78:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1)
    80001a7a:	6cbc                	ld	a5,88(s1)
    80001a7c:	7bb8                	ld	a4,112(a5)
    80001a7e:	57fd                	li	a5,-1
    80001a80:	02f70d63          	beq	a4,a5,80001aba <forkret+0x8e>
      panic("exec");
  }

  prepare_return();
    80001a84:	28d000ef          	jal	80002510 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a88:	68a8                	ld	a0,80(s1)
    80001a8a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a8c:	04000737          	lui	a4,0x4000
    80001a90:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a92:	0732                	slli	a4,a4,0xc
    80001a94:	00004797          	auipc	a5,0x4
    80001a98:	60878793          	addi	a5,a5,1544 # 8000609c <userret>
    80001a9c:	00004697          	auipc	a3,0x4
    80001aa0:	56468693          	addi	a3,a3,1380 # 80006000 <_trampoline>
    80001aa4:	8f95                	sub	a5,a5,a3
    80001aa6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001aa8:	577d                	li	a4,-1
    80001aaa:	177e                	slli	a4,a4,0x3f
    80001aac:	8d59                	or	a0,a0,a4
    80001aae:	9782                	jalr	a5
}
    80001ab0:	70a2                	ld	ra,40(sp)
    80001ab2:	7402                	ld	s0,32(sp)
    80001ab4:	64e2                	ld	s1,24(sp)
    80001ab6:	6145                	addi	sp,sp,48
    80001ab8:	8082                	ret
      panic("exec");
    80001aba:	00005517          	auipc	a0,0x5
    80001abe:	6de50513          	addi	a0,a0,1758 # 80007198 <etext+0x198>
    80001ac2:	d63fe0ef          	jal	80000824 <panic>

0000000080001ac6 <allocpid>:
{
    80001ac6:	1101                	addi	sp,sp,-32
    80001ac8:	ec06                	sd	ra,24(sp)
    80001aca:	e822                	sd	s0,16(sp)
    80001acc:	e426                	sd	s1,8(sp)
    80001ace:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ad0:	0000e517          	auipc	a0,0xe
    80001ad4:	ec050513          	addi	a0,a0,-320 # 8000f990 <pid_lock>
    80001ad8:	950ff0ef          	jal	80000c28 <acquire>
  pid = nextpid++;
    80001adc:	00006797          	auipc	a5,0x6
    80001ae0:	d5878793          	addi	a5,a5,-680 # 80007834 <nextpid>
    80001ae4:	4384                	lw	s1,0(a5)
    80001ae6:	0014871b          	addiw	a4,s1,1
    80001aea:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aec:	0000e517          	auipc	a0,0xe
    80001af0:	ea450513          	addi	a0,a0,-348 # 8000f990 <pid_lock>
    80001af4:	9c8ff0ef          	jal	80000cbc <release>
}
    80001af8:	8526                	mv	a0,s1
    80001afa:	60e2                	ld	ra,24(sp)
    80001afc:	6442                	ld	s0,16(sp)
    80001afe:	64a2                	ld	s1,8(sp)
    80001b00:	6105                	addi	sp,sp,32
    80001b02:	8082                	ret

0000000080001b04 <proc_pagetable>:
{
    80001b04:	1101                	addi	sp,sp,-32
    80001b06:	ec06                	sd	ra,24(sp)
    80001b08:	e822                	sd	s0,16(sp)
    80001b0a:	e426                	sd	s1,8(sp)
    80001b0c:	e04a                	sd	s2,0(sp)
    80001b0e:	1000                	addi	s0,sp,32
    80001b10:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b12:	ef6ff0ef          	jal	80001208 <uvmcreate>
    80001b16:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b18:	cd05                	beqz	a0,80001b50 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b1a:	4729                	li	a4,10
    80001b1c:	00004697          	auipc	a3,0x4
    80001b20:	4e468693          	addi	a3,a3,1252 # 80006000 <_trampoline>
    80001b24:	6605                	lui	a2,0x1
    80001b26:	040005b7          	lui	a1,0x4000
    80001b2a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b2c:	05b2                	slli	a1,a1,0xc
    80001b2e:	d32ff0ef          	jal	80001060 <mappages>
    80001b32:	02054663          	bltz	a0,80001b5e <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b36:	4719                	li	a4,6
    80001b38:	05893683          	ld	a3,88(s2)
    80001b3c:	6605                	lui	a2,0x1
    80001b3e:	020005b7          	lui	a1,0x2000
    80001b42:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b44:	05b6                	slli	a1,a1,0xd
    80001b46:	8526                	mv	a0,s1
    80001b48:	d18ff0ef          	jal	80001060 <mappages>
    80001b4c:	00054f63          	bltz	a0,80001b6a <proc_pagetable+0x66>
}
    80001b50:	8526                	mv	a0,s1
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret
    uvmfree(pagetable, 0);
    80001b5e:	4581                	li	a1,0
    80001b60:	8526                	mv	a0,s1
    80001b62:	8a1ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b66:	4481                	li	s1,0
    80001b68:	b7e5                	j	80001b50 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b6a:	4681                	li	a3,0
    80001b6c:	4605                	li	a2,1
    80001b6e:	040005b7          	lui	a1,0x4000
    80001b72:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b74:	05b2                	slli	a1,a1,0xc
    80001b76:	8526                	mv	a0,s1
    80001b78:	eb6ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b7c:	4581                	li	a1,0
    80001b7e:	8526                	mv	a0,s1
    80001b80:	883ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b84:	4481                	li	s1,0
    80001b86:	b7e9                	j	80001b50 <proc_pagetable+0x4c>

0000000080001b88 <proc_freepagetable>:
{
    80001b88:	1101                	addi	sp,sp,-32
    80001b8a:	ec06                	sd	ra,24(sp)
    80001b8c:	e822                	sd	s0,16(sp)
    80001b8e:	e426                	sd	s1,8(sp)
    80001b90:	e04a                	sd	s2,0(sp)
    80001b92:	1000                	addi	s0,sp,32
    80001b94:	84aa                	mv	s1,a0
    80001b96:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b98:	4681                	li	a3,0
    80001b9a:	4605                	li	a2,1
    80001b9c:	040005b7          	lui	a1,0x4000
    80001ba0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ba2:	05b2                	slli	a1,a1,0xc
    80001ba4:	e8aff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ba8:	4681                	li	a3,0
    80001baa:	4605                	li	a2,1
    80001bac:	020005b7          	lui	a1,0x2000
    80001bb0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bb2:	05b6                	slli	a1,a1,0xd
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	e78ff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001bba:	85ca                	mv	a1,s2
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	845ff0ef          	jal	80001402 <uvmfree>
}
    80001bc2:	60e2                	ld	ra,24(sp)
    80001bc4:	6442                	ld	s0,16(sp)
    80001bc6:	64a2                	ld	s1,8(sp)
    80001bc8:	6902                	ld	s2,0(sp)
    80001bca:	6105                	addi	sp,sp,32
    80001bcc:	8082                	ret

0000000080001bce <freeproc>:
{
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	1000                	addi	s0,sp,32
    80001bd8:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001bda:	6d28                	ld	a0,88(a0)
    80001bdc:	c119                	beqz	a0,80001be2 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001bde:	e7ffe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001be2:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001be6:	68a8                	ld	a0,80(s1)
    80001be8:	c501                	beqz	a0,80001bf0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001bea:	64ac                	ld	a1,72(s1)
    80001bec:	f9dff0ef          	jal	80001b88 <proc_freepagetable>
  p->pagetable = 0;
    80001bf0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bf4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bf8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bfc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c00:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c04:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c08:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c0c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c10:	0004ac23          	sw	zero,24(s1)
}
    80001c14:	60e2                	ld	ra,24(sp)
    80001c16:	6442                	ld	s0,16(sp)
    80001c18:	64a2                	ld	s1,8(sp)
    80001c1a:	6105                	addi	sp,sp,32
    80001c1c:	8082                	ret

0000000080001c1e <allocproc>:
{
    80001c1e:	1101                	addi	sp,sp,-32
    80001c20:	ec06                	sd	ra,24(sp)
    80001c22:	e822                	sd	s0,16(sp)
    80001c24:	e426                	sd	s1,8(sp)
    80001c26:	e04a                	sd	s2,0(sp)
    80001c28:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001c2a:	0000e497          	auipc	s1,0xe
    80001c2e:	19648493          	addi	s1,s1,406 # 8000fdc0 <proc>
    80001c32:	00014917          	auipc	s2,0x14
    80001c36:	d8e90913          	addi	s2,s2,-626 # 800159c0 <tickslock>
    acquire(&p->lock);
    80001c3a:	8526                	mv	a0,s1
    80001c3c:	fedfe0ef          	jal	80000c28 <acquire>
    if (p->state == UNUSED)
    80001c40:	4c9c                	lw	a5,24(s1)
    80001c42:	cb91                	beqz	a5,80001c56 <allocproc+0x38>
      release(&p->lock);
    80001c44:	8526                	mv	a0,s1
    80001c46:	876ff0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c4a:	17048493          	addi	s1,s1,368
    80001c4e:	ff2496e3          	bne	s1,s2,80001c3a <allocproc+0x1c>
  return 0;
    80001c52:	4481                	li	s1,0
    80001c54:	a089                	j	80001c96 <allocproc+0x78>
  p->pid = allocpid();
    80001c56:	e71ff0ef          	jal	80001ac6 <allocpid>
    80001c5a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c5c:	4785                	li	a5,1
    80001c5e:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c60:	ee5fe0ef          	jal	80000b44 <kalloc>
    80001c64:	892a                	mv	s2,a0
    80001c66:	eca8                	sd	a0,88(s1)
    80001c68:	cd15                	beqz	a0,80001ca4 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	e99ff0ef          	jal	80001b04 <proc_pagetable>
    80001c70:	892a                	mv	s2,a0
    80001c72:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c74:	c121                	beqz	a0,80001cb4 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001c76:	07000613          	li	a2,112
    80001c7a:	4581                	li	a1,0
    80001c7c:	06048513          	addi	a0,s1,96
    80001c80:	878ff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001c84:	00000797          	auipc	a5,0x0
    80001c88:	da878793          	addi	a5,a5,-600 # 80001a2c <forkret>
    80001c8c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c8e:	60bc                	ld	a5,64(s1)
    80001c90:	6705                	lui	a4,0x1
    80001c92:	97ba                	add	a5,a5,a4
    80001c94:	f4bc                	sd	a5,104(s1)
}
    80001c96:	8526                	mv	a0,s1
    80001c98:	60e2                	ld	ra,24(sp)
    80001c9a:	6442                	ld	s0,16(sp)
    80001c9c:	64a2                	ld	s1,8(sp)
    80001c9e:	6902                	ld	s2,0(sp)
    80001ca0:	6105                	addi	sp,sp,32
    80001ca2:	8082                	ret
    freeproc(p);
    80001ca4:	8526                	mv	a0,s1
    80001ca6:	f29ff0ef          	jal	80001bce <freeproc>
    release(&p->lock);
    80001caa:	8526                	mv	a0,s1
    80001cac:	810ff0ef          	jal	80000cbc <release>
    return 0;
    80001cb0:	84ca                	mv	s1,s2
    80001cb2:	b7d5                	j	80001c96 <allocproc+0x78>
    freeproc(p);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	f19ff0ef          	jal	80001bce <freeproc>
    release(&p->lock);
    80001cba:	8526                	mv	a0,s1
    80001cbc:	800ff0ef          	jal	80000cbc <release>
    return 0;
    80001cc0:	84ca                	mv	s1,s2
    80001cc2:	bfd1                	j	80001c96 <allocproc+0x78>

0000000080001cc4 <userinit>:
{
    80001cc4:	1101                	addi	sp,sp,-32
    80001cc6:	ec06                	sd	ra,24(sp)
    80001cc8:	e822                	sd	s0,16(sp)
    80001cca:	e426                	sd	s1,8(sp)
    80001ccc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cce:	f51ff0ef          	jal	80001c1e <allocproc>
    80001cd2:	84aa                	mv	s1,a0
  initproc = p;
    80001cd4:	00006797          	auipc	a5,0x6
    80001cd8:	b8a7be23          	sd	a0,-1124(a5) # 80007870 <initproc>
  p->cwd = namei("/");
    80001cdc:	00005517          	auipc	a0,0x5
    80001ce0:	4c450513          	addi	a0,a0,1220 # 800071a0 <etext+0x1a0>
    80001ce4:	5c7010ef          	jal	80003aaa <namei>
    80001ce8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cec:	478d                	li	a5,3
    80001cee:	cc9c                	sw	a5,24(s1)
  enqueue_fifo(p);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	aafff0ef          	jal	800017a0 <enqueue_fifo>
  release(&p->lock);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	fc5fe0ef          	jal	80000cbc <release>
}
    80001cfc:	60e2                	ld	ra,24(sp)
    80001cfe:	6442                	ld	s0,16(sp)
    80001d00:	64a2                	ld	s1,8(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret

0000000080001d06 <growproc>:
{
    80001d06:	1101                	addi	sp,sp,-32
    80001d08:	ec06                	sd	ra,24(sp)
    80001d0a:	e822                	sd	s0,16(sp)
    80001d0c:	e426                	sd	s1,8(sp)
    80001d0e:	e04a                	sd	s2,0(sp)
    80001d10:	1000                	addi	s0,sp,32
    80001d12:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d14:	ce7ff0ef          	jal	800019fa <myproc>
    80001d18:	892a                	mv	s2,a0
  sz = p->sz;
    80001d1a:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d1c:	02905963          	blez	s1,80001d4e <growproc+0x48>
    if (sz + n > TRAPFRAME)
    80001d20:	00b48633          	add	a2,s1,a1
    80001d24:	020007b7          	lui	a5,0x2000
    80001d28:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001d2a:	07b6                	slli	a5,a5,0xd
    80001d2c:	02c7ea63          	bltu	a5,a2,80001d60 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d30:	4691                	li	a3,4
    80001d32:	6928                	ld	a0,80(a0)
    80001d34:	dc8ff0ef          	jal	800012fc <uvmalloc>
    80001d38:	85aa                	mv	a1,a0
    80001d3a:	c50d                	beqz	a0,80001d64 <growproc+0x5e>
  p->sz = sz;
    80001d3c:	04b93423          	sd	a1,72(s2)
  return 0;
    80001d40:	4501                	li	a0,0
}
    80001d42:	60e2                	ld	ra,24(sp)
    80001d44:	6442                	ld	s0,16(sp)
    80001d46:	64a2                	ld	s1,8(sp)
    80001d48:	6902                	ld	s2,0(sp)
    80001d4a:	6105                	addi	sp,sp,32
    80001d4c:	8082                	ret
  else if (n < 0)
    80001d4e:	fe04d7e3          	bgez	s1,80001d3c <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d52:	00b48633          	add	a2,s1,a1
    80001d56:	6928                	ld	a0,80(a0)
    80001d58:	d60ff0ef          	jal	800012b8 <uvmdealloc>
    80001d5c:	85aa                	mv	a1,a0
    80001d5e:	bff9                	j	80001d3c <growproc+0x36>
      return -1;
    80001d60:	557d                	li	a0,-1
    80001d62:	b7c5                	j	80001d42 <growproc+0x3c>
      return -1;
    80001d64:	557d                	li	a0,-1
    80001d66:	bff1                	j	80001d42 <growproc+0x3c>

0000000080001d68 <kfork>:
{
    80001d68:	7139                	addi	sp,sp,-64
    80001d6a:	fc06                	sd	ra,56(sp)
    80001d6c:	f822                	sd	s0,48(sp)
    80001d6e:	f426                	sd	s1,40(sp)
    80001d70:	e456                	sd	s5,8(sp)
    80001d72:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d74:	c87ff0ef          	jal	800019fa <myproc>
    80001d78:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001d7a:	ea5ff0ef          	jal	80001c1e <allocproc>
    80001d7e:	0e050d63          	beqz	a0,80001e78 <kfork+0x110>
    80001d82:	ec4e                	sd	s3,24(sp)
    80001d84:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001d86:	048ab603          	ld	a2,72(s5)
    80001d8a:	692c                	ld	a1,80(a0)
    80001d8c:	050ab503          	ld	a0,80(s5)
    80001d90:	ea4ff0ef          	jal	80001434 <uvmcopy>
    80001d94:	04054863          	bltz	a0,80001de4 <kfork+0x7c>
    80001d98:	f04a                	sd	s2,32(sp)
    80001d9a:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001d9c:	048ab783          	ld	a5,72(s5)
    80001da0:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001da4:	058ab683          	ld	a3,88(s5)
    80001da8:	87b6                	mv	a5,a3
    80001daa:	0589b703          	ld	a4,88(s3)
    80001dae:	12068693          	addi	a3,a3,288
    80001db2:	6388                	ld	a0,0(a5)
    80001db4:	678c                	ld	a1,8(a5)
    80001db6:	6b90                	ld	a2,16(a5)
    80001db8:	e308                	sd	a0,0(a4)
    80001dba:	e70c                	sd	a1,8(a4)
    80001dbc:	eb10                	sd	a2,16(a4)
    80001dbe:	6f90                	ld	a2,24(a5)
    80001dc0:	ef10                	sd	a2,24(a4)
    80001dc2:	02078793          	addi	a5,a5,32
    80001dc6:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001dca:	fed794e3          	bne	a5,a3,80001db2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001dce:	0589b783          	ld	a5,88(s3)
    80001dd2:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001dd6:	0d0a8493          	addi	s1,s5,208
    80001dda:	0d098913          	addi	s2,s3,208
    80001dde:	150a8a13          	addi	s4,s5,336
    80001de2:	a831                	j	80001dfe <kfork+0x96>
    freeproc(np);
    80001de4:	854e                	mv	a0,s3
    80001de6:	de9ff0ef          	jal	80001bce <freeproc>
    release(&np->lock);
    80001dea:	854e                	mv	a0,s3
    80001dec:	ed1fe0ef          	jal	80000cbc <release>
    return -1;
    80001df0:	54fd                	li	s1,-1
    80001df2:	69e2                	ld	s3,24(sp)
    80001df4:	a89d                	j	80001e6a <kfork+0x102>
  for (i = 0; i < NOFILE; i++)
    80001df6:	04a1                	addi	s1,s1,8
    80001df8:	0921                	addi	s2,s2,8
    80001dfa:	01448963          	beq	s1,s4,80001e0c <kfork+0xa4>
    if (p->ofile[i])
    80001dfe:	6088                	ld	a0,0(s1)
    80001e00:	d97d                	beqz	a0,80001df6 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e02:	264020ef          	jal	80004066 <filedup>
    80001e06:	00a93023          	sd	a0,0(s2)
    80001e0a:	b7f5                	j	80001df6 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001e0c:	150ab503          	ld	a0,336(s5)
    80001e10:	436010ef          	jal	80003246 <idup>
    80001e14:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e18:	4641                	li	a2,16
    80001e1a:	158a8593          	addi	a1,s5,344
    80001e1e:	15898513          	addi	a0,s3,344
    80001e22:	82aff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001e26:	0309a483          	lw	s1,48(s3)
  release(&np->lock);
    80001e2a:	854e                	mv	a0,s3
    80001e2c:	e91fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001e30:	0000e517          	auipc	a0,0xe
    80001e34:	b7850513          	addi	a0,a0,-1160 # 8000f9a8 <wait_lock>
    80001e38:	df1fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001e3c:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e40:	0000e517          	auipc	a0,0xe
    80001e44:	b6850513          	addi	a0,a0,-1176 # 8000f9a8 <wait_lock>
    80001e48:	e75fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001e4c:	854e                	mv	a0,s3
    80001e4e:	ddbfe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001e52:	478d                	li	a5,3
    80001e54:	00f9ac23          	sw	a5,24(s3)
  enqueue_fifo(np);
    80001e58:	854e                	mv	a0,s3
    80001e5a:	947ff0ef          	jal	800017a0 <enqueue_fifo>
  release(&np->lock);
    80001e5e:	854e                	mv	a0,s3
    80001e60:	e5dfe0ef          	jal	80000cbc <release>
  return pid;
    80001e64:	7902                	ld	s2,32(sp)
    80001e66:	69e2                	ld	s3,24(sp)
    80001e68:	6a42                	ld	s4,16(sp)
}
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	70e2                	ld	ra,56(sp)
    80001e6e:	7442                	ld	s0,48(sp)
    80001e70:	74a2                	ld	s1,40(sp)
    80001e72:	6aa2                	ld	s5,8(sp)
    80001e74:	6121                	addi	sp,sp,64
    80001e76:	8082                	ret
    return -1;
    80001e78:	54fd                	li	s1,-1
    80001e7a:	bfc5                	j	80001e6a <kfork+0x102>

0000000080001e7c <scheduler>:
{
    80001e7c:	7139                	addi	sp,sp,-64
    80001e7e:	fc06                	sd	ra,56(sp)
    80001e80:	f822                	sd	s0,48(sp)
    80001e82:	f426                	sd	s1,40(sp)
    80001e84:	f04a                	sd	s2,32(sp)
    80001e86:	ec4e                	sd	s3,24(sp)
    80001e88:	e852                	sd	s4,16(sp)
    80001e8a:	e456                	sd	s5,8(sp)
    80001e8c:	0080                	addi	s0,sp,64
    80001e8e:	8792                	mv	a5,tp
  return r_tp();
    80001e90:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e92:	00779a13          	slli	s4,a5,0x7
    80001e96:	0000e717          	auipc	a4,0xe
    80001e9a:	ae270713          	addi	a4,a4,-1310 # 8000f978 <fifo_lock>
    80001e9e:	9752                	add	a4,a4,s4
    80001ea0:	04073423          	sd	zero,72(a4)
    swtch(&c->context, &p->context);
    80001ea4:	0000e717          	auipc	a4,0xe
    80001ea8:	b2470713          	addi	a4,a4,-1244 # 8000f9c8 <cpus+0x8>
    80001eac:	9a3a                	add	s4,s4,a4
    if (p->state != RUNNABLE)
    80001eae:	498d                	li	s3,3
    p->state = RUNNING;
    80001eb0:	4a91                	li	s5,4
    c->proc = p;
    80001eb2:	079e                	slli	a5,a5,0x7
    80001eb4:	0000e917          	auipc	s2,0xe
    80001eb8:	ac490913          	addi	s2,s2,-1340 # 8000f978 <fifo_lock>
    80001ebc:	993e                	add	s2,s2,a5
    80001ebe:	a019                	j	80001ec4 <scheduler+0x48>
      asm volatile("wfi");
    80001ec0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ec4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ec8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ecc:	10079073          	csrw	sstatus,a5
    p = dequeue_fifo();
    80001ed0:	92bff0ef          	jal	800017fa <dequeue_fifo>
    80001ed4:	84aa                	mv	s1,a0
    if (p == 0)
    80001ed6:	d56d                	beqz	a0,80001ec0 <scheduler+0x44>
    acquire(&p->lock);
    80001ed8:	d51fe0ef          	jal	80000c28 <acquire>
    if (p->state != RUNNABLE)
    80001edc:	4c9c                	lw	a5,24(s1)
    80001ede:	03379163          	bne	a5,s3,80001f00 <scheduler+0x84>
    p->state = RUNNING;
    80001ee2:	0154ac23          	sw	s5,24(s1)
    c->proc = p;
    80001ee6:	04993423          	sd	s1,72(s2)
    swtch(&c->context, &p->context);
    80001eea:	06048593          	addi	a1,s1,96
    80001eee:	8552                	mv	a0,s4
    80001ef0:	576000ef          	jal	80002466 <swtch>
    c->proc = 0;
    80001ef4:	04093423          	sd	zero,72(s2)
    release(&p->lock);
    80001ef8:	8526                	mv	a0,s1
    80001efa:	dc3fe0ef          	jal	80000cbc <release>
    80001efe:	b7d9                	j	80001ec4 <scheduler+0x48>
      release(&p->lock);
    80001f00:	8526                	mv	a0,s1
    80001f02:	dbbfe0ef          	jal	80000cbc <release>
      continue;
    80001f06:	bf7d                	j	80001ec4 <scheduler+0x48>

0000000080001f08 <sched>:
{
    80001f08:	7179                	addi	sp,sp,-48
    80001f0a:	f406                	sd	ra,40(sp)
    80001f0c:	f022                	sd	s0,32(sp)
    80001f0e:	ec26                	sd	s1,24(sp)
    80001f10:	e84a                	sd	s2,16(sp)
    80001f12:	e44e                	sd	s3,8(sp)
    80001f14:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f16:	ae5ff0ef          	jal	800019fa <myproc>
    80001f1a:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f1c:	c9dfe0ef          	jal	80000bb8 <holding>
    80001f20:	c935                	beqz	a0,80001f94 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f22:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f24:	2781                	sext.w	a5,a5
    80001f26:	079e                	slli	a5,a5,0x7
    80001f28:	0000e717          	auipc	a4,0xe
    80001f2c:	a5070713          	addi	a4,a4,-1456 # 8000f978 <fifo_lock>
    80001f30:	97ba                	add	a5,a5,a4
    80001f32:	0c07a703          	lw	a4,192(a5)
    80001f36:	4785                	li	a5,1
    80001f38:	06f71463          	bne	a4,a5,80001fa0 <sched+0x98>
  if (p->state == RUNNING)
    80001f3c:	4c98                	lw	a4,24(s1)
    80001f3e:	4791                	li	a5,4
    80001f40:	06f70663          	beq	a4,a5,80001fac <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f48:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f4a:	e7bd                	bnez	a5,80001fb8 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f4c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f4e:	0000e917          	auipc	s2,0xe
    80001f52:	a2a90913          	addi	s2,s2,-1494 # 8000f978 <fifo_lock>
    80001f56:	2781                	sext.w	a5,a5
    80001f58:	079e                	slli	a5,a5,0x7
    80001f5a:	97ca                	add	a5,a5,s2
    80001f5c:	0c47a983          	lw	s3,196(a5)
    80001f60:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f62:	2781                	sext.w	a5,a5
    80001f64:	079e                	slli	a5,a5,0x7
    80001f66:	07a1                	addi	a5,a5,8
    80001f68:	0000e597          	auipc	a1,0xe
    80001f6c:	a5858593          	addi	a1,a1,-1448 # 8000f9c0 <cpus>
    80001f70:	95be                	add	a1,a1,a5
    80001f72:	06048513          	addi	a0,s1,96
    80001f76:	4f0000ef          	jal	80002466 <swtch>
    80001f7a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f7c:	2781                	sext.w	a5,a5
    80001f7e:	079e                	slli	a5,a5,0x7
    80001f80:	993e                	add	s2,s2,a5
    80001f82:	0d392223          	sw	s3,196(s2)
}
    80001f86:	70a2                	ld	ra,40(sp)
    80001f88:	7402                	ld	s0,32(sp)
    80001f8a:	64e2                	ld	s1,24(sp)
    80001f8c:	6942                	ld	s2,16(sp)
    80001f8e:	69a2                	ld	s3,8(sp)
    80001f90:	6145                	addi	sp,sp,48
    80001f92:	8082                	ret
    panic("sched p->lock");
    80001f94:	00005517          	auipc	a0,0x5
    80001f98:	21450513          	addi	a0,a0,532 # 800071a8 <etext+0x1a8>
    80001f9c:	889fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001fa0:	00005517          	auipc	a0,0x5
    80001fa4:	21850513          	addi	a0,a0,536 # 800071b8 <etext+0x1b8>
    80001fa8:	87dfe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001fac:	00005517          	auipc	a0,0x5
    80001fb0:	21c50513          	addi	a0,a0,540 # 800071c8 <etext+0x1c8>
    80001fb4:	871fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001fb8:	00005517          	auipc	a0,0x5
    80001fbc:	22050513          	addi	a0,a0,544 # 800071d8 <etext+0x1d8>
    80001fc0:	865fe0ef          	jal	80000824 <panic>

0000000080001fc4 <yield>:
{
    80001fc4:	1101                	addi	sp,sp,-32
    80001fc6:	ec06                	sd	ra,24(sp)
    80001fc8:	e822                	sd	s0,16(sp)
    80001fca:	e426                	sd	s1,8(sp)
    80001fcc:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fce:	a2dff0ef          	jal	800019fa <myproc>
    80001fd2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fd4:	c55fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fd8:	478d                	li	a5,3
    80001fda:	cc9c                	sw	a5,24(s1)
  enqueue_fifo(p);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	fc2ff0ef          	jal	800017a0 <enqueue_fifo>
  sched();
    80001fe2:	f27ff0ef          	jal	80001f08 <sched>
  release(&p->lock);
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	cd5fe0ef          	jal	80000cbc <release>
}
    80001fec:	60e2                	ld	ra,24(sp)
    80001fee:	6442                	ld	s0,16(sp)
    80001ff0:	64a2                	ld	s1,8(sp)
    80001ff2:	6105                	addi	sp,sp,32
    80001ff4:	8082                	ret

0000000080001ff6 <sleep>:

void sleep(void *chan, struct spinlock *lk)
{
    80001ff6:	7179                	addi	sp,sp,-48
    80001ff8:	f406                	sd	ra,40(sp)
    80001ffa:	f022                	sd	s0,32(sp)
    80001ffc:	ec26                	sd	s1,24(sp)
    80001ffe:	e84a                	sd	s2,16(sp)
    80002000:	e44e                	sd	s3,8(sp)
    80002002:	1800                	addi	s0,sp,48
    80002004:	89aa                	mv	s3,a0
    80002006:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002008:	9f3ff0ef          	jal	800019fa <myproc>
    8000200c:	84aa                	mv	s1,a0

  acquire(&p->lock);
    8000200e:	c1bfe0ef          	jal	80000c28 <acquire>
  release(lk);
    80002012:	854a                	mv	a0,s2
    80002014:	ca9fe0ef          	jal	80000cbc <release>

  p->chan = chan;
    80002018:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000201c:	4789                	li	a5,2
    8000201e:	cc9c                	sw	a5,24(s1)

  sched();
    80002020:	ee9ff0ef          	jal	80001f08 <sched>

  p->chan = 0;
    80002024:	0204b023          	sd	zero,32(s1)

  release(&p->lock);
    80002028:	8526                	mv	a0,s1
    8000202a:	c93fe0ef          	jal	80000cbc <release>
  acquire(lk);
    8000202e:	854a                	mv	a0,s2
    80002030:	bf9fe0ef          	jal	80000c28 <acquire>
}
    80002034:	70a2                	ld	ra,40(sp)
    80002036:	7402                	ld	s0,32(sp)
    80002038:	64e2                	ld	s1,24(sp)
    8000203a:	6942                	ld	s2,16(sp)
    8000203c:	69a2                	ld	s3,8(sp)
    8000203e:	6145                	addi	sp,sp,48
    80002040:	8082                	ret

0000000080002042 <wakeup>:

void wakeup(void *chan)
{
    80002042:	7139                	addi	sp,sp,-64
    80002044:	fc06                	sd	ra,56(sp)
    80002046:	f822                	sd	s0,48(sp)
    80002048:	f426                	sd	s1,40(sp)
    8000204a:	f04a                	sd	s2,32(sp)
    8000204c:	ec4e                	sd	s3,24(sp)
    8000204e:	e852                	sd	s4,16(sp)
    80002050:	e456                	sd	s5,8(sp)
    80002052:	0080                	addi	s0,sp,64
    80002054:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002056:	0000e497          	auipc	s1,0xe
    8000205a:	d6a48493          	addi	s1,s1,-662 # 8000fdc0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    8000205e:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002060:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002062:	00014917          	auipc	s2,0x14
    80002066:	95e90913          	addi	s2,s2,-1698 # 800159c0 <tickslock>
    8000206a:	a801                	j	8000207a <wakeup+0x38>
        enqueue_fifo(p);
      }
      release(&p->lock);
    8000206c:	8526                	mv	a0,s1
    8000206e:	c4ffe0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002072:	17048493          	addi	s1,s1,368
    80002076:	03248563          	beq	s1,s2,800020a0 <wakeup+0x5e>
    if (p != myproc())
    8000207a:	981ff0ef          	jal	800019fa <myproc>
    8000207e:	fe950ae3          	beq	a0,s1,80002072 <wakeup+0x30>
      acquire(&p->lock);
    80002082:	8526                	mv	a0,s1
    80002084:	ba5fe0ef          	jal	80000c28 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002088:	4c9c                	lw	a5,24(s1)
    8000208a:	ff3791e3          	bne	a5,s3,8000206c <wakeup+0x2a>
    8000208e:	709c                	ld	a5,32(s1)
    80002090:	fd479ee3          	bne	a5,s4,8000206c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002094:	0154ac23          	sw	s5,24(s1)
        enqueue_fifo(p);
    80002098:	8526                	mv	a0,s1
    8000209a:	f06ff0ef          	jal	800017a0 <enqueue_fifo>
    8000209e:	b7f9                	j	8000206c <wakeup+0x2a>
    }
  }
}
    800020a0:	70e2                	ld	ra,56(sp)
    800020a2:	7442                	ld	s0,48(sp)
    800020a4:	74a2                	ld	s1,40(sp)
    800020a6:	7902                	ld	s2,32(sp)
    800020a8:	69e2                	ld	s3,24(sp)
    800020aa:	6a42                	ld	s4,16(sp)
    800020ac:	6aa2                	ld	s5,8(sp)
    800020ae:	6121                	addi	sp,sp,64
    800020b0:	8082                	ret

00000000800020b2 <reparent>:
{
    800020b2:	7179                	addi	sp,sp,-48
    800020b4:	f406                	sd	ra,40(sp)
    800020b6:	f022                	sd	s0,32(sp)
    800020b8:	ec26                	sd	s1,24(sp)
    800020ba:	e84a                	sd	s2,16(sp)
    800020bc:	e44e                	sd	s3,8(sp)
    800020be:	e052                	sd	s4,0(sp)
    800020c0:	1800                	addi	s0,sp,48
    800020c2:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800020c4:	0000e497          	auipc	s1,0xe
    800020c8:	cfc48493          	addi	s1,s1,-772 # 8000fdc0 <proc>
      pp->parent = initproc;
    800020cc:	00005a17          	auipc	s4,0x5
    800020d0:	7a4a0a13          	addi	s4,s4,1956 # 80007870 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800020d4:	00014997          	auipc	s3,0x14
    800020d8:	8ec98993          	addi	s3,s3,-1812 # 800159c0 <tickslock>
    800020dc:	a029                	j	800020e6 <reparent+0x34>
    800020de:	17048493          	addi	s1,s1,368
    800020e2:	01348b63          	beq	s1,s3,800020f8 <reparent+0x46>
    if (pp->parent == p)
    800020e6:	7c9c                	ld	a5,56(s1)
    800020e8:	ff279be3          	bne	a5,s2,800020de <reparent+0x2c>
      pp->parent = initproc;
    800020ec:	000a3503          	ld	a0,0(s4)
    800020f0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020f2:	f51ff0ef          	jal	80002042 <wakeup>
    800020f6:	b7e5                	j	800020de <reparent+0x2c>
}
    800020f8:	70a2                	ld	ra,40(sp)
    800020fa:	7402                	ld	s0,32(sp)
    800020fc:	64e2                	ld	s1,24(sp)
    800020fe:	6942                	ld	s2,16(sp)
    80002100:	69a2                	ld	s3,8(sp)
    80002102:	6a02                	ld	s4,0(sp)
    80002104:	6145                	addi	sp,sp,48
    80002106:	8082                	ret

0000000080002108 <kexit>:
{
    80002108:	7179                	addi	sp,sp,-48
    8000210a:	f406                	sd	ra,40(sp)
    8000210c:	f022                	sd	s0,32(sp)
    8000210e:	ec26                	sd	s1,24(sp)
    80002110:	e84a                	sd	s2,16(sp)
    80002112:	e44e                	sd	s3,8(sp)
    80002114:	e052                	sd	s4,0(sp)
    80002116:	1800                	addi	s0,sp,48
    80002118:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000211a:	8e1ff0ef          	jal	800019fa <myproc>
    8000211e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002120:	00005797          	auipc	a5,0x5
    80002124:	7507b783          	ld	a5,1872(a5) # 80007870 <initproc>
    80002128:	0d050493          	addi	s1,a0,208
    8000212c:	15050913          	addi	s2,a0,336
    80002130:	00a79b63          	bne	a5,a0,80002146 <kexit+0x3e>
    panic("init exiting");
    80002134:	00005517          	auipc	a0,0x5
    80002138:	0bc50513          	addi	a0,a0,188 # 800071f0 <etext+0x1f0>
    8000213c:	ee8fe0ef          	jal	80000824 <panic>
  for (int fd = 0; fd < NOFILE; fd++)
    80002140:	04a1                	addi	s1,s1,8
    80002142:	01248963          	beq	s1,s2,80002154 <kexit+0x4c>
    if (p->ofile[fd])
    80002146:	6088                	ld	a0,0(s1)
    80002148:	dd65                	beqz	a0,80002140 <kexit+0x38>
      fileclose(f);
    8000214a:	763010ef          	jal	800040ac <fileclose>
      p->ofile[fd] = 0;
    8000214e:	0004b023          	sd	zero,0(s1)
    80002152:	b7fd                	j	80002140 <kexit+0x38>
  begin_op();
    80002154:	335010ef          	jal	80003c88 <begin_op>
  iput(p->cwd);
    80002158:	1509b503          	ld	a0,336(s3)
    8000215c:	2a2010ef          	jal	800033fe <iput>
  end_op();
    80002160:	399010ef          	jal	80003cf8 <end_op>
  p->cwd = 0;
    80002164:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002168:	0000e517          	auipc	a0,0xe
    8000216c:	84050513          	addi	a0,a0,-1984 # 8000f9a8 <wait_lock>
    80002170:	ab9fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002174:	854e                	mv	a0,s3
    80002176:	f3dff0ef          	jal	800020b2 <reparent>
  wakeup(p->parent);
    8000217a:	0389b503          	ld	a0,56(s3)
    8000217e:	ec5ff0ef          	jal	80002042 <wakeup>
  acquire(&p->lock);
    80002182:	854e                	mv	a0,s3
    80002184:	aa5fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    80002188:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000218c:	4795                	li	a5,5
    8000218e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002192:	0000e517          	auipc	a0,0xe
    80002196:	81650513          	addi	a0,a0,-2026 # 8000f9a8 <wait_lock>
    8000219a:	b23fe0ef          	jal	80000cbc <release>
  sched();
    8000219e:	d6bff0ef          	jal	80001f08 <sched>
  panic("zombie exit");
    800021a2:	00005517          	auipc	a0,0x5
    800021a6:	05e50513          	addi	a0,a0,94 # 80007200 <etext+0x200>
    800021aa:	e7afe0ef          	jal	80000824 <panic>

00000000800021ae <kkill>:

int kkill(int pid)
{
    800021ae:	7179                	addi	sp,sp,-48
    800021b0:	f406                	sd	ra,40(sp)
    800021b2:	f022                	sd	s0,32(sp)
    800021b4:	ec26                	sd	s1,24(sp)
    800021b6:	e84a                	sd	s2,16(sp)
    800021b8:	e44e                	sd	s3,8(sp)
    800021ba:	1800                	addi	s0,sp,48
    800021bc:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800021be:	0000e497          	auipc	s1,0xe
    800021c2:	c0248493          	addi	s1,s1,-1022 # 8000fdc0 <proc>
    800021c6:	00013997          	auipc	s3,0x13
    800021ca:	7fa98993          	addi	s3,s3,2042 # 800159c0 <tickslock>
  {
    acquire(&p->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	a59fe0ef          	jal	80000c28 <acquire>
    if (p->pid == pid)
    800021d4:	589c                	lw	a5,48(s1)
    800021d6:	01278b63          	beq	a5,s2,800021ec <kkill+0x3e>
        enqueue_fifo(p);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021da:	8526                	mv	a0,s1
    800021dc:	ae1fe0ef          	jal	80000cbc <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800021e0:	17048493          	addi	s1,s1,368
    800021e4:	ff3495e3          	bne	s1,s3,800021ce <kkill+0x20>
  }
  return -1;
    800021e8:	557d                	li	a0,-1
    800021ea:	a819                	j	80002200 <kkill+0x52>
      p->killed = 1;
    800021ec:	4785                	li	a5,1
    800021ee:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800021f0:	4c98                	lw	a4,24(s1)
    800021f2:	4789                	li	a5,2
    800021f4:	00f70d63          	beq	a4,a5,8000220e <kkill+0x60>
      release(&p->lock);
    800021f8:	8526                	mv	a0,s1
    800021fa:	ac3fe0ef          	jal	80000cbc <release>
      return 0;
    800021fe:	4501                	li	a0,0
}
    80002200:	70a2                	ld	ra,40(sp)
    80002202:	7402                	ld	s0,32(sp)
    80002204:	64e2                	ld	s1,24(sp)
    80002206:	6942                	ld	s2,16(sp)
    80002208:	69a2                	ld	s3,8(sp)
    8000220a:	6145                	addi	sp,sp,48
    8000220c:	8082                	ret
        p->state = RUNNABLE;
    8000220e:	478d                	li	a5,3
    80002210:	cc9c                	sw	a5,24(s1)
        enqueue_fifo(p);
    80002212:	8526                	mv	a0,s1
    80002214:	d8cff0ef          	jal	800017a0 <enqueue_fifo>
    80002218:	b7c5                	j	800021f8 <kkill+0x4a>

000000008000221a <setkilled>:

void setkilled(struct proc *p)
{
    8000221a:	1101                	addi	sp,sp,-32
    8000221c:	ec06                	sd	ra,24(sp)
    8000221e:	e822                	sd	s0,16(sp)
    80002220:	e426                	sd	s1,8(sp)
    80002222:	1000                	addi	s0,sp,32
    80002224:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002226:	a03fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    8000222a:	4785                	li	a5,1
    8000222c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	a8dfe0ef          	jal	80000cbc <release>
}
    80002234:	60e2                	ld	ra,24(sp)
    80002236:	6442                	ld	s0,16(sp)
    80002238:	64a2                	ld	s1,8(sp)
    8000223a:	6105                	addi	sp,sp,32
    8000223c:	8082                	ret

000000008000223e <killed>:

int killed(struct proc *p)
{
    8000223e:	1101                	addi	sp,sp,-32
    80002240:	ec06                	sd	ra,24(sp)
    80002242:	e822                	sd	s0,16(sp)
    80002244:	e426                	sd	s1,8(sp)
    80002246:	e04a                	sd	s2,0(sp)
    80002248:	1000                	addi	s0,sp,32
    8000224a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000224c:	9ddfe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002250:	549c                	lw	a5,40(s1)
    80002252:	893e                	mv	s2,a5
  release(&p->lock);
    80002254:	8526                	mv	a0,s1
    80002256:	a67fe0ef          	jal	80000cbc <release>
  return k;
}
    8000225a:	854a                	mv	a0,s2
    8000225c:	60e2                	ld	ra,24(sp)
    8000225e:	6442                	ld	s0,16(sp)
    80002260:	64a2                	ld	s1,8(sp)
    80002262:	6902                	ld	s2,0(sp)
    80002264:	6105                	addi	sp,sp,32
    80002266:	8082                	ret

0000000080002268 <kwait>:
{
    80002268:	715d                	addi	sp,sp,-80
    8000226a:	e486                	sd	ra,72(sp)
    8000226c:	e0a2                	sd	s0,64(sp)
    8000226e:	fc26                	sd	s1,56(sp)
    80002270:	f84a                	sd	s2,48(sp)
    80002272:	f44e                	sd	s3,40(sp)
    80002274:	f052                	sd	s4,32(sp)
    80002276:	ec56                	sd	s5,24(sp)
    80002278:	e85a                	sd	s6,16(sp)
    8000227a:	e45e                	sd	s7,8(sp)
    8000227c:	0880                	addi	s0,sp,80
    8000227e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002280:	f7aff0ef          	jal	800019fa <myproc>
    80002284:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002286:	0000d517          	auipc	a0,0xd
    8000228a:	72250513          	addi	a0,a0,1826 # 8000f9a8 <wait_lock>
    8000228e:	99bfe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE)
    80002292:	4a15                	li	s4,5
        havekids = 1;
    80002294:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002296:	00013997          	auipc	s3,0x13
    8000229a:	72a98993          	addi	s3,s3,1834 # 800159c0 <tickslock>
    sleep(p, &wait_lock);
    8000229e:	0000db17          	auipc	s6,0xd
    800022a2:	70ab0b13          	addi	s6,s6,1802 # 8000f9a8 <wait_lock>
    800022a6:	a869                	j	80002340 <kwait+0xd8>
          pid = pp->pid;
    800022a8:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr,
    800022ac:	000b8c63          	beqz	s7,800022c4 <kwait+0x5c>
    800022b0:	4691                	li	a3,4
    800022b2:	02c48613          	addi	a2,s1,44
    800022b6:	85de                	mv	a1,s7
    800022b8:	05093503          	ld	a0,80(s2)
    800022bc:	b98ff0ef          	jal	80001654 <copyout>
    800022c0:	02054a63          	bltz	a0,800022f4 <kwait+0x8c>
          freeproc(pp);
    800022c4:	8526                	mv	a0,s1
    800022c6:	909ff0ef          	jal	80001bce <freeproc>
          release(&pp->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	9f1fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    800022d0:	0000d517          	auipc	a0,0xd
    800022d4:	6d850513          	addi	a0,a0,1752 # 8000f9a8 <wait_lock>
    800022d8:	9e5fe0ef          	jal	80000cbc <release>
}
    800022dc:	854e                	mv	a0,s3
    800022de:	60a6                	ld	ra,72(sp)
    800022e0:	6406                	ld	s0,64(sp)
    800022e2:	74e2                	ld	s1,56(sp)
    800022e4:	7942                	ld	s2,48(sp)
    800022e6:	79a2                	ld	s3,40(sp)
    800022e8:	7a02                	ld	s4,32(sp)
    800022ea:	6ae2                	ld	s5,24(sp)
    800022ec:	6b42                	ld	s6,16(sp)
    800022ee:	6ba2                	ld	s7,8(sp)
    800022f0:	6161                	addi	sp,sp,80
    800022f2:	8082                	ret
            release(&pp->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	9c7fe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    800022fa:	0000d517          	auipc	a0,0xd
    800022fe:	6ae50513          	addi	a0,a0,1710 # 8000f9a8 <wait_lock>
    80002302:	9bbfe0ef          	jal	80000cbc <release>
            return -1;
    80002306:	59fd                	li	s3,-1
    80002308:	bfd1                	j	800022dc <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000230a:	17048493          	addi	s1,s1,368
    8000230e:	03348063          	beq	s1,s3,8000232e <kwait+0xc6>
      if (pp->parent == p)
    80002312:	7c9c                	ld	a5,56(s1)
    80002314:	ff279be3          	bne	a5,s2,8000230a <kwait+0xa2>
        acquire(&pp->lock);
    80002318:	8526                	mv	a0,s1
    8000231a:	90ffe0ef          	jal	80000c28 <acquire>
        if (pp->state == ZOMBIE)
    8000231e:	4c9c                	lw	a5,24(s1)
    80002320:	f94784e3          	beq	a5,s4,800022a8 <kwait+0x40>
        release(&pp->lock);
    80002324:	8526                	mv	a0,s1
    80002326:	997fe0ef          	jal	80000cbc <release>
        havekids = 1;
    8000232a:	8756                	mv	a4,s5
    8000232c:	bff9                	j	8000230a <kwait+0xa2>
    if (!havekids || killed(p))
    8000232e:	cf19                	beqz	a4,8000234c <kwait+0xe4>
    80002330:	854a                	mv	a0,s2
    80002332:	f0dff0ef          	jal	8000223e <killed>
    80002336:	e919                	bnez	a0,8000234c <kwait+0xe4>
    sleep(p, &wait_lock);
    80002338:	85da                	mv	a1,s6
    8000233a:	854a                	mv	a0,s2
    8000233c:	cbbff0ef          	jal	80001ff6 <sleep>
    havekids = 0;
    80002340:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002342:	0000e497          	auipc	s1,0xe
    80002346:	a7e48493          	addi	s1,s1,-1410 # 8000fdc0 <proc>
    8000234a:	b7e1                	j	80002312 <kwait+0xaa>
      release(&wait_lock);
    8000234c:	0000d517          	auipc	a0,0xd
    80002350:	65c50513          	addi	a0,a0,1628 # 8000f9a8 <wait_lock>
    80002354:	969fe0ef          	jal	80000cbc <release>
      return -1;
    80002358:	59fd                	li	s3,-1
    8000235a:	b749                	j	800022dc <kwait+0x74>

000000008000235c <either_copyout>:

int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000235c:	7179                	addi	sp,sp,-48
    8000235e:	f406                	sd	ra,40(sp)
    80002360:	f022                	sd	s0,32(sp)
    80002362:	ec26                	sd	s1,24(sp)
    80002364:	e84a                	sd	s2,16(sp)
    80002366:	e44e                	sd	s3,8(sp)
    80002368:	e052                	sd	s4,0(sp)
    8000236a:	1800                	addi	s0,sp,48
    8000236c:	84aa                	mv	s1,a0
    8000236e:	8a2e                	mv	s4,a1
    80002370:	89b2                	mv	s3,a2
    80002372:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002374:	e86ff0ef          	jal	800019fa <myproc>
  if (user_dst)
    80002378:	cc99                	beqz	s1,80002396 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000237a:	86ca                	mv	a3,s2
    8000237c:	864e                	mv	a2,s3
    8000237e:	85d2                	mv	a1,s4
    80002380:	6928                	ld	a0,80(a0)
    80002382:	ad2ff0ef          	jal	80001654 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002386:	70a2                	ld	ra,40(sp)
    80002388:	7402                	ld	s0,32(sp)
    8000238a:	64e2                	ld	s1,24(sp)
    8000238c:	6942                	ld	s2,16(sp)
    8000238e:	69a2                	ld	s3,8(sp)
    80002390:	6a02                	ld	s4,0(sp)
    80002392:	6145                	addi	sp,sp,48
    80002394:	8082                	ret
    memmove((char *)dst, src, len);
    80002396:	0009061b          	sext.w	a2,s2
    8000239a:	85ce                	mv	a1,s3
    8000239c:	8552                	mv	a0,s4
    8000239e:	9bbfe0ef          	jal	80000d58 <memmove>
    return 0;
    800023a2:	8526                	mv	a0,s1
    800023a4:	b7cd                	j	80002386 <either_copyout+0x2a>

00000000800023a6 <either_copyin>:

int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023a6:	7179                	addi	sp,sp,-48
    800023a8:	f406                	sd	ra,40(sp)
    800023aa:	f022                	sd	s0,32(sp)
    800023ac:	ec26                	sd	s1,24(sp)
    800023ae:	e84a                	sd	s2,16(sp)
    800023b0:	e44e                	sd	s3,8(sp)
    800023b2:	e052                	sd	s4,0(sp)
    800023b4:	1800                	addi	s0,sp,48
    800023b6:	8a2a                	mv	s4,a0
    800023b8:	84ae                	mv	s1,a1
    800023ba:	89b2                	mv	s3,a2
    800023bc:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023be:	e3cff0ef          	jal	800019fa <myproc>
  if (user_src)
    800023c2:	cc99                	beqz	s1,800023e0 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800023c4:	86ca                	mv	a3,s2
    800023c6:	864e                	mv	a2,s3
    800023c8:	85d2                	mv	a1,s4
    800023ca:	6928                	ld	a0,80(a0)
    800023cc:	b46ff0ef          	jal	80001712 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800023d0:	70a2                	ld	ra,40(sp)
    800023d2:	7402                	ld	s0,32(sp)
    800023d4:	64e2                	ld	s1,24(sp)
    800023d6:	6942                	ld	s2,16(sp)
    800023d8:	69a2                	ld	s3,8(sp)
    800023da:	6a02                	ld	s4,0(sp)
    800023dc:	6145                	addi	sp,sp,48
    800023de:	8082                	ret
    memmove(dst, (char *)src, len);
    800023e0:	0009061b          	sext.w	a2,s2
    800023e4:	85ce                	mv	a1,s3
    800023e6:	8552                	mv	a0,s4
    800023e8:	971fe0ef          	jal	80000d58 <memmove>
    return 0;
    800023ec:	8526                	mv	a0,s1
    800023ee:	b7cd                	j	800023d0 <either_copyin+0x2a>

00000000800023f0 <procdump>:

void procdump(void)
{
    800023f0:	7179                	addi	sp,sp,-48
    800023f2:	f406                	sd	ra,40(sp)
    800023f4:	f022                	sd	s0,32(sp)
    800023f6:	ec26                	sd	s1,24(sp)
    800023f8:	e84a                	sd	s2,16(sp)
    800023fa:	e44e                	sd	s3,8(sp)
    800023fc:	e052                	sd	s4,0(sp)
    800023fe:	1800                	addi	s0,sp,48
      [RUNNING] "run",
      [ZOMBIE] "zombie"};

  struct proc *p;

  printf("\n");
    80002400:	00005517          	auipc	a0,0x5
    80002404:	c7850513          	addi	a0,a0,-904 # 80007078 <etext+0x78>
    80002408:	8f2fe0ef          	jal	800004fa <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000240c:	0000e497          	auipc	s1,0xe
    80002410:	b0c48493          	addi	s1,s1,-1268 # 8000ff18 <proc+0x158>
    80002414:	00013917          	auipc	s2,0x13
    80002418:	70490913          	addi	s2,s2,1796 # 80015b18 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    char *state = states[p->state];
    8000241c:	00005a17          	auipc	s4,0x5
    80002420:	314a0a13          	addi	s4,s4,788 # 80007730 <states.0>
    printf("%d %s %s\n", p->pid, state, p->name);
    80002424:	00005997          	auipc	s3,0x5
    80002428:	dec98993          	addi	s3,s3,-532 # 80007210 <etext+0x210>
    8000242c:	a029                	j	80002436 <procdump+0x46>
  for (p = proc; p < &proc[NPROC]; p++)
    8000242e:	17048493          	addi	s1,s1,368
    80002432:	03248263          	beq	s1,s2,80002456 <procdump+0x66>
    if (p->state == UNUSED)
    80002436:	ec04a783          	lw	a5,-320(s1)
    8000243a:	dbf5                	beqz	a5,8000242e <procdump+0x3e>
    char *state = states[p->state];
    8000243c:	02079713          	slli	a4,a5,0x20
    80002440:	01d75793          	srli	a5,a4,0x1d
    80002444:	97d2                	add	a5,a5,s4
    printf("%d %s %s\n", p->pid, state, p->name);
    80002446:	86a6                	mv	a3,s1
    80002448:	6390                	ld	a2,0(a5)
    8000244a:	ed84a583          	lw	a1,-296(s1)
    8000244e:	854e                	mv	a0,s3
    80002450:	8aafe0ef          	jal	800004fa <printf>
    80002454:	bfe9                	j	8000242e <procdump+0x3e>
  }
}
    80002456:	70a2                	ld	ra,40(sp)
    80002458:	7402                	ld	s0,32(sp)
    8000245a:	64e2                	ld	s1,24(sp)
    8000245c:	6942                	ld	s2,16(sp)
    8000245e:	69a2                	ld	s3,8(sp)
    80002460:	6a02                	ld	s4,0(sp)
    80002462:	6145                	addi	sp,sp,48
    80002464:	8082                	ret

0000000080002466 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002466:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000246a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000246e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002470:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002472:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002476:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000247a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000247e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002482:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002486:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000248a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000248e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002492:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002496:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000249a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000249e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800024a2:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800024a4:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800024a6:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800024aa:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800024ae:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800024b2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800024b6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800024ba:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800024be:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800024c2:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800024c6:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800024ca:	0685bd83          	ld	s11,104(a1)
        
        ret
    800024ce:	8082                	ret

00000000800024d0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024d0:	1141                	addi	sp,sp,-16
    800024d2:	e406                	sd	ra,8(sp)
    800024d4:	e022                	sd	s0,0(sp)
    800024d6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024d8:	00005597          	auipc	a1,0x5
    800024dc:	d7858593          	addi	a1,a1,-648 # 80007250 <etext+0x250>
    800024e0:	00013517          	auipc	a0,0x13
    800024e4:	4e050513          	addi	a0,a0,1248 # 800159c0 <tickslock>
    800024e8:	eb6fe0ef          	jal	80000b9e <initlock>
}
    800024ec:	60a2                	ld	ra,8(sp)
    800024ee:	6402                	ld	s0,0(sp)
    800024f0:	0141                	addi	sp,sp,16
    800024f2:	8082                	ret

00000000800024f4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024f4:	1141                	addi	sp,sp,-16
    800024f6:	e406                	sd	ra,8(sp)
    800024f8:	e022                	sd	s0,0(sp)
    800024fa:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024fc:	00003797          	auipc	a5,0x3
    80002500:	f7478793          	addi	a5,a5,-140 # 80005470 <kernelvec>
    80002504:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002508:	60a2                	ld	ra,8(sp)
    8000250a:	6402                	ld	s0,0(sp)
    8000250c:	0141                	addi	sp,sp,16
    8000250e:	8082                	ret

0000000080002510 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002510:	1141                	addi	sp,sp,-16
    80002512:	e406                	sd	ra,8(sp)
    80002514:	e022                	sd	s0,0(sp)
    80002516:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002518:	ce2ff0ef          	jal	800019fa <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000251c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002520:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002522:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002526:	04000737          	lui	a4,0x4000
    8000252a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000252c:	0732                	slli	a4,a4,0xc
    8000252e:	00004797          	auipc	a5,0x4
    80002532:	ad278793          	addi	a5,a5,-1326 # 80006000 <_trampoline>
    80002536:	00004697          	auipc	a3,0x4
    8000253a:	aca68693          	addi	a3,a3,-1334 # 80006000 <_trampoline>
    8000253e:	8f95                	sub	a5,a5,a3
    80002540:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002542:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002546:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002548:	18002773          	csrr	a4,satp
    8000254c:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000254e:	6d38                	ld	a4,88(a0)
    80002550:	613c                	ld	a5,64(a0)
    80002552:	6685                	lui	a3,0x1
    80002554:	97b6                	add	a5,a5,a3
    80002556:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002558:	6d3c                	ld	a5,88(a0)
    8000255a:	00000717          	auipc	a4,0x0
    8000255e:	0fc70713          	addi	a4,a4,252 # 80002656 <usertrap>
    80002562:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002564:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002566:	8712                	mv	a4,tp
    80002568:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000256a:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000256e:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002572:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002576:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000257a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000257c:	6f9c                	ld	a5,24(a5)
    8000257e:	14179073          	csrw	sepc,a5
}
    80002582:	60a2                	ld	ra,8(sp)
    80002584:	6402                	ld	s0,0(sp)
    80002586:	0141                	addi	sp,sp,16
    80002588:	8082                	ret

000000008000258a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000258a:	1141                	addi	sp,sp,-16
    8000258c:	e406                	sd	ra,8(sp)
    8000258e:	e022                	sd	s0,0(sp)
    80002590:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002592:	c34ff0ef          	jal	800019c6 <cpuid>
    80002596:	cd11                	beqz	a0,800025b2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002598:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000259c:	000f4737          	lui	a4,0xf4
    800025a0:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025a4:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800025a6:	14d79073          	csrw	stimecmp,a5
}
    800025aa:	60a2                	ld	ra,8(sp)
    800025ac:	6402                	ld	s0,0(sp)
    800025ae:	0141                	addi	sp,sp,16
    800025b0:	8082                	ret
    acquire(&tickslock);
    800025b2:	00013517          	auipc	a0,0x13
    800025b6:	40e50513          	addi	a0,a0,1038 # 800159c0 <tickslock>
    800025ba:	e6efe0ef          	jal	80000c28 <acquire>
    ticks++;
    800025be:	00005717          	auipc	a4,0x5
    800025c2:	2ba70713          	addi	a4,a4,698 # 80007878 <ticks>
    800025c6:	431c                	lw	a5,0(a4)
    800025c8:	2785                	addiw	a5,a5,1
    800025ca:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800025cc:	853a                	mv	a0,a4
    800025ce:	a75ff0ef          	jal	80002042 <wakeup>
    release(&tickslock);
    800025d2:	00013517          	auipc	a0,0x13
    800025d6:	3ee50513          	addi	a0,a0,1006 # 800159c0 <tickslock>
    800025da:	ee2fe0ef          	jal	80000cbc <release>
    800025de:	bf6d                	j	80002598 <clockintr+0xe>

00000000800025e0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025e0:	1101                	addi	sp,sp,-32
    800025e2:	ec06                	sd	ra,24(sp)
    800025e4:	e822                	sd	s0,16(sp)
    800025e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025e8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800025ec:	57fd                	li	a5,-1
    800025ee:	17fe                	slli	a5,a5,0x3f
    800025f0:	07a5                	addi	a5,a5,9
    800025f2:	00f70c63          	beq	a4,a5,8000260a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025f6:	57fd                	li	a5,-1
    800025f8:	17fe                	slli	a5,a5,0x3f
    800025fa:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025fc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025fe:	04f70863          	beq	a4,a5,8000264e <devintr+0x6e>
  }
}
    80002602:	60e2                	ld	ra,24(sp)
    80002604:	6442                	ld	s0,16(sp)
    80002606:	6105                	addi	sp,sp,32
    80002608:	8082                	ret
    8000260a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000260c:	711020ef          	jal	8000551c <plic_claim>
    80002610:	872a                	mv	a4,a0
    80002612:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002614:	47a9                	li	a5,10
    80002616:	00f50963          	beq	a0,a5,80002628 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    8000261a:	4785                	li	a5,1
    8000261c:	00f50963          	beq	a0,a5,8000262e <devintr+0x4e>
    return 1;
    80002620:	4505                	li	a0,1
    } else if(irq){
    80002622:	eb09                	bnez	a4,80002634 <devintr+0x54>
    80002624:	64a2                	ld	s1,8(sp)
    80002626:	bff1                	j	80002602 <devintr+0x22>
      uartintr();
    80002628:	bccfe0ef          	jal	800009f4 <uartintr>
    if(irq)
    8000262c:	a819                	j	80002642 <devintr+0x62>
      virtio_disk_intr();
    8000262e:	384030ef          	jal	800059b2 <virtio_disk_intr>
    if(irq)
    80002632:	a801                	j	80002642 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002634:	85ba                	mv	a1,a4
    80002636:	00005517          	auipc	a0,0x5
    8000263a:	c2250513          	addi	a0,a0,-990 # 80007258 <etext+0x258>
    8000263e:	ebdfd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002642:	8526                	mv	a0,s1
    80002644:	6f9020ef          	jal	8000553c <plic_complete>
    return 1;
    80002648:	4505                	li	a0,1
    8000264a:	64a2                	ld	s1,8(sp)
    8000264c:	bf5d                	j	80002602 <devintr+0x22>
    clockintr();
    8000264e:	f3dff0ef          	jal	8000258a <clockintr>
    return 2;
    80002652:	4509                	li	a0,2
    80002654:	b77d                	j	80002602 <devintr+0x22>

0000000080002656 <usertrap>:
{
    80002656:	1101                	addi	sp,sp,-32
    80002658:	ec06                	sd	ra,24(sp)
    8000265a:	e822                	sd	s0,16(sp)
    8000265c:	e426                	sd	s1,8(sp)
    8000265e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002660:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002664:	1007f793          	andi	a5,a5,256
    80002668:	e7bd                	bnez	a5,800026d6 <usertrap+0x80>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000266a:	00003797          	auipc	a5,0x3
    8000266e:	e0678793          	addi	a5,a5,-506 # 80005470 <kernelvec>
    80002672:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002676:	b84ff0ef          	jal	800019fa <myproc>
    8000267a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000267c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000267e:	14102773          	csrr	a4,sepc
    80002682:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002684:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002688:	47a1                	li	a5,8
    8000268a:	04f70c63          	beq	a4,a5,800026e2 <usertrap+0x8c>
  } else if((which_dev = devintr()) != 0){
    8000268e:	f53ff0ef          	jal	800025e0 <devintr>
    80002692:	e53d                	bnez	a0,80002700 <usertrap+0xaa>
    80002694:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002698:	47bd                	li	a5,15
    8000269a:	08f70763          	beq	a4,a5,80002728 <usertrap+0xd2>
    8000269e:	14202773          	csrr	a4,scause
    800026a2:	47b5                	li	a5,13
    800026a4:	08f70263          	beq	a4,a5,80002728 <usertrap+0xd2>
    800026a8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026ac:	5890                	lw	a2,48(s1)
    800026ae:	00005517          	auipc	a0,0x5
    800026b2:	bea50513          	addi	a0,a0,-1046 # 80007298 <etext+0x298>
    800026b6:	e45fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026ba:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026be:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800026c2:	00005517          	auipc	a0,0x5
    800026c6:	c0650513          	addi	a0,a0,-1018 # 800072c8 <etext+0x2c8>
    800026ca:	e31fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800026ce:	8526                	mv	a0,s1
    800026d0:	b4bff0ef          	jal	8000221a <setkilled>
    800026d4:	a035                	j	80002700 <usertrap+0xaa>
    panic("usertrap: not from user mode");
    800026d6:	00005517          	auipc	a0,0x5
    800026da:	ba250513          	addi	a0,a0,-1118 # 80007278 <etext+0x278>
    800026de:	946fe0ef          	jal	80000824 <panic>
    if(killed(p))
    800026e2:	b5dff0ef          	jal	8000223e <killed>
    800026e6:	ed0d                	bnez	a0,80002720 <usertrap+0xca>
    p->trapframe->epc += 4;
    800026e8:	6cb8                	ld	a4,88(s1)
    800026ea:	6f1c                	ld	a5,24(a4)
    800026ec:	0791                	addi	a5,a5,4
    800026ee:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026f0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026f4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f8:	10079073          	csrw	sstatus,a5
    syscall();
    800026fc:	216000ef          	jal	80002912 <syscall>
  if(killed(p))
    80002700:	8526                	mv	a0,s1
    80002702:	b3dff0ef          	jal	8000223e <killed>
    80002706:	ed0d                	bnez	a0,80002740 <usertrap+0xea>
  prepare_return();
    80002708:	e09ff0ef          	jal	80002510 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000270c:	68a8                	ld	a0,80(s1)
    8000270e:	8131                	srli	a0,a0,0xc
}
    80002710:	57fd                	li	a5,-1
    80002712:	17fe                	slli	a5,a5,0x3f
    80002714:	8d5d                	or	a0,a0,a5
    80002716:	60e2                	ld	ra,24(sp)
    80002718:	6442                	ld	s0,16(sp)
    8000271a:	64a2                	ld	s1,8(sp)
    8000271c:	6105                	addi	sp,sp,32
    8000271e:	8082                	ret
      kexit(-1);
    80002720:	557d                	li	a0,-1
    80002722:	9e7ff0ef          	jal	80002108 <kexit>
    80002726:	b7c9                	j	800026e8 <usertrap+0x92>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002728:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000272c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002730:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002732:	00163613          	seqz	a2,a2
    80002736:	68a8                	ld	a0,80(s1)
    80002738:	e99fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000273c:	f171                	bnez	a0,80002700 <usertrap+0xaa>
    8000273e:	b7ad                	j	800026a8 <usertrap+0x52>
    kexit(-1);
    80002740:	557d                	li	a0,-1
    80002742:	9c7ff0ef          	jal	80002108 <kexit>
    80002746:	b7c9                	j	80002708 <usertrap+0xb2>

0000000080002748 <kerneltrap>:
{
    80002748:	7179                	addi	sp,sp,-48
    8000274a:	f406                	sd	ra,40(sp)
    8000274c:	f022                	sd	s0,32(sp)
    8000274e:	ec26                	sd	s1,24(sp)
    80002750:	e84a                	sd	s2,16(sp)
    80002752:	e44e                	sd	s3,8(sp)
    80002754:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002756:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000275a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000275e:	142027f3          	csrr	a5,scause
    80002762:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002764:	1004f793          	andi	a5,s1,256
    80002768:	c39d                	beqz	a5,8000278e <kerneltrap+0x46>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000276a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000276e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002770:	e78d                	bnez	a5,8000279a <kerneltrap+0x52>
  if((which_dev = devintr()) == 0){
    80002772:	e6fff0ef          	jal	800025e0 <devintr>
    80002776:	c905                	beqz	a0,800027a6 <kerneltrap+0x5e>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002778:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000277c:	10049073          	csrw	sstatus,s1
}
    80002780:	70a2                	ld	ra,40(sp)
    80002782:	7402                	ld	s0,32(sp)
    80002784:	64e2                	ld	s1,24(sp)
    80002786:	6942                	ld	s2,16(sp)
    80002788:	69a2                	ld	s3,8(sp)
    8000278a:	6145                	addi	sp,sp,48
    8000278c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000278e:	00005517          	auipc	a0,0x5
    80002792:	b6250513          	addi	a0,a0,-1182 # 800072f0 <etext+0x2f0>
    80002796:	88efe0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    8000279a:	00005517          	auipc	a0,0x5
    8000279e:	b7e50513          	addi	a0,a0,-1154 # 80007318 <etext+0x318>
    800027a2:	882fe0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027a6:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027aa:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800027ae:	85ce                	mv	a1,s3
    800027b0:	00005517          	auipc	a0,0x5
    800027b4:	b8850513          	addi	a0,a0,-1144 # 80007338 <etext+0x338>
    800027b8:	d43fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800027bc:	00005517          	auipc	a0,0x5
    800027c0:	ba450513          	addi	a0,a0,-1116 # 80007360 <etext+0x360>
    800027c4:	860fe0ef          	jal	80000824 <panic>

00000000800027c8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027c8:	1101                	addi	sp,sp,-32
    800027ca:	ec06                	sd	ra,24(sp)
    800027cc:	e822                	sd	s0,16(sp)
    800027ce:	e426                	sd	s1,8(sp)
    800027d0:	1000                	addi	s0,sp,32
    800027d2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027d4:	a26ff0ef          	jal	800019fa <myproc>
  switch (n) {
    800027d8:	4795                	li	a5,5
    800027da:	0497e163          	bltu	a5,s1,8000281c <argraw+0x54>
    800027de:	048a                	slli	s1,s1,0x2
    800027e0:	00005717          	auipc	a4,0x5
    800027e4:	f8070713          	addi	a4,a4,-128 # 80007760 <states.0+0x30>
    800027e8:	94ba                	add	s1,s1,a4
    800027ea:	409c                	lw	a5,0(s1)
    800027ec:	97ba                	add	a5,a5,a4
    800027ee:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027f0:	6d3c                	ld	a5,88(a0)
    800027f2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027f4:	60e2                	ld	ra,24(sp)
    800027f6:	6442                	ld	s0,16(sp)
    800027f8:	64a2                	ld	s1,8(sp)
    800027fa:	6105                	addi	sp,sp,32
    800027fc:	8082                	ret
    return p->trapframe->a1;
    800027fe:	6d3c                	ld	a5,88(a0)
    80002800:	7fa8                	ld	a0,120(a5)
    80002802:	bfcd                	j	800027f4 <argraw+0x2c>
    return p->trapframe->a2;
    80002804:	6d3c                	ld	a5,88(a0)
    80002806:	63c8                	ld	a0,128(a5)
    80002808:	b7f5                	j	800027f4 <argraw+0x2c>
    return p->trapframe->a3;
    8000280a:	6d3c                	ld	a5,88(a0)
    8000280c:	67c8                	ld	a0,136(a5)
    8000280e:	b7dd                	j	800027f4 <argraw+0x2c>
    return p->trapframe->a4;
    80002810:	6d3c                	ld	a5,88(a0)
    80002812:	6bc8                	ld	a0,144(a5)
    80002814:	b7c5                	j	800027f4 <argraw+0x2c>
    return p->trapframe->a5;
    80002816:	6d3c                	ld	a5,88(a0)
    80002818:	6fc8                	ld	a0,152(a5)
    8000281a:	bfe9                	j	800027f4 <argraw+0x2c>
  panic("argraw");
    8000281c:	00005517          	auipc	a0,0x5
    80002820:	b5450513          	addi	a0,a0,-1196 # 80007370 <etext+0x370>
    80002824:	800fe0ef          	jal	80000824 <panic>

0000000080002828 <fetchaddr>:
{
    80002828:	1101                	addi	sp,sp,-32
    8000282a:	ec06                	sd	ra,24(sp)
    8000282c:	e822                	sd	s0,16(sp)
    8000282e:	e426                	sd	s1,8(sp)
    80002830:	e04a                	sd	s2,0(sp)
    80002832:	1000                	addi	s0,sp,32
    80002834:	84aa                	mv	s1,a0
    80002836:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002838:	9c2ff0ef          	jal	800019fa <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000283c:	653c                	ld	a5,72(a0)
    8000283e:	02f4f663          	bgeu	s1,a5,8000286a <fetchaddr+0x42>
    80002842:	00848713          	addi	a4,s1,8
    80002846:	02e7e463          	bltu	a5,a4,8000286e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000284a:	46a1                	li	a3,8
    8000284c:	8626                	mv	a2,s1
    8000284e:	85ca                	mv	a1,s2
    80002850:	6928                	ld	a0,80(a0)
    80002852:	ec1fe0ef          	jal	80001712 <copyin>
    80002856:	00a03533          	snez	a0,a0
    8000285a:	40a0053b          	negw	a0,a0
}
    8000285e:	60e2                	ld	ra,24(sp)
    80002860:	6442                	ld	s0,16(sp)
    80002862:	64a2                	ld	s1,8(sp)
    80002864:	6902                	ld	s2,0(sp)
    80002866:	6105                	addi	sp,sp,32
    80002868:	8082                	ret
    return -1;
    8000286a:	557d                	li	a0,-1
    8000286c:	bfcd                	j	8000285e <fetchaddr+0x36>
    8000286e:	557d                	li	a0,-1
    80002870:	b7fd                	j	8000285e <fetchaddr+0x36>

0000000080002872 <fetchstr>:
{
    80002872:	7179                	addi	sp,sp,-48
    80002874:	f406                	sd	ra,40(sp)
    80002876:	f022                	sd	s0,32(sp)
    80002878:	ec26                	sd	s1,24(sp)
    8000287a:	e84a                	sd	s2,16(sp)
    8000287c:	e44e                	sd	s3,8(sp)
    8000287e:	1800                	addi	s0,sp,48
    80002880:	89aa                	mv	s3,a0
    80002882:	84ae                	mv	s1,a1
    80002884:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002886:	974ff0ef          	jal	800019fa <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000288a:	86ca                	mv	a3,s2
    8000288c:	864e                	mv	a2,s3
    8000288e:	85a6                	mv	a1,s1
    80002890:	6928                	ld	a0,80(a0)
    80002892:	c67fe0ef          	jal	800014f8 <copyinstr>
    80002896:	00054c63          	bltz	a0,800028ae <fetchstr+0x3c>
  return strlen(buf);
    8000289a:	8526                	mv	a0,s1
    8000289c:	de6fe0ef          	jal	80000e82 <strlen>
}
    800028a0:	70a2                	ld	ra,40(sp)
    800028a2:	7402                	ld	s0,32(sp)
    800028a4:	64e2                	ld	s1,24(sp)
    800028a6:	6942                	ld	s2,16(sp)
    800028a8:	69a2                	ld	s3,8(sp)
    800028aa:	6145                	addi	sp,sp,48
    800028ac:	8082                	ret
    return -1;
    800028ae:	557d                	li	a0,-1
    800028b0:	bfc5                	j	800028a0 <fetchstr+0x2e>

00000000800028b2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028b2:	1101                	addi	sp,sp,-32
    800028b4:	ec06                	sd	ra,24(sp)
    800028b6:	e822                	sd	s0,16(sp)
    800028b8:	e426                	sd	s1,8(sp)
    800028ba:	1000                	addi	s0,sp,32
    800028bc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028be:	f0bff0ef          	jal	800027c8 <argraw>
    800028c2:	c088                	sw	a0,0(s1)
}
    800028c4:	60e2                	ld	ra,24(sp)
    800028c6:	6442                	ld	s0,16(sp)
    800028c8:	64a2                	ld	s1,8(sp)
    800028ca:	6105                	addi	sp,sp,32
    800028cc:	8082                	ret

00000000800028ce <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028ce:	1101                	addi	sp,sp,-32
    800028d0:	ec06                	sd	ra,24(sp)
    800028d2:	e822                	sd	s0,16(sp)
    800028d4:	e426                	sd	s1,8(sp)
    800028d6:	1000                	addi	s0,sp,32
    800028d8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028da:	eefff0ef          	jal	800027c8 <argraw>
    800028de:	e088                	sd	a0,0(s1)
}
    800028e0:	60e2                	ld	ra,24(sp)
    800028e2:	6442                	ld	s0,16(sp)
    800028e4:	64a2                	ld	s1,8(sp)
    800028e6:	6105                	addi	sp,sp,32
    800028e8:	8082                	ret

00000000800028ea <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028ea:	1101                	addi	sp,sp,-32
    800028ec:	ec06                	sd	ra,24(sp)
    800028ee:	e822                	sd	s0,16(sp)
    800028f0:	e426                	sd	s1,8(sp)
    800028f2:	e04a                	sd	s2,0(sp)
    800028f4:	1000                	addi	s0,sp,32
    800028f6:	892e                	mv	s2,a1
    800028f8:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028fa:	ecfff0ef          	jal	800027c8 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028fe:	8626                	mv	a2,s1
    80002900:	85ca                	mv	a1,s2
    80002902:	f71ff0ef          	jal	80002872 <fetchstr>
}
    80002906:	60e2                	ld	ra,24(sp)
    80002908:	6442                	ld	s0,16(sp)
    8000290a:	64a2                	ld	s1,8(sp)
    8000290c:	6902                	ld	s2,0(sp)
    8000290e:	6105                	addi	sp,sp,32
    80002910:	8082                	ret

0000000080002912 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002912:	1101                	addi	sp,sp,-32
    80002914:	ec06                	sd	ra,24(sp)
    80002916:	e822                	sd	s0,16(sp)
    80002918:	e426                	sd	s1,8(sp)
    8000291a:	e04a                	sd	s2,0(sp)
    8000291c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000291e:	8dcff0ef          	jal	800019fa <myproc>
    80002922:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002924:	05853903          	ld	s2,88(a0)
    80002928:	0a893783          	ld	a5,168(s2)
    8000292c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002930:	37fd                	addiw	a5,a5,-1
    80002932:	4751                	li	a4,20
    80002934:	00f76f63          	bltu	a4,a5,80002952 <syscall+0x40>
    80002938:	00369713          	slli	a4,a3,0x3
    8000293c:	00005797          	auipc	a5,0x5
    80002940:	e3c78793          	addi	a5,a5,-452 # 80007778 <syscalls>
    80002944:	97ba                	add	a5,a5,a4
    80002946:	639c                	ld	a5,0(a5)
    80002948:	c789                	beqz	a5,80002952 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000294a:	9782                	jalr	a5
    8000294c:	06a93823          	sd	a0,112(s2)
    80002950:	a829                	j	8000296a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002952:	15848613          	addi	a2,s1,344
    80002956:	588c                	lw	a1,48(s1)
    80002958:	00005517          	auipc	a0,0x5
    8000295c:	a2050513          	addi	a0,a0,-1504 # 80007378 <etext+0x378>
    80002960:	b9bfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002964:	6cbc                	ld	a5,88(s1)
    80002966:	577d                	li	a4,-1
    80002968:	fbb8                	sd	a4,112(a5)
  }
}
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	64a2                	ld	s1,8(sp)
    80002970:	6902                	ld	s2,0(sp)
    80002972:	6105                	addi	sp,sp,32
    80002974:	8082                	ret

0000000080002976 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002976:	1101                	addi	sp,sp,-32
    80002978:	ec06                	sd	ra,24(sp)
    8000297a:	e822                	sd	s0,16(sp)
    8000297c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000297e:	fec40593          	addi	a1,s0,-20
    80002982:	4501                	li	a0,0
    80002984:	f2fff0ef          	jal	800028b2 <argint>
  kexit(n);
    80002988:	fec42503          	lw	a0,-20(s0)
    8000298c:	f7cff0ef          	jal	80002108 <kexit>
  return 0;  // not reached
}
    80002990:	4501                	li	a0,0
    80002992:	60e2                	ld	ra,24(sp)
    80002994:	6442                	ld	s0,16(sp)
    80002996:	6105                	addi	sp,sp,32
    80002998:	8082                	ret

000000008000299a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000299a:	1141                	addi	sp,sp,-16
    8000299c:	e406                	sd	ra,8(sp)
    8000299e:	e022                	sd	s0,0(sp)
    800029a0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029a2:	858ff0ef          	jal	800019fa <myproc>
}
    800029a6:	5908                	lw	a0,48(a0)
    800029a8:	60a2                	ld	ra,8(sp)
    800029aa:	6402                	ld	s0,0(sp)
    800029ac:	0141                	addi	sp,sp,16
    800029ae:	8082                	ret

00000000800029b0 <sys_fork>:

uint64
sys_fork(void)
{
    800029b0:	1141                	addi	sp,sp,-16
    800029b2:	e406                	sd	ra,8(sp)
    800029b4:	e022                	sd	s0,0(sp)
    800029b6:	0800                	addi	s0,sp,16
  return kfork();
    800029b8:	bb0ff0ef          	jal	80001d68 <kfork>
}
    800029bc:	60a2                	ld	ra,8(sp)
    800029be:	6402                	ld	s0,0(sp)
    800029c0:	0141                	addi	sp,sp,16
    800029c2:	8082                	ret

00000000800029c4 <sys_wait>:

uint64
sys_wait(void)
{
    800029c4:	1101                	addi	sp,sp,-32
    800029c6:	ec06                	sd	ra,24(sp)
    800029c8:	e822                	sd	s0,16(sp)
    800029ca:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029cc:	fe840593          	addi	a1,s0,-24
    800029d0:	4501                	li	a0,0
    800029d2:	efdff0ef          	jal	800028ce <argaddr>
  return kwait(p);
    800029d6:	fe843503          	ld	a0,-24(s0)
    800029da:	88fff0ef          	jal	80002268 <kwait>
}
    800029de:	60e2                	ld	ra,24(sp)
    800029e0:	6442                	ld	s0,16(sp)
    800029e2:	6105                	addi	sp,sp,32
    800029e4:	8082                	ret

00000000800029e6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029e6:	7179                	addi	sp,sp,-48
    800029e8:	f406                	sd	ra,40(sp)
    800029ea:	f022                	sd	s0,32(sp)
    800029ec:	ec26                	sd	s1,24(sp)
    800029ee:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029f0:	fd840593          	addi	a1,s0,-40
    800029f4:	4501                	li	a0,0
    800029f6:	ebdff0ef          	jal	800028b2 <argint>
  argint(1, &t);
    800029fa:	fdc40593          	addi	a1,s0,-36
    800029fe:	4505                	li	a0,1
    80002a00:	eb3ff0ef          	jal	800028b2 <argint>
  addr = myproc()->sz;
    80002a04:	ff7fe0ef          	jal	800019fa <myproc>
    80002a08:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002a0a:	fdc42703          	lw	a4,-36(s0)
    80002a0e:	4785                	li	a5,1
    80002a10:	02f70763          	beq	a4,a5,80002a3e <sys_sbrk+0x58>
    80002a14:	fd842783          	lw	a5,-40(s0)
    80002a18:	0207c363          	bltz	a5,80002a3e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002a1c:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002a1e:	02000737          	lui	a4,0x2000
    80002a22:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002a24:	0736                	slli	a4,a4,0xd
    80002a26:	02f76a63          	bltu	a4,a5,80002a5a <sys_sbrk+0x74>
    80002a2a:	0297e863          	bltu	a5,s1,80002a5a <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a2e:	fcdfe0ef          	jal	800019fa <myproc>
    80002a32:	fd842703          	lw	a4,-40(s0)
    80002a36:	653c                	ld	a5,72(a0)
    80002a38:	97ba                	add	a5,a5,a4
    80002a3a:	e53c                	sd	a5,72(a0)
    80002a3c:	a039                	j	80002a4a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002a3e:	fd842503          	lw	a0,-40(s0)
    80002a42:	ac4ff0ef          	jal	80001d06 <growproc>
    80002a46:	00054863          	bltz	a0,80002a56 <sys_sbrk+0x70>
  }
  return addr;
}
    80002a4a:	8526                	mv	a0,s1
    80002a4c:	70a2                	ld	ra,40(sp)
    80002a4e:	7402                	ld	s0,32(sp)
    80002a50:	64e2                	ld	s1,24(sp)
    80002a52:	6145                	addi	sp,sp,48
    80002a54:	8082                	ret
      return -1;
    80002a56:	54fd                	li	s1,-1
    80002a58:	bfcd                	j	80002a4a <sys_sbrk+0x64>
      return -1;
    80002a5a:	54fd                	li	s1,-1
    80002a5c:	b7fd                	j	80002a4a <sys_sbrk+0x64>

0000000080002a5e <sys_pause>:

uint64
sys_pause(void)
{
    80002a5e:	7139                	addi	sp,sp,-64
    80002a60:	fc06                	sd	ra,56(sp)
    80002a62:	f822                	sd	s0,48(sp)
    80002a64:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a66:	fcc40593          	addi	a1,s0,-52
    80002a6a:	4501                	li	a0,0
    80002a6c:	e47ff0ef          	jal	800028b2 <argint>
  if(n < 0)
    80002a70:	fcc42783          	lw	a5,-52(s0)
    80002a74:	0607c863          	bltz	a5,80002ae4 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a78:	00013517          	auipc	a0,0x13
    80002a7c:	f4850513          	addi	a0,a0,-184 # 800159c0 <tickslock>
    80002a80:	9a8fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002a84:	fcc42783          	lw	a5,-52(s0)
    80002a88:	c3b9                	beqz	a5,80002ace <sys_pause+0x70>
    80002a8a:	f426                	sd	s1,40(sp)
    80002a8c:	f04a                	sd	s2,32(sp)
    80002a8e:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a90:	00005997          	auipc	s3,0x5
    80002a94:	de89a983          	lw	s3,-536(s3) # 80007878 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a98:	00013917          	auipc	s2,0x13
    80002a9c:	f2890913          	addi	s2,s2,-216 # 800159c0 <tickslock>
    80002aa0:	00005497          	auipc	s1,0x5
    80002aa4:	dd848493          	addi	s1,s1,-552 # 80007878 <ticks>
    if(killed(myproc())){
    80002aa8:	f53fe0ef          	jal	800019fa <myproc>
    80002aac:	f92ff0ef          	jal	8000223e <killed>
    80002ab0:	ed0d                	bnez	a0,80002aea <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002ab2:	85ca                	mv	a1,s2
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	d40ff0ef          	jal	80001ff6 <sleep>
  while(ticks - ticks0 < n){
    80002aba:	409c                	lw	a5,0(s1)
    80002abc:	413787bb          	subw	a5,a5,s3
    80002ac0:	fcc42703          	lw	a4,-52(s0)
    80002ac4:	fee7e2e3          	bltu	a5,a4,80002aa8 <sys_pause+0x4a>
    80002ac8:	74a2                	ld	s1,40(sp)
    80002aca:	7902                	ld	s2,32(sp)
    80002acc:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002ace:	00013517          	auipc	a0,0x13
    80002ad2:	ef250513          	addi	a0,a0,-270 # 800159c0 <tickslock>
    80002ad6:	9e6fe0ef          	jal	80000cbc <release>
  return 0;
    80002ada:	4501                	li	a0,0
}
    80002adc:	70e2                	ld	ra,56(sp)
    80002ade:	7442                	ld	s0,48(sp)
    80002ae0:	6121                	addi	sp,sp,64
    80002ae2:	8082                	ret
    n = 0;
    80002ae4:	fc042623          	sw	zero,-52(s0)
    80002ae8:	bf41                	j	80002a78 <sys_pause+0x1a>
      release(&tickslock);
    80002aea:	00013517          	auipc	a0,0x13
    80002aee:	ed650513          	addi	a0,a0,-298 # 800159c0 <tickslock>
    80002af2:	9cafe0ef          	jal	80000cbc <release>
      return -1;
    80002af6:	557d                	li	a0,-1
    80002af8:	74a2                	ld	s1,40(sp)
    80002afa:	7902                	ld	s2,32(sp)
    80002afc:	69e2                	ld	s3,24(sp)
    80002afe:	bff9                	j	80002adc <sys_pause+0x7e>

0000000080002b00 <sys_kill>:

uint64
sys_kill(void)
{
    80002b00:	1101                	addi	sp,sp,-32
    80002b02:	ec06                	sd	ra,24(sp)
    80002b04:	e822                	sd	s0,16(sp)
    80002b06:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002b08:	fec40593          	addi	a1,s0,-20
    80002b0c:	4501                	li	a0,0
    80002b0e:	da5ff0ef          	jal	800028b2 <argint>
  return kkill(pid);
    80002b12:	fec42503          	lw	a0,-20(s0)
    80002b16:	e98ff0ef          	jal	800021ae <kkill>
}
    80002b1a:	60e2                	ld	ra,24(sp)
    80002b1c:	6442                	ld	s0,16(sp)
    80002b1e:	6105                	addi	sp,sp,32
    80002b20:	8082                	ret

0000000080002b22 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b22:	1101                	addi	sp,sp,-32
    80002b24:	ec06                	sd	ra,24(sp)
    80002b26:	e822                	sd	s0,16(sp)
    80002b28:	e426                	sd	s1,8(sp)
    80002b2a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b2c:	00013517          	auipc	a0,0x13
    80002b30:	e9450513          	addi	a0,a0,-364 # 800159c0 <tickslock>
    80002b34:	8f4fe0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002b38:	00005797          	auipc	a5,0x5
    80002b3c:	d407a783          	lw	a5,-704(a5) # 80007878 <ticks>
    80002b40:	84be                	mv	s1,a5
  release(&tickslock);
    80002b42:	00013517          	auipc	a0,0x13
    80002b46:	e7e50513          	addi	a0,a0,-386 # 800159c0 <tickslock>
    80002b4a:	972fe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002b4e:	02049513          	slli	a0,s1,0x20
    80002b52:	9101                	srli	a0,a0,0x20
    80002b54:	60e2                	ld	ra,24(sp)
    80002b56:	6442                	ld	s0,16(sp)
    80002b58:	64a2                	ld	s1,8(sp)
    80002b5a:	6105                	addi	sp,sp,32
    80002b5c:	8082                	ret

0000000080002b5e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b5e:	7179                	addi	sp,sp,-48
    80002b60:	f406                	sd	ra,40(sp)
    80002b62:	f022                	sd	s0,32(sp)
    80002b64:	ec26                	sd	s1,24(sp)
    80002b66:	e84a                	sd	s2,16(sp)
    80002b68:	e44e                	sd	s3,8(sp)
    80002b6a:	e052                	sd	s4,0(sp)
    80002b6c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b6e:	00005597          	auipc	a1,0x5
    80002b72:	82a58593          	addi	a1,a1,-2006 # 80007398 <etext+0x398>
    80002b76:	00013517          	auipc	a0,0x13
    80002b7a:	e6250513          	addi	a0,a0,-414 # 800159d8 <bcache>
    80002b7e:	820fe0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b82:	0001b797          	auipc	a5,0x1b
    80002b86:	e5678793          	addi	a5,a5,-426 # 8001d9d8 <bcache+0x8000>
    80002b8a:	0001b717          	auipc	a4,0x1b
    80002b8e:	0b670713          	addi	a4,a4,182 # 8001dc40 <bcache+0x8268>
    80002b92:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b96:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b9a:	00013497          	auipc	s1,0x13
    80002b9e:	e5648493          	addi	s1,s1,-426 # 800159f0 <bcache+0x18>
    b->next = bcache.head.next;
    80002ba2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ba4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ba6:	00004a17          	auipc	s4,0x4
    80002baa:	7faa0a13          	addi	s4,s4,2042 # 800073a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002bae:	2b893783          	ld	a5,696(s2)
    80002bb2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bb4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bb8:	85d2                	mv	a1,s4
    80002bba:	01048513          	addi	a0,s1,16
    80002bbe:	328010ef          	jal	80003ee6 <initsleeplock>
    bcache.head.next->prev = b;
    80002bc2:	2b893783          	ld	a5,696(s2)
    80002bc6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bc8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bcc:	45848493          	addi	s1,s1,1112
    80002bd0:	fd349fe3          	bne	s1,s3,80002bae <binit+0x50>
  }
}
    80002bd4:	70a2                	ld	ra,40(sp)
    80002bd6:	7402                	ld	s0,32(sp)
    80002bd8:	64e2                	ld	s1,24(sp)
    80002bda:	6942                	ld	s2,16(sp)
    80002bdc:	69a2                	ld	s3,8(sp)
    80002bde:	6a02                	ld	s4,0(sp)
    80002be0:	6145                	addi	sp,sp,48
    80002be2:	8082                	ret

0000000080002be4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002be4:	7179                	addi	sp,sp,-48
    80002be6:	f406                	sd	ra,40(sp)
    80002be8:	f022                	sd	s0,32(sp)
    80002bea:	ec26                	sd	s1,24(sp)
    80002bec:	e84a                	sd	s2,16(sp)
    80002bee:	e44e                	sd	s3,8(sp)
    80002bf0:	1800                	addi	s0,sp,48
    80002bf2:	892a                	mv	s2,a0
    80002bf4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bf6:	00013517          	auipc	a0,0x13
    80002bfa:	de250513          	addi	a0,a0,-542 # 800159d8 <bcache>
    80002bfe:	82afe0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c02:	0001b497          	auipc	s1,0x1b
    80002c06:	08e4b483          	ld	s1,142(s1) # 8001dc90 <bcache+0x82b8>
    80002c0a:	0001b797          	auipc	a5,0x1b
    80002c0e:	03678793          	addi	a5,a5,54 # 8001dc40 <bcache+0x8268>
    80002c12:	02f48b63          	beq	s1,a5,80002c48 <bread+0x64>
    80002c16:	873e                	mv	a4,a5
    80002c18:	a021                	j	80002c20 <bread+0x3c>
    80002c1a:	68a4                	ld	s1,80(s1)
    80002c1c:	02e48663          	beq	s1,a4,80002c48 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c20:	449c                	lw	a5,8(s1)
    80002c22:	ff279ce3          	bne	a5,s2,80002c1a <bread+0x36>
    80002c26:	44dc                	lw	a5,12(s1)
    80002c28:	ff3799e3          	bne	a5,s3,80002c1a <bread+0x36>
      b->refcnt++;
    80002c2c:	40bc                	lw	a5,64(s1)
    80002c2e:	2785                	addiw	a5,a5,1
    80002c30:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c32:	00013517          	auipc	a0,0x13
    80002c36:	da650513          	addi	a0,a0,-602 # 800159d8 <bcache>
    80002c3a:	882fe0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002c3e:	01048513          	addi	a0,s1,16
    80002c42:	2da010ef          	jal	80003f1c <acquiresleep>
      return b;
    80002c46:	a889                	j	80002c98 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c48:	0001b497          	auipc	s1,0x1b
    80002c4c:	0404b483          	ld	s1,64(s1) # 8001dc88 <bcache+0x82b0>
    80002c50:	0001b797          	auipc	a5,0x1b
    80002c54:	ff078793          	addi	a5,a5,-16 # 8001dc40 <bcache+0x8268>
    80002c58:	00f48863          	beq	s1,a5,80002c68 <bread+0x84>
    80002c5c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c5e:	40bc                	lw	a5,64(s1)
    80002c60:	cb91                	beqz	a5,80002c74 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c62:	64a4                	ld	s1,72(s1)
    80002c64:	fee49de3          	bne	s1,a4,80002c5e <bread+0x7a>
  panic("bget: no buffers");
    80002c68:	00004517          	auipc	a0,0x4
    80002c6c:	74050513          	addi	a0,a0,1856 # 800073a8 <etext+0x3a8>
    80002c70:	bb5fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002c74:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c78:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c7c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c80:	4785                	li	a5,1
    80002c82:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c84:	00013517          	auipc	a0,0x13
    80002c88:	d5450513          	addi	a0,a0,-684 # 800159d8 <bcache>
    80002c8c:	830fe0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002c90:	01048513          	addi	a0,s1,16
    80002c94:	288010ef          	jal	80003f1c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c98:	409c                	lw	a5,0(s1)
    80002c9a:	cb89                	beqz	a5,80002cac <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c9c:	8526                	mv	a0,s1
    80002c9e:	70a2                	ld	ra,40(sp)
    80002ca0:	7402                	ld	s0,32(sp)
    80002ca2:	64e2                	ld	s1,24(sp)
    80002ca4:	6942                	ld	s2,16(sp)
    80002ca6:	69a2                	ld	s3,8(sp)
    80002ca8:	6145                	addi	sp,sp,48
    80002caa:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cac:	4581                	li	a1,0
    80002cae:	8526                	mv	a0,s1
    80002cb0:	2f1020ef          	jal	800057a0 <virtio_disk_rw>
    b->valid = 1;
    80002cb4:	4785                	li	a5,1
    80002cb6:	c09c                	sw	a5,0(s1)
  return b;
    80002cb8:	b7d5                	j	80002c9c <bread+0xb8>

0000000080002cba <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cba:	1101                	addi	sp,sp,-32
    80002cbc:	ec06                	sd	ra,24(sp)
    80002cbe:	e822                	sd	s0,16(sp)
    80002cc0:	e426                	sd	s1,8(sp)
    80002cc2:	1000                	addi	s0,sp,32
    80002cc4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cc6:	0541                	addi	a0,a0,16
    80002cc8:	2d2010ef          	jal	80003f9a <holdingsleep>
    80002ccc:	c911                	beqz	a0,80002ce0 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cce:	4585                	li	a1,1
    80002cd0:	8526                	mv	a0,s1
    80002cd2:	2cf020ef          	jal	800057a0 <virtio_disk_rw>
}
    80002cd6:	60e2                	ld	ra,24(sp)
    80002cd8:	6442                	ld	s0,16(sp)
    80002cda:	64a2                	ld	s1,8(sp)
    80002cdc:	6105                	addi	sp,sp,32
    80002cde:	8082                	ret
    panic("bwrite");
    80002ce0:	00004517          	auipc	a0,0x4
    80002ce4:	6e050513          	addi	a0,a0,1760 # 800073c0 <etext+0x3c0>
    80002ce8:	b3dfd0ef          	jal	80000824 <panic>

0000000080002cec <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cec:	1101                	addi	sp,sp,-32
    80002cee:	ec06                	sd	ra,24(sp)
    80002cf0:	e822                	sd	s0,16(sp)
    80002cf2:	e426                	sd	s1,8(sp)
    80002cf4:	e04a                	sd	s2,0(sp)
    80002cf6:	1000                	addi	s0,sp,32
    80002cf8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cfa:	01050913          	addi	s2,a0,16
    80002cfe:	854a                	mv	a0,s2
    80002d00:	29a010ef          	jal	80003f9a <holdingsleep>
    80002d04:	c125                	beqz	a0,80002d64 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d06:	854a                	mv	a0,s2
    80002d08:	25a010ef          	jal	80003f62 <releasesleep>

  acquire(&bcache.lock);
    80002d0c:	00013517          	auipc	a0,0x13
    80002d10:	ccc50513          	addi	a0,a0,-820 # 800159d8 <bcache>
    80002d14:	f15fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002d18:	40bc                	lw	a5,64(s1)
    80002d1a:	37fd                	addiw	a5,a5,-1
    80002d1c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d1e:	e79d                	bnez	a5,80002d4c <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d20:	68b8                	ld	a4,80(s1)
    80002d22:	64bc                	ld	a5,72(s1)
    80002d24:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d26:	68b8                	ld	a4,80(s1)
    80002d28:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d2a:	0001b797          	auipc	a5,0x1b
    80002d2e:	cae78793          	addi	a5,a5,-850 # 8001d9d8 <bcache+0x8000>
    80002d32:	2b87b703          	ld	a4,696(a5)
    80002d36:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d38:	0001b717          	auipc	a4,0x1b
    80002d3c:	f0870713          	addi	a4,a4,-248 # 8001dc40 <bcache+0x8268>
    80002d40:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d42:	2b87b703          	ld	a4,696(a5)
    80002d46:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d48:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d4c:	00013517          	auipc	a0,0x13
    80002d50:	c8c50513          	addi	a0,a0,-884 # 800159d8 <bcache>
    80002d54:	f69fd0ef          	jal	80000cbc <release>
}
    80002d58:	60e2                	ld	ra,24(sp)
    80002d5a:	6442                	ld	s0,16(sp)
    80002d5c:	64a2                	ld	s1,8(sp)
    80002d5e:	6902                	ld	s2,0(sp)
    80002d60:	6105                	addi	sp,sp,32
    80002d62:	8082                	ret
    panic("brelse");
    80002d64:	00004517          	auipc	a0,0x4
    80002d68:	66450513          	addi	a0,a0,1636 # 800073c8 <etext+0x3c8>
    80002d6c:	ab9fd0ef          	jal	80000824 <panic>

0000000080002d70 <bpin>:

void
bpin(struct buf *b) {
    80002d70:	1101                	addi	sp,sp,-32
    80002d72:	ec06                	sd	ra,24(sp)
    80002d74:	e822                	sd	s0,16(sp)
    80002d76:	e426                	sd	s1,8(sp)
    80002d78:	1000                	addi	s0,sp,32
    80002d7a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d7c:	00013517          	auipc	a0,0x13
    80002d80:	c5c50513          	addi	a0,a0,-932 # 800159d8 <bcache>
    80002d84:	ea5fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002d88:	40bc                	lw	a5,64(s1)
    80002d8a:	2785                	addiw	a5,a5,1
    80002d8c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d8e:	00013517          	auipc	a0,0x13
    80002d92:	c4a50513          	addi	a0,a0,-950 # 800159d8 <bcache>
    80002d96:	f27fd0ef          	jal	80000cbc <release>
}
    80002d9a:	60e2                	ld	ra,24(sp)
    80002d9c:	6442                	ld	s0,16(sp)
    80002d9e:	64a2                	ld	s1,8(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret

0000000080002da4 <bunpin>:

void
bunpin(struct buf *b) {
    80002da4:	1101                	addi	sp,sp,-32
    80002da6:	ec06                	sd	ra,24(sp)
    80002da8:	e822                	sd	s0,16(sp)
    80002daa:	e426                	sd	s1,8(sp)
    80002dac:	1000                	addi	s0,sp,32
    80002dae:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002db0:	00013517          	auipc	a0,0x13
    80002db4:	c2850513          	addi	a0,a0,-984 # 800159d8 <bcache>
    80002db8:	e71fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002dbc:	40bc                	lw	a5,64(s1)
    80002dbe:	37fd                	addiw	a5,a5,-1
    80002dc0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dc2:	00013517          	auipc	a0,0x13
    80002dc6:	c1650513          	addi	a0,a0,-1002 # 800159d8 <bcache>
    80002dca:	ef3fd0ef          	jal	80000cbc <release>
}
    80002dce:	60e2                	ld	ra,24(sp)
    80002dd0:	6442                	ld	s0,16(sp)
    80002dd2:	64a2                	ld	s1,8(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret

0000000080002dd8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dd8:	1101                	addi	sp,sp,-32
    80002dda:	ec06                	sd	ra,24(sp)
    80002ddc:	e822                	sd	s0,16(sp)
    80002dde:	e426                	sd	s1,8(sp)
    80002de0:	e04a                	sd	s2,0(sp)
    80002de2:	1000                	addi	s0,sp,32
    80002de4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002de6:	00d5d79b          	srliw	a5,a1,0xd
    80002dea:	0001b597          	auipc	a1,0x1b
    80002dee:	2ca5a583          	lw	a1,714(a1) # 8001e0b4 <sb+0x1c>
    80002df2:	9dbd                	addw	a1,a1,a5
    80002df4:	df1ff0ef          	jal	80002be4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002df8:	0074f713          	andi	a4,s1,7
    80002dfc:	4785                	li	a5,1
    80002dfe:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e02:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002e04:	90d9                	srli	s1,s1,0x36
    80002e06:	00950733          	add	a4,a0,s1
    80002e0a:	05874703          	lbu	a4,88(a4)
    80002e0e:	00e7f6b3          	and	a3,a5,a4
    80002e12:	c29d                	beqz	a3,80002e38 <bfree+0x60>
    80002e14:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e16:	94aa                	add	s1,s1,a0
    80002e18:	fff7c793          	not	a5,a5
    80002e1c:	8f7d                	and	a4,a4,a5
    80002e1e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e22:	000010ef          	jal	80003e22 <log_write>
  brelse(bp);
    80002e26:	854a                	mv	a0,s2
    80002e28:	ec5ff0ef          	jal	80002cec <brelse>
}
    80002e2c:	60e2                	ld	ra,24(sp)
    80002e2e:	6442                	ld	s0,16(sp)
    80002e30:	64a2                	ld	s1,8(sp)
    80002e32:	6902                	ld	s2,0(sp)
    80002e34:	6105                	addi	sp,sp,32
    80002e36:	8082                	ret
    panic("freeing free block");
    80002e38:	00004517          	auipc	a0,0x4
    80002e3c:	59850513          	addi	a0,a0,1432 # 800073d0 <etext+0x3d0>
    80002e40:	9e5fd0ef          	jal	80000824 <panic>

0000000080002e44 <balloc>:
{
    80002e44:	715d                	addi	sp,sp,-80
    80002e46:	e486                	sd	ra,72(sp)
    80002e48:	e0a2                	sd	s0,64(sp)
    80002e4a:	fc26                	sd	s1,56(sp)
    80002e4c:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002e4e:	0001b797          	auipc	a5,0x1b
    80002e52:	24e7a783          	lw	a5,590(a5) # 8001e09c <sb+0x4>
    80002e56:	0e078263          	beqz	a5,80002f3a <balloc+0xf6>
    80002e5a:	f84a                	sd	s2,48(sp)
    80002e5c:	f44e                	sd	s3,40(sp)
    80002e5e:	f052                	sd	s4,32(sp)
    80002e60:	ec56                	sd	s5,24(sp)
    80002e62:	e85a                	sd	s6,16(sp)
    80002e64:	e45e                	sd	s7,8(sp)
    80002e66:	e062                	sd	s8,0(sp)
    80002e68:	8baa                	mv	s7,a0
    80002e6a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e6c:	0001bb17          	auipc	s6,0x1b
    80002e70:	22cb0b13          	addi	s6,s6,556 # 8001e098 <sb>
      m = 1 << (bi % 8);
    80002e74:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e76:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e78:	6c09                	lui	s8,0x2
    80002e7a:	a09d                	j	80002ee0 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e7c:	97ca                	add	a5,a5,s2
    80002e7e:	8e55                	or	a2,a2,a3
    80002e80:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e84:	854a                	mv	a0,s2
    80002e86:	79d000ef          	jal	80003e22 <log_write>
        brelse(bp);
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	e61ff0ef          	jal	80002cec <brelse>
  bp = bread(dev, bno);
    80002e90:	85a6                	mv	a1,s1
    80002e92:	855e                	mv	a0,s7
    80002e94:	d51ff0ef          	jal	80002be4 <bread>
    80002e98:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e9a:	40000613          	li	a2,1024
    80002e9e:	4581                	li	a1,0
    80002ea0:	05850513          	addi	a0,a0,88
    80002ea4:	e55fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    80002ea8:	854a                	mv	a0,s2
    80002eaa:	779000ef          	jal	80003e22 <log_write>
  brelse(bp);
    80002eae:	854a                	mv	a0,s2
    80002eb0:	e3dff0ef          	jal	80002cec <brelse>
}
    80002eb4:	7942                	ld	s2,48(sp)
    80002eb6:	79a2                	ld	s3,40(sp)
    80002eb8:	7a02                	ld	s4,32(sp)
    80002eba:	6ae2                	ld	s5,24(sp)
    80002ebc:	6b42                	ld	s6,16(sp)
    80002ebe:	6ba2                	ld	s7,8(sp)
    80002ec0:	6c02                	ld	s8,0(sp)
}
    80002ec2:	8526                	mv	a0,s1
    80002ec4:	60a6                	ld	ra,72(sp)
    80002ec6:	6406                	ld	s0,64(sp)
    80002ec8:	74e2                	ld	s1,56(sp)
    80002eca:	6161                	addi	sp,sp,80
    80002ecc:	8082                	ret
    brelse(bp);
    80002ece:	854a                	mv	a0,s2
    80002ed0:	e1dff0ef          	jal	80002cec <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ed4:	015c0abb          	addw	s5,s8,s5
    80002ed8:	004b2783          	lw	a5,4(s6)
    80002edc:	04faf863          	bgeu	s5,a5,80002f2c <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002ee0:	40dad59b          	sraiw	a1,s5,0xd
    80002ee4:	01cb2783          	lw	a5,28(s6)
    80002ee8:	9dbd                	addw	a1,a1,a5
    80002eea:	855e                	mv	a0,s7
    80002eec:	cf9ff0ef          	jal	80002be4 <bread>
    80002ef0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ef2:	004b2503          	lw	a0,4(s6)
    80002ef6:	84d6                	mv	s1,s5
    80002ef8:	4701                	li	a4,0
    80002efa:	fca4fae3          	bgeu	s1,a0,80002ece <balloc+0x8a>
      m = 1 << (bi % 8);
    80002efe:	00777693          	andi	a3,a4,7
    80002f02:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f06:	41f7579b          	sraiw	a5,a4,0x1f
    80002f0a:	01d7d79b          	srliw	a5,a5,0x1d
    80002f0e:	9fb9                	addw	a5,a5,a4
    80002f10:	4037d79b          	sraiw	a5,a5,0x3
    80002f14:	00f90633          	add	a2,s2,a5
    80002f18:	05864603          	lbu	a2,88(a2)
    80002f1c:	00c6f5b3          	and	a1,a3,a2
    80002f20:	ddb1                	beqz	a1,80002e7c <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f22:	2705                	addiw	a4,a4,1
    80002f24:	2485                	addiw	s1,s1,1
    80002f26:	fd471ae3          	bne	a4,s4,80002efa <balloc+0xb6>
    80002f2a:	b755                	j	80002ece <balloc+0x8a>
    80002f2c:	7942                	ld	s2,48(sp)
    80002f2e:	79a2                	ld	s3,40(sp)
    80002f30:	7a02                	ld	s4,32(sp)
    80002f32:	6ae2                	ld	s5,24(sp)
    80002f34:	6b42                	ld	s6,16(sp)
    80002f36:	6ba2                	ld	s7,8(sp)
    80002f38:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f3a:	00004517          	auipc	a0,0x4
    80002f3e:	4ae50513          	addi	a0,a0,1198 # 800073e8 <etext+0x3e8>
    80002f42:	db8fd0ef          	jal	800004fa <printf>
  return 0;
    80002f46:	4481                	li	s1,0
    80002f48:	bfad                	j	80002ec2 <balloc+0x7e>

0000000080002f4a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f4a:	7179                	addi	sp,sp,-48
    80002f4c:	f406                	sd	ra,40(sp)
    80002f4e:	f022                	sd	s0,32(sp)
    80002f50:	ec26                	sd	s1,24(sp)
    80002f52:	e84a                	sd	s2,16(sp)
    80002f54:	e44e                	sd	s3,8(sp)
    80002f56:	1800                	addi	s0,sp,48
    80002f58:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f5a:	47ad                	li	a5,11
    80002f5c:	02b7e363          	bltu	a5,a1,80002f82 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002f60:	02059793          	slli	a5,a1,0x20
    80002f64:	01e7d593          	srli	a1,a5,0x1e
    80002f68:	00b509b3          	add	s3,a0,a1
    80002f6c:	0509a483          	lw	s1,80(s3)
    80002f70:	e0b5                	bnez	s1,80002fd4 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f72:	4108                	lw	a0,0(a0)
    80002f74:	ed1ff0ef          	jal	80002e44 <balloc>
    80002f78:	84aa                	mv	s1,a0
      if(addr == 0)
    80002f7a:	cd29                	beqz	a0,80002fd4 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f7c:	04a9a823          	sw	a0,80(s3)
    80002f80:	a891                	j	80002fd4 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f82:	ff45879b          	addiw	a5,a1,-12
    80002f86:	873e                	mv	a4,a5
    80002f88:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80002f8a:	0ff00793          	li	a5,255
    80002f8e:	06e7e763          	bltu	a5,a4,80002ffc <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f92:	08052483          	lw	s1,128(a0)
    80002f96:	e891                	bnez	s1,80002faa <bmap+0x60>
      addr = balloc(ip->dev);
    80002f98:	4108                	lw	a0,0(a0)
    80002f9a:	eabff0ef          	jal	80002e44 <balloc>
    80002f9e:	84aa                	mv	s1,a0
      if(addr == 0)
    80002fa0:	c915                	beqz	a0,80002fd4 <bmap+0x8a>
    80002fa2:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fa4:	08a92023          	sw	a0,128(s2)
    80002fa8:	a011                	j	80002fac <bmap+0x62>
    80002faa:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fac:	85a6                	mv	a1,s1
    80002fae:	00092503          	lw	a0,0(s2)
    80002fb2:	c33ff0ef          	jal	80002be4 <bread>
    80002fb6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fb8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fbc:	02099713          	slli	a4,s3,0x20
    80002fc0:	01e75593          	srli	a1,a4,0x1e
    80002fc4:	97ae                	add	a5,a5,a1
    80002fc6:	89be                	mv	s3,a5
    80002fc8:	4384                	lw	s1,0(a5)
    80002fca:	cc89                	beqz	s1,80002fe4 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fcc:	8552                	mv	a0,s4
    80002fce:	d1fff0ef          	jal	80002cec <brelse>
    return addr;
    80002fd2:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fd4:	8526                	mv	a0,s1
    80002fd6:	70a2                	ld	ra,40(sp)
    80002fd8:	7402                	ld	s0,32(sp)
    80002fda:	64e2                	ld	s1,24(sp)
    80002fdc:	6942                	ld	s2,16(sp)
    80002fde:	69a2                	ld	s3,8(sp)
    80002fe0:	6145                	addi	sp,sp,48
    80002fe2:	8082                	ret
      addr = balloc(ip->dev);
    80002fe4:	00092503          	lw	a0,0(s2)
    80002fe8:	e5dff0ef          	jal	80002e44 <balloc>
    80002fec:	84aa                	mv	s1,a0
      if(addr){
    80002fee:	dd79                	beqz	a0,80002fcc <bmap+0x82>
        a[bn] = addr;
    80002ff0:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002ff4:	8552                	mv	a0,s4
    80002ff6:	62d000ef          	jal	80003e22 <log_write>
    80002ffa:	bfc9                	j	80002fcc <bmap+0x82>
    80002ffc:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002ffe:	00004517          	auipc	a0,0x4
    80003002:	40250513          	addi	a0,a0,1026 # 80007400 <etext+0x400>
    80003006:	81ffd0ef          	jal	80000824 <panic>

000000008000300a <iget>:
{
    8000300a:	7179                	addi	sp,sp,-48
    8000300c:	f406                	sd	ra,40(sp)
    8000300e:	f022                	sd	s0,32(sp)
    80003010:	ec26                	sd	s1,24(sp)
    80003012:	e84a                	sd	s2,16(sp)
    80003014:	e44e                	sd	s3,8(sp)
    80003016:	e052                	sd	s4,0(sp)
    80003018:	1800                	addi	s0,sp,48
    8000301a:	892a                	mv	s2,a0
    8000301c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000301e:	0001b517          	auipc	a0,0x1b
    80003022:	09a50513          	addi	a0,a0,154 # 8001e0b8 <itable>
    80003026:	c03fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000302a:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000302c:	0001b497          	auipc	s1,0x1b
    80003030:	0a448493          	addi	s1,s1,164 # 8001e0d0 <itable+0x18>
    80003034:	0001d697          	auipc	a3,0x1d
    80003038:	b2c68693          	addi	a3,a3,-1236 # 8001fb60 <log>
    8000303c:	a809                	j	8000304e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000303e:	e781                	bnez	a5,80003046 <iget+0x3c>
    80003040:	00099363          	bnez	s3,80003046 <iget+0x3c>
      empty = ip;
    80003044:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003046:	08848493          	addi	s1,s1,136
    8000304a:	02d48563          	beq	s1,a3,80003074 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000304e:	449c                	lw	a5,8(s1)
    80003050:	fef057e3          	blez	a5,8000303e <iget+0x34>
    80003054:	4098                	lw	a4,0(s1)
    80003056:	ff2718e3          	bne	a4,s2,80003046 <iget+0x3c>
    8000305a:	40d8                	lw	a4,4(s1)
    8000305c:	ff4715e3          	bne	a4,s4,80003046 <iget+0x3c>
      ip->ref++;
    80003060:	2785                	addiw	a5,a5,1
    80003062:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003064:	0001b517          	auipc	a0,0x1b
    80003068:	05450513          	addi	a0,a0,84 # 8001e0b8 <itable>
    8000306c:	c51fd0ef          	jal	80000cbc <release>
      return ip;
    80003070:	89a6                	mv	s3,s1
    80003072:	a015                	j	80003096 <iget+0x8c>
  if(empty == 0)
    80003074:	02098a63          	beqz	s3,800030a8 <iget+0x9e>
  ip->dev = dev;
    80003078:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000307c:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003080:	4785                	li	a5,1
    80003082:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003086:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000308a:	0001b517          	auipc	a0,0x1b
    8000308e:	02e50513          	addi	a0,a0,46 # 8001e0b8 <itable>
    80003092:	c2bfd0ef          	jal	80000cbc <release>
}
    80003096:	854e                	mv	a0,s3
    80003098:	70a2                	ld	ra,40(sp)
    8000309a:	7402                	ld	s0,32(sp)
    8000309c:	64e2                	ld	s1,24(sp)
    8000309e:	6942                	ld	s2,16(sp)
    800030a0:	69a2                	ld	s3,8(sp)
    800030a2:	6a02                	ld	s4,0(sp)
    800030a4:	6145                	addi	sp,sp,48
    800030a6:	8082                	ret
    panic("iget: no inodes");
    800030a8:	00004517          	auipc	a0,0x4
    800030ac:	37050513          	addi	a0,a0,880 # 80007418 <etext+0x418>
    800030b0:	f74fd0ef          	jal	80000824 <panic>

00000000800030b4 <iinit>:
{
    800030b4:	7179                	addi	sp,sp,-48
    800030b6:	f406                	sd	ra,40(sp)
    800030b8:	f022                	sd	s0,32(sp)
    800030ba:	ec26                	sd	s1,24(sp)
    800030bc:	e84a                	sd	s2,16(sp)
    800030be:	e44e                	sd	s3,8(sp)
    800030c0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030c2:	00004597          	auipc	a1,0x4
    800030c6:	36658593          	addi	a1,a1,870 # 80007428 <etext+0x428>
    800030ca:	0001b517          	auipc	a0,0x1b
    800030ce:	fee50513          	addi	a0,a0,-18 # 8001e0b8 <itable>
    800030d2:	acdfd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    800030d6:	0001b497          	auipc	s1,0x1b
    800030da:	00a48493          	addi	s1,s1,10 # 8001e0e0 <itable+0x28>
    800030de:	0001d997          	auipc	s3,0x1d
    800030e2:	a9298993          	addi	s3,s3,-1390 # 8001fb70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030e6:	00004917          	auipc	s2,0x4
    800030ea:	34a90913          	addi	s2,s2,842 # 80007430 <etext+0x430>
    800030ee:	85ca                	mv	a1,s2
    800030f0:	8526                	mv	a0,s1
    800030f2:	5f5000ef          	jal	80003ee6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800030f6:	08848493          	addi	s1,s1,136
    800030fa:	ff349ae3          	bne	s1,s3,800030ee <iinit+0x3a>
}
    800030fe:	70a2                	ld	ra,40(sp)
    80003100:	7402                	ld	s0,32(sp)
    80003102:	64e2                	ld	s1,24(sp)
    80003104:	6942                	ld	s2,16(sp)
    80003106:	69a2                	ld	s3,8(sp)
    80003108:	6145                	addi	sp,sp,48
    8000310a:	8082                	ret

000000008000310c <ialloc>:
{
    8000310c:	7139                	addi	sp,sp,-64
    8000310e:	fc06                	sd	ra,56(sp)
    80003110:	f822                	sd	s0,48(sp)
    80003112:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003114:	0001b717          	auipc	a4,0x1b
    80003118:	f9072703          	lw	a4,-112(a4) # 8001e0a4 <sb+0xc>
    8000311c:	4785                	li	a5,1
    8000311e:	06e7f063          	bgeu	a5,a4,8000317e <ialloc+0x72>
    80003122:	f426                	sd	s1,40(sp)
    80003124:	f04a                	sd	s2,32(sp)
    80003126:	ec4e                	sd	s3,24(sp)
    80003128:	e852                	sd	s4,16(sp)
    8000312a:	e456                	sd	s5,8(sp)
    8000312c:	e05a                	sd	s6,0(sp)
    8000312e:	8aaa                	mv	s5,a0
    80003130:	8b2e                	mv	s6,a1
    80003132:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003134:	0001ba17          	auipc	s4,0x1b
    80003138:	f64a0a13          	addi	s4,s4,-156 # 8001e098 <sb>
    8000313c:	00495593          	srli	a1,s2,0x4
    80003140:	018a2783          	lw	a5,24(s4)
    80003144:	9dbd                	addw	a1,a1,a5
    80003146:	8556                	mv	a0,s5
    80003148:	a9dff0ef          	jal	80002be4 <bread>
    8000314c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000314e:	05850993          	addi	s3,a0,88
    80003152:	00f97793          	andi	a5,s2,15
    80003156:	079a                	slli	a5,a5,0x6
    80003158:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000315a:	00099783          	lh	a5,0(s3)
    8000315e:	cb9d                	beqz	a5,80003194 <ialloc+0x88>
    brelse(bp);
    80003160:	b8dff0ef          	jal	80002cec <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003164:	0905                	addi	s2,s2,1
    80003166:	00ca2703          	lw	a4,12(s4)
    8000316a:	0009079b          	sext.w	a5,s2
    8000316e:	fce7e7e3          	bltu	a5,a4,8000313c <ialloc+0x30>
    80003172:	74a2                	ld	s1,40(sp)
    80003174:	7902                	ld	s2,32(sp)
    80003176:	69e2                	ld	s3,24(sp)
    80003178:	6a42                	ld	s4,16(sp)
    8000317a:	6aa2                	ld	s5,8(sp)
    8000317c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000317e:	00004517          	auipc	a0,0x4
    80003182:	2ba50513          	addi	a0,a0,698 # 80007438 <etext+0x438>
    80003186:	b74fd0ef          	jal	800004fa <printf>
  return 0;
    8000318a:	4501                	li	a0,0
}
    8000318c:	70e2                	ld	ra,56(sp)
    8000318e:	7442                	ld	s0,48(sp)
    80003190:	6121                	addi	sp,sp,64
    80003192:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003194:	04000613          	li	a2,64
    80003198:	4581                	li	a1,0
    8000319a:	854e                	mv	a0,s3
    8000319c:	b5dfd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    800031a0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031a4:	8526                	mv	a0,s1
    800031a6:	47d000ef          	jal	80003e22 <log_write>
      brelse(bp);
    800031aa:	8526                	mv	a0,s1
    800031ac:	b41ff0ef          	jal	80002cec <brelse>
      return iget(dev, inum);
    800031b0:	0009059b          	sext.w	a1,s2
    800031b4:	8556                	mv	a0,s5
    800031b6:	e55ff0ef          	jal	8000300a <iget>
    800031ba:	74a2                	ld	s1,40(sp)
    800031bc:	7902                	ld	s2,32(sp)
    800031be:	69e2                	ld	s3,24(sp)
    800031c0:	6a42                	ld	s4,16(sp)
    800031c2:	6aa2                	ld	s5,8(sp)
    800031c4:	6b02                	ld	s6,0(sp)
    800031c6:	b7d9                	j	8000318c <ialloc+0x80>

00000000800031c8 <iupdate>:
{
    800031c8:	1101                	addi	sp,sp,-32
    800031ca:	ec06                	sd	ra,24(sp)
    800031cc:	e822                	sd	s0,16(sp)
    800031ce:	e426                	sd	s1,8(sp)
    800031d0:	e04a                	sd	s2,0(sp)
    800031d2:	1000                	addi	s0,sp,32
    800031d4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031d6:	415c                	lw	a5,4(a0)
    800031d8:	0047d79b          	srliw	a5,a5,0x4
    800031dc:	0001b597          	auipc	a1,0x1b
    800031e0:	ed45a583          	lw	a1,-300(a1) # 8001e0b0 <sb+0x18>
    800031e4:	9dbd                	addw	a1,a1,a5
    800031e6:	4108                	lw	a0,0(a0)
    800031e8:	9fdff0ef          	jal	80002be4 <bread>
    800031ec:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800031ee:	05850793          	addi	a5,a0,88
    800031f2:	40d8                	lw	a4,4(s1)
    800031f4:	8b3d                	andi	a4,a4,15
    800031f6:	071a                	slli	a4,a4,0x6
    800031f8:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031fa:	04449703          	lh	a4,68(s1)
    800031fe:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003202:	04649703          	lh	a4,70(s1)
    80003206:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000320a:	04849703          	lh	a4,72(s1)
    8000320e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003212:	04a49703          	lh	a4,74(s1)
    80003216:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000321a:	44f8                	lw	a4,76(s1)
    8000321c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000321e:	03400613          	li	a2,52
    80003222:	05048593          	addi	a1,s1,80
    80003226:	00c78513          	addi	a0,a5,12
    8000322a:	b2ffd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    8000322e:	854a                	mv	a0,s2
    80003230:	3f3000ef          	jal	80003e22 <log_write>
  brelse(bp);
    80003234:	854a                	mv	a0,s2
    80003236:	ab7ff0ef          	jal	80002cec <brelse>
}
    8000323a:	60e2                	ld	ra,24(sp)
    8000323c:	6442                	ld	s0,16(sp)
    8000323e:	64a2                	ld	s1,8(sp)
    80003240:	6902                	ld	s2,0(sp)
    80003242:	6105                	addi	sp,sp,32
    80003244:	8082                	ret

0000000080003246 <idup>:
{
    80003246:	1101                	addi	sp,sp,-32
    80003248:	ec06                	sd	ra,24(sp)
    8000324a:	e822                	sd	s0,16(sp)
    8000324c:	e426                	sd	s1,8(sp)
    8000324e:	1000                	addi	s0,sp,32
    80003250:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003252:	0001b517          	auipc	a0,0x1b
    80003256:	e6650513          	addi	a0,a0,-410 # 8001e0b8 <itable>
    8000325a:	9cffd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000325e:	449c                	lw	a5,8(s1)
    80003260:	2785                	addiw	a5,a5,1
    80003262:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003264:	0001b517          	auipc	a0,0x1b
    80003268:	e5450513          	addi	a0,a0,-428 # 8001e0b8 <itable>
    8000326c:	a51fd0ef          	jal	80000cbc <release>
}
    80003270:	8526                	mv	a0,s1
    80003272:	60e2                	ld	ra,24(sp)
    80003274:	6442                	ld	s0,16(sp)
    80003276:	64a2                	ld	s1,8(sp)
    80003278:	6105                	addi	sp,sp,32
    8000327a:	8082                	ret

000000008000327c <ilock>:
{
    8000327c:	1101                	addi	sp,sp,-32
    8000327e:	ec06                	sd	ra,24(sp)
    80003280:	e822                	sd	s0,16(sp)
    80003282:	e426                	sd	s1,8(sp)
    80003284:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003286:	cd19                	beqz	a0,800032a4 <ilock+0x28>
    80003288:	84aa                	mv	s1,a0
    8000328a:	451c                	lw	a5,8(a0)
    8000328c:	00f05c63          	blez	a5,800032a4 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003290:	0541                	addi	a0,a0,16
    80003292:	48b000ef          	jal	80003f1c <acquiresleep>
  if(ip->valid == 0){
    80003296:	40bc                	lw	a5,64(s1)
    80003298:	cf89                	beqz	a5,800032b2 <ilock+0x36>
}
    8000329a:	60e2                	ld	ra,24(sp)
    8000329c:	6442                	ld	s0,16(sp)
    8000329e:	64a2                	ld	s1,8(sp)
    800032a0:	6105                	addi	sp,sp,32
    800032a2:	8082                	ret
    800032a4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032a6:	00004517          	auipc	a0,0x4
    800032aa:	1aa50513          	addi	a0,a0,426 # 80007450 <etext+0x450>
    800032ae:	d76fd0ef          	jal	80000824 <panic>
    800032b2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032b4:	40dc                	lw	a5,4(s1)
    800032b6:	0047d79b          	srliw	a5,a5,0x4
    800032ba:	0001b597          	auipc	a1,0x1b
    800032be:	df65a583          	lw	a1,-522(a1) # 8001e0b0 <sb+0x18>
    800032c2:	9dbd                	addw	a1,a1,a5
    800032c4:	4088                	lw	a0,0(s1)
    800032c6:	91fff0ef          	jal	80002be4 <bread>
    800032ca:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032cc:	05850593          	addi	a1,a0,88
    800032d0:	40dc                	lw	a5,4(s1)
    800032d2:	8bbd                	andi	a5,a5,15
    800032d4:	079a                	slli	a5,a5,0x6
    800032d6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032d8:	00059783          	lh	a5,0(a1)
    800032dc:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032e0:	00259783          	lh	a5,2(a1)
    800032e4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032e8:	00459783          	lh	a5,4(a1)
    800032ec:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032f0:	00659783          	lh	a5,6(a1)
    800032f4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032f8:	459c                	lw	a5,8(a1)
    800032fa:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032fc:	03400613          	li	a2,52
    80003300:	05b1                	addi	a1,a1,12
    80003302:	05048513          	addi	a0,s1,80
    80003306:	a53fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    8000330a:	854a                	mv	a0,s2
    8000330c:	9e1ff0ef          	jal	80002cec <brelse>
    ip->valid = 1;
    80003310:	4785                	li	a5,1
    80003312:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003314:	04449783          	lh	a5,68(s1)
    80003318:	c399                	beqz	a5,8000331e <ilock+0xa2>
    8000331a:	6902                	ld	s2,0(sp)
    8000331c:	bfbd                	j	8000329a <ilock+0x1e>
      panic("ilock: no type");
    8000331e:	00004517          	auipc	a0,0x4
    80003322:	13a50513          	addi	a0,a0,314 # 80007458 <etext+0x458>
    80003326:	cfefd0ef          	jal	80000824 <panic>

000000008000332a <iunlock>:
{
    8000332a:	1101                	addi	sp,sp,-32
    8000332c:	ec06                	sd	ra,24(sp)
    8000332e:	e822                	sd	s0,16(sp)
    80003330:	e426                	sd	s1,8(sp)
    80003332:	e04a                	sd	s2,0(sp)
    80003334:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003336:	c505                	beqz	a0,8000335e <iunlock+0x34>
    80003338:	84aa                	mv	s1,a0
    8000333a:	01050913          	addi	s2,a0,16
    8000333e:	854a                	mv	a0,s2
    80003340:	45b000ef          	jal	80003f9a <holdingsleep>
    80003344:	cd09                	beqz	a0,8000335e <iunlock+0x34>
    80003346:	449c                	lw	a5,8(s1)
    80003348:	00f05b63          	blez	a5,8000335e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000334c:	854a                	mv	a0,s2
    8000334e:	415000ef          	jal	80003f62 <releasesleep>
}
    80003352:	60e2                	ld	ra,24(sp)
    80003354:	6442                	ld	s0,16(sp)
    80003356:	64a2                	ld	s1,8(sp)
    80003358:	6902                	ld	s2,0(sp)
    8000335a:	6105                	addi	sp,sp,32
    8000335c:	8082                	ret
    panic("iunlock");
    8000335e:	00004517          	auipc	a0,0x4
    80003362:	10a50513          	addi	a0,a0,266 # 80007468 <etext+0x468>
    80003366:	cbefd0ef          	jal	80000824 <panic>

000000008000336a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000336a:	7179                	addi	sp,sp,-48
    8000336c:	f406                	sd	ra,40(sp)
    8000336e:	f022                	sd	s0,32(sp)
    80003370:	ec26                	sd	s1,24(sp)
    80003372:	e84a                	sd	s2,16(sp)
    80003374:	e44e                	sd	s3,8(sp)
    80003376:	1800                	addi	s0,sp,48
    80003378:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000337a:	05050493          	addi	s1,a0,80
    8000337e:	08050913          	addi	s2,a0,128
    80003382:	a021                	j	8000338a <itrunc+0x20>
    80003384:	0491                	addi	s1,s1,4
    80003386:	01248b63          	beq	s1,s2,8000339c <itrunc+0x32>
    if(ip->addrs[i]){
    8000338a:	408c                	lw	a1,0(s1)
    8000338c:	dde5                	beqz	a1,80003384 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000338e:	0009a503          	lw	a0,0(s3)
    80003392:	a47ff0ef          	jal	80002dd8 <bfree>
      ip->addrs[i] = 0;
    80003396:	0004a023          	sw	zero,0(s1)
    8000339a:	b7ed                	j	80003384 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000339c:	0809a583          	lw	a1,128(s3)
    800033a0:	ed89                	bnez	a1,800033ba <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033a2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033a6:	854e                	mv	a0,s3
    800033a8:	e21ff0ef          	jal	800031c8 <iupdate>
}
    800033ac:	70a2                	ld	ra,40(sp)
    800033ae:	7402                	ld	s0,32(sp)
    800033b0:	64e2                	ld	s1,24(sp)
    800033b2:	6942                	ld	s2,16(sp)
    800033b4:	69a2                	ld	s3,8(sp)
    800033b6:	6145                	addi	sp,sp,48
    800033b8:	8082                	ret
    800033ba:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033bc:	0009a503          	lw	a0,0(s3)
    800033c0:	825ff0ef          	jal	80002be4 <bread>
    800033c4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800033c6:	05850493          	addi	s1,a0,88
    800033ca:	45850913          	addi	s2,a0,1112
    800033ce:	a021                	j	800033d6 <itrunc+0x6c>
    800033d0:	0491                	addi	s1,s1,4
    800033d2:	01248963          	beq	s1,s2,800033e4 <itrunc+0x7a>
      if(a[j])
    800033d6:	408c                	lw	a1,0(s1)
    800033d8:	dde5                	beqz	a1,800033d0 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033da:	0009a503          	lw	a0,0(s3)
    800033de:	9fbff0ef          	jal	80002dd8 <bfree>
    800033e2:	b7fd                	j	800033d0 <itrunc+0x66>
    brelse(bp);
    800033e4:	8552                	mv	a0,s4
    800033e6:	907ff0ef          	jal	80002cec <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033ea:	0809a583          	lw	a1,128(s3)
    800033ee:	0009a503          	lw	a0,0(s3)
    800033f2:	9e7ff0ef          	jal	80002dd8 <bfree>
    ip->addrs[NDIRECT] = 0;
    800033f6:	0809a023          	sw	zero,128(s3)
    800033fa:	6a02                	ld	s4,0(sp)
    800033fc:	b75d                	j	800033a2 <itrunc+0x38>

00000000800033fe <iput>:
{
    800033fe:	1101                	addi	sp,sp,-32
    80003400:	ec06                	sd	ra,24(sp)
    80003402:	e822                	sd	s0,16(sp)
    80003404:	e426                	sd	s1,8(sp)
    80003406:	1000                	addi	s0,sp,32
    80003408:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000340a:	0001b517          	auipc	a0,0x1b
    8000340e:	cae50513          	addi	a0,a0,-850 # 8001e0b8 <itable>
    80003412:	817fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003416:	4498                	lw	a4,8(s1)
    80003418:	4785                	li	a5,1
    8000341a:	02f70063          	beq	a4,a5,8000343a <iput+0x3c>
  ip->ref--;
    8000341e:	449c                	lw	a5,8(s1)
    80003420:	37fd                	addiw	a5,a5,-1
    80003422:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003424:	0001b517          	auipc	a0,0x1b
    80003428:	c9450513          	addi	a0,a0,-876 # 8001e0b8 <itable>
    8000342c:	891fd0ef          	jal	80000cbc <release>
}
    80003430:	60e2                	ld	ra,24(sp)
    80003432:	6442                	ld	s0,16(sp)
    80003434:	64a2                	ld	s1,8(sp)
    80003436:	6105                	addi	sp,sp,32
    80003438:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000343a:	40bc                	lw	a5,64(s1)
    8000343c:	d3ed                	beqz	a5,8000341e <iput+0x20>
    8000343e:	04a49783          	lh	a5,74(s1)
    80003442:	fff1                	bnez	a5,8000341e <iput+0x20>
    80003444:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003446:	01048793          	addi	a5,s1,16
    8000344a:	893e                	mv	s2,a5
    8000344c:	853e                	mv	a0,a5
    8000344e:	2cf000ef          	jal	80003f1c <acquiresleep>
    release(&itable.lock);
    80003452:	0001b517          	auipc	a0,0x1b
    80003456:	c6650513          	addi	a0,a0,-922 # 8001e0b8 <itable>
    8000345a:	863fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    8000345e:	8526                	mv	a0,s1
    80003460:	f0bff0ef          	jal	8000336a <itrunc>
    ip->type = 0;
    80003464:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003468:	8526                	mv	a0,s1
    8000346a:	d5fff0ef          	jal	800031c8 <iupdate>
    ip->valid = 0;
    8000346e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003472:	854a                	mv	a0,s2
    80003474:	2ef000ef          	jal	80003f62 <releasesleep>
    acquire(&itable.lock);
    80003478:	0001b517          	auipc	a0,0x1b
    8000347c:	c4050513          	addi	a0,a0,-960 # 8001e0b8 <itable>
    80003480:	fa8fd0ef          	jal	80000c28 <acquire>
    80003484:	6902                	ld	s2,0(sp)
    80003486:	bf61                	j	8000341e <iput+0x20>

0000000080003488 <iunlockput>:
{
    80003488:	1101                	addi	sp,sp,-32
    8000348a:	ec06                	sd	ra,24(sp)
    8000348c:	e822                	sd	s0,16(sp)
    8000348e:	e426                	sd	s1,8(sp)
    80003490:	1000                	addi	s0,sp,32
    80003492:	84aa                	mv	s1,a0
  iunlock(ip);
    80003494:	e97ff0ef          	jal	8000332a <iunlock>
  iput(ip);
    80003498:	8526                	mv	a0,s1
    8000349a:	f65ff0ef          	jal	800033fe <iput>
}
    8000349e:	60e2                	ld	ra,24(sp)
    800034a0:	6442                	ld	s0,16(sp)
    800034a2:	64a2                	ld	s1,8(sp)
    800034a4:	6105                	addi	sp,sp,32
    800034a6:	8082                	ret

00000000800034a8 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034a8:	0001b717          	auipc	a4,0x1b
    800034ac:	bfc72703          	lw	a4,-1028(a4) # 8001e0a4 <sb+0xc>
    800034b0:	4785                	li	a5,1
    800034b2:	0ae7fe63          	bgeu	a5,a4,8000356e <ireclaim+0xc6>
{
    800034b6:	7139                	addi	sp,sp,-64
    800034b8:	fc06                	sd	ra,56(sp)
    800034ba:	f822                	sd	s0,48(sp)
    800034bc:	f426                	sd	s1,40(sp)
    800034be:	f04a                	sd	s2,32(sp)
    800034c0:	ec4e                	sd	s3,24(sp)
    800034c2:	e852                	sd	s4,16(sp)
    800034c4:	e456                	sd	s5,8(sp)
    800034c6:	e05a                	sd	s6,0(sp)
    800034c8:	0080                	addi	s0,sp,64
    800034ca:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034cc:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034ce:	0001ba17          	auipc	s4,0x1b
    800034d2:	bcaa0a13          	addi	s4,s4,-1078 # 8001e098 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800034d6:	00004b17          	auipc	s6,0x4
    800034da:	f9ab0b13          	addi	s6,s6,-102 # 80007470 <etext+0x470>
    800034de:	a099                	j	80003524 <ireclaim+0x7c>
    800034e0:	85ce                	mv	a1,s3
    800034e2:	855a                	mv	a0,s6
    800034e4:	816fd0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800034e8:	85ce                	mv	a1,s3
    800034ea:	8556                	mv	a0,s5
    800034ec:	b1fff0ef          	jal	8000300a <iget>
    800034f0:	89aa                	mv	s3,a0
    brelse(bp);
    800034f2:	854a                	mv	a0,s2
    800034f4:	ff8ff0ef          	jal	80002cec <brelse>
    if (ip) {
    800034f8:	00098f63          	beqz	s3,80003516 <ireclaim+0x6e>
      begin_op();
    800034fc:	78c000ef          	jal	80003c88 <begin_op>
      ilock(ip);
    80003500:	854e                	mv	a0,s3
    80003502:	d7bff0ef          	jal	8000327c <ilock>
      iunlock(ip);
    80003506:	854e                	mv	a0,s3
    80003508:	e23ff0ef          	jal	8000332a <iunlock>
      iput(ip);
    8000350c:	854e                	mv	a0,s3
    8000350e:	ef1ff0ef          	jal	800033fe <iput>
      end_op();
    80003512:	7e6000ef          	jal	80003cf8 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003516:	0485                	addi	s1,s1,1
    80003518:	00ca2703          	lw	a4,12(s4)
    8000351c:	0004879b          	sext.w	a5,s1
    80003520:	02e7fd63          	bgeu	a5,a4,8000355a <ireclaim+0xb2>
    80003524:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003528:	0044d593          	srli	a1,s1,0x4
    8000352c:	018a2783          	lw	a5,24(s4)
    80003530:	9dbd                	addw	a1,a1,a5
    80003532:	8556                	mv	a0,s5
    80003534:	eb0ff0ef          	jal	80002be4 <bread>
    80003538:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000353a:	05850793          	addi	a5,a0,88
    8000353e:	00f9f713          	andi	a4,s3,15
    80003542:	071a                	slli	a4,a4,0x6
    80003544:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003546:	00079703          	lh	a4,0(a5)
    8000354a:	c701                	beqz	a4,80003552 <ireclaim+0xaa>
    8000354c:	00679783          	lh	a5,6(a5)
    80003550:	dbc1                	beqz	a5,800034e0 <ireclaim+0x38>
    brelse(bp);
    80003552:	854a                	mv	a0,s2
    80003554:	f98ff0ef          	jal	80002cec <brelse>
    if (ip) {
    80003558:	bf7d                	j	80003516 <ireclaim+0x6e>
}
    8000355a:	70e2                	ld	ra,56(sp)
    8000355c:	7442                	ld	s0,48(sp)
    8000355e:	74a2                	ld	s1,40(sp)
    80003560:	7902                	ld	s2,32(sp)
    80003562:	69e2                	ld	s3,24(sp)
    80003564:	6a42                	ld	s4,16(sp)
    80003566:	6aa2                	ld	s5,8(sp)
    80003568:	6b02                	ld	s6,0(sp)
    8000356a:	6121                	addi	sp,sp,64
    8000356c:	8082                	ret
    8000356e:	8082                	ret

0000000080003570 <fsinit>:
fsinit(int dev) {
    80003570:	1101                	addi	sp,sp,-32
    80003572:	ec06                	sd	ra,24(sp)
    80003574:	e822                	sd	s0,16(sp)
    80003576:	e426                	sd	s1,8(sp)
    80003578:	e04a                	sd	s2,0(sp)
    8000357a:	1000                	addi	s0,sp,32
    8000357c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000357e:	4585                	li	a1,1
    80003580:	e64ff0ef          	jal	80002be4 <bread>
    80003584:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003586:	02000613          	li	a2,32
    8000358a:	05850593          	addi	a1,a0,88
    8000358e:	0001b517          	auipc	a0,0x1b
    80003592:	b0a50513          	addi	a0,a0,-1270 # 8001e098 <sb>
    80003596:	fc2fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    8000359a:	8526                	mv	a0,s1
    8000359c:	f50ff0ef          	jal	80002cec <brelse>
  if(sb.magic != FSMAGIC)
    800035a0:	0001b717          	auipc	a4,0x1b
    800035a4:	af872703          	lw	a4,-1288(a4) # 8001e098 <sb>
    800035a8:	102037b7          	lui	a5,0x10203
    800035ac:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035b0:	02f71263          	bne	a4,a5,800035d4 <fsinit+0x64>
  initlog(dev, &sb);
    800035b4:	0001b597          	auipc	a1,0x1b
    800035b8:	ae458593          	addi	a1,a1,-1308 # 8001e098 <sb>
    800035bc:	854a                	mv	a0,s2
    800035be:	648000ef          	jal	80003c06 <initlog>
  ireclaim(dev);
    800035c2:	854a                	mv	a0,s2
    800035c4:	ee5ff0ef          	jal	800034a8 <ireclaim>
}
    800035c8:	60e2                	ld	ra,24(sp)
    800035ca:	6442                	ld	s0,16(sp)
    800035cc:	64a2                	ld	s1,8(sp)
    800035ce:	6902                	ld	s2,0(sp)
    800035d0:	6105                	addi	sp,sp,32
    800035d2:	8082                	ret
    panic("invalid file system");
    800035d4:	00004517          	auipc	a0,0x4
    800035d8:	ebc50513          	addi	a0,a0,-324 # 80007490 <etext+0x490>
    800035dc:	a48fd0ef          	jal	80000824 <panic>

00000000800035e0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035e0:	1141                	addi	sp,sp,-16
    800035e2:	e406                	sd	ra,8(sp)
    800035e4:	e022                	sd	s0,0(sp)
    800035e6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035e8:	411c                	lw	a5,0(a0)
    800035ea:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035ec:	415c                	lw	a5,4(a0)
    800035ee:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800035f0:	04451783          	lh	a5,68(a0)
    800035f4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800035f8:	04a51783          	lh	a5,74(a0)
    800035fc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003600:	04c56783          	lwu	a5,76(a0)
    80003604:	e99c                	sd	a5,16(a1)
}
    80003606:	60a2                	ld	ra,8(sp)
    80003608:	6402                	ld	s0,0(sp)
    8000360a:	0141                	addi	sp,sp,16
    8000360c:	8082                	ret

000000008000360e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000360e:	457c                	lw	a5,76(a0)
    80003610:	0ed7e663          	bltu	a5,a3,800036fc <readi+0xee>
{
    80003614:	7159                	addi	sp,sp,-112
    80003616:	f486                	sd	ra,104(sp)
    80003618:	f0a2                	sd	s0,96(sp)
    8000361a:	eca6                	sd	s1,88(sp)
    8000361c:	e0d2                	sd	s4,64(sp)
    8000361e:	fc56                	sd	s5,56(sp)
    80003620:	f85a                	sd	s6,48(sp)
    80003622:	f45e                	sd	s7,40(sp)
    80003624:	1880                	addi	s0,sp,112
    80003626:	8b2a                	mv	s6,a0
    80003628:	8bae                	mv	s7,a1
    8000362a:	8a32                	mv	s4,a2
    8000362c:	84b6                	mv	s1,a3
    8000362e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003630:	9f35                	addw	a4,a4,a3
    return 0;
    80003632:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003634:	0ad76b63          	bltu	a4,a3,800036ea <readi+0xdc>
    80003638:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000363a:	00e7f463          	bgeu	a5,a4,80003642 <readi+0x34>
    n = ip->size - off;
    8000363e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003642:	080a8b63          	beqz	s5,800036d8 <readi+0xca>
    80003646:	e8ca                	sd	s2,80(sp)
    80003648:	f062                	sd	s8,32(sp)
    8000364a:	ec66                	sd	s9,24(sp)
    8000364c:	e86a                	sd	s10,16(sp)
    8000364e:	e46e                	sd	s11,8(sp)
    80003650:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003652:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003656:	5c7d                	li	s8,-1
    80003658:	a80d                	j	8000368a <readi+0x7c>
    8000365a:	020d1d93          	slli	s11,s10,0x20
    8000365e:	020ddd93          	srli	s11,s11,0x20
    80003662:	05890613          	addi	a2,s2,88
    80003666:	86ee                	mv	a3,s11
    80003668:	963e                	add	a2,a2,a5
    8000366a:	85d2                	mv	a1,s4
    8000366c:	855e                	mv	a0,s7
    8000366e:	ceffe0ef          	jal	8000235c <either_copyout>
    80003672:	05850363          	beq	a0,s8,800036b8 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003676:	854a                	mv	a0,s2
    80003678:	e74ff0ef          	jal	80002cec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000367c:	013d09bb          	addw	s3,s10,s3
    80003680:	009d04bb          	addw	s1,s10,s1
    80003684:	9a6e                	add	s4,s4,s11
    80003686:	0559f363          	bgeu	s3,s5,800036cc <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000368a:	00a4d59b          	srliw	a1,s1,0xa
    8000368e:	855a                	mv	a0,s6
    80003690:	8bbff0ef          	jal	80002f4a <bmap>
    80003694:	85aa                	mv	a1,a0
    if(addr == 0)
    80003696:	c139                	beqz	a0,800036dc <readi+0xce>
    bp = bread(ip->dev, addr);
    80003698:	000b2503          	lw	a0,0(s6)
    8000369c:	d48ff0ef          	jal	80002be4 <bread>
    800036a0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036a2:	3ff4f793          	andi	a5,s1,1023
    800036a6:	40fc873b          	subw	a4,s9,a5
    800036aa:	413a86bb          	subw	a3,s5,s3
    800036ae:	8d3a                	mv	s10,a4
    800036b0:	fae6f5e3          	bgeu	a3,a4,8000365a <readi+0x4c>
    800036b4:	8d36                	mv	s10,a3
    800036b6:	b755                	j	8000365a <readi+0x4c>
      brelse(bp);
    800036b8:	854a                	mv	a0,s2
    800036ba:	e32ff0ef          	jal	80002cec <brelse>
      tot = -1;
    800036be:	59fd                	li	s3,-1
      break;
    800036c0:	6946                	ld	s2,80(sp)
    800036c2:	7c02                	ld	s8,32(sp)
    800036c4:	6ce2                	ld	s9,24(sp)
    800036c6:	6d42                	ld	s10,16(sp)
    800036c8:	6da2                	ld	s11,8(sp)
    800036ca:	a831                	j	800036e6 <readi+0xd8>
    800036cc:	6946                	ld	s2,80(sp)
    800036ce:	7c02                	ld	s8,32(sp)
    800036d0:	6ce2                	ld	s9,24(sp)
    800036d2:	6d42                	ld	s10,16(sp)
    800036d4:	6da2                	ld	s11,8(sp)
    800036d6:	a801                	j	800036e6 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036d8:	89d6                	mv	s3,s5
    800036da:	a031                	j	800036e6 <readi+0xd8>
    800036dc:	6946                	ld	s2,80(sp)
    800036de:	7c02                	ld	s8,32(sp)
    800036e0:	6ce2                	ld	s9,24(sp)
    800036e2:	6d42                	ld	s10,16(sp)
    800036e4:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800036e6:	854e                	mv	a0,s3
    800036e8:	69a6                	ld	s3,72(sp)
}
    800036ea:	70a6                	ld	ra,104(sp)
    800036ec:	7406                	ld	s0,96(sp)
    800036ee:	64e6                	ld	s1,88(sp)
    800036f0:	6a06                	ld	s4,64(sp)
    800036f2:	7ae2                	ld	s5,56(sp)
    800036f4:	7b42                	ld	s6,48(sp)
    800036f6:	7ba2                	ld	s7,40(sp)
    800036f8:	6165                	addi	sp,sp,112
    800036fa:	8082                	ret
    return 0;
    800036fc:	4501                	li	a0,0
}
    800036fe:	8082                	ret

0000000080003700 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003700:	457c                	lw	a5,76(a0)
    80003702:	0ed7eb63          	bltu	a5,a3,800037f8 <writei+0xf8>
{
    80003706:	7159                	addi	sp,sp,-112
    80003708:	f486                	sd	ra,104(sp)
    8000370a:	f0a2                	sd	s0,96(sp)
    8000370c:	e8ca                	sd	s2,80(sp)
    8000370e:	e0d2                	sd	s4,64(sp)
    80003710:	fc56                	sd	s5,56(sp)
    80003712:	f85a                	sd	s6,48(sp)
    80003714:	f45e                	sd	s7,40(sp)
    80003716:	1880                	addi	s0,sp,112
    80003718:	8aaa                	mv	s5,a0
    8000371a:	8bae                	mv	s7,a1
    8000371c:	8a32                	mv	s4,a2
    8000371e:	8936                	mv	s2,a3
    80003720:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003722:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003726:	00043737          	lui	a4,0x43
    8000372a:	0cf76963          	bltu	a4,a5,800037fc <writei+0xfc>
    8000372e:	0cd7e763          	bltu	a5,a3,800037fc <writei+0xfc>
    80003732:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003734:	0a0b0a63          	beqz	s6,800037e8 <writei+0xe8>
    80003738:	eca6                	sd	s1,88(sp)
    8000373a:	f062                	sd	s8,32(sp)
    8000373c:	ec66                	sd	s9,24(sp)
    8000373e:	e86a                	sd	s10,16(sp)
    80003740:	e46e                	sd	s11,8(sp)
    80003742:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003744:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003748:	5c7d                	li	s8,-1
    8000374a:	a825                	j	80003782 <writei+0x82>
    8000374c:	020d1d93          	slli	s11,s10,0x20
    80003750:	020ddd93          	srli	s11,s11,0x20
    80003754:	05848513          	addi	a0,s1,88
    80003758:	86ee                	mv	a3,s11
    8000375a:	8652                	mv	a2,s4
    8000375c:	85de                	mv	a1,s7
    8000375e:	953e                	add	a0,a0,a5
    80003760:	c47fe0ef          	jal	800023a6 <either_copyin>
    80003764:	05850663          	beq	a0,s8,800037b0 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003768:	8526                	mv	a0,s1
    8000376a:	6b8000ef          	jal	80003e22 <log_write>
    brelse(bp);
    8000376e:	8526                	mv	a0,s1
    80003770:	d7cff0ef          	jal	80002cec <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003774:	013d09bb          	addw	s3,s10,s3
    80003778:	012d093b          	addw	s2,s10,s2
    8000377c:	9a6e                	add	s4,s4,s11
    8000377e:	0369fc63          	bgeu	s3,s6,800037b6 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003782:	00a9559b          	srliw	a1,s2,0xa
    80003786:	8556                	mv	a0,s5
    80003788:	fc2ff0ef          	jal	80002f4a <bmap>
    8000378c:	85aa                	mv	a1,a0
    if(addr == 0)
    8000378e:	c505                	beqz	a0,800037b6 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003790:	000aa503          	lw	a0,0(s5)
    80003794:	c50ff0ef          	jal	80002be4 <bread>
    80003798:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000379a:	3ff97793          	andi	a5,s2,1023
    8000379e:	40fc873b          	subw	a4,s9,a5
    800037a2:	413b06bb          	subw	a3,s6,s3
    800037a6:	8d3a                	mv	s10,a4
    800037a8:	fae6f2e3          	bgeu	a3,a4,8000374c <writei+0x4c>
    800037ac:	8d36                	mv	s10,a3
    800037ae:	bf79                	j	8000374c <writei+0x4c>
      brelse(bp);
    800037b0:	8526                	mv	a0,s1
    800037b2:	d3aff0ef          	jal	80002cec <brelse>
  }

  if(off > ip->size)
    800037b6:	04caa783          	lw	a5,76(s5)
    800037ba:	0327f963          	bgeu	a5,s2,800037ec <writei+0xec>
    ip->size = off;
    800037be:	052aa623          	sw	s2,76(s5)
    800037c2:	64e6                	ld	s1,88(sp)
    800037c4:	7c02                	ld	s8,32(sp)
    800037c6:	6ce2                	ld	s9,24(sp)
    800037c8:	6d42                	ld	s10,16(sp)
    800037ca:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037cc:	8556                	mv	a0,s5
    800037ce:	9fbff0ef          	jal	800031c8 <iupdate>

  return tot;
    800037d2:	854e                	mv	a0,s3
    800037d4:	69a6                	ld	s3,72(sp)
}
    800037d6:	70a6                	ld	ra,104(sp)
    800037d8:	7406                	ld	s0,96(sp)
    800037da:	6946                	ld	s2,80(sp)
    800037dc:	6a06                	ld	s4,64(sp)
    800037de:	7ae2                	ld	s5,56(sp)
    800037e0:	7b42                	ld	s6,48(sp)
    800037e2:	7ba2                	ld	s7,40(sp)
    800037e4:	6165                	addi	sp,sp,112
    800037e6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037e8:	89da                	mv	s3,s6
    800037ea:	b7cd                	j	800037cc <writei+0xcc>
    800037ec:	64e6                	ld	s1,88(sp)
    800037ee:	7c02                	ld	s8,32(sp)
    800037f0:	6ce2                	ld	s9,24(sp)
    800037f2:	6d42                	ld	s10,16(sp)
    800037f4:	6da2                	ld	s11,8(sp)
    800037f6:	bfd9                	j	800037cc <writei+0xcc>
    return -1;
    800037f8:	557d                	li	a0,-1
}
    800037fa:	8082                	ret
    return -1;
    800037fc:	557d                	li	a0,-1
    800037fe:	bfe1                	j	800037d6 <writei+0xd6>

0000000080003800 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003800:	1141                	addi	sp,sp,-16
    80003802:	e406                	sd	ra,8(sp)
    80003804:	e022                	sd	s0,0(sp)
    80003806:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003808:	4639                	li	a2,14
    8000380a:	dc2fd0ef          	jal	80000dcc <strncmp>
}
    8000380e:	60a2                	ld	ra,8(sp)
    80003810:	6402                	ld	s0,0(sp)
    80003812:	0141                	addi	sp,sp,16
    80003814:	8082                	ret

0000000080003816 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003816:	711d                	addi	sp,sp,-96
    80003818:	ec86                	sd	ra,88(sp)
    8000381a:	e8a2                	sd	s0,80(sp)
    8000381c:	e4a6                	sd	s1,72(sp)
    8000381e:	e0ca                	sd	s2,64(sp)
    80003820:	fc4e                	sd	s3,56(sp)
    80003822:	f852                	sd	s4,48(sp)
    80003824:	f456                	sd	s5,40(sp)
    80003826:	f05a                	sd	s6,32(sp)
    80003828:	ec5e                	sd	s7,24(sp)
    8000382a:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000382c:	04451703          	lh	a4,68(a0)
    80003830:	4785                	li	a5,1
    80003832:	00f71f63          	bne	a4,a5,80003850 <dirlookup+0x3a>
    80003836:	892a                	mv	s2,a0
    80003838:	8aae                	mv	s5,a1
    8000383a:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000383c:	457c                	lw	a5,76(a0)
    8000383e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003840:	fa040a13          	addi	s4,s0,-96
    80003844:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003846:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000384a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000384c:	e39d                	bnez	a5,80003872 <dirlookup+0x5c>
    8000384e:	a8b9                	j	800038ac <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003850:	00004517          	auipc	a0,0x4
    80003854:	c5850513          	addi	a0,a0,-936 # 800074a8 <etext+0x4a8>
    80003858:	fcdfc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    8000385c:	00004517          	auipc	a0,0x4
    80003860:	c6450513          	addi	a0,a0,-924 # 800074c0 <etext+0x4c0>
    80003864:	fc1fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003868:	24c1                	addiw	s1,s1,16
    8000386a:	04c92783          	lw	a5,76(s2)
    8000386e:	02f4fe63          	bgeu	s1,a5,800038aa <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003872:	874e                	mv	a4,s3
    80003874:	86a6                	mv	a3,s1
    80003876:	8652                	mv	a2,s4
    80003878:	4581                	li	a1,0
    8000387a:	854a                	mv	a0,s2
    8000387c:	d93ff0ef          	jal	8000360e <readi>
    80003880:	fd351ee3          	bne	a0,s3,8000385c <dirlookup+0x46>
    if(de.inum == 0)
    80003884:	fa045783          	lhu	a5,-96(s0)
    80003888:	d3e5                	beqz	a5,80003868 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    8000388a:	85da                	mv	a1,s6
    8000388c:	8556                	mv	a0,s5
    8000388e:	f73ff0ef          	jal	80003800 <namecmp>
    80003892:	f979                	bnez	a0,80003868 <dirlookup+0x52>
      if(poff)
    80003894:	000b8463          	beqz	s7,8000389c <dirlookup+0x86>
        *poff = off;
    80003898:	009ba023          	sw	s1,0(s7) # 1000 <_entry-0x7ffff000>
      return iget(dp->dev, inum);
    8000389c:	fa045583          	lhu	a1,-96(s0)
    800038a0:	00092503          	lw	a0,0(s2)
    800038a4:	f66ff0ef          	jal	8000300a <iget>
    800038a8:	a011                	j	800038ac <dirlookup+0x96>
  return 0;
    800038aa:	4501                	li	a0,0
}
    800038ac:	60e6                	ld	ra,88(sp)
    800038ae:	6446                	ld	s0,80(sp)
    800038b0:	64a6                	ld	s1,72(sp)
    800038b2:	6906                	ld	s2,64(sp)
    800038b4:	79e2                	ld	s3,56(sp)
    800038b6:	7a42                	ld	s4,48(sp)
    800038b8:	7aa2                	ld	s5,40(sp)
    800038ba:	7b02                	ld	s6,32(sp)
    800038bc:	6be2                	ld	s7,24(sp)
    800038be:	6125                	addi	sp,sp,96
    800038c0:	8082                	ret

00000000800038c2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800038c2:	711d                	addi	sp,sp,-96
    800038c4:	ec86                	sd	ra,88(sp)
    800038c6:	e8a2                	sd	s0,80(sp)
    800038c8:	e4a6                	sd	s1,72(sp)
    800038ca:	e0ca                	sd	s2,64(sp)
    800038cc:	fc4e                	sd	s3,56(sp)
    800038ce:	f852                	sd	s4,48(sp)
    800038d0:	f456                	sd	s5,40(sp)
    800038d2:	f05a                	sd	s6,32(sp)
    800038d4:	ec5e                	sd	s7,24(sp)
    800038d6:	e862                	sd	s8,16(sp)
    800038d8:	e466                	sd	s9,8(sp)
    800038da:	e06a                	sd	s10,0(sp)
    800038dc:	1080                	addi	s0,sp,96
    800038de:	84aa                	mv	s1,a0
    800038e0:	8b2e                	mv	s6,a1
    800038e2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800038e4:	00054703          	lbu	a4,0(a0)
    800038e8:	02f00793          	li	a5,47
    800038ec:	00f70f63          	beq	a4,a5,8000390a <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800038f0:	90afe0ef          	jal	800019fa <myproc>
    800038f4:	15053503          	ld	a0,336(a0)
    800038f8:	94fff0ef          	jal	80003246 <idup>
    800038fc:	8a2a                	mv	s4,a0
  while(*path == '/')
    800038fe:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003902:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003904:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003906:	4b85                	li	s7,1
    80003908:	a879                	j	800039a6 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000390a:	4585                	li	a1,1
    8000390c:	852e                	mv	a0,a1
    8000390e:	efcff0ef          	jal	8000300a <iget>
    80003912:	8a2a                	mv	s4,a0
    80003914:	b7ed                	j	800038fe <namex+0x3c>
      iunlockput(ip);
    80003916:	8552                	mv	a0,s4
    80003918:	b71ff0ef          	jal	80003488 <iunlockput>
      return 0;
    8000391c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000391e:	8552                	mv	a0,s4
    80003920:	60e6                	ld	ra,88(sp)
    80003922:	6446                	ld	s0,80(sp)
    80003924:	64a6                	ld	s1,72(sp)
    80003926:	6906                	ld	s2,64(sp)
    80003928:	79e2                	ld	s3,56(sp)
    8000392a:	7a42                	ld	s4,48(sp)
    8000392c:	7aa2                	ld	s5,40(sp)
    8000392e:	7b02                	ld	s6,32(sp)
    80003930:	6be2                	ld	s7,24(sp)
    80003932:	6c42                	ld	s8,16(sp)
    80003934:	6ca2                	ld	s9,8(sp)
    80003936:	6d02                	ld	s10,0(sp)
    80003938:	6125                	addi	sp,sp,96
    8000393a:	8082                	ret
      iunlock(ip);
    8000393c:	8552                	mv	a0,s4
    8000393e:	9edff0ef          	jal	8000332a <iunlock>
      return ip;
    80003942:	bff1                	j	8000391e <namex+0x5c>
      iunlockput(ip);
    80003944:	8552                	mv	a0,s4
    80003946:	b43ff0ef          	jal	80003488 <iunlockput>
      return 0;
    8000394a:	8a4a                	mv	s4,s2
    8000394c:	bfc9                	j	8000391e <namex+0x5c>
  len = path - s;
    8000394e:	40990633          	sub	a2,s2,s1
    80003952:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003956:	09ac5463          	bge	s8,s10,800039de <namex+0x11c>
    memmove(name, s, DIRSIZ);
    8000395a:	8666                	mv	a2,s9
    8000395c:	85a6                	mv	a1,s1
    8000395e:	8556                	mv	a0,s5
    80003960:	bf8fd0ef          	jal	80000d58 <memmove>
    80003964:	84ca                	mv	s1,s2
  while(*path == '/')
    80003966:	0004c783          	lbu	a5,0(s1)
    8000396a:	01379763          	bne	a5,s3,80003978 <namex+0xb6>
    path++;
    8000396e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003970:	0004c783          	lbu	a5,0(s1)
    80003974:	ff378de3          	beq	a5,s3,8000396e <namex+0xac>
    ilock(ip);
    80003978:	8552                	mv	a0,s4
    8000397a:	903ff0ef          	jal	8000327c <ilock>
    if(ip->type != T_DIR){
    8000397e:	044a1783          	lh	a5,68(s4)
    80003982:	f9779ae3          	bne	a5,s7,80003916 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003986:	000b0563          	beqz	s6,80003990 <namex+0xce>
    8000398a:	0004c783          	lbu	a5,0(s1)
    8000398e:	d7dd                	beqz	a5,8000393c <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003990:	4601                	li	a2,0
    80003992:	85d6                	mv	a1,s5
    80003994:	8552                	mv	a0,s4
    80003996:	e81ff0ef          	jal	80003816 <dirlookup>
    8000399a:	892a                	mv	s2,a0
    8000399c:	d545                	beqz	a0,80003944 <namex+0x82>
    iunlockput(ip);
    8000399e:	8552                	mv	a0,s4
    800039a0:	ae9ff0ef          	jal	80003488 <iunlockput>
    ip = next;
    800039a4:	8a4a                	mv	s4,s2
  while(*path == '/')
    800039a6:	0004c783          	lbu	a5,0(s1)
    800039aa:	01379763          	bne	a5,s3,800039b8 <namex+0xf6>
    path++;
    800039ae:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039b0:	0004c783          	lbu	a5,0(s1)
    800039b4:	ff378de3          	beq	a5,s3,800039ae <namex+0xec>
  if(*path == 0)
    800039b8:	cf8d                	beqz	a5,800039f2 <namex+0x130>
  while(*path != '/' && *path != 0)
    800039ba:	0004c783          	lbu	a5,0(s1)
    800039be:	fd178713          	addi	a4,a5,-47
    800039c2:	cb19                	beqz	a4,800039d8 <namex+0x116>
    800039c4:	cb91                	beqz	a5,800039d8 <namex+0x116>
    800039c6:	8926                	mv	s2,s1
    path++;
    800039c8:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    800039ca:	00094783          	lbu	a5,0(s2)
    800039ce:	fd178713          	addi	a4,a5,-47
    800039d2:	df35                	beqz	a4,8000394e <namex+0x8c>
    800039d4:	fbf5                	bnez	a5,800039c8 <namex+0x106>
    800039d6:	bfa5                	j	8000394e <namex+0x8c>
    800039d8:	8926                	mv	s2,s1
  len = path - s;
    800039da:	4d01                	li	s10,0
    800039dc:	4601                	li	a2,0
    memmove(name, s, len);
    800039de:	2601                	sext.w	a2,a2
    800039e0:	85a6                	mv	a1,s1
    800039e2:	8556                	mv	a0,s5
    800039e4:	b74fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    800039e8:	9d56                	add	s10,s10,s5
    800039ea:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde260>
    800039ee:	84ca                	mv	s1,s2
    800039f0:	bf9d                	j	80003966 <namex+0xa4>
  if(nameiparent){
    800039f2:	f20b06e3          	beqz	s6,8000391e <namex+0x5c>
    iput(ip);
    800039f6:	8552                	mv	a0,s4
    800039f8:	a07ff0ef          	jal	800033fe <iput>
    return 0;
    800039fc:	4a01                	li	s4,0
    800039fe:	b705                	j	8000391e <namex+0x5c>

0000000080003a00 <dirlink>:
{
    80003a00:	715d                	addi	sp,sp,-80
    80003a02:	e486                	sd	ra,72(sp)
    80003a04:	e0a2                	sd	s0,64(sp)
    80003a06:	f84a                	sd	s2,48(sp)
    80003a08:	ec56                	sd	s5,24(sp)
    80003a0a:	e85a                	sd	s6,16(sp)
    80003a0c:	0880                	addi	s0,sp,80
    80003a0e:	892a                	mv	s2,a0
    80003a10:	8aae                	mv	s5,a1
    80003a12:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a14:	4601                	li	a2,0
    80003a16:	e01ff0ef          	jal	80003816 <dirlookup>
    80003a1a:	ed1d                	bnez	a0,80003a58 <dirlink+0x58>
    80003a1c:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a1e:	04c92483          	lw	s1,76(s2)
    80003a22:	c4b9                	beqz	s1,80003a70 <dirlink+0x70>
    80003a24:	f44e                	sd	s3,40(sp)
    80003a26:	f052                	sd	s4,32(sp)
    80003a28:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a2a:	fb040a13          	addi	s4,s0,-80
    80003a2e:	49c1                	li	s3,16
    80003a30:	874e                	mv	a4,s3
    80003a32:	86a6                	mv	a3,s1
    80003a34:	8652                	mv	a2,s4
    80003a36:	4581                	li	a1,0
    80003a38:	854a                	mv	a0,s2
    80003a3a:	bd5ff0ef          	jal	8000360e <readi>
    80003a3e:	03351163          	bne	a0,s3,80003a60 <dirlink+0x60>
    if(de.inum == 0)
    80003a42:	fb045783          	lhu	a5,-80(s0)
    80003a46:	c39d                	beqz	a5,80003a6c <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a48:	24c1                	addiw	s1,s1,16
    80003a4a:	04c92783          	lw	a5,76(s2)
    80003a4e:	fef4e1e3          	bltu	s1,a5,80003a30 <dirlink+0x30>
    80003a52:	79a2                	ld	s3,40(sp)
    80003a54:	7a02                	ld	s4,32(sp)
    80003a56:	a829                	j	80003a70 <dirlink+0x70>
    iput(ip);
    80003a58:	9a7ff0ef          	jal	800033fe <iput>
    return -1;
    80003a5c:	557d                	li	a0,-1
    80003a5e:	a83d                	j	80003a9c <dirlink+0x9c>
      panic("dirlink read");
    80003a60:	00004517          	auipc	a0,0x4
    80003a64:	a7050513          	addi	a0,a0,-1424 # 800074d0 <etext+0x4d0>
    80003a68:	dbdfc0ef          	jal	80000824 <panic>
    80003a6c:	79a2                	ld	s3,40(sp)
    80003a6e:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003a70:	4639                	li	a2,14
    80003a72:	85d6                	mv	a1,s5
    80003a74:	fb240513          	addi	a0,s0,-78
    80003a78:	b8efd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003a7c:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a80:	4741                	li	a4,16
    80003a82:	86a6                	mv	a3,s1
    80003a84:	fb040613          	addi	a2,s0,-80
    80003a88:	4581                	li	a1,0
    80003a8a:	854a                	mv	a0,s2
    80003a8c:	c75ff0ef          	jal	80003700 <writei>
    80003a90:	1541                	addi	a0,a0,-16
    80003a92:	00a03533          	snez	a0,a0
    80003a96:	40a0053b          	negw	a0,a0
    80003a9a:	74e2                	ld	s1,56(sp)
}
    80003a9c:	60a6                	ld	ra,72(sp)
    80003a9e:	6406                	ld	s0,64(sp)
    80003aa0:	7942                	ld	s2,48(sp)
    80003aa2:	6ae2                	ld	s5,24(sp)
    80003aa4:	6b42                	ld	s6,16(sp)
    80003aa6:	6161                	addi	sp,sp,80
    80003aa8:	8082                	ret

0000000080003aaa <namei>:

struct inode*
namei(char *path)
{
    80003aaa:	1101                	addi	sp,sp,-32
    80003aac:	ec06                	sd	ra,24(sp)
    80003aae:	e822                	sd	s0,16(sp)
    80003ab0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ab2:	fe040613          	addi	a2,s0,-32
    80003ab6:	4581                	li	a1,0
    80003ab8:	e0bff0ef          	jal	800038c2 <namex>
}
    80003abc:	60e2                	ld	ra,24(sp)
    80003abe:	6442                	ld	s0,16(sp)
    80003ac0:	6105                	addi	sp,sp,32
    80003ac2:	8082                	ret

0000000080003ac4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ac4:	1141                	addi	sp,sp,-16
    80003ac6:	e406                	sd	ra,8(sp)
    80003ac8:	e022                	sd	s0,0(sp)
    80003aca:	0800                	addi	s0,sp,16
    80003acc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ace:	4585                	li	a1,1
    80003ad0:	df3ff0ef          	jal	800038c2 <namex>
}
    80003ad4:	60a2                	ld	ra,8(sp)
    80003ad6:	6402                	ld	s0,0(sp)
    80003ad8:	0141                	addi	sp,sp,16
    80003ada:	8082                	ret

0000000080003adc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003adc:	1101                	addi	sp,sp,-32
    80003ade:	ec06                	sd	ra,24(sp)
    80003ae0:	e822                	sd	s0,16(sp)
    80003ae2:	e426                	sd	s1,8(sp)
    80003ae4:	e04a                	sd	s2,0(sp)
    80003ae6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ae8:	0001c917          	auipc	s2,0x1c
    80003aec:	07890913          	addi	s2,s2,120 # 8001fb60 <log>
    80003af0:	01892583          	lw	a1,24(s2)
    80003af4:	02492503          	lw	a0,36(s2)
    80003af8:	8ecff0ef          	jal	80002be4 <bread>
    80003afc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003afe:	02892603          	lw	a2,40(s2)
    80003b02:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b04:	00c05f63          	blez	a2,80003b22 <write_head+0x46>
    80003b08:	0001c717          	auipc	a4,0x1c
    80003b0c:	08470713          	addi	a4,a4,132 # 8001fb8c <log+0x2c>
    80003b10:	87aa                	mv	a5,a0
    80003b12:	060a                	slli	a2,a2,0x2
    80003b14:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b16:	4314                	lw	a3,0(a4)
    80003b18:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b1a:	0711                	addi	a4,a4,4
    80003b1c:	0791                	addi	a5,a5,4
    80003b1e:	fec79ce3          	bne	a5,a2,80003b16 <write_head+0x3a>
  }
  bwrite(buf);
    80003b22:	8526                	mv	a0,s1
    80003b24:	996ff0ef          	jal	80002cba <bwrite>
  brelse(buf);
    80003b28:	8526                	mv	a0,s1
    80003b2a:	9c2ff0ef          	jal	80002cec <brelse>
}
    80003b2e:	60e2                	ld	ra,24(sp)
    80003b30:	6442                	ld	s0,16(sp)
    80003b32:	64a2                	ld	s1,8(sp)
    80003b34:	6902                	ld	s2,0(sp)
    80003b36:	6105                	addi	sp,sp,32
    80003b38:	8082                	ret

0000000080003b3a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b3a:	0001c797          	auipc	a5,0x1c
    80003b3e:	04e7a783          	lw	a5,78(a5) # 8001fb88 <log+0x28>
    80003b42:	0cf05163          	blez	a5,80003c04 <install_trans+0xca>
{
    80003b46:	715d                	addi	sp,sp,-80
    80003b48:	e486                	sd	ra,72(sp)
    80003b4a:	e0a2                	sd	s0,64(sp)
    80003b4c:	fc26                	sd	s1,56(sp)
    80003b4e:	f84a                	sd	s2,48(sp)
    80003b50:	f44e                	sd	s3,40(sp)
    80003b52:	f052                	sd	s4,32(sp)
    80003b54:	ec56                	sd	s5,24(sp)
    80003b56:	e85a                	sd	s6,16(sp)
    80003b58:	e45e                	sd	s7,8(sp)
    80003b5a:	e062                	sd	s8,0(sp)
    80003b5c:	0880                	addi	s0,sp,80
    80003b5e:	8b2a                	mv	s6,a0
    80003b60:	0001ca97          	auipc	s5,0x1c
    80003b64:	02ca8a93          	addi	s5,s5,44 # 8001fb8c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b68:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b6a:	00004c17          	auipc	s8,0x4
    80003b6e:	976c0c13          	addi	s8,s8,-1674 # 800074e0 <etext+0x4e0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b72:	0001ca17          	auipc	s4,0x1c
    80003b76:	feea0a13          	addi	s4,s4,-18 # 8001fb60 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b7a:	40000b93          	li	s7,1024
    80003b7e:	a025                	j	80003ba6 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b80:	000aa603          	lw	a2,0(s5)
    80003b84:	85ce                	mv	a1,s3
    80003b86:	8562                	mv	a0,s8
    80003b88:	973fc0ef          	jal	800004fa <printf>
    80003b8c:	a839                	j	80003baa <install_trans+0x70>
    brelse(lbuf);
    80003b8e:	854a                	mv	a0,s2
    80003b90:	95cff0ef          	jal	80002cec <brelse>
    brelse(dbuf);
    80003b94:	8526                	mv	a0,s1
    80003b96:	956ff0ef          	jal	80002cec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b9a:	2985                	addiw	s3,s3,1
    80003b9c:	0a91                	addi	s5,s5,4
    80003b9e:	028a2783          	lw	a5,40(s4)
    80003ba2:	04f9d563          	bge	s3,a5,80003bec <install_trans+0xb2>
    if(recovering) {
    80003ba6:	fc0b1de3          	bnez	s6,80003b80 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003baa:	018a2583          	lw	a1,24(s4)
    80003bae:	013585bb          	addw	a1,a1,s3
    80003bb2:	2585                	addiw	a1,a1,1
    80003bb4:	024a2503          	lw	a0,36(s4)
    80003bb8:	82cff0ef          	jal	80002be4 <bread>
    80003bbc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003bbe:	000aa583          	lw	a1,0(s5)
    80003bc2:	024a2503          	lw	a0,36(s4)
    80003bc6:	81eff0ef          	jal	80002be4 <bread>
    80003bca:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bcc:	865e                	mv	a2,s7
    80003bce:	05890593          	addi	a1,s2,88
    80003bd2:	05850513          	addi	a0,a0,88
    80003bd6:	982fd0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003bda:	8526                	mv	a0,s1
    80003bdc:	8deff0ef          	jal	80002cba <bwrite>
    if(recovering == 0)
    80003be0:	fa0b17e3          	bnez	s6,80003b8e <install_trans+0x54>
      bunpin(dbuf);
    80003be4:	8526                	mv	a0,s1
    80003be6:	9beff0ef          	jal	80002da4 <bunpin>
    80003bea:	b755                	j	80003b8e <install_trans+0x54>
}
    80003bec:	60a6                	ld	ra,72(sp)
    80003bee:	6406                	ld	s0,64(sp)
    80003bf0:	74e2                	ld	s1,56(sp)
    80003bf2:	7942                	ld	s2,48(sp)
    80003bf4:	79a2                	ld	s3,40(sp)
    80003bf6:	7a02                	ld	s4,32(sp)
    80003bf8:	6ae2                	ld	s5,24(sp)
    80003bfa:	6b42                	ld	s6,16(sp)
    80003bfc:	6ba2                	ld	s7,8(sp)
    80003bfe:	6c02                	ld	s8,0(sp)
    80003c00:	6161                	addi	sp,sp,80
    80003c02:	8082                	ret
    80003c04:	8082                	ret

0000000080003c06 <initlog>:
{
    80003c06:	7179                	addi	sp,sp,-48
    80003c08:	f406                	sd	ra,40(sp)
    80003c0a:	f022                	sd	s0,32(sp)
    80003c0c:	ec26                	sd	s1,24(sp)
    80003c0e:	e84a                	sd	s2,16(sp)
    80003c10:	e44e                	sd	s3,8(sp)
    80003c12:	1800                	addi	s0,sp,48
    80003c14:	84aa                	mv	s1,a0
    80003c16:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c18:	0001c917          	auipc	s2,0x1c
    80003c1c:	f4890913          	addi	s2,s2,-184 # 8001fb60 <log>
    80003c20:	00004597          	auipc	a1,0x4
    80003c24:	8e058593          	addi	a1,a1,-1824 # 80007500 <etext+0x500>
    80003c28:	854a                	mv	a0,s2
    80003c2a:	f75fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003c2e:	0149a583          	lw	a1,20(s3)
    80003c32:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003c36:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003c3a:	8526                	mv	a0,s1
    80003c3c:	fa9fe0ef          	jal	80002be4 <bread>
  log.lh.n = lh->n;
    80003c40:	4d30                	lw	a2,88(a0)
    80003c42:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003c46:	00c05f63          	blez	a2,80003c64 <initlog+0x5e>
    80003c4a:	87aa                	mv	a5,a0
    80003c4c:	0001c717          	auipc	a4,0x1c
    80003c50:	f4070713          	addi	a4,a4,-192 # 8001fb8c <log+0x2c>
    80003c54:	060a                	slli	a2,a2,0x2
    80003c56:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c58:	4ff4                	lw	a3,92(a5)
    80003c5a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c5c:	0791                	addi	a5,a5,4
    80003c5e:	0711                	addi	a4,a4,4
    80003c60:	fec79ce3          	bne	a5,a2,80003c58 <initlog+0x52>
  brelse(buf);
    80003c64:	888ff0ef          	jal	80002cec <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c68:	4505                	li	a0,1
    80003c6a:	ed1ff0ef          	jal	80003b3a <install_trans>
  log.lh.n = 0;
    80003c6e:	0001c797          	auipc	a5,0x1c
    80003c72:	f007ad23          	sw	zero,-230(a5) # 8001fb88 <log+0x28>
  write_head(); // clear the log
    80003c76:	e67ff0ef          	jal	80003adc <write_head>
}
    80003c7a:	70a2                	ld	ra,40(sp)
    80003c7c:	7402                	ld	s0,32(sp)
    80003c7e:	64e2                	ld	s1,24(sp)
    80003c80:	6942                	ld	s2,16(sp)
    80003c82:	69a2                	ld	s3,8(sp)
    80003c84:	6145                	addi	sp,sp,48
    80003c86:	8082                	ret

0000000080003c88 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c88:	1101                	addi	sp,sp,-32
    80003c8a:	ec06                	sd	ra,24(sp)
    80003c8c:	e822                	sd	s0,16(sp)
    80003c8e:	e426                	sd	s1,8(sp)
    80003c90:	e04a                	sd	s2,0(sp)
    80003c92:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c94:	0001c517          	auipc	a0,0x1c
    80003c98:	ecc50513          	addi	a0,a0,-308 # 8001fb60 <log>
    80003c9c:	f8dfc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003ca0:	0001c497          	auipc	s1,0x1c
    80003ca4:	ec048493          	addi	s1,s1,-320 # 8001fb60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ca8:	4979                	li	s2,30
    80003caa:	a029                	j	80003cb4 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003cac:	85a6                	mv	a1,s1
    80003cae:	8526                	mv	a0,s1
    80003cb0:	b46fe0ef          	jal	80001ff6 <sleep>
    if(log.committing){
    80003cb4:	509c                	lw	a5,32(s1)
    80003cb6:	fbfd                	bnez	a5,80003cac <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cb8:	4cd8                	lw	a4,28(s1)
    80003cba:	2705                	addiw	a4,a4,1
    80003cbc:	0027179b          	slliw	a5,a4,0x2
    80003cc0:	9fb9                	addw	a5,a5,a4
    80003cc2:	0017979b          	slliw	a5,a5,0x1
    80003cc6:	5494                	lw	a3,40(s1)
    80003cc8:	9fb5                	addw	a5,a5,a3
    80003cca:	00f95763          	bge	s2,a5,80003cd8 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003cce:	85a6                	mv	a1,s1
    80003cd0:	8526                	mv	a0,s1
    80003cd2:	b24fe0ef          	jal	80001ff6 <sleep>
    80003cd6:	bff9                	j	80003cb4 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003cd8:	0001c797          	auipc	a5,0x1c
    80003cdc:	eae7a223          	sw	a4,-348(a5) # 8001fb7c <log+0x1c>
      release(&log.lock);
    80003ce0:	0001c517          	auipc	a0,0x1c
    80003ce4:	e8050513          	addi	a0,a0,-384 # 8001fb60 <log>
    80003ce8:	fd5fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003cec:	60e2                	ld	ra,24(sp)
    80003cee:	6442                	ld	s0,16(sp)
    80003cf0:	64a2                	ld	s1,8(sp)
    80003cf2:	6902                	ld	s2,0(sp)
    80003cf4:	6105                	addi	sp,sp,32
    80003cf6:	8082                	ret

0000000080003cf8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003cf8:	7139                	addi	sp,sp,-64
    80003cfa:	fc06                	sd	ra,56(sp)
    80003cfc:	f822                	sd	s0,48(sp)
    80003cfe:	f426                	sd	s1,40(sp)
    80003d00:	f04a                	sd	s2,32(sp)
    80003d02:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d04:	0001c497          	auipc	s1,0x1c
    80003d08:	e5c48493          	addi	s1,s1,-420 # 8001fb60 <log>
    80003d0c:	8526                	mv	a0,s1
    80003d0e:	f1bfc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003d12:	4cdc                	lw	a5,28(s1)
    80003d14:	37fd                	addiw	a5,a5,-1
    80003d16:	893e                	mv	s2,a5
    80003d18:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d1a:	509c                	lw	a5,32(s1)
    80003d1c:	e7b1                	bnez	a5,80003d68 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d1e:	04091e63          	bnez	s2,80003d7a <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003d22:	0001c497          	auipc	s1,0x1c
    80003d26:	e3e48493          	addi	s1,s1,-450 # 8001fb60 <log>
    80003d2a:	4785                	li	a5,1
    80003d2c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	f8dfc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d34:	549c                	lw	a5,40(s1)
    80003d36:	06f04463          	bgtz	a5,80003d9e <end_op+0xa6>
    acquire(&log.lock);
    80003d3a:	0001c517          	auipc	a0,0x1c
    80003d3e:	e2650513          	addi	a0,a0,-474 # 8001fb60 <log>
    80003d42:	ee7fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003d46:	0001c797          	auipc	a5,0x1c
    80003d4a:	e207ad23          	sw	zero,-454(a5) # 8001fb80 <log+0x20>
    wakeup(&log);
    80003d4e:	0001c517          	auipc	a0,0x1c
    80003d52:	e1250513          	addi	a0,a0,-494 # 8001fb60 <log>
    80003d56:	aecfe0ef          	jal	80002042 <wakeup>
    release(&log.lock);
    80003d5a:	0001c517          	auipc	a0,0x1c
    80003d5e:	e0650513          	addi	a0,a0,-506 # 8001fb60 <log>
    80003d62:	f5bfc0ef          	jal	80000cbc <release>
}
    80003d66:	a035                	j	80003d92 <end_op+0x9a>
    80003d68:	ec4e                	sd	s3,24(sp)
    80003d6a:	e852                	sd	s4,16(sp)
    80003d6c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d6e:	00003517          	auipc	a0,0x3
    80003d72:	79a50513          	addi	a0,a0,1946 # 80007508 <etext+0x508>
    80003d76:	aaffc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003d7a:	0001c517          	auipc	a0,0x1c
    80003d7e:	de650513          	addi	a0,a0,-538 # 8001fb60 <log>
    80003d82:	ac0fe0ef          	jal	80002042 <wakeup>
  release(&log.lock);
    80003d86:	0001c517          	auipc	a0,0x1c
    80003d8a:	dda50513          	addi	a0,a0,-550 # 8001fb60 <log>
    80003d8e:	f2ffc0ef          	jal	80000cbc <release>
}
    80003d92:	70e2                	ld	ra,56(sp)
    80003d94:	7442                	ld	s0,48(sp)
    80003d96:	74a2                	ld	s1,40(sp)
    80003d98:	7902                	ld	s2,32(sp)
    80003d9a:	6121                	addi	sp,sp,64
    80003d9c:	8082                	ret
    80003d9e:	ec4e                	sd	s3,24(sp)
    80003da0:	e852                	sd	s4,16(sp)
    80003da2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003da4:	0001ca97          	auipc	s5,0x1c
    80003da8:	de8a8a93          	addi	s5,s5,-536 # 8001fb8c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003dac:	0001ca17          	auipc	s4,0x1c
    80003db0:	db4a0a13          	addi	s4,s4,-588 # 8001fb60 <log>
    80003db4:	018a2583          	lw	a1,24(s4)
    80003db8:	012585bb          	addw	a1,a1,s2
    80003dbc:	2585                	addiw	a1,a1,1
    80003dbe:	024a2503          	lw	a0,36(s4)
    80003dc2:	e23fe0ef          	jal	80002be4 <bread>
    80003dc6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003dc8:	000aa583          	lw	a1,0(s5)
    80003dcc:	024a2503          	lw	a0,36(s4)
    80003dd0:	e15fe0ef          	jal	80002be4 <bread>
    80003dd4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003dd6:	40000613          	li	a2,1024
    80003dda:	05850593          	addi	a1,a0,88
    80003dde:	05848513          	addi	a0,s1,88
    80003de2:	f77fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003de6:	8526                	mv	a0,s1
    80003de8:	ed3fe0ef          	jal	80002cba <bwrite>
    brelse(from);
    80003dec:	854e                	mv	a0,s3
    80003dee:	efffe0ef          	jal	80002cec <brelse>
    brelse(to);
    80003df2:	8526                	mv	a0,s1
    80003df4:	ef9fe0ef          	jal	80002cec <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003df8:	2905                	addiw	s2,s2,1
    80003dfa:	0a91                	addi	s5,s5,4
    80003dfc:	028a2783          	lw	a5,40(s4)
    80003e00:	faf94ae3          	blt	s2,a5,80003db4 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e04:	cd9ff0ef          	jal	80003adc <write_head>
    install_trans(0); // Now install writes to home locations
    80003e08:	4501                	li	a0,0
    80003e0a:	d31ff0ef          	jal	80003b3a <install_trans>
    log.lh.n = 0;
    80003e0e:	0001c797          	auipc	a5,0x1c
    80003e12:	d607ad23          	sw	zero,-646(a5) # 8001fb88 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e16:	cc7ff0ef          	jal	80003adc <write_head>
    80003e1a:	69e2                	ld	s3,24(sp)
    80003e1c:	6a42                	ld	s4,16(sp)
    80003e1e:	6aa2                	ld	s5,8(sp)
    80003e20:	bf29                	j	80003d3a <end_op+0x42>

0000000080003e22 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e22:	1101                	addi	sp,sp,-32
    80003e24:	ec06                	sd	ra,24(sp)
    80003e26:	e822                	sd	s0,16(sp)
    80003e28:	e426                	sd	s1,8(sp)
    80003e2a:	1000                	addi	s0,sp,32
    80003e2c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e2e:	0001c517          	auipc	a0,0x1c
    80003e32:	d3250513          	addi	a0,a0,-718 # 8001fb60 <log>
    80003e36:	df3fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e3a:	0001c617          	auipc	a2,0x1c
    80003e3e:	d4e62603          	lw	a2,-690(a2) # 8001fb88 <log+0x28>
    80003e42:	47f5                	li	a5,29
    80003e44:	04c7cd63          	blt	a5,a2,80003e9e <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e48:	0001c797          	auipc	a5,0x1c
    80003e4c:	d347a783          	lw	a5,-716(a5) # 8001fb7c <log+0x1c>
    80003e50:	04f05d63          	blez	a5,80003eaa <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e54:	4781                	li	a5,0
    80003e56:	06c05063          	blez	a2,80003eb6 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e5a:	44cc                	lw	a1,12(s1)
    80003e5c:	0001c717          	auipc	a4,0x1c
    80003e60:	d3070713          	addi	a4,a4,-720 # 8001fb8c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003e64:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e66:	4314                	lw	a3,0(a4)
    80003e68:	04b68763          	beq	a3,a1,80003eb6 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003e6c:	2785                	addiw	a5,a5,1
    80003e6e:	0711                	addi	a4,a4,4
    80003e70:	fef61be3          	bne	a2,a5,80003e66 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e74:	060a                	slli	a2,a2,0x2
    80003e76:	02060613          	addi	a2,a2,32
    80003e7a:	0001c797          	auipc	a5,0x1c
    80003e7e:	ce678793          	addi	a5,a5,-794 # 8001fb60 <log>
    80003e82:	97b2                	add	a5,a5,a2
    80003e84:	44d8                	lw	a4,12(s1)
    80003e86:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003e88:	8526                	mv	a0,s1
    80003e8a:	ee7fe0ef          	jal	80002d70 <bpin>
    log.lh.n++;
    80003e8e:	0001c717          	auipc	a4,0x1c
    80003e92:	cd270713          	addi	a4,a4,-814 # 8001fb60 <log>
    80003e96:	571c                	lw	a5,40(a4)
    80003e98:	2785                	addiw	a5,a5,1
    80003e9a:	d71c                	sw	a5,40(a4)
    80003e9c:	a815                	j	80003ed0 <log_write+0xae>
    panic("too big a transaction");
    80003e9e:	00003517          	auipc	a0,0x3
    80003ea2:	67a50513          	addi	a0,a0,1658 # 80007518 <etext+0x518>
    80003ea6:	97ffc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    80003eaa:	00003517          	auipc	a0,0x3
    80003eae:	68650513          	addi	a0,a0,1670 # 80007530 <etext+0x530>
    80003eb2:	973fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80003eb6:	00279693          	slli	a3,a5,0x2
    80003eba:	02068693          	addi	a3,a3,32
    80003ebe:	0001c717          	auipc	a4,0x1c
    80003ec2:	ca270713          	addi	a4,a4,-862 # 8001fb60 <log>
    80003ec6:	9736                	add	a4,a4,a3
    80003ec8:	44d4                	lw	a3,12(s1)
    80003eca:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ecc:	faf60ee3          	beq	a2,a5,80003e88 <log_write+0x66>
  }
  release(&log.lock);
    80003ed0:	0001c517          	auipc	a0,0x1c
    80003ed4:	c9050513          	addi	a0,a0,-880 # 8001fb60 <log>
    80003ed8:	de5fc0ef          	jal	80000cbc <release>
}
    80003edc:	60e2                	ld	ra,24(sp)
    80003ede:	6442                	ld	s0,16(sp)
    80003ee0:	64a2                	ld	s1,8(sp)
    80003ee2:	6105                	addi	sp,sp,32
    80003ee4:	8082                	ret

0000000080003ee6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003ee6:	1101                	addi	sp,sp,-32
    80003ee8:	ec06                	sd	ra,24(sp)
    80003eea:	e822                	sd	s0,16(sp)
    80003eec:	e426                	sd	s1,8(sp)
    80003eee:	e04a                	sd	s2,0(sp)
    80003ef0:	1000                	addi	s0,sp,32
    80003ef2:	84aa                	mv	s1,a0
    80003ef4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003ef6:	00003597          	auipc	a1,0x3
    80003efa:	65a58593          	addi	a1,a1,1626 # 80007550 <etext+0x550>
    80003efe:	0521                	addi	a0,a0,8
    80003f00:	c9ffc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80003f04:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f08:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f0c:	0204a423          	sw	zero,40(s1)
}
    80003f10:	60e2                	ld	ra,24(sp)
    80003f12:	6442                	ld	s0,16(sp)
    80003f14:	64a2                	ld	s1,8(sp)
    80003f16:	6902                	ld	s2,0(sp)
    80003f18:	6105                	addi	sp,sp,32
    80003f1a:	8082                	ret

0000000080003f1c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f1c:	1101                	addi	sp,sp,-32
    80003f1e:	ec06                	sd	ra,24(sp)
    80003f20:	e822                	sd	s0,16(sp)
    80003f22:	e426                	sd	s1,8(sp)
    80003f24:	e04a                	sd	s2,0(sp)
    80003f26:	1000                	addi	s0,sp,32
    80003f28:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f2a:	00850913          	addi	s2,a0,8
    80003f2e:	854a                	mv	a0,s2
    80003f30:	cf9fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80003f34:	409c                	lw	a5,0(s1)
    80003f36:	c799                	beqz	a5,80003f44 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f38:	85ca                	mv	a1,s2
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	8bafe0ef          	jal	80001ff6 <sleep>
  while (lk->locked) {
    80003f40:	409c                	lw	a5,0(s1)
    80003f42:	fbfd                	bnez	a5,80003f38 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f44:	4785                	li	a5,1
    80003f46:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f48:	ab3fd0ef          	jal	800019fa <myproc>
    80003f4c:	591c                	lw	a5,48(a0)
    80003f4e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f50:	854a                	mv	a0,s2
    80003f52:	d6bfc0ef          	jal	80000cbc <release>
}
    80003f56:	60e2                	ld	ra,24(sp)
    80003f58:	6442                	ld	s0,16(sp)
    80003f5a:	64a2                	ld	s1,8(sp)
    80003f5c:	6902                	ld	s2,0(sp)
    80003f5e:	6105                	addi	sp,sp,32
    80003f60:	8082                	ret

0000000080003f62 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f62:	1101                	addi	sp,sp,-32
    80003f64:	ec06                	sd	ra,24(sp)
    80003f66:	e822                	sd	s0,16(sp)
    80003f68:	e426                	sd	s1,8(sp)
    80003f6a:	e04a                	sd	s2,0(sp)
    80003f6c:	1000                	addi	s0,sp,32
    80003f6e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f70:	00850913          	addi	s2,a0,8
    80003f74:	854a                	mv	a0,s2
    80003f76:	cb3fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80003f7a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f7e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f82:	8526                	mv	a0,s1
    80003f84:	8befe0ef          	jal	80002042 <wakeup>
  release(&lk->lk);
    80003f88:	854a                	mv	a0,s2
    80003f8a:	d33fc0ef          	jal	80000cbc <release>
}
    80003f8e:	60e2                	ld	ra,24(sp)
    80003f90:	6442                	ld	s0,16(sp)
    80003f92:	64a2                	ld	s1,8(sp)
    80003f94:	6902                	ld	s2,0(sp)
    80003f96:	6105                	addi	sp,sp,32
    80003f98:	8082                	ret

0000000080003f9a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f9a:	7179                	addi	sp,sp,-48
    80003f9c:	f406                	sd	ra,40(sp)
    80003f9e:	f022                	sd	s0,32(sp)
    80003fa0:	ec26                	sd	s1,24(sp)
    80003fa2:	e84a                	sd	s2,16(sp)
    80003fa4:	1800                	addi	s0,sp,48
    80003fa6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003fa8:	00850913          	addi	s2,a0,8
    80003fac:	854a                	mv	a0,s2
    80003fae:	c7bfc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fb2:	409c                	lw	a5,0(s1)
    80003fb4:	ef81                	bnez	a5,80003fcc <holdingsleep+0x32>
    80003fb6:	4481                	li	s1,0
  release(&lk->lk);
    80003fb8:	854a                	mv	a0,s2
    80003fba:	d03fc0ef          	jal	80000cbc <release>
  return r;
}
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	70a2                	ld	ra,40(sp)
    80003fc2:	7402                	ld	s0,32(sp)
    80003fc4:	64e2                	ld	s1,24(sp)
    80003fc6:	6942                	ld	s2,16(sp)
    80003fc8:	6145                	addi	sp,sp,48
    80003fca:	8082                	ret
    80003fcc:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fce:	0284a983          	lw	s3,40(s1)
    80003fd2:	a29fd0ef          	jal	800019fa <myproc>
    80003fd6:	5904                	lw	s1,48(a0)
    80003fd8:	413484b3          	sub	s1,s1,s3
    80003fdc:	0014b493          	seqz	s1,s1
    80003fe0:	69a2                	ld	s3,8(sp)
    80003fe2:	bfd9                	j	80003fb8 <holdingsleep+0x1e>

0000000080003fe4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003fe4:	1141                	addi	sp,sp,-16
    80003fe6:	e406                	sd	ra,8(sp)
    80003fe8:	e022                	sd	s0,0(sp)
    80003fea:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003fec:	00003597          	auipc	a1,0x3
    80003ff0:	57458593          	addi	a1,a1,1396 # 80007560 <etext+0x560>
    80003ff4:	0001c517          	auipc	a0,0x1c
    80003ff8:	cb450513          	addi	a0,a0,-844 # 8001fca8 <ftable>
    80003ffc:	ba3fc0ef          	jal	80000b9e <initlock>
}
    80004000:	60a2                	ld	ra,8(sp)
    80004002:	6402                	ld	s0,0(sp)
    80004004:	0141                	addi	sp,sp,16
    80004006:	8082                	ret

0000000080004008 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004008:	1101                	addi	sp,sp,-32
    8000400a:	ec06                	sd	ra,24(sp)
    8000400c:	e822                	sd	s0,16(sp)
    8000400e:	e426                	sd	s1,8(sp)
    80004010:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004012:	0001c517          	auipc	a0,0x1c
    80004016:	c9650513          	addi	a0,a0,-874 # 8001fca8 <ftable>
    8000401a:	c0ffc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000401e:	0001c497          	auipc	s1,0x1c
    80004022:	ca248493          	addi	s1,s1,-862 # 8001fcc0 <ftable+0x18>
    80004026:	0001d717          	auipc	a4,0x1d
    8000402a:	c3a70713          	addi	a4,a4,-966 # 80020c60 <disk>
    if(f->ref == 0){
    8000402e:	40dc                	lw	a5,4(s1)
    80004030:	cf89                	beqz	a5,8000404a <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004032:	02848493          	addi	s1,s1,40
    80004036:	fee49ce3          	bne	s1,a4,8000402e <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000403a:	0001c517          	auipc	a0,0x1c
    8000403e:	c6e50513          	addi	a0,a0,-914 # 8001fca8 <ftable>
    80004042:	c7bfc0ef          	jal	80000cbc <release>
  return 0;
    80004046:	4481                	li	s1,0
    80004048:	a809                	j	8000405a <filealloc+0x52>
      f->ref = 1;
    8000404a:	4785                	li	a5,1
    8000404c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000404e:	0001c517          	auipc	a0,0x1c
    80004052:	c5a50513          	addi	a0,a0,-934 # 8001fca8 <ftable>
    80004056:	c67fc0ef          	jal	80000cbc <release>
}
    8000405a:	8526                	mv	a0,s1
    8000405c:	60e2                	ld	ra,24(sp)
    8000405e:	6442                	ld	s0,16(sp)
    80004060:	64a2                	ld	s1,8(sp)
    80004062:	6105                	addi	sp,sp,32
    80004064:	8082                	ret

0000000080004066 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004066:	1101                	addi	sp,sp,-32
    80004068:	ec06                	sd	ra,24(sp)
    8000406a:	e822                	sd	s0,16(sp)
    8000406c:	e426                	sd	s1,8(sp)
    8000406e:	1000                	addi	s0,sp,32
    80004070:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004072:	0001c517          	auipc	a0,0x1c
    80004076:	c3650513          	addi	a0,a0,-970 # 8001fca8 <ftable>
    8000407a:	baffc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000407e:	40dc                	lw	a5,4(s1)
    80004080:	02f05063          	blez	a5,800040a0 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004084:	2785                	addiw	a5,a5,1
    80004086:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004088:	0001c517          	auipc	a0,0x1c
    8000408c:	c2050513          	addi	a0,a0,-992 # 8001fca8 <ftable>
    80004090:	c2dfc0ef          	jal	80000cbc <release>
  return f;
}
    80004094:	8526                	mv	a0,s1
    80004096:	60e2                	ld	ra,24(sp)
    80004098:	6442                	ld	s0,16(sp)
    8000409a:	64a2                	ld	s1,8(sp)
    8000409c:	6105                	addi	sp,sp,32
    8000409e:	8082                	ret
    panic("filedup");
    800040a0:	00003517          	auipc	a0,0x3
    800040a4:	4c850513          	addi	a0,a0,1224 # 80007568 <etext+0x568>
    800040a8:	f7cfc0ef          	jal	80000824 <panic>

00000000800040ac <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800040ac:	7139                	addi	sp,sp,-64
    800040ae:	fc06                	sd	ra,56(sp)
    800040b0:	f822                	sd	s0,48(sp)
    800040b2:	f426                	sd	s1,40(sp)
    800040b4:	0080                	addi	s0,sp,64
    800040b6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040b8:	0001c517          	auipc	a0,0x1c
    800040bc:	bf050513          	addi	a0,a0,-1040 # 8001fca8 <ftable>
    800040c0:	b69fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800040c4:	40dc                	lw	a5,4(s1)
    800040c6:	04f05a63          	blez	a5,8000411a <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800040ca:	37fd                	addiw	a5,a5,-1
    800040cc:	c0dc                	sw	a5,4(s1)
    800040ce:	06f04063          	bgtz	a5,8000412e <fileclose+0x82>
    800040d2:	f04a                	sd	s2,32(sp)
    800040d4:	ec4e                	sd	s3,24(sp)
    800040d6:	e852                	sd	s4,16(sp)
    800040d8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800040da:	0004a903          	lw	s2,0(s1)
    800040de:	0094c783          	lbu	a5,9(s1)
    800040e2:	89be                	mv	s3,a5
    800040e4:	689c                	ld	a5,16(s1)
    800040e6:	8a3e                	mv	s4,a5
    800040e8:	6c9c                	ld	a5,24(s1)
    800040ea:	8abe                	mv	s5,a5
  f->ref = 0;
    800040ec:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800040f0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800040f4:	0001c517          	auipc	a0,0x1c
    800040f8:	bb450513          	addi	a0,a0,-1100 # 8001fca8 <ftable>
    800040fc:	bc1fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    80004100:	4785                	li	a5,1
    80004102:	04f90163          	beq	s2,a5,80004144 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004106:	ffe9079b          	addiw	a5,s2,-2
    8000410a:	4705                	li	a4,1
    8000410c:	04f77563          	bgeu	a4,a5,80004156 <fileclose+0xaa>
    80004110:	7902                	ld	s2,32(sp)
    80004112:	69e2                	ld	s3,24(sp)
    80004114:	6a42                	ld	s4,16(sp)
    80004116:	6aa2                	ld	s5,8(sp)
    80004118:	a00d                	j	8000413a <fileclose+0x8e>
    8000411a:	f04a                	sd	s2,32(sp)
    8000411c:	ec4e                	sd	s3,24(sp)
    8000411e:	e852                	sd	s4,16(sp)
    80004120:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004122:	00003517          	auipc	a0,0x3
    80004126:	44e50513          	addi	a0,a0,1102 # 80007570 <etext+0x570>
    8000412a:	efafc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    8000412e:	0001c517          	auipc	a0,0x1c
    80004132:	b7a50513          	addi	a0,a0,-1158 # 8001fca8 <ftable>
    80004136:	b87fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000413a:	70e2                	ld	ra,56(sp)
    8000413c:	7442                	ld	s0,48(sp)
    8000413e:	74a2                	ld	s1,40(sp)
    80004140:	6121                	addi	sp,sp,64
    80004142:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004144:	85ce                	mv	a1,s3
    80004146:	8552                	mv	a0,s4
    80004148:	348000ef          	jal	80004490 <pipeclose>
    8000414c:	7902                	ld	s2,32(sp)
    8000414e:	69e2                	ld	s3,24(sp)
    80004150:	6a42                	ld	s4,16(sp)
    80004152:	6aa2                	ld	s5,8(sp)
    80004154:	b7dd                	j	8000413a <fileclose+0x8e>
    begin_op();
    80004156:	b33ff0ef          	jal	80003c88 <begin_op>
    iput(ff.ip);
    8000415a:	8556                	mv	a0,s5
    8000415c:	aa2ff0ef          	jal	800033fe <iput>
    end_op();
    80004160:	b99ff0ef          	jal	80003cf8 <end_op>
    80004164:	7902                	ld	s2,32(sp)
    80004166:	69e2                	ld	s3,24(sp)
    80004168:	6a42                	ld	s4,16(sp)
    8000416a:	6aa2                	ld	s5,8(sp)
    8000416c:	b7f9                	j	8000413a <fileclose+0x8e>

000000008000416e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000416e:	715d                	addi	sp,sp,-80
    80004170:	e486                	sd	ra,72(sp)
    80004172:	e0a2                	sd	s0,64(sp)
    80004174:	fc26                	sd	s1,56(sp)
    80004176:	f052                	sd	s4,32(sp)
    80004178:	0880                	addi	s0,sp,80
    8000417a:	84aa                	mv	s1,a0
    8000417c:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000417e:	87dfd0ef          	jal	800019fa <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004182:	409c                	lw	a5,0(s1)
    80004184:	37f9                	addiw	a5,a5,-2
    80004186:	4705                	li	a4,1
    80004188:	04f76263          	bltu	a4,a5,800041cc <filestat+0x5e>
    8000418c:	f84a                	sd	s2,48(sp)
    8000418e:	f44e                	sd	s3,40(sp)
    80004190:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004192:	6c88                	ld	a0,24(s1)
    80004194:	8e8ff0ef          	jal	8000327c <ilock>
    stati(f->ip, &st);
    80004198:	fb840913          	addi	s2,s0,-72
    8000419c:	85ca                	mv	a1,s2
    8000419e:	6c88                	ld	a0,24(s1)
    800041a0:	c40ff0ef          	jal	800035e0 <stati>
    iunlock(f->ip);
    800041a4:	6c88                	ld	a0,24(s1)
    800041a6:	984ff0ef          	jal	8000332a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800041aa:	46e1                	li	a3,24
    800041ac:	864a                	mv	a2,s2
    800041ae:	85d2                	mv	a1,s4
    800041b0:	0509b503          	ld	a0,80(s3)
    800041b4:	ca0fd0ef          	jal	80001654 <copyout>
    800041b8:	41f5551b          	sraiw	a0,a0,0x1f
    800041bc:	7942                	ld	s2,48(sp)
    800041be:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800041c0:	60a6                	ld	ra,72(sp)
    800041c2:	6406                	ld	s0,64(sp)
    800041c4:	74e2                	ld	s1,56(sp)
    800041c6:	7a02                	ld	s4,32(sp)
    800041c8:	6161                	addi	sp,sp,80
    800041ca:	8082                	ret
  return -1;
    800041cc:	557d                	li	a0,-1
    800041ce:	bfcd                	j	800041c0 <filestat+0x52>

00000000800041d0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041d0:	7179                	addi	sp,sp,-48
    800041d2:	f406                	sd	ra,40(sp)
    800041d4:	f022                	sd	s0,32(sp)
    800041d6:	e84a                	sd	s2,16(sp)
    800041d8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800041da:	00854783          	lbu	a5,8(a0)
    800041de:	cfd1                	beqz	a5,8000427a <fileread+0xaa>
    800041e0:	ec26                	sd	s1,24(sp)
    800041e2:	e44e                	sd	s3,8(sp)
    800041e4:	84aa                	mv	s1,a0
    800041e6:	892e                	mv	s2,a1
    800041e8:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800041ea:	411c                	lw	a5,0(a0)
    800041ec:	4705                	li	a4,1
    800041ee:	04e78363          	beq	a5,a4,80004234 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041f2:	470d                	li	a4,3
    800041f4:	04e78763          	beq	a5,a4,80004242 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800041f8:	4709                	li	a4,2
    800041fa:	06e79a63          	bne	a5,a4,8000426e <fileread+0x9e>
    ilock(f->ip);
    800041fe:	6d08                	ld	a0,24(a0)
    80004200:	87cff0ef          	jal	8000327c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004204:	874e                	mv	a4,s3
    80004206:	5094                	lw	a3,32(s1)
    80004208:	864a                	mv	a2,s2
    8000420a:	4585                	li	a1,1
    8000420c:	6c88                	ld	a0,24(s1)
    8000420e:	c00ff0ef          	jal	8000360e <readi>
    80004212:	892a                	mv	s2,a0
    80004214:	00a05563          	blez	a0,8000421e <fileread+0x4e>
      f->off += r;
    80004218:	509c                	lw	a5,32(s1)
    8000421a:	9fa9                	addw	a5,a5,a0
    8000421c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000421e:	6c88                	ld	a0,24(s1)
    80004220:	90aff0ef          	jal	8000332a <iunlock>
    80004224:	64e2                	ld	s1,24(sp)
    80004226:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004228:	854a                	mv	a0,s2
    8000422a:	70a2                	ld	ra,40(sp)
    8000422c:	7402                	ld	s0,32(sp)
    8000422e:	6942                	ld	s2,16(sp)
    80004230:	6145                	addi	sp,sp,48
    80004232:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004234:	6908                	ld	a0,16(a0)
    80004236:	3b0000ef          	jal	800045e6 <piperead>
    8000423a:	892a                	mv	s2,a0
    8000423c:	64e2                	ld	s1,24(sp)
    8000423e:	69a2                	ld	s3,8(sp)
    80004240:	b7e5                	j	80004228 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004242:	02451783          	lh	a5,36(a0)
    80004246:	03079693          	slli	a3,a5,0x30
    8000424a:	92c1                	srli	a3,a3,0x30
    8000424c:	4725                	li	a4,9
    8000424e:	02d76963          	bltu	a4,a3,80004280 <fileread+0xb0>
    80004252:	0792                	slli	a5,a5,0x4
    80004254:	0001c717          	auipc	a4,0x1c
    80004258:	9b470713          	addi	a4,a4,-1612 # 8001fc08 <devsw>
    8000425c:	97ba                	add	a5,a5,a4
    8000425e:	639c                	ld	a5,0(a5)
    80004260:	c78d                	beqz	a5,8000428a <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004262:	4505                	li	a0,1
    80004264:	9782                	jalr	a5
    80004266:	892a                	mv	s2,a0
    80004268:	64e2                	ld	s1,24(sp)
    8000426a:	69a2                	ld	s3,8(sp)
    8000426c:	bf75                	j	80004228 <fileread+0x58>
    panic("fileread");
    8000426e:	00003517          	auipc	a0,0x3
    80004272:	31250513          	addi	a0,a0,786 # 80007580 <etext+0x580>
    80004276:	daefc0ef          	jal	80000824 <panic>
    return -1;
    8000427a:	57fd                	li	a5,-1
    8000427c:	893e                	mv	s2,a5
    8000427e:	b76d                	j	80004228 <fileread+0x58>
      return -1;
    80004280:	57fd                	li	a5,-1
    80004282:	893e                	mv	s2,a5
    80004284:	64e2                	ld	s1,24(sp)
    80004286:	69a2                	ld	s3,8(sp)
    80004288:	b745                	j	80004228 <fileread+0x58>
    8000428a:	57fd                	li	a5,-1
    8000428c:	893e                	mv	s2,a5
    8000428e:	64e2                	ld	s1,24(sp)
    80004290:	69a2                	ld	s3,8(sp)
    80004292:	bf59                	j	80004228 <fileread+0x58>

0000000080004294 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004294:	00954783          	lbu	a5,9(a0)
    80004298:	10078f63          	beqz	a5,800043b6 <filewrite+0x122>
{
    8000429c:	711d                	addi	sp,sp,-96
    8000429e:	ec86                	sd	ra,88(sp)
    800042a0:	e8a2                	sd	s0,80(sp)
    800042a2:	e0ca                	sd	s2,64(sp)
    800042a4:	f456                	sd	s5,40(sp)
    800042a6:	f05a                	sd	s6,32(sp)
    800042a8:	1080                	addi	s0,sp,96
    800042aa:	892a                	mv	s2,a0
    800042ac:	8b2e                	mv	s6,a1
    800042ae:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800042b0:	411c                	lw	a5,0(a0)
    800042b2:	4705                	li	a4,1
    800042b4:	02e78a63          	beq	a5,a4,800042e8 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042b8:	470d                	li	a4,3
    800042ba:	02e78b63          	beq	a5,a4,800042f0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800042be:	4709                	li	a4,2
    800042c0:	0ce79f63          	bne	a5,a4,8000439e <filewrite+0x10a>
    800042c4:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800042c6:	0ac05a63          	blez	a2,8000437a <filewrite+0xe6>
    800042ca:	e4a6                	sd	s1,72(sp)
    800042cc:	fc4e                	sd	s3,56(sp)
    800042ce:	ec5e                	sd	s7,24(sp)
    800042d0:	e862                	sd	s8,16(sp)
    800042d2:	e466                	sd	s9,8(sp)
    int i = 0;
    800042d4:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800042d6:	6b85                	lui	s7,0x1
    800042d8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800042dc:	6785                	lui	a5,0x1
    800042de:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800042e2:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800042e4:	4c05                	li	s8,1
    800042e6:	a8ad                	j	80004360 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800042e8:	6908                	ld	a0,16(a0)
    800042ea:	204000ef          	jal	800044ee <pipewrite>
    800042ee:	a04d                	j	80004390 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800042f0:	02451783          	lh	a5,36(a0)
    800042f4:	03079693          	slli	a3,a5,0x30
    800042f8:	92c1                	srli	a3,a3,0x30
    800042fa:	4725                	li	a4,9
    800042fc:	0ad76f63          	bltu	a4,a3,800043ba <filewrite+0x126>
    80004300:	0792                	slli	a5,a5,0x4
    80004302:	0001c717          	auipc	a4,0x1c
    80004306:	90670713          	addi	a4,a4,-1786 # 8001fc08 <devsw>
    8000430a:	97ba                	add	a5,a5,a4
    8000430c:	679c                	ld	a5,8(a5)
    8000430e:	cbc5                	beqz	a5,800043be <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004310:	4505                	li	a0,1
    80004312:	9782                	jalr	a5
    80004314:	a8b5                	j	80004390 <filewrite+0xfc>
      if(n1 > max)
    80004316:	2981                	sext.w	s3,s3
      begin_op();
    80004318:	971ff0ef          	jal	80003c88 <begin_op>
      ilock(f->ip);
    8000431c:	01893503          	ld	a0,24(s2)
    80004320:	f5dfe0ef          	jal	8000327c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004324:	874e                	mv	a4,s3
    80004326:	02092683          	lw	a3,32(s2)
    8000432a:	016a0633          	add	a2,s4,s6
    8000432e:	85e2                	mv	a1,s8
    80004330:	01893503          	ld	a0,24(s2)
    80004334:	bccff0ef          	jal	80003700 <writei>
    80004338:	84aa                	mv	s1,a0
    8000433a:	00a05763          	blez	a0,80004348 <filewrite+0xb4>
        f->off += r;
    8000433e:	02092783          	lw	a5,32(s2)
    80004342:	9fa9                	addw	a5,a5,a0
    80004344:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004348:	01893503          	ld	a0,24(s2)
    8000434c:	fdffe0ef          	jal	8000332a <iunlock>
      end_op();
    80004350:	9a9ff0ef          	jal	80003cf8 <end_op>

      if(r != n1){
    80004354:	02999563          	bne	s3,s1,8000437e <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004358:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000435c:	015a5963          	bge	s4,s5,8000436e <filewrite+0xda>
      int n1 = n - i;
    80004360:	414a87bb          	subw	a5,s5,s4
    80004364:	89be                	mv	s3,a5
      if(n1 > max)
    80004366:	fafbd8e3          	bge	s7,a5,80004316 <filewrite+0x82>
    8000436a:	89e6                	mv	s3,s9
    8000436c:	b76d                	j	80004316 <filewrite+0x82>
    8000436e:	64a6                	ld	s1,72(sp)
    80004370:	79e2                	ld	s3,56(sp)
    80004372:	6be2                	ld	s7,24(sp)
    80004374:	6c42                	ld	s8,16(sp)
    80004376:	6ca2                	ld	s9,8(sp)
    80004378:	a801                	j	80004388 <filewrite+0xf4>
    int i = 0;
    8000437a:	4a01                	li	s4,0
    8000437c:	a031                	j	80004388 <filewrite+0xf4>
    8000437e:	64a6                	ld	s1,72(sp)
    80004380:	79e2                	ld	s3,56(sp)
    80004382:	6be2                	ld	s7,24(sp)
    80004384:	6c42                	ld	s8,16(sp)
    80004386:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004388:	034a9d63          	bne	s5,s4,800043c2 <filewrite+0x12e>
    8000438c:	8556                	mv	a0,s5
    8000438e:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004390:	60e6                	ld	ra,88(sp)
    80004392:	6446                	ld	s0,80(sp)
    80004394:	6906                	ld	s2,64(sp)
    80004396:	7aa2                	ld	s5,40(sp)
    80004398:	7b02                	ld	s6,32(sp)
    8000439a:	6125                	addi	sp,sp,96
    8000439c:	8082                	ret
    8000439e:	e4a6                	sd	s1,72(sp)
    800043a0:	fc4e                	sd	s3,56(sp)
    800043a2:	f852                	sd	s4,48(sp)
    800043a4:	ec5e                	sd	s7,24(sp)
    800043a6:	e862                	sd	s8,16(sp)
    800043a8:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800043aa:	00003517          	auipc	a0,0x3
    800043ae:	1e650513          	addi	a0,a0,486 # 80007590 <etext+0x590>
    800043b2:	c72fc0ef          	jal	80000824 <panic>
    return -1;
    800043b6:	557d                	li	a0,-1
}
    800043b8:	8082                	ret
      return -1;
    800043ba:	557d                	li	a0,-1
    800043bc:	bfd1                	j	80004390 <filewrite+0xfc>
    800043be:	557d                	li	a0,-1
    800043c0:	bfc1                	j	80004390 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800043c2:	557d                	li	a0,-1
    800043c4:	7a42                	ld	s4,48(sp)
    800043c6:	b7e9                	j	80004390 <filewrite+0xfc>

00000000800043c8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800043c8:	7179                	addi	sp,sp,-48
    800043ca:	f406                	sd	ra,40(sp)
    800043cc:	f022                	sd	s0,32(sp)
    800043ce:	ec26                	sd	s1,24(sp)
    800043d0:	e052                	sd	s4,0(sp)
    800043d2:	1800                	addi	s0,sp,48
    800043d4:	84aa                	mv	s1,a0
    800043d6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043d8:	0005b023          	sd	zero,0(a1)
    800043dc:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043e0:	c29ff0ef          	jal	80004008 <filealloc>
    800043e4:	e088                	sd	a0,0(s1)
    800043e6:	c549                	beqz	a0,80004470 <pipealloc+0xa8>
    800043e8:	c21ff0ef          	jal	80004008 <filealloc>
    800043ec:	00aa3023          	sd	a0,0(s4)
    800043f0:	cd25                	beqz	a0,80004468 <pipealloc+0xa0>
    800043f2:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800043f4:	f50fc0ef          	jal	80000b44 <kalloc>
    800043f8:	892a                	mv	s2,a0
    800043fa:	c12d                	beqz	a0,8000445c <pipealloc+0x94>
    800043fc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800043fe:	4985                	li	s3,1
    80004400:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004404:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004408:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000440c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004410:	00003597          	auipc	a1,0x3
    80004414:	19058593          	addi	a1,a1,400 # 800075a0 <etext+0x5a0>
    80004418:	f86fc0ef          	jal	80000b9e <initlock>
  (*f0)->type = FD_PIPE;
    8000441c:	609c                	ld	a5,0(s1)
    8000441e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004422:	609c                	ld	a5,0(s1)
    80004424:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004428:	609c                	ld	a5,0(s1)
    8000442a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000442e:	609c                	ld	a5,0(s1)
    80004430:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004434:	000a3783          	ld	a5,0(s4)
    80004438:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000443c:	000a3783          	ld	a5,0(s4)
    80004440:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004444:	000a3783          	ld	a5,0(s4)
    80004448:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000444c:	000a3783          	ld	a5,0(s4)
    80004450:	0127b823          	sd	s2,16(a5)
  return 0;
    80004454:	4501                	li	a0,0
    80004456:	6942                	ld	s2,16(sp)
    80004458:	69a2                	ld	s3,8(sp)
    8000445a:	a01d                	j	80004480 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000445c:	6088                	ld	a0,0(s1)
    8000445e:	c119                	beqz	a0,80004464 <pipealloc+0x9c>
    80004460:	6942                	ld	s2,16(sp)
    80004462:	a029                	j	8000446c <pipealloc+0xa4>
    80004464:	6942                	ld	s2,16(sp)
    80004466:	a029                	j	80004470 <pipealloc+0xa8>
    80004468:	6088                	ld	a0,0(s1)
    8000446a:	c10d                	beqz	a0,8000448c <pipealloc+0xc4>
    fileclose(*f0);
    8000446c:	c41ff0ef          	jal	800040ac <fileclose>
  if(*f1)
    80004470:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004474:	557d                	li	a0,-1
  if(*f1)
    80004476:	c789                	beqz	a5,80004480 <pipealloc+0xb8>
    fileclose(*f1);
    80004478:	853e                	mv	a0,a5
    8000447a:	c33ff0ef          	jal	800040ac <fileclose>
  return -1;
    8000447e:	557d                	li	a0,-1
}
    80004480:	70a2                	ld	ra,40(sp)
    80004482:	7402                	ld	s0,32(sp)
    80004484:	64e2                	ld	s1,24(sp)
    80004486:	6a02                	ld	s4,0(sp)
    80004488:	6145                	addi	sp,sp,48
    8000448a:	8082                	ret
  return -1;
    8000448c:	557d                	li	a0,-1
    8000448e:	bfcd                	j	80004480 <pipealloc+0xb8>

0000000080004490 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004490:	1101                	addi	sp,sp,-32
    80004492:	ec06                	sd	ra,24(sp)
    80004494:	e822                	sd	s0,16(sp)
    80004496:	e426                	sd	s1,8(sp)
    80004498:	e04a                	sd	s2,0(sp)
    8000449a:	1000                	addi	s0,sp,32
    8000449c:	84aa                	mv	s1,a0
    8000449e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044a0:	f88fc0ef          	jal	80000c28 <acquire>
  if(writable){
    800044a4:	02090763          	beqz	s2,800044d2 <pipeclose+0x42>
    pi->writeopen = 0;
    800044a8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044ac:	21848513          	addi	a0,s1,536
    800044b0:	b93fd0ef          	jal	80002042 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800044b4:	2204a783          	lw	a5,544(s1)
    800044b8:	e781                	bnez	a5,800044c0 <pipeclose+0x30>
    800044ba:	2244a783          	lw	a5,548(s1)
    800044be:	c38d                	beqz	a5,800044e0 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    800044c0:	8526                	mv	a0,s1
    800044c2:	ffafc0ef          	jal	80000cbc <release>
}
    800044c6:	60e2                	ld	ra,24(sp)
    800044c8:	6442                	ld	s0,16(sp)
    800044ca:	64a2                	ld	s1,8(sp)
    800044cc:	6902                	ld	s2,0(sp)
    800044ce:	6105                	addi	sp,sp,32
    800044d0:	8082                	ret
    pi->readopen = 0;
    800044d2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044d6:	21c48513          	addi	a0,s1,540
    800044da:	b69fd0ef          	jal	80002042 <wakeup>
    800044de:	bfd9                	j	800044b4 <pipeclose+0x24>
    release(&pi->lock);
    800044e0:	8526                	mv	a0,s1
    800044e2:	fdafc0ef          	jal	80000cbc <release>
    kfree((char*)pi);
    800044e6:	8526                	mv	a0,s1
    800044e8:	d74fc0ef          	jal	80000a5c <kfree>
    800044ec:	bfe9                	j	800044c6 <pipeclose+0x36>

00000000800044ee <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800044ee:	7159                	addi	sp,sp,-112
    800044f0:	f486                	sd	ra,104(sp)
    800044f2:	f0a2                	sd	s0,96(sp)
    800044f4:	eca6                	sd	s1,88(sp)
    800044f6:	e8ca                	sd	s2,80(sp)
    800044f8:	e4ce                	sd	s3,72(sp)
    800044fa:	e0d2                	sd	s4,64(sp)
    800044fc:	fc56                	sd	s5,56(sp)
    800044fe:	1880                	addi	s0,sp,112
    80004500:	84aa                	mv	s1,a0
    80004502:	8aae                	mv	s5,a1
    80004504:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004506:	cf4fd0ef          	jal	800019fa <myproc>
    8000450a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000450c:	8526                	mv	a0,s1
    8000450e:	f1afc0ef          	jal	80000c28 <acquire>
  while(i < n){
    80004512:	0d405263          	blez	s4,800045d6 <pipewrite+0xe8>
    80004516:	f85a                	sd	s6,48(sp)
    80004518:	f45e                	sd	s7,40(sp)
    8000451a:	f062                	sd	s8,32(sp)
    8000451c:	ec66                	sd	s9,24(sp)
    8000451e:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004520:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004522:	f9f40c13          	addi	s8,s0,-97
    80004526:	4b85                	li	s7,1
    80004528:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000452a:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000452e:	21c48c93          	addi	s9,s1,540
    80004532:	a82d                	j	8000456c <pipewrite+0x7e>
      release(&pi->lock);
    80004534:	8526                	mv	a0,s1
    80004536:	f86fc0ef          	jal	80000cbc <release>
      return -1;
    8000453a:	597d                	li	s2,-1
    8000453c:	7b42                	ld	s6,48(sp)
    8000453e:	7ba2                	ld	s7,40(sp)
    80004540:	7c02                	ld	s8,32(sp)
    80004542:	6ce2                	ld	s9,24(sp)
    80004544:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004546:	854a                	mv	a0,s2
    80004548:	70a6                	ld	ra,104(sp)
    8000454a:	7406                	ld	s0,96(sp)
    8000454c:	64e6                	ld	s1,88(sp)
    8000454e:	6946                	ld	s2,80(sp)
    80004550:	69a6                	ld	s3,72(sp)
    80004552:	6a06                	ld	s4,64(sp)
    80004554:	7ae2                	ld	s5,56(sp)
    80004556:	6165                	addi	sp,sp,112
    80004558:	8082                	ret
      wakeup(&pi->nread);
    8000455a:	856a                	mv	a0,s10
    8000455c:	ae7fd0ef          	jal	80002042 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004560:	85a6                	mv	a1,s1
    80004562:	8566                	mv	a0,s9
    80004564:	a93fd0ef          	jal	80001ff6 <sleep>
  while(i < n){
    80004568:	05495a63          	bge	s2,s4,800045bc <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000456c:	2204a783          	lw	a5,544(s1)
    80004570:	d3f1                	beqz	a5,80004534 <pipewrite+0x46>
    80004572:	854e                	mv	a0,s3
    80004574:	ccbfd0ef          	jal	8000223e <killed>
    80004578:	fd55                	bnez	a0,80004534 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000457a:	2184a783          	lw	a5,536(s1)
    8000457e:	21c4a703          	lw	a4,540(s1)
    80004582:	2007879b          	addiw	a5,a5,512
    80004586:	fcf70ae3          	beq	a4,a5,8000455a <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000458a:	86de                	mv	a3,s7
    8000458c:	01590633          	add	a2,s2,s5
    80004590:	85e2                	mv	a1,s8
    80004592:	0509b503          	ld	a0,80(s3)
    80004596:	97cfd0ef          	jal	80001712 <copyin>
    8000459a:	05650063          	beq	a0,s6,800045da <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000459e:	21c4a783          	lw	a5,540(s1)
    800045a2:	0017871b          	addiw	a4,a5,1
    800045a6:	20e4ae23          	sw	a4,540(s1)
    800045aa:	1ff7f793          	andi	a5,a5,511
    800045ae:	97a6                	add	a5,a5,s1
    800045b0:	f9f44703          	lbu	a4,-97(s0)
    800045b4:	00e78c23          	sb	a4,24(a5)
      i++;
    800045b8:	2905                	addiw	s2,s2,1
    800045ba:	b77d                	j	80004568 <pipewrite+0x7a>
    800045bc:	7b42                	ld	s6,48(sp)
    800045be:	7ba2                	ld	s7,40(sp)
    800045c0:	7c02                	ld	s8,32(sp)
    800045c2:	6ce2                	ld	s9,24(sp)
    800045c4:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800045c6:	21848513          	addi	a0,s1,536
    800045ca:	a79fd0ef          	jal	80002042 <wakeup>
  release(&pi->lock);
    800045ce:	8526                	mv	a0,s1
    800045d0:	eecfc0ef          	jal	80000cbc <release>
  return i;
    800045d4:	bf8d                	j	80004546 <pipewrite+0x58>
  int i = 0;
    800045d6:	4901                	li	s2,0
    800045d8:	b7fd                	j	800045c6 <pipewrite+0xd8>
    800045da:	7b42                	ld	s6,48(sp)
    800045dc:	7ba2                	ld	s7,40(sp)
    800045de:	7c02                	ld	s8,32(sp)
    800045e0:	6ce2                	ld	s9,24(sp)
    800045e2:	6d42                	ld	s10,16(sp)
    800045e4:	b7cd                	j	800045c6 <pipewrite+0xd8>

00000000800045e6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045e6:	711d                	addi	sp,sp,-96
    800045e8:	ec86                	sd	ra,88(sp)
    800045ea:	e8a2                	sd	s0,80(sp)
    800045ec:	e4a6                	sd	s1,72(sp)
    800045ee:	e0ca                	sd	s2,64(sp)
    800045f0:	fc4e                	sd	s3,56(sp)
    800045f2:	f852                	sd	s4,48(sp)
    800045f4:	f456                	sd	s5,40(sp)
    800045f6:	1080                	addi	s0,sp,96
    800045f8:	84aa                	mv	s1,a0
    800045fa:	892e                	mv	s2,a1
    800045fc:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800045fe:	bfcfd0ef          	jal	800019fa <myproc>
    80004602:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004604:	8526                	mv	a0,s1
    80004606:	e22fc0ef          	jal	80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000460a:	2184a703          	lw	a4,536(s1)
    8000460e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004612:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004616:	02f71763          	bne	a4,a5,80004644 <piperead+0x5e>
    8000461a:	2244a783          	lw	a5,548(s1)
    8000461e:	cf85                	beqz	a5,80004656 <piperead+0x70>
    if(killed(pr)){
    80004620:	8552                	mv	a0,s4
    80004622:	c1dfd0ef          	jal	8000223e <killed>
    80004626:	e11d                	bnez	a0,8000464c <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004628:	85a6                	mv	a1,s1
    8000462a:	854e                	mv	a0,s3
    8000462c:	9cbfd0ef          	jal	80001ff6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004630:	2184a703          	lw	a4,536(s1)
    80004634:	21c4a783          	lw	a5,540(s1)
    80004638:	fef701e3          	beq	a4,a5,8000461a <piperead+0x34>
    8000463c:	f05a                	sd	s6,32(sp)
    8000463e:	ec5e                	sd	s7,24(sp)
    80004640:	e862                	sd	s8,16(sp)
    80004642:	a829                	j	8000465c <piperead+0x76>
    80004644:	f05a                	sd	s6,32(sp)
    80004646:	ec5e                	sd	s7,24(sp)
    80004648:	e862                	sd	s8,16(sp)
    8000464a:	a809                	j	8000465c <piperead+0x76>
      release(&pi->lock);
    8000464c:	8526                	mv	a0,s1
    8000464e:	e6efc0ef          	jal	80000cbc <release>
      return -1;
    80004652:	59fd                	li	s3,-1
    80004654:	a0a5                	j	800046bc <piperead+0xd6>
    80004656:	f05a                	sd	s6,32(sp)
    80004658:	ec5e                	sd	s7,24(sp)
    8000465a:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000465c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000465e:	faf40c13          	addi	s8,s0,-81
    80004662:	4b85                	li	s7,1
    80004664:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004666:	05505163          	blez	s5,800046a8 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    8000466a:	2184a783          	lw	a5,536(s1)
    8000466e:	21c4a703          	lw	a4,540(s1)
    80004672:	02f70b63          	beq	a4,a5,800046a8 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004676:	1ff7f793          	andi	a5,a5,511
    8000467a:	97a6                	add	a5,a5,s1
    8000467c:	0187c783          	lbu	a5,24(a5)
    80004680:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004684:	86de                	mv	a3,s7
    80004686:	8662                	mv	a2,s8
    80004688:	85ca                	mv	a1,s2
    8000468a:	050a3503          	ld	a0,80(s4)
    8000468e:	fc7fc0ef          	jal	80001654 <copyout>
    80004692:	03650f63          	beq	a0,s6,800046d0 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004696:	2184a783          	lw	a5,536(s1)
    8000469a:	2785                	addiw	a5,a5,1
    8000469c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046a0:	2985                	addiw	s3,s3,1
    800046a2:	0905                	addi	s2,s2,1
    800046a4:	fd3a93e3          	bne	s5,s3,8000466a <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800046a8:	21c48513          	addi	a0,s1,540
    800046ac:	997fd0ef          	jal	80002042 <wakeup>
  release(&pi->lock);
    800046b0:	8526                	mv	a0,s1
    800046b2:	e0afc0ef          	jal	80000cbc <release>
    800046b6:	7b02                	ld	s6,32(sp)
    800046b8:	6be2                	ld	s7,24(sp)
    800046ba:	6c42                	ld	s8,16(sp)
  return i;
}
    800046bc:	854e                	mv	a0,s3
    800046be:	60e6                	ld	ra,88(sp)
    800046c0:	6446                	ld	s0,80(sp)
    800046c2:	64a6                	ld	s1,72(sp)
    800046c4:	6906                	ld	s2,64(sp)
    800046c6:	79e2                	ld	s3,56(sp)
    800046c8:	7a42                	ld	s4,48(sp)
    800046ca:	7aa2                	ld	s5,40(sp)
    800046cc:	6125                	addi	sp,sp,96
    800046ce:	8082                	ret
      if(i == 0)
    800046d0:	fc099ce3          	bnez	s3,800046a8 <piperead+0xc2>
        i = -1;
    800046d4:	89aa                	mv	s3,a0
    800046d6:	bfc9                	j	800046a8 <piperead+0xc2>

00000000800046d8 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800046d8:	1141                	addi	sp,sp,-16
    800046da:	e406                	sd	ra,8(sp)
    800046dc:	e022                	sd	s0,0(sp)
    800046de:	0800                	addi	s0,sp,16
    800046e0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800046e2:	0035151b          	slliw	a0,a0,0x3
    800046e6:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800046e8:	8b89                	andi	a5,a5,2
    800046ea:	c399                	beqz	a5,800046f0 <flags2perm+0x18>
      perm |= PTE_W;
    800046ec:	00456513          	ori	a0,a0,4
    return perm;
}
    800046f0:	60a2                	ld	ra,8(sp)
    800046f2:	6402                	ld	s0,0(sp)
    800046f4:	0141                	addi	sp,sp,16
    800046f6:	8082                	ret

00000000800046f8 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800046f8:	de010113          	addi	sp,sp,-544
    800046fc:	20113c23          	sd	ra,536(sp)
    80004700:	20813823          	sd	s0,528(sp)
    80004704:	20913423          	sd	s1,520(sp)
    80004708:	21213023          	sd	s2,512(sp)
    8000470c:	1400                	addi	s0,sp,544
    8000470e:	892a                	mv	s2,a0
    80004710:	dea43823          	sd	a0,-528(s0)
    80004714:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004718:	ae2fd0ef          	jal	800019fa <myproc>
    8000471c:	84aa                	mv	s1,a0

  begin_op();
    8000471e:	d6aff0ef          	jal	80003c88 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004722:	854a                	mv	a0,s2
    80004724:	b86ff0ef          	jal	80003aaa <namei>
    80004728:	cd21                	beqz	a0,80004780 <kexec+0x88>
    8000472a:	fbd2                	sd	s4,496(sp)
    8000472c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000472e:	b4ffe0ef          	jal	8000327c <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004732:	04000713          	li	a4,64
    80004736:	4681                	li	a3,0
    80004738:	e5040613          	addi	a2,s0,-432
    8000473c:	4581                	li	a1,0
    8000473e:	8552                	mv	a0,s4
    80004740:	ecffe0ef          	jal	8000360e <readi>
    80004744:	04000793          	li	a5,64
    80004748:	00f51a63          	bne	a0,a5,8000475c <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000474c:	e5042703          	lw	a4,-432(s0)
    80004750:	464c47b7          	lui	a5,0x464c4
    80004754:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004758:	02f70863          	beq	a4,a5,80004788 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000475c:	8552                	mv	a0,s4
    8000475e:	d2bfe0ef          	jal	80003488 <iunlockput>
    end_op();
    80004762:	d96ff0ef          	jal	80003cf8 <end_op>
  }
  return -1;
    80004766:	557d                	li	a0,-1
    80004768:	7a5e                	ld	s4,496(sp)
}
    8000476a:	21813083          	ld	ra,536(sp)
    8000476e:	21013403          	ld	s0,528(sp)
    80004772:	20813483          	ld	s1,520(sp)
    80004776:	20013903          	ld	s2,512(sp)
    8000477a:	22010113          	addi	sp,sp,544
    8000477e:	8082                	ret
    end_op();
    80004780:	d78ff0ef          	jal	80003cf8 <end_op>
    return -1;
    80004784:	557d                	li	a0,-1
    80004786:	b7d5                	j	8000476a <kexec+0x72>
    80004788:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000478a:	8526                	mv	a0,s1
    8000478c:	b78fd0ef          	jal	80001b04 <proc_pagetable>
    80004790:	8b2a                	mv	s6,a0
    80004792:	26050f63          	beqz	a0,80004a10 <kexec+0x318>
    80004796:	ffce                	sd	s3,504(sp)
    80004798:	f7d6                	sd	s5,488(sp)
    8000479a:	efde                	sd	s7,472(sp)
    8000479c:	ebe2                	sd	s8,464(sp)
    8000479e:	e7e6                	sd	s9,456(sp)
    800047a0:	e3ea                	sd	s10,448(sp)
    800047a2:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047a4:	e8845783          	lhu	a5,-376(s0)
    800047a8:	0e078963          	beqz	a5,8000489a <kexec+0x1a2>
    800047ac:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047b0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047b2:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047b4:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800047b8:	6c85                	lui	s9,0x1
    800047ba:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047be:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800047c2:	6a85                	lui	s5,0x1
    800047c4:	a085                	j	80004824 <kexec+0x12c>
      panic("loadseg: address should exist");
    800047c6:	00003517          	auipc	a0,0x3
    800047ca:	de250513          	addi	a0,a0,-542 # 800075a8 <etext+0x5a8>
    800047ce:	856fc0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    800047d2:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047d4:	874a                	mv	a4,s2
    800047d6:	009b86bb          	addw	a3,s7,s1
    800047da:	4581                	li	a1,0
    800047dc:	8552                	mv	a0,s4
    800047de:	e31fe0ef          	jal	8000360e <readi>
    800047e2:	22a91b63          	bne	s2,a0,80004a18 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    800047e6:	009a84bb          	addw	s1,s5,s1
    800047ea:	0334f263          	bgeu	s1,s3,8000480e <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800047ee:	02049593          	slli	a1,s1,0x20
    800047f2:	9181                	srli	a1,a1,0x20
    800047f4:	95e2                	add	a1,a1,s8
    800047f6:	855a                	mv	a0,s6
    800047f8:	82ffc0ef          	jal	80001026 <walkaddr>
    800047fc:	862a                	mv	a2,a0
    if(pa == 0)
    800047fe:	d561                	beqz	a0,800047c6 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004800:	409987bb          	subw	a5,s3,s1
    80004804:	893e                	mv	s2,a5
    80004806:	fcfcf6e3          	bgeu	s9,a5,800047d2 <kexec+0xda>
    8000480a:	8956                	mv	s2,s5
    8000480c:	b7d9                	j	800047d2 <kexec+0xda>
    sz = sz1;
    8000480e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004812:	2d05                	addiw	s10,s10,1
    80004814:	e0843783          	ld	a5,-504(s0)
    80004818:	0387869b          	addiw	a3,a5,56
    8000481c:	e8845783          	lhu	a5,-376(s0)
    80004820:	06fd5e63          	bge	s10,a5,8000489c <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004824:	e0d43423          	sd	a3,-504(s0)
    80004828:	876e                	mv	a4,s11
    8000482a:	e1840613          	addi	a2,s0,-488
    8000482e:	4581                	li	a1,0
    80004830:	8552                	mv	a0,s4
    80004832:	dddfe0ef          	jal	8000360e <readi>
    80004836:	1db51f63          	bne	a0,s11,80004a14 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    8000483a:	e1842783          	lw	a5,-488(s0)
    8000483e:	4705                	li	a4,1
    80004840:	fce799e3          	bne	a5,a4,80004812 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004844:	e4043483          	ld	s1,-448(s0)
    80004848:	e3843783          	ld	a5,-456(s0)
    8000484c:	1ef4e463          	bltu	s1,a5,80004a34 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004850:	e2843783          	ld	a5,-472(s0)
    80004854:	94be                	add	s1,s1,a5
    80004856:	1ef4e263          	bltu	s1,a5,80004a3a <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    8000485a:	de843703          	ld	a4,-536(s0)
    8000485e:	8ff9                	and	a5,a5,a4
    80004860:	1e079063          	bnez	a5,80004a40 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004864:	e1c42503          	lw	a0,-484(s0)
    80004868:	e71ff0ef          	jal	800046d8 <flags2perm>
    8000486c:	86aa                	mv	a3,a0
    8000486e:	8626                	mv	a2,s1
    80004870:	85ca                	mv	a1,s2
    80004872:	855a                	mv	a0,s6
    80004874:	a89fc0ef          	jal	800012fc <uvmalloc>
    80004878:	dea43c23          	sd	a0,-520(s0)
    8000487c:	1c050563          	beqz	a0,80004a46 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004880:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004884:	00098863          	beqz	s3,80004894 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004888:	e2843c03          	ld	s8,-472(s0)
    8000488c:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004890:	4481                	li	s1,0
    80004892:	bfb1                	j	800047ee <kexec+0xf6>
    sz = sz1;
    80004894:	df843903          	ld	s2,-520(s0)
    80004898:	bfad                	j	80004812 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000489a:	4901                	li	s2,0
  iunlockput(ip);
    8000489c:	8552                	mv	a0,s4
    8000489e:	bebfe0ef          	jal	80003488 <iunlockput>
  end_op();
    800048a2:	c56ff0ef          	jal	80003cf8 <end_op>
  p = myproc();
    800048a6:	954fd0ef          	jal	800019fa <myproc>
    800048aa:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800048ac:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800048b0:	6985                	lui	s3,0x1
    800048b2:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800048b4:	99ca                	add	s3,s3,s2
    800048b6:	77fd                	lui	a5,0xfffff
    800048b8:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048bc:	4691                	li	a3,4
    800048be:	6609                	lui	a2,0x2
    800048c0:	964e                	add	a2,a2,s3
    800048c2:	85ce                	mv	a1,s3
    800048c4:	855a                	mv	a0,s6
    800048c6:	a37fc0ef          	jal	800012fc <uvmalloc>
    800048ca:	8a2a                	mv	s4,a0
    800048cc:	e105                	bnez	a0,800048ec <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800048ce:	85ce                	mv	a1,s3
    800048d0:	855a                	mv	a0,s6
    800048d2:	ab6fd0ef          	jal	80001b88 <proc_freepagetable>
  return -1;
    800048d6:	557d                	li	a0,-1
    800048d8:	79fe                	ld	s3,504(sp)
    800048da:	7a5e                	ld	s4,496(sp)
    800048dc:	7abe                	ld	s5,488(sp)
    800048de:	7b1e                	ld	s6,480(sp)
    800048e0:	6bfe                	ld	s7,472(sp)
    800048e2:	6c5e                	ld	s8,464(sp)
    800048e4:	6cbe                	ld	s9,456(sp)
    800048e6:	6d1e                	ld	s10,448(sp)
    800048e8:	7dfa                	ld	s11,440(sp)
    800048ea:	b541                	j	8000476a <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800048ec:	75f9                	lui	a1,0xffffe
    800048ee:	95aa                	add	a1,a1,a0
    800048f0:	855a                	mv	a0,s6
    800048f2:	bddfc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800048f6:	800a0b93          	addi	s7,s4,-2048
    800048fa:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    800048fe:	e0043783          	ld	a5,-512(s0)
    80004902:	6388                	ld	a0,0(a5)
  sp = sz;
    80004904:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004906:	4481                	li	s1,0
    ustack[argc] = sp;
    80004908:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    8000490c:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004910:	cd21                	beqz	a0,80004968 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004912:	d70fc0ef          	jal	80000e82 <strlen>
    80004916:	0015079b          	addiw	a5,a0,1
    8000491a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000491e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004922:	13796563          	bltu	s2,s7,80004a4c <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004926:	e0043d83          	ld	s11,-512(s0)
    8000492a:	000db983          	ld	s3,0(s11)
    8000492e:	854e                	mv	a0,s3
    80004930:	d52fc0ef          	jal	80000e82 <strlen>
    80004934:	0015069b          	addiw	a3,a0,1
    80004938:	864e                	mv	a2,s3
    8000493a:	85ca                	mv	a1,s2
    8000493c:	855a                	mv	a0,s6
    8000493e:	d17fc0ef          	jal	80001654 <copyout>
    80004942:	10054763          	bltz	a0,80004a50 <kexec+0x358>
    ustack[argc] = sp;
    80004946:	00349793          	slli	a5,s1,0x3
    8000494a:	97e6                	add	a5,a5,s9
    8000494c:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde260>
  for(argc = 0; argv[argc]; argc++) {
    80004950:	0485                	addi	s1,s1,1
    80004952:	008d8793          	addi	a5,s11,8
    80004956:	e0f43023          	sd	a5,-512(s0)
    8000495a:	008db503          	ld	a0,8(s11)
    8000495e:	c509                	beqz	a0,80004968 <kexec+0x270>
    if(argc >= MAXARG)
    80004960:	fb8499e3          	bne	s1,s8,80004912 <kexec+0x21a>
  sz = sz1;
    80004964:	89d2                	mv	s3,s4
    80004966:	b7a5                	j	800048ce <kexec+0x1d6>
  ustack[argc] = 0;
    80004968:	00349793          	slli	a5,s1,0x3
    8000496c:	f9078793          	addi	a5,a5,-112
    80004970:	97a2                	add	a5,a5,s0
    80004972:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004976:	00349693          	slli	a3,s1,0x3
    8000497a:	06a1                	addi	a3,a3,8
    8000497c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004980:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004984:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004986:	f57964e3          	bltu	s2,s7,800048ce <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000498a:	e9040613          	addi	a2,s0,-368
    8000498e:	85ca                	mv	a1,s2
    80004990:	855a                	mv	a0,s6
    80004992:	cc3fc0ef          	jal	80001654 <copyout>
    80004996:	f2054ce3          	bltz	a0,800048ce <kexec+0x1d6>
  p->trapframe->a1 = sp;
    8000499a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000499e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800049a2:	df043783          	ld	a5,-528(s0)
    800049a6:	0007c703          	lbu	a4,0(a5)
    800049aa:	cf11                	beqz	a4,800049c6 <kexec+0x2ce>
    800049ac:	0785                	addi	a5,a5,1
    if(*s == '/')
    800049ae:	02f00693          	li	a3,47
    800049b2:	a029                	j	800049bc <kexec+0x2c4>
  for(last=s=path; *s; s++)
    800049b4:	0785                	addi	a5,a5,1
    800049b6:	fff7c703          	lbu	a4,-1(a5)
    800049ba:	c711                	beqz	a4,800049c6 <kexec+0x2ce>
    if(*s == '/')
    800049bc:	fed71ce3          	bne	a4,a3,800049b4 <kexec+0x2bc>
      last = s+1;
    800049c0:	def43823          	sd	a5,-528(s0)
    800049c4:	bfc5                	j	800049b4 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    800049c6:	4641                	li	a2,16
    800049c8:	df043583          	ld	a1,-528(s0)
    800049cc:	158a8513          	addi	a0,s5,344
    800049d0:	c7cfc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    800049d4:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800049d8:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800049dc:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800049e0:	058ab783          	ld	a5,88(s5)
    800049e4:	e6843703          	ld	a4,-408(s0)
    800049e8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800049ea:	058ab783          	ld	a5,88(s5)
    800049ee:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800049f2:	85ea                	mv	a1,s10
    800049f4:	994fd0ef          	jal	80001b88 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800049f8:	0004851b          	sext.w	a0,s1
    800049fc:	79fe                	ld	s3,504(sp)
    800049fe:	7a5e                	ld	s4,496(sp)
    80004a00:	7abe                	ld	s5,488(sp)
    80004a02:	7b1e                	ld	s6,480(sp)
    80004a04:	6bfe                	ld	s7,472(sp)
    80004a06:	6c5e                	ld	s8,464(sp)
    80004a08:	6cbe                	ld	s9,456(sp)
    80004a0a:	6d1e                	ld	s10,448(sp)
    80004a0c:	7dfa                	ld	s11,440(sp)
    80004a0e:	bbb1                	j	8000476a <kexec+0x72>
    80004a10:	7b1e                	ld	s6,480(sp)
    80004a12:	b3a9                	j	8000475c <kexec+0x64>
    80004a14:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004a18:	df843583          	ld	a1,-520(s0)
    80004a1c:	855a                	mv	a0,s6
    80004a1e:	96afd0ef          	jal	80001b88 <proc_freepagetable>
  if(ip){
    80004a22:	79fe                	ld	s3,504(sp)
    80004a24:	7abe                	ld	s5,488(sp)
    80004a26:	7b1e                	ld	s6,480(sp)
    80004a28:	6bfe                	ld	s7,472(sp)
    80004a2a:	6c5e                	ld	s8,464(sp)
    80004a2c:	6cbe                	ld	s9,456(sp)
    80004a2e:	6d1e                	ld	s10,448(sp)
    80004a30:	7dfa                	ld	s11,440(sp)
    80004a32:	b32d                	j	8000475c <kexec+0x64>
    80004a34:	df243c23          	sd	s2,-520(s0)
    80004a38:	b7c5                	j	80004a18 <kexec+0x320>
    80004a3a:	df243c23          	sd	s2,-520(s0)
    80004a3e:	bfe9                	j	80004a18 <kexec+0x320>
    80004a40:	df243c23          	sd	s2,-520(s0)
    80004a44:	bfd1                	j	80004a18 <kexec+0x320>
    80004a46:	df243c23          	sd	s2,-520(s0)
    80004a4a:	b7f9                	j	80004a18 <kexec+0x320>
  sz = sz1;
    80004a4c:	89d2                	mv	s3,s4
    80004a4e:	b541                	j	800048ce <kexec+0x1d6>
    80004a50:	89d2                	mv	s3,s4
    80004a52:	bdb5                	j	800048ce <kexec+0x1d6>

0000000080004a54 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a54:	7179                	addi	sp,sp,-48
    80004a56:	f406                	sd	ra,40(sp)
    80004a58:	f022                	sd	s0,32(sp)
    80004a5a:	ec26                	sd	s1,24(sp)
    80004a5c:	e84a                	sd	s2,16(sp)
    80004a5e:	1800                	addi	s0,sp,48
    80004a60:	892e                	mv	s2,a1
    80004a62:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a64:	fdc40593          	addi	a1,s0,-36
    80004a68:	e4bfd0ef          	jal	800028b2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a6c:	fdc42703          	lw	a4,-36(s0)
    80004a70:	47bd                	li	a5,15
    80004a72:	02e7ea63          	bltu	a5,a4,80004aa6 <argfd+0x52>
    80004a76:	f85fc0ef          	jal	800019fa <myproc>
    80004a7a:	fdc42703          	lw	a4,-36(s0)
    80004a7e:	00371793          	slli	a5,a4,0x3
    80004a82:	0d078793          	addi	a5,a5,208
    80004a86:	953e                	add	a0,a0,a5
    80004a88:	611c                	ld	a5,0(a0)
    80004a8a:	c385                	beqz	a5,80004aaa <argfd+0x56>
    return -1;
  if(pfd)
    80004a8c:	00090463          	beqz	s2,80004a94 <argfd+0x40>
    *pfd = fd;
    80004a90:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a94:	4501                	li	a0,0
  if(pf)
    80004a96:	c091                	beqz	s1,80004a9a <argfd+0x46>
    *pf = f;
    80004a98:	e09c                	sd	a5,0(s1)
}
    80004a9a:	70a2                	ld	ra,40(sp)
    80004a9c:	7402                	ld	s0,32(sp)
    80004a9e:	64e2                	ld	s1,24(sp)
    80004aa0:	6942                	ld	s2,16(sp)
    80004aa2:	6145                	addi	sp,sp,48
    80004aa4:	8082                	ret
    return -1;
    80004aa6:	557d                	li	a0,-1
    80004aa8:	bfcd                	j	80004a9a <argfd+0x46>
    80004aaa:	557d                	li	a0,-1
    80004aac:	b7fd                	j	80004a9a <argfd+0x46>

0000000080004aae <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004aae:	1101                	addi	sp,sp,-32
    80004ab0:	ec06                	sd	ra,24(sp)
    80004ab2:	e822                	sd	s0,16(sp)
    80004ab4:	e426                	sd	s1,8(sp)
    80004ab6:	1000                	addi	s0,sp,32
    80004ab8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004aba:	f41fc0ef          	jal	800019fa <myproc>
    80004abe:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ac0:	0d050793          	addi	a5,a0,208
    80004ac4:	4501                	li	a0,0
    80004ac6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ac8:	6398                	ld	a4,0(a5)
    80004aca:	cb19                	beqz	a4,80004ae0 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004acc:	2505                	addiw	a0,a0,1
    80004ace:	07a1                	addi	a5,a5,8
    80004ad0:	fed51ce3          	bne	a0,a3,80004ac8 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ad4:	557d                	li	a0,-1
}
    80004ad6:	60e2                	ld	ra,24(sp)
    80004ad8:	6442                	ld	s0,16(sp)
    80004ada:	64a2                	ld	s1,8(sp)
    80004adc:	6105                	addi	sp,sp,32
    80004ade:	8082                	ret
      p->ofile[fd] = f;
    80004ae0:	00351793          	slli	a5,a0,0x3
    80004ae4:	0d078793          	addi	a5,a5,208
    80004ae8:	963e                	add	a2,a2,a5
    80004aea:	e204                	sd	s1,0(a2)
      return fd;
    80004aec:	b7ed                	j	80004ad6 <fdalloc+0x28>

0000000080004aee <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004aee:	715d                	addi	sp,sp,-80
    80004af0:	e486                	sd	ra,72(sp)
    80004af2:	e0a2                	sd	s0,64(sp)
    80004af4:	fc26                	sd	s1,56(sp)
    80004af6:	f84a                	sd	s2,48(sp)
    80004af8:	f44e                	sd	s3,40(sp)
    80004afa:	f052                	sd	s4,32(sp)
    80004afc:	ec56                	sd	s5,24(sp)
    80004afe:	e85a                	sd	s6,16(sp)
    80004b00:	0880                	addi	s0,sp,80
    80004b02:	892e                	mv	s2,a1
    80004b04:	8a2e                	mv	s4,a1
    80004b06:	8ab2                	mv	s5,a2
    80004b08:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b0a:	fb040593          	addi	a1,s0,-80
    80004b0e:	fb7fe0ef          	jal	80003ac4 <nameiparent>
    80004b12:	84aa                	mv	s1,a0
    80004b14:	10050763          	beqz	a0,80004c22 <create+0x134>
    return 0;

  ilock(dp);
    80004b18:	f64fe0ef          	jal	8000327c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b1c:	4601                	li	a2,0
    80004b1e:	fb040593          	addi	a1,s0,-80
    80004b22:	8526                	mv	a0,s1
    80004b24:	cf3fe0ef          	jal	80003816 <dirlookup>
    80004b28:	89aa                	mv	s3,a0
    80004b2a:	c131                	beqz	a0,80004b6e <create+0x80>
    iunlockput(dp);
    80004b2c:	8526                	mv	a0,s1
    80004b2e:	95bfe0ef          	jal	80003488 <iunlockput>
    ilock(ip);
    80004b32:	854e                	mv	a0,s3
    80004b34:	f48fe0ef          	jal	8000327c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b38:	4789                	li	a5,2
    80004b3a:	02f91563          	bne	s2,a5,80004b64 <create+0x76>
    80004b3e:	0449d783          	lhu	a5,68(s3)
    80004b42:	37f9                	addiw	a5,a5,-2
    80004b44:	17c2                	slli	a5,a5,0x30
    80004b46:	93c1                	srli	a5,a5,0x30
    80004b48:	4705                	li	a4,1
    80004b4a:	00f76d63          	bltu	a4,a5,80004b64 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b4e:	854e                	mv	a0,s3
    80004b50:	60a6                	ld	ra,72(sp)
    80004b52:	6406                	ld	s0,64(sp)
    80004b54:	74e2                	ld	s1,56(sp)
    80004b56:	7942                	ld	s2,48(sp)
    80004b58:	79a2                	ld	s3,40(sp)
    80004b5a:	7a02                	ld	s4,32(sp)
    80004b5c:	6ae2                	ld	s5,24(sp)
    80004b5e:	6b42                	ld	s6,16(sp)
    80004b60:	6161                	addi	sp,sp,80
    80004b62:	8082                	ret
    iunlockput(ip);
    80004b64:	854e                	mv	a0,s3
    80004b66:	923fe0ef          	jal	80003488 <iunlockput>
    return 0;
    80004b6a:	4981                	li	s3,0
    80004b6c:	b7cd                	j	80004b4e <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b6e:	85ca                	mv	a1,s2
    80004b70:	4088                	lw	a0,0(s1)
    80004b72:	d9afe0ef          	jal	8000310c <ialloc>
    80004b76:	892a                	mv	s2,a0
    80004b78:	cd15                	beqz	a0,80004bb4 <create+0xc6>
  ilock(ip);
    80004b7a:	f02fe0ef          	jal	8000327c <ilock>
  ip->major = major;
    80004b7e:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004b82:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004b86:	4785                	li	a5,1
    80004b88:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004b8c:	854a                	mv	a0,s2
    80004b8e:	e3afe0ef          	jal	800031c8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b92:	4705                	li	a4,1
    80004b94:	02ea0463          	beq	s4,a4,80004bbc <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b98:	00492603          	lw	a2,4(s2)
    80004b9c:	fb040593          	addi	a1,s0,-80
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	e5ffe0ef          	jal	80003a00 <dirlink>
    80004ba6:	06054263          	bltz	a0,80004c0a <create+0x11c>
  iunlockput(dp);
    80004baa:	8526                	mv	a0,s1
    80004bac:	8ddfe0ef          	jal	80003488 <iunlockput>
  return ip;
    80004bb0:	89ca                	mv	s3,s2
    80004bb2:	bf71                	j	80004b4e <create+0x60>
    iunlockput(dp);
    80004bb4:	8526                	mv	a0,s1
    80004bb6:	8d3fe0ef          	jal	80003488 <iunlockput>
    return 0;
    80004bba:	bf51                	j	80004b4e <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004bbc:	00492603          	lw	a2,4(s2)
    80004bc0:	00003597          	auipc	a1,0x3
    80004bc4:	a0858593          	addi	a1,a1,-1528 # 800075c8 <etext+0x5c8>
    80004bc8:	854a                	mv	a0,s2
    80004bca:	e37fe0ef          	jal	80003a00 <dirlink>
    80004bce:	02054e63          	bltz	a0,80004c0a <create+0x11c>
    80004bd2:	40d0                	lw	a2,4(s1)
    80004bd4:	00003597          	auipc	a1,0x3
    80004bd8:	9fc58593          	addi	a1,a1,-1540 # 800075d0 <etext+0x5d0>
    80004bdc:	854a                	mv	a0,s2
    80004bde:	e23fe0ef          	jal	80003a00 <dirlink>
    80004be2:	02054463          	bltz	a0,80004c0a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004be6:	00492603          	lw	a2,4(s2)
    80004bea:	fb040593          	addi	a1,s0,-80
    80004bee:	8526                	mv	a0,s1
    80004bf0:	e11fe0ef          	jal	80003a00 <dirlink>
    80004bf4:	00054b63          	bltz	a0,80004c0a <create+0x11c>
    dp->nlink++;  // for ".."
    80004bf8:	04a4d783          	lhu	a5,74(s1)
    80004bfc:	2785                	addiw	a5,a5,1
    80004bfe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c02:	8526                	mv	a0,s1
    80004c04:	dc4fe0ef          	jal	800031c8 <iupdate>
    80004c08:	b74d                	j	80004baa <create+0xbc>
  ip->nlink = 0;
    80004c0a:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004c0e:	854a                	mv	a0,s2
    80004c10:	db8fe0ef          	jal	800031c8 <iupdate>
  iunlockput(ip);
    80004c14:	854a                	mv	a0,s2
    80004c16:	873fe0ef          	jal	80003488 <iunlockput>
  iunlockput(dp);
    80004c1a:	8526                	mv	a0,s1
    80004c1c:	86dfe0ef          	jal	80003488 <iunlockput>
  return 0;
    80004c20:	b73d                	j	80004b4e <create+0x60>
    return 0;
    80004c22:	89aa                	mv	s3,a0
    80004c24:	b72d                	j	80004b4e <create+0x60>

0000000080004c26 <sys_dup>:
{
    80004c26:	7179                	addi	sp,sp,-48
    80004c28:	f406                	sd	ra,40(sp)
    80004c2a:	f022                	sd	s0,32(sp)
    80004c2c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c2e:	fd840613          	addi	a2,s0,-40
    80004c32:	4581                	li	a1,0
    80004c34:	4501                	li	a0,0
    80004c36:	e1fff0ef          	jal	80004a54 <argfd>
    return -1;
    80004c3a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c3c:	02054363          	bltz	a0,80004c62 <sys_dup+0x3c>
    80004c40:	ec26                	sd	s1,24(sp)
    80004c42:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c44:	fd843483          	ld	s1,-40(s0)
    80004c48:	8526                	mv	a0,s1
    80004c4a:	e65ff0ef          	jal	80004aae <fdalloc>
    80004c4e:	892a                	mv	s2,a0
    return -1;
    80004c50:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c52:	00054d63          	bltz	a0,80004c6c <sys_dup+0x46>
  filedup(f);
    80004c56:	8526                	mv	a0,s1
    80004c58:	c0eff0ef          	jal	80004066 <filedup>
  return fd;
    80004c5c:	87ca                	mv	a5,s2
    80004c5e:	64e2                	ld	s1,24(sp)
    80004c60:	6942                	ld	s2,16(sp)
}
    80004c62:	853e                	mv	a0,a5
    80004c64:	70a2                	ld	ra,40(sp)
    80004c66:	7402                	ld	s0,32(sp)
    80004c68:	6145                	addi	sp,sp,48
    80004c6a:	8082                	ret
    80004c6c:	64e2                	ld	s1,24(sp)
    80004c6e:	6942                	ld	s2,16(sp)
    80004c70:	bfcd                	j	80004c62 <sys_dup+0x3c>

0000000080004c72 <sys_read>:
{
    80004c72:	7179                	addi	sp,sp,-48
    80004c74:	f406                	sd	ra,40(sp)
    80004c76:	f022                	sd	s0,32(sp)
    80004c78:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c7a:	fd840593          	addi	a1,s0,-40
    80004c7e:	4505                	li	a0,1
    80004c80:	c4ffd0ef          	jal	800028ce <argaddr>
  argint(2, &n);
    80004c84:	fe440593          	addi	a1,s0,-28
    80004c88:	4509                	li	a0,2
    80004c8a:	c29fd0ef          	jal	800028b2 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c8e:	fe840613          	addi	a2,s0,-24
    80004c92:	4581                	li	a1,0
    80004c94:	4501                	li	a0,0
    80004c96:	dbfff0ef          	jal	80004a54 <argfd>
    80004c9a:	87aa                	mv	a5,a0
    return -1;
    80004c9c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c9e:	0007ca63          	bltz	a5,80004cb2 <sys_read+0x40>
  return fileread(f, p, n);
    80004ca2:	fe442603          	lw	a2,-28(s0)
    80004ca6:	fd843583          	ld	a1,-40(s0)
    80004caa:	fe843503          	ld	a0,-24(s0)
    80004cae:	d22ff0ef          	jal	800041d0 <fileread>
}
    80004cb2:	70a2                	ld	ra,40(sp)
    80004cb4:	7402                	ld	s0,32(sp)
    80004cb6:	6145                	addi	sp,sp,48
    80004cb8:	8082                	ret

0000000080004cba <sys_write>:
{
    80004cba:	7179                	addi	sp,sp,-48
    80004cbc:	f406                	sd	ra,40(sp)
    80004cbe:	f022                	sd	s0,32(sp)
    80004cc0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cc2:	fd840593          	addi	a1,s0,-40
    80004cc6:	4505                	li	a0,1
    80004cc8:	c07fd0ef          	jal	800028ce <argaddr>
  argint(2, &n);
    80004ccc:	fe440593          	addi	a1,s0,-28
    80004cd0:	4509                	li	a0,2
    80004cd2:	be1fd0ef          	jal	800028b2 <argint>
  if(argfd(0, 0, &f) < 0)
    80004cd6:	fe840613          	addi	a2,s0,-24
    80004cda:	4581                	li	a1,0
    80004cdc:	4501                	li	a0,0
    80004cde:	d77ff0ef          	jal	80004a54 <argfd>
    80004ce2:	87aa                	mv	a5,a0
    return -1;
    80004ce4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ce6:	0007ca63          	bltz	a5,80004cfa <sys_write+0x40>
  return filewrite(f, p, n);
    80004cea:	fe442603          	lw	a2,-28(s0)
    80004cee:	fd843583          	ld	a1,-40(s0)
    80004cf2:	fe843503          	ld	a0,-24(s0)
    80004cf6:	d9eff0ef          	jal	80004294 <filewrite>
}
    80004cfa:	70a2                	ld	ra,40(sp)
    80004cfc:	7402                	ld	s0,32(sp)
    80004cfe:	6145                	addi	sp,sp,48
    80004d00:	8082                	ret

0000000080004d02 <sys_close>:
{
    80004d02:	1101                	addi	sp,sp,-32
    80004d04:	ec06                	sd	ra,24(sp)
    80004d06:	e822                	sd	s0,16(sp)
    80004d08:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d0a:	fe040613          	addi	a2,s0,-32
    80004d0e:	fec40593          	addi	a1,s0,-20
    80004d12:	4501                	li	a0,0
    80004d14:	d41ff0ef          	jal	80004a54 <argfd>
    return -1;
    80004d18:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d1a:	02054163          	bltz	a0,80004d3c <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004d1e:	cddfc0ef          	jal	800019fa <myproc>
    80004d22:	fec42783          	lw	a5,-20(s0)
    80004d26:	078e                	slli	a5,a5,0x3
    80004d28:	0d078793          	addi	a5,a5,208
    80004d2c:	953e                	add	a0,a0,a5
    80004d2e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d32:	fe043503          	ld	a0,-32(s0)
    80004d36:	b76ff0ef          	jal	800040ac <fileclose>
  return 0;
    80004d3a:	4781                	li	a5,0
}
    80004d3c:	853e                	mv	a0,a5
    80004d3e:	60e2                	ld	ra,24(sp)
    80004d40:	6442                	ld	s0,16(sp)
    80004d42:	6105                	addi	sp,sp,32
    80004d44:	8082                	ret

0000000080004d46 <sys_fstat>:
{
    80004d46:	1101                	addi	sp,sp,-32
    80004d48:	ec06                	sd	ra,24(sp)
    80004d4a:	e822                	sd	s0,16(sp)
    80004d4c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d4e:	fe040593          	addi	a1,s0,-32
    80004d52:	4505                	li	a0,1
    80004d54:	b7bfd0ef          	jal	800028ce <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d58:	fe840613          	addi	a2,s0,-24
    80004d5c:	4581                	li	a1,0
    80004d5e:	4501                	li	a0,0
    80004d60:	cf5ff0ef          	jal	80004a54 <argfd>
    80004d64:	87aa                	mv	a5,a0
    return -1;
    80004d66:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d68:	0007c863          	bltz	a5,80004d78 <sys_fstat+0x32>
  return filestat(f, st);
    80004d6c:	fe043583          	ld	a1,-32(s0)
    80004d70:	fe843503          	ld	a0,-24(s0)
    80004d74:	bfaff0ef          	jal	8000416e <filestat>
}
    80004d78:	60e2                	ld	ra,24(sp)
    80004d7a:	6442                	ld	s0,16(sp)
    80004d7c:	6105                	addi	sp,sp,32
    80004d7e:	8082                	ret

0000000080004d80 <sys_link>:
{
    80004d80:	7169                	addi	sp,sp,-304
    80004d82:	f606                	sd	ra,296(sp)
    80004d84:	f222                	sd	s0,288(sp)
    80004d86:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d88:	08000613          	li	a2,128
    80004d8c:	ed040593          	addi	a1,s0,-304
    80004d90:	4501                	li	a0,0
    80004d92:	b59fd0ef          	jal	800028ea <argstr>
    return -1;
    80004d96:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d98:	0c054e63          	bltz	a0,80004e74 <sys_link+0xf4>
    80004d9c:	08000613          	li	a2,128
    80004da0:	f5040593          	addi	a1,s0,-176
    80004da4:	4505                	li	a0,1
    80004da6:	b45fd0ef          	jal	800028ea <argstr>
    return -1;
    80004daa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dac:	0c054463          	bltz	a0,80004e74 <sys_link+0xf4>
    80004db0:	ee26                	sd	s1,280(sp)
  begin_op();
    80004db2:	ed7fe0ef          	jal	80003c88 <begin_op>
  if((ip = namei(old)) == 0){
    80004db6:	ed040513          	addi	a0,s0,-304
    80004dba:	cf1fe0ef          	jal	80003aaa <namei>
    80004dbe:	84aa                	mv	s1,a0
    80004dc0:	c53d                	beqz	a0,80004e2e <sys_link+0xae>
  ilock(ip);
    80004dc2:	cbafe0ef          	jal	8000327c <ilock>
  if(ip->type == T_DIR){
    80004dc6:	04449703          	lh	a4,68(s1)
    80004dca:	4785                	li	a5,1
    80004dcc:	06f70663          	beq	a4,a5,80004e38 <sys_link+0xb8>
    80004dd0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004dd2:	04a4d783          	lhu	a5,74(s1)
    80004dd6:	2785                	addiw	a5,a5,1
    80004dd8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004ddc:	8526                	mv	a0,s1
    80004dde:	beafe0ef          	jal	800031c8 <iupdate>
  iunlock(ip);
    80004de2:	8526                	mv	a0,s1
    80004de4:	d46fe0ef          	jal	8000332a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004de8:	fd040593          	addi	a1,s0,-48
    80004dec:	f5040513          	addi	a0,s0,-176
    80004df0:	cd5fe0ef          	jal	80003ac4 <nameiparent>
    80004df4:	892a                	mv	s2,a0
    80004df6:	cd21                	beqz	a0,80004e4e <sys_link+0xce>
  ilock(dp);
    80004df8:	c84fe0ef          	jal	8000327c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004dfc:	854a                	mv	a0,s2
    80004dfe:	00092703          	lw	a4,0(s2)
    80004e02:	409c                	lw	a5,0(s1)
    80004e04:	04f71263          	bne	a4,a5,80004e48 <sys_link+0xc8>
    80004e08:	40d0                	lw	a2,4(s1)
    80004e0a:	fd040593          	addi	a1,s0,-48
    80004e0e:	bf3fe0ef          	jal	80003a00 <dirlink>
    80004e12:	02054b63          	bltz	a0,80004e48 <sys_link+0xc8>
  iunlockput(dp);
    80004e16:	854a                	mv	a0,s2
    80004e18:	e70fe0ef          	jal	80003488 <iunlockput>
  iput(ip);
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	de0fe0ef          	jal	800033fe <iput>
  end_op();
    80004e22:	ed7fe0ef          	jal	80003cf8 <end_op>
  return 0;
    80004e26:	4781                	li	a5,0
    80004e28:	64f2                	ld	s1,280(sp)
    80004e2a:	6952                	ld	s2,272(sp)
    80004e2c:	a0a1                	j	80004e74 <sys_link+0xf4>
    end_op();
    80004e2e:	ecbfe0ef          	jal	80003cf8 <end_op>
    return -1;
    80004e32:	57fd                	li	a5,-1
    80004e34:	64f2                	ld	s1,280(sp)
    80004e36:	a83d                	j	80004e74 <sys_link+0xf4>
    iunlockput(ip);
    80004e38:	8526                	mv	a0,s1
    80004e3a:	e4efe0ef          	jal	80003488 <iunlockput>
    end_op();
    80004e3e:	ebbfe0ef          	jal	80003cf8 <end_op>
    return -1;
    80004e42:	57fd                	li	a5,-1
    80004e44:	64f2                	ld	s1,280(sp)
    80004e46:	a03d                	j	80004e74 <sys_link+0xf4>
    iunlockput(dp);
    80004e48:	854a                	mv	a0,s2
    80004e4a:	e3efe0ef          	jal	80003488 <iunlockput>
  ilock(ip);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	c2cfe0ef          	jal	8000327c <ilock>
  ip->nlink--;
    80004e54:	04a4d783          	lhu	a5,74(s1)
    80004e58:	37fd                	addiw	a5,a5,-1
    80004e5a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	b68fe0ef          	jal	800031c8 <iupdate>
  iunlockput(ip);
    80004e64:	8526                	mv	a0,s1
    80004e66:	e22fe0ef          	jal	80003488 <iunlockput>
  end_op();
    80004e6a:	e8ffe0ef          	jal	80003cf8 <end_op>
  return -1;
    80004e6e:	57fd                	li	a5,-1
    80004e70:	64f2                	ld	s1,280(sp)
    80004e72:	6952                	ld	s2,272(sp)
}
    80004e74:	853e                	mv	a0,a5
    80004e76:	70b2                	ld	ra,296(sp)
    80004e78:	7412                	ld	s0,288(sp)
    80004e7a:	6155                	addi	sp,sp,304
    80004e7c:	8082                	ret

0000000080004e7e <sys_unlink>:
{
    80004e7e:	7151                	addi	sp,sp,-240
    80004e80:	f586                	sd	ra,232(sp)
    80004e82:	f1a2                	sd	s0,224(sp)
    80004e84:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e86:	08000613          	li	a2,128
    80004e8a:	f3040593          	addi	a1,s0,-208
    80004e8e:	4501                	li	a0,0
    80004e90:	a5bfd0ef          	jal	800028ea <argstr>
    80004e94:	14054d63          	bltz	a0,80004fee <sys_unlink+0x170>
    80004e98:	eda6                	sd	s1,216(sp)
  begin_op();
    80004e9a:	deffe0ef          	jal	80003c88 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e9e:	fb040593          	addi	a1,s0,-80
    80004ea2:	f3040513          	addi	a0,s0,-208
    80004ea6:	c1ffe0ef          	jal	80003ac4 <nameiparent>
    80004eaa:	84aa                	mv	s1,a0
    80004eac:	c955                	beqz	a0,80004f60 <sys_unlink+0xe2>
  ilock(dp);
    80004eae:	bcefe0ef          	jal	8000327c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004eb2:	00002597          	auipc	a1,0x2
    80004eb6:	71658593          	addi	a1,a1,1814 # 800075c8 <etext+0x5c8>
    80004eba:	fb040513          	addi	a0,s0,-80
    80004ebe:	943fe0ef          	jal	80003800 <namecmp>
    80004ec2:	10050b63          	beqz	a0,80004fd8 <sys_unlink+0x15a>
    80004ec6:	00002597          	auipc	a1,0x2
    80004eca:	70a58593          	addi	a1,a1,1802 # 800075d0 <etext+0x5d0>
    80004ece:	fb040513          	addi	a0,s0,-80
    80004ed2:	92ffe0ef          	jal	80003800 <namecmp>
    80004ed6:	10050163          	beqz	a0,80004fd8 <sys_unlink+0x15a>
    80004eda:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004edc:	f2c40613          	addi	a2,s0,-212
    80004ee0:	fb040593          	addi	a1,s0,-80
    80004ee4:	8526                	mv	a0,s1
    80004ee6:	931fe0ef          	jal	80003816 <dirlookup>
    80004eea:	892a                	mv	s2,a0
    80004eec:	0e050563          	beqz	a0,80004fd6 <sys_unlink+0x158>
    80004ef0:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80004ef2:	b8afe0ef          	jal	8000327c <ilock>
  if(ip->nlink < 1)
    80004ef6:	04a91783          	lh	a5,74(s2)
    80004efa:	06f05863          	blez	a5,80004f6a <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004efe:	04491703          	lh	a4,68(s2)
    80004f02:	4785                	li	a5,1
    80004f04:	06f70963          	beq	a4,a5,80004f76 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80004f08:	fc040993          	addi	s3,s0,-64
    80004f0c:	4641                	li	a2,16
    80004f0e:	4581                	li	a1,0
    80004f10:	854e                	mv	a0,s3
    80004f12:	de7fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f16:	4741                	li	a4,16
    80004f18:	f2c42683          	lw	a3,-212(s0)
    80004f1c:	864e                	mv	a2,s3
    80004f1e:	4581                	li	a1,0
    80004f20:	8526                	mv	a0,s1
    80004f22:	fdefe0ef          	jal	80003700 <writei>
    80004f26:	47c1                	li	a5,16
    80004f28:	08f51863          	bne	a0,a5,80004fb8 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80004f2c:	04491703          	lh	a4,68(s2)
    80004f30:	4785                	li	a5,1
    80004f32:	08f70963          	beq	a4,a5,80004fc4 <sys_unlink+0x146>
  iunlockput(dp);
    80004f36:	8526                	mv	a0,s1
    80004f38:	d50fe0ef          	jal	80003488 <iunlockput>
  ip->nlink--;
    80004f3c:	04a95783          	lhu	a5,74(s2)
    80004f40:	37fd                	addiw	a5,a5,-1
    80004f42:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f46:	854a                	mv	a0,s2
    80004f48:	a80fe0ef          	jal	800031c8 <iupdate>
  iunlockput(ip);
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	d3afe0ef          	jal	80003488 <iunlockput>
  end_op();
    80004f52:	da7fe0ef          	jal	80003cf8 <end_op>
  return 0;
    80004f56:	4501                	li	a0,0
    80004f58:	64ee                	ld	s1,216(sp)
    80004f5a:	694e                	ld	s2,208(sp)
    80004f5c:	69ae                	ld	s3,200(sp)
    80004f5e:	a061                	j	80004fe6 <sys_unlink+0x168>
    end_op();
    80004f60:	d99fe0ef          	jal	80003cf8 <end_op>
    return -1;
    80004f64:	557d                	li	a0,-1
    80004f66:	64ee                	ld	s1,216(sp)
    80004f68:	a8bd                	j	80004fe6 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004f6a:	00002517          	auipc	a0,0x2
    80004f6e:	66e50513          	addi	a0,a0,1646 # 800075d8 <etext+0x5d8>
    80004f72:	8b3fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f76:	04c92703          	lw	a4,76(s2)
    80004f7a:	02000793          	li	a5,32
    80004f7e:	f8e7f5e3          	bgeu	a5,a4,80004f08 <sys_unlink+0x8a>
    80004f82:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f84:	4741                	li	a4,16
    80004f86:	86ce                	mv	a3,s3
    80004f88:	f1840613          	addi	a2,s0,-232
    80004f8c:	4581                	li	a1,0
    80004f8e:	854a                	mv	a0,s2
    80004f90:	e7efe0ef          	jal	8000360e <readi>
    80004f94:	47c1                	li	a5,16
    80004f96:	00f51b63          	bne	a0,a5,80004fac <sys_unlink+0x12e>
    if(de.inum != 0)
    80004f9a:	f1845783          	lhu	a5,-232(s0)
    80004f9e:	ebb1                	bnez	a5,80004ff2 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fa0:	29c1                	addiw	s3,s3,16
    80004fa2:	04c92783          	lw	a5,76(s2)
    80004fa6:	fcf9efe3          	bltu	s3,a5,80004f84 <sys_unlink+0x106>
    80004faa:	bfb9                	j	80004f08 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004fac:	00002517          	auipc	a0,0x2
    80004fb0:	64450513          	addi	a0,a0,1604 # 800075f0 <etext+0x5f0>
    80004fb4:	871fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    80004fb8:	00002517          	auipc	a0,0x2
    80004fbc:	65050513          	addi	a0,a0,1616 # 80007608 <etext+0x608>
    80004fc0:	865fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80004fc4:	04a4d783          	lhu	a5,74(s1)
    80004fc8:	37fd                	addiw	a5,a5,-1
    80004fca:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fce:	8526                	mv	a0,s1
    80004fd0:	9f8fe0ef          	jal	800031c8 <iupdate>
    80004fd4:	b78d                	j	80004f36 <sys_unlink+0xb8>
    80004fd6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004fd8:	8526                	mv	a0,s1
    80004fda:	caefe0ef          	jal	80003488 <iunlockput>
  end_op();
    80004fde:	d1bfe0ef          	jal	80003cf8 <end_op>
  return -1;
    80004fe2:	557d                	li	a0,-1
    80004fe4:	64ee                	ld	s1,216(sp)
}
    80004fe6:	70ae                	ld	ra,232(sp)
    80004fe8:	740e                	ld	s0,224(sp)
    80004fea:	616d                	addi	sp,sp,240
    80004fec:	8082                	ret
    return -1;
    80004fee:	557d                	li	a0,-1
    80004ff0:	bfdd                	j	80004fe6 <sys_unlink+0x168>
    iunlockput(ip);
    80004ff2:	854a                	mv	a0,s2
    80004ff4:	c94fe0ef          	jal	80003488 <iunlockput>
    goto bad;
    80004ff8:	694e                	ld	s2,208(sp)
    80004ffa:	69ae                	ld	s3,200(sp)
    80004ffc:	bff1                	j	80004fd8 <sys_unlink+0x15a>

0000000080004ffe <sys_open>:

uint64
sys_open(void)
{
    80004ffe:	7131                	addi	sp,sp,-192
    80005000:	fd06                	sd	ra,184(sp)
    80005002:	f922                	sd	s0,176(sp)
    80005004:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005006:	f4c40593          	addi	a1,s0,-180
    8000500a:	4505                	li	a0,1
    8000500c:	8a7fd0ef          	jal	800028b2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005010:	08000613          	li	a2,128
    80005014:	f5040593          	addi	a1,s0,-176
    80005018:	4501                	li	a0,0
    8000501a:	8d1fd0ef          	jal	800028ea <argstr>
    8000501e:	87aa                	mv	a5,a0
    return -1;
    80005020:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005022:	0a07c363          	bltz	a5,800050c8 <sys_open+0xca>
    80005026:	f526                	sd	s1,168(sp)

  begin_op();
    80005028:	c61fe0ef          	jal	80003c88 <begin_op>

  if(omode & O_CREATE){
    8000502c:	f4c42783          	lw	a5,-180(s0)
    80005030:	2007f793          	andi	a5,a5,512
    80005034:	c3dd                	beqz	a5,800050da <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005036:	4681                	li	a3,0
    80005038:	4601                	li	a2,0
    8000503a:	4589                	li	a1,2
    8000503c:	f5040513          	addi	a0,s0,-176
    80005040:	aafff0ef          	jal	80004aee <create>
    80005044:	84aa                	mv	s1,a0
    if(ip == 0){
    80005046:	c549                	beqz	a0,800050d0 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005048:	04449703          	lh	a4,68(s1)
    8000504c:	478d                	li	a5,3
    8000504e:	00f71763          	bne	a4,a5,8000505c <sys_open+0x5e>
    80005052:	0464d703          	lhu	a4,70(s1)
    80005056:	47a5                	li	a5,9
    80005058:	0ae7ee63          	bltu	a5,a4,80005114 <sys_open+0x116>
    8000505c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000505e:	fabfe0ef          	jal	80004008 <filealloc>
    80005062:	892a                	mv	s2,a0
    80005064:	c561                	beqz	a0,8000512c <sys_open+0x12e>
    80005066:	ed4e                	sd	s3,152(sp)
    80005068:	a47ff0ef          	jal	80004aae <fdalloc>
    8000506c:	89aa                	mv	s3,a0
    8000506e:	0a054b63          	bltz	a0,80005124 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005072:	04449703          	lh	a4,68(s1)
    80005076:	478d                	li	a5,3
    80005078:	0cf70363          	beq	a4,a5,8000513e <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000507c:	4789                	li	a5,2
    8000507e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005082:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005086:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000508a:	f4c42783          	lw	a5,-180(s0)
    8000508e:	0017f713          	andi	a4,a5,1
    80005092:	00174713          	xori	a4,a4,1
    80005096:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000509a:	0037f713          	andi	a4,a5,3
    8000509e:	00e03733          	snez	a4,a4
    800050a2:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050a6:	4007f793          	andi	a5,a5,1024
    800050aa:	c791                	beqz	a5,800050b6 <sys_open+0xb8>
    800050ac:	04449703          	lh	a4,68(s1)
    800050b0:	4789                	li	a5,2
    800050b2:	08f70d63          	beq	a4,a5,8000514c <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800050b6:	8526                	mv	a0,s1
    800050b8:	a72fe0ef          	jal	8000332a <iunlock>
  end_op();
    800050bc:	c3dfe0ef          	jal	80003cf8 <end_op>

  return fd;
    800050c0:	854e                	mv	a0,s3
    800050c2:	74aa                	ld	s1,168(sp)
    800050c4:	790a                	ld	s2,160(sp)
    800050c6:	69ea                	ld	s3,152(sp)
}
    800050c8:	70ea                	ld	ra,184(sp)
    800050ca:	744a                	ld	s0,176(sp)
    800050cc:	6129                	addi	sp,sp,192
    800050ce:	8082                	ret
      end_op();
    800050d0:	c29fe0ef          	jal	80003cf8 <end_op>
      return -1;
    800050d4:	557d                	li	a0,-1
    800050d6:	74aa                	ld	s1,168(sp)
    800050d8:	bfc5                	j	800050c8 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800050da:	f5040513          	addi	a0,s0,-176
    800050de:	9cdfe0ef          	jal	80003aaa <namei>
    800050e2:	84aa                	mv	s1,a0
    800050e4:	c11d                	beqz	a0,8000510a <sys_open+0x10c>
    ilock(ip);
    800050e6:	996fe0ef          	jal	8000327c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050ea:	04449703          	lh	a4,68(s1)
    800050ee:	4785                	li	a5,1
    800050f0:	f4f71ce3          	bne	a4,a5,80005048 <sys_open+0x4a>
    800050f4:	f4c42783          	lw	a5,-180(s0)
    800050f8:	d3b5                	beqz	a5,8000505c <sys_open+0x5e>
      iunlockput(ip);
    800050fa:	8526                	mv	a0,s1
    800050fc:	b8cfe0ef          	jal	80003488 <iunlockput>
      end_op();
    80005100:	bf9fe0ef          	jal	80003cf8 <end_op>
      return -1;
    80005104:	557d                	li	a0,-1
    80005106:	74aa                	ld	s1,168(sp)
    80005108:	b7c1                	j	800050c8 <sys_open+0xca>
      end_op();
    8000510a:	beffe0ef          	jal	80003cf8 <end_op>
      return -1;
    8000510e:	557d                	li	a0,-1
    80005110:	74aa                	ld	s1,168(sp)
    80005112:	bf5d                	j	800050c8 <sys_open+0xca>
    iunlockput(ip);
    80005114:	8526                	mv	a0,s1
    80005116:	b72fe0ef          	jal	80003488 <iunlockput>
    end_op();
    8000511a:	bdffe0ef          	jal	80003cf8 <end_op>
    return -1;
    8000511e:	557d                	li	a0,-1
    80005120:	74aa                	ld	s1,168(sp)
    80005122:	b75d                	j	800050c8 <sys_open+0xca>
      fileclose(f);
    80005124:	854a                	mv	a0,s2
    80005126:	f87fe0ef          	jal	800040ac <fileclose>
    8000512a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000512c:	8526                	mv	a0,s1
    8000512e:	b5afe0ef          	jal	80003488 <iunlockput>
    end_op();
    80005132:	bc7fe0ef          	jal	80003cf8 <end_op>
    return -1;
    80005136:	557d                	li	a0,-1
    80005138:	74aa                	ld	s1,168(sp)
    8000513a:	790a                	ld	s2,160(sp)
    8000513c:	b771                	j	800050c8 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000513e:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005142:	04649783          	lh	a5,70(s1)
    80005146:	02f91223          	sh	a5,36(s2)
    8000514a:	bf35                	j	80005086 <sys_open+0x88>
    itrunc(ip);
    8000514c:	8526                	mv	a0,s1
    8000514e:	a1cfe0ef          	jal	8000336a <itrunc>
    80005152:	b795                	j	800050b6 <sys_open+0xb8>

0000000080005154 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005154:	7175                	addi	sp,sp,-144
    80005156:	e506                	sd	ra,136(sp)
    80005158:	e122                	sd	s0,128(sp)
    8000515a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000515c:	b2dfe0ef          	jal	80003c88 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005160:	08000613          	li	a2,128
    80005164:	f7040593          	addi	a1,s0,-144
    80005168:	4501                	li	a0,0
    8000516a:	f80fd0ef          	jal	800028ea <argstr>
    8000516e:	02054363          	bltz	a0,80005194 <sys_mkdir+0x40>
    80005172:	4681                	li	a3,0
    80005174:	4601                	li	a2,0
    80005176:	4585                	li	a1,1
    80005178:	f7040513          	addi	a0,s0,-144
    8000517c:	973ff0ef          	jal	80004aee <create>
    80005180:	c911                	beqz	a0,80005194 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005182:	b06fe0ef          	jal	80003488 <iunlockput>
  end_op();
    80005186:	b73fe0ef          	jal	80003cf8 <end_op>
  return 0;
    8000518a:	4501                	li	a0,0
}
    8000518c:	60aa                	ld	ra,136(sp)
    8000518e:	640a                	ld	s0,128(sp)
    80005190:	6149                	addi	sp,sp,144
    80005192:	8082                	ret
    end_op();
    80005194:	b65fe0ef          	jal	80003cf8 <end_op>
    return -1;
    80005198:	557d                	li	a0,-1
    8000519a:	bfcd                	j	8000518c <sys_mkdir+0x38>

000000008000519c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000519c:	7135                	addi	sp,sp,-160
    8000519e:	ed06                	sd	ra,152(sp)
    800051a0:	e922                	sd	s0,144(sp)
    800051a2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051a4:	ae5fe0ef          	jal	80003c88 <begin_op>
  argint(1, &major);
    800051a8:	f6c40593          	addi	a1,s0,-148
    800051ac:	4505                	li	a0,1
    800051ae:	f04fd0ef          	jal	800028b2 <argint>
  argint(2, &minor);
    800051b2:	f6840593          	addi	a1,s0,-152
    800051b6:	4509                	li	a0,2
    800051b8:	efafd0ef          	jal	800028b2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051bc:	08000613          	li	a2,128
    800051c0:	f7040593          	addi	a1,s0,-144
    800051c4:	4501                	li	a0,0
    800051c6:	f24fd0ef          	jal	800028ea <argstr>
    800051ca:	02054563          	bltz	a0,800051f4 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800051ce:	f6841683          	lh	a3,-152(s0)
    800051d2:	f6c41603          	lh	a2,-148(s0)
    800051d6:	458d                	li	a1,3
    800051d8:	f7040513          	addi	a0,s0,-144
    800051dc:	913ff0ef          	jal	80004aee <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051e0:	c911                	beqz	a0,800051f4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051e2:	aa6fe0ef          	jal	80003488 <iunlockput>
  end_op();
    800051e6:	b13fe0ef          	jal	80003cf8 <end_op>
  return 0;
    800051ea:	4501                	li	a0,0
}
    800051ec:	60ea                	ld	ra,152(sp)
    800051ee:	644a                	ld	s0,144(sp)
    800051f0:	610d                	addi	sp,sp,160
    800051f2:	8082                	ret
    end_op();
    800051f4:	b05fe0ef          	jal	80003cf8 <end_op>
    return -1;
    800051f8:	557d                	li	a0,-1
    800051fa:	bfcd                	j	800051ec <sys_mknod+0x50>

00000000800051fc <sys_chdir>:

uint64
sys_chdir(void)
{
    800051fc:	7135                	addi	sp,sp,-160
    800051fe:	ed06                	sd	ra,152(sp)
    80005200:	e922                	sd	s0,144(sp)
    80005202:	e14a                	sd	s2,128(sp)
    80005204:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005206:	ff4fc0ef          	jal	800019fa <myproc>
    8000520a:	892a                	mv	s2,a0
  
  begin_op();
    8000520c:	a7dfe0ef          	jal	80003c88 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005210:	08000613          	li	a2,128
    80005214:	f6040593          	addi	a1,s0,-160
    80005218:	4501                	li	a0,0
    8000521a:	ed0fd0ef          	jal	800028ea <argstr>
    8000521e:	04054363          	bltz	a0,80005264 <sys_chdir+0x68>
    80005222:	e526                	sd	s1,136(sp)
    80005224:	f6040513          	addi	a0,s0,-160
    80005228:	883fe0ef          	jal	80003aaa <namei>
    8000522c:	84aa                	mv	s1,a0
    8000522e:	c915                	beqz	a0,80005262 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005230:	84cfe0ef          	jal	8000327c <ilock>
  if(ip->type != T_DIR){
    80005234:	04449703          	lh	a4,68(s1)
    80005238:	4785                	li	a5,1
    8000523a:	02f71963          	bne	a4,a5,8000526c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000523e:	8526                	mv	a0,s1
    80005240:	8eafe0ef          	jal	8000332a <iunlock>
  iput(p->cwd);
    80005244:	15093503          	ld	a0,336(s2)
    80005248:	9b6fe0ef          	jal	800033fe <iput>
  end_op();
    8000524c:	aadfe0ef          	jal	80003cf8 <end_op>
  p->cwd = ip;
    80005250:	14993823          	sd	s1,336(s2)
  return 0;
    80005254:	4501                	li	a0,0
    80005256:	64aa                	ld	s1,136(sp)
}
    80005258:	60ea                	ld	ra,152(sp)
    8000525a:	644a                	ld	s0,144(sp)
    8000525c:	690a                	ld	s2,128(sp)
    8000525e:	610d                	addi	sp,sp,160
    80005260:	8082                	ret
    80005262:	64aa                	ld	s1,136(sp)
    end_op();
    80005264:	a95fe0ef          	jal	80003cf8 <end_op>
    return -1;
    80005268:	557d                	li	a0,-1
    8000526a:	b7fd                	j	80005258 <sys_chdir+0x5c>
    iunlockput(ip);
    8000526c:	8526                	mv	a0,s1
    8000526e:	a1afe0ef          	jal	80003488 <iunlockput>
    end_op();
    80005272:	a87fe0ef          	jal	80003cf8 <end_op>
    return -1;
    80005276:	557d                	li	a0,-1
    80005278:	64aa                	ld	s1,136(sp)
    8000527a:	bff9                	j	80005258 <sys_chdir+0x5c>

000000008000527c <sys_exec>:

uint64
sys_exec(void)
{
    8000527c:	7105                	addi	sp,sp,-480
    8000527e:	ef86                	sd	ra,472(sp)
    80005280:	eba2                	sd	s0,464(sp)
    80005282:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005284:	e2840593          	addi	a1,s0,-472
    80005288:	4505                	li	a0,1
    8000528a:	e44fd0ef          	jal	800028ce <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000528e:	08000613          	li	a2,128
    80005292:	f3040593          	addi	a1,s0,-208
    80005296:	4501                	li	a0,0
    80005298:	e52fd0ef          	jal	800028ea <argstr>
    8000529c:	87aa                	mv	a5,a0
    return -1;
    8000529e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052a0:	0e07c063          	bltz	a5,80005380 <sys_exec+0x104>
    800052a4:	e7a6                	sd	s1,456(sp)
    800052a6:	e3ca                	sd	s2,448(sp)
    800052a8:	ff4e                	sd	s3,440(sp)
    800052aa:	fb52                	sd	s4,432(sp)
    800052ac:	f756                	sd	s5,424(sp)
    800052ae:	f35a                	sd	s6,416(sp)
    800052b0:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800052b2:	e3040a13          	addi	s4,s0,-464
    800052b6:	10000613          	li	a2,256
    800052ba:	4581                	li	a1,0
    800052bc:	8552                	mv	a0,s4
    800052be:	a3bfb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800052c2:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800052c4:	89d2                	mv	s3,s4
    800052c6:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052c8:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052cc:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800052ce:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052d2:	00391513          	slli	a0,s2,0x3
    800052d6:	85d6                	mv	a1,s5
    800052d8:	e2843783          	ld	a5,-472(s0)
    800052dc:	953e                	add	a0,a0,a5
    800052de:	d4afd0ef          	jal	80002828 <fetchaddr>
    800052e2:	02054663          	bltz	a0,8000530e <sys_exec+0x92>
    if(uarg == 0){
    800052e6:	e2043783          	ld	a5,-480(s0)
    800052ea:	c7a1                	beqz	a5,80005332 <sys_exec+0xb6>
    argv[i] = kalloc();
    800052ec:	859fb0ef          	jal	80000b44 <kalloc>
    800052f0:	85aa                	mv	a1,a0
    800052f2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800052f6:	cd01                	beqz	a0,8000530e <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052f8:	865a                	mv	a2,s6
    800052fa:	e2043503          	ld	a0,-480(s0)
    800052fe:	d74fd0ef          	jal	80002872 <fetchstr>
    80005302:	00054663          	bltz	a0,8000530e <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005306:	0905                	addi	s2,s2,1
    80005308:	09a1                	addi	s3,s3,8
    8000530a:	fd7914e3          	bne	s2,s7,800052d2 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000530e:	100a0a13          	addi	s4,s4,256
    80005312:	6088                	ld	a0,0(s1)
    80005314:	cd31                	beqz	a0,80005370 <sys_exec+0xf4>
    kfree(argv[i]);
    80005316:	f46fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000531a:	04a1                	addi	s1,s1,8
    8000531c:	ff449be3          	bne	s1,s4,80005312 <sys_exec+0x96>
  return -1;
    80005320:	557d                	li	a0,-1
    80005322:	64be                	ld	s1,456(sp)
    80005324:	691e                	ld	s2,448(sp)
    80005326:	79fa                	ld	s3,440(sp)
    80005328:	7a5a                	ld	s4,432(sp)
    8000532a:	7aba                	ld	s5,424(sp)
    8000532c:	7b1a                	ld	s6,416(sp)
    8000532e:	6bfa                	ld	s7,408(sp)
    80005330:	a881                	j	80005380 <sys_exec+0x104>
      argv[i] = 0;
    80005332:	0009079b          	sext.w	a5,s2
    80005336:	e3040593          	addi	a1,s0,-464
    8000533a:	078e                	slli	a5,a5,0x3
    8000533c:	97ae                	add	a5,a5,a1
    8000533e:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005342:	f3040513          	addi	a0,s0,-208
    80005346:	bb2ff0ef          	jal	800046f8 <kexec>
    8000534a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000534c:	100a0a13          	addi	s4,s4,256
    80005350:	6088                	ld	a0,0(s1)
    80005352:	c511                	beqz	a0,8000535e <sys_exec+0xe2>
    kfree(argv[i]);
    80005354:	f08fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005358:	04a1                	addi	s1,s1,8
    8000535a:	ff449be3          	bne	s1,s4,80005350 <sys_exec+0xd4>
  return ret;
    8000535e:	854a                	mv	a0,s2
    80005360:	64be                	ld	s1,456(sp)
    80005362:	691e                	ld	s2,448(sp)
    80005364:	79fa                	ld	s3,440(sp)
    80005366:	7a5a                	ld	s4,432(sp)
    80005368:	7aba                	ld	s5,424(sp)
    8000536a:	7b1a                	ld	s6,416(sp)
    8000536c:	6bfa                	ld	s7,408(sp)
    8000536e:	a809                	j	80005380 <sys_exec+0x104>
  return -1;
    80005370:	557d                	li	a0,-1
    80005372:	64be                	ld	s1,456(sp)
    80005374:	691e                	ld	s2,448(sp)
    80005376:	79fa                	ld	s3,440(sp)
    80005378:	7a5a                	ld	s4,432(sp)
    8000537a:	7aba                	ld	s5,424(sp)
    8000537c:	7b1a                	ld	s6,416(sp)
    8000537e:	6bfa                	ld	s7,408(sp)
}
    80005380:	60fe                	ld	ra,472(sp)
    80005382:	645e                	ld	s0,464(sp)
    80005384:	613d                	addi	sp,sp,480
    80005386:	8082                	ret

0000000080005388 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005388:	7139                	addi	sp,sp,-64
    8000538a:	fc06                	sd	ra,56(sp)
    8000538c:	f822                	sd	s0,48(sp)
    8000538e:	f426                	sd	s1,40(sp)
    80005390:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005392:	e68fc0ef          	jal	800019fa <myproc>
    80005396:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005398:	fd840593          	addi	a1,s0,-40
    8000539c:	4501                	li	a0,0
    8000539e:	d30fd0ef          	jal	800028ce <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053a2:	fc840593          	addi	a1,s0,-56
    800053a6:	fd040513          	addi	a0,s0,-48
    800053aa:	81eff0ef          	jal	800043c8 <pipealloc>
    return -1;
    800053ae:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053b0:	0a054763          	bltz	a0,8000545e <sys_pipe+0xd6>
  fd0 = -1;
    800053b4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053b8:	fd043503          	ld	a0,-48(s0)
    800053bc:	ef2ff0ef          	jal	80004aae <fdalloc>
    800053c0:	fca42223          	sw	a0,-60(s0)
    800053c4:	08054463          	bltz	a0,8000544c <sys_pipe+0xc4>
    800053c8:	fc843503          	ld	a0,-56(s0)
    800053cc:	ee2ff0ef          	jal	80004aae <fdalloc>
    800053d0:	fca42023          	sw	a0,-64(s0)
    800053d4:	06054263          	bltz	a0,80005438 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053d8:	4691                	li	a3,4
    800053da:	fc440613          	addi	a2,s0,-60
    800053de:	fd843583          	ld	a1,-40(s0)
    800053e2:	68a8                	ld	a0,80(s1)
    800053e4:	a70fc0ef          	jal	80001654 <copyout>
    800053e8:	00054e63          	bltz	a0,80005404 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800053ec:	4691                	li	a3,4
    800053ee:	fc040613          	addi	a2,s0,-64
    800053f2:	fd843583          	ld	a1,-40(s0)
    800053f6:	95b6                	add	a1,a1,a3
    800053f8:	68a8                	ld	a0,80(s1)
    800053fa:	a5afc0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800053fe:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005400:	04055f63          	bgez	a0,8000545e <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005404:	fc442783          	lw	a5,-60(s0)
    80005408:	078e                	slli	a5,a5,0x3
    8000540a:	0d078793          	addi	a5,a5,208
    8000540e:	97a6                	add	a5,a5,s1
    80005410:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005414:	fc042783          	lw	a5,-64(s0)
    80005418:	078e                	slli	a5,a5,0x3
    8000541a:	0d078793          	addi	a5,a5,208
    8000541e:	97a6                	add	a5,a5,s1
    80005420:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005424:	fd043503          	ld	a0,-48(s0)
    80005428:	c85fe0ef          	jal	800040ac <fileclose>
    fileclose(wf);
    8000542c:	fc843503          	ld	a0,-56(s0)
    80005430:	c7dfe0ef          	jal	800040ac <fileclose>
    return -1;
    80005434:	57fd                	li	a5,-1
    80005436:	a025                	j	8000545e <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005438:	fc442783          	lw	a5,-60(s0)
    8000543c:	0007c863          	bltz	a5,8000544c <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005440:	078e                	slli	a5,a5,0x3
    80005442:	0d078793          	addi	a5,a5,208
    80005446:	97a6                	add	a5,a5,s1
    80005448:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000544c:	fd043503          	ld	a0,-48(s0)
    80005450:	c5dfe0ef          	jal	800040ac <fileclose>
    fileclose(wf);
    80005454:	fc843503          	ld	a0,-56(s0)
    80005458:	c55fe0ef          	jal	800040ac <fileclose>
    return -1;
    8000545c:	57fd                	li	a5,-1
}
    8000545e:	853e                	mv	a0,a5
    80005460:	70e2                	ld	ra,56(sp)
    80005462:	7442                	ld	s0,48(sp)
    80005464:	74a2                	ld	s1,40(sp)
    80005466:	6121                	addi	sp,sp,64
    80005468:	8082                	ret
    8000546a:	0000                	unimp
    8000546c:	0000                	unimp
	...

0000000080005470 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005470:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005472:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005474:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005476:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005478:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000547a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000547c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000547e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005480:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005482:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005484:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005486:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005488:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000548a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000548c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000548e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005490:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005492:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005494:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005496:	ab2fd0ef          	jal	80002748 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000549a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000549c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000549e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800054a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800054a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800054a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800054a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800054a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800054aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800054ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800054ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800054b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054be:	10200073          	sret
    800054c2:	00000013          	nop
    800054c6:	00000013          	nop
    800054ca:	00000013          	nop

00000000800054ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800054ce:	1141                	addi	sp,sp,-16
    800054d0:	e406                	sd	ra,8(sp)
    800054d2:	e022                	sd	s0,0(sp)
    800054d4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800054d6:	0c000737          	lui	a4,0xc000
    800054da:	4785                	li	a5,1
    800054dc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800054de:	c35c                	sw	a5,4(a4)
}
    800054e0:	60a2                	ld	ra,8(sp)
    800054e2:	6402                	ld	s0,0(sp)
    800054e4:	0141                	addi	sp,sp,16
    800054e6:	8082                	ret

00000000800054e8 <plicinithart>:

void
plicinithart(void)
{
    800054e8:	1141                	addi	sp,sp,-16
    800054ea:	e406                	sd	ra,8(sp)
    800054ec:	e022                	sd	s0,0(sp)
    800054ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054f0:	cd6fc0ef          	jal	800019c6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800054f4:	0085171b          	slliw	a4,a0,0x8
    800054f8:	0c0027b7          	lui	a5,0xc002
    800054fc:	97ba                	add	a5,a5,a4
    800054fe:	40200713          	li	a4,1026
    80005502:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005506:	00d5151b          	slliw	a0,a0,0xd
    8000550a:	0c2017b7          	lui	a5,0xc201
    8000550e:	97aa                	add	a5,a5,a0
    80005510:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005514:	60a2                	ld	ra,8(sp)
    80005516:	6402                	ld	s0,0(sp)
    80005518:	0141                	addi	sp,sp,16
    8000551a:	8082                	ret

000000008000551c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000551c:	1141                	addi	sp,sp,-16
    8000551e:	e406                	sd	ra,8(sp)
    80005520:	e022                	sd	s0,0(sp)
    80005522:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005524:	ca2fc0ef          	jal	800019c6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005528:	00d5151b          	slliw	a0,a0,0xd
    8000552c:	0c2017b7          	lui	a5,0xc201
    80005530:	97aa                	add	a5,a5,a0
  return irq;
}
    80005532:	43c8                	lw	a0,4(a5)
    80005534:	60a2                	ld	ra,8(sp)
    80005536:	6402                	ld	s0,0(sp)
    80005538:	0141                	addi	sp,sp,16
    8000553a:	8082                	ret

000000008000553c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000553c:	1101                	addi	sp,sp,-32
    8000553e:	ec06                	sd	ra,24(sp)
    80005540:	e822                	sd	s0,16(sp)
    80005542:	e426                	sd	s1,8(sp)
    80005544:	1000                	addi	s0,sp,32
    80005546:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005548:	c7efc0ef          	jal	800019c6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000554c:	00d5179b          	slliw	a5,a0,0xd
    80005550:	0c201737          	lui	a4,0xc201
    80005554:	97ba                	add	a5,a5,a4
    80005556:	c3c4                	sw	s1,4(a5)
}
    80005558:	60e2                	ld	ra,24(sp)
    8000555a:	6442                	ld	s0,16(sp)
    8000555c:	64a2                	ld	s1,8(sp)
    8000555e:	6105                	addi	sp,sp,32
    80005560:	8082                	ret

0000000080005562 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005562:	1141                	addi	sp,sp,-16
    80005564:	e406                	sd	ra,8(sp)
    80005566:	e022                	sd	s0,0(sp)
    80005568:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000556a:	479d                	li	a5,7
    8000556c:	04a7ca63          	blt	a5,a0,800055c0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005570:	0001b797          	auipc	a5,0x1b
    80005574:	6f078793          	addi	a5,a5,1776 # 80020c60 <disk>
    80005578:	97aa                	add	a5,a5,a0
    8000557a:	0187c783          	lbu	a5,24(a5)
    8000557e:	e7b9                	bnez	a5,800055cc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005580:	00451693          	slli	a3,a0,0x4
    80005584:	0001b797          	auipc	a5,0x1b
    80005588:	6dc78793          	addi	a5,a5,1756 # 80020c60 <disk>
    8000558c:	6398                	ld	a4,0(a5)
    8000558e:	9736                	add	a4,a4,a3
    80005590:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005594:	6398                	ld	a4,0(a5)
    80005596:	9736                	add	a4,a4,a3
    80005598:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000559c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800055a0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800055a4:	97aa                	add	a5,a5,a0
    800055a6:	4705                	li	a4,1
    800055a8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800055ac:	0001b517          	auipc	a0,0x1b
    800055b0:	6cc50513          	addi	a0,a0,1740 # 80020c78 <disk+0x18>
    800055b4:	a8ffc0ef          	jal	80002042 <wakeup>
}
    800055b8:	60a2                	ld	ra,8(sp)
    800055ba:	6402                	ld	s0,0(sp)
    800055bc:	0141                	addi	sp,sp,16
    800055be:	8082                	ret
    panic("free_desc 1");
    800055c0:	00002517          	auipc	a0,0x2
    800055c4:	05850513          	addi	a0,a0,88 # 80007618 <etext+0x618>
    800055c8:	a5cfb0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    800055cc:	00002517          	auipc	a0,0x2
    800055d0:	05c50513          	addi	a0,a0,92 # 80007628 <etext+0x628>
    800055d4:	a50fb0ef          	jal	80000824 <panic>

00000000800055d8 <virtio_disk_init>:
{
    800055d8:	1101                	addi	sp,sp,-32
    800055da:	ec06                	sd	ra,24(sp)
    800055dc:	e822                	sd	s0,16(sp)
    800055de:	e426                	sd	s1,8(sp)
    800055e0:	e04a                	sd	s2,0(sp)
    800055e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055e4:	00002597          	auipc	a1,0x2
    800055e8:	05458593          	addi	a1,a1,84 # 80007638 <etext+0x638>
    800055ec:	0001b517          	auipc	a0,0x1b
    800055f0:	79c50513          	addi	a0,a0,1948 # 80020d88 <disk+0x128>
    800055f4:	daafb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055f8:	100017b7          	lui	a5,0x10001
    800055fc:	4398                	lw	a4,0(a5)
    800055fe:	2701                	sext.w	a4,a4
    80005600:	747277b7          	lui	a5,0x74727
    80005604:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005608:	14f71863          	bne	a4,a5,80005758 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000560c:	100017b7          	lui	a5,0x10001
    80005610:	43dc                	lw	a5,4(a5)
    80005612:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005614:	4709                	li	a4,2
    80005616:	14e79163          	bne	a5,a4,80005758 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000561a:	100017b7          	lui	a5,0x10001
    8000561e:	479c                	lw	a5,8(a5)
    80005620:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005622:	12e79b63          	bne	a5,a4,80005758 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005626:	100017b7          	lui	a5,0x10001
    8000562a:	47d8                	lw	a4,12(a5)
    8000562c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000562e:	554d47b7          	lui	a5,0x554d4
    80005632:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005636:	12f71163          	bne	a4,a5,80005758 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000563a:	100017b7          	lui	a5,0x10001
    8000563e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005642:	4705                	li	a4,1
    80005644:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005646:	470d                	li	a4,3
    80005648:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000564a:	10001737          	lui	a4,0x10001
    8000564e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005650:	c7ffe6b7          	lui	a3,0xc7ffe
    80005654:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9bf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005658:	8f75                	and	a4,a4,a3
    8000565a:	100016b7          	lui	a3,0x10001
    8000565e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005660:	472d                	li	a4,11
    80005662:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005664:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005668:	439c                	lw	a5,0(a5)
    8000566a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000566e:	8ba1                	andi	a5,a5,8
    80005670:	0e078a63          	beqz	a5,80005764 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005674:	100017b7          	lui	a5,0x10001
    80005678:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000567c:	43fc                	lw	a5,68(a5)
    8000567e:	2781                	sext.w	a5,a5
    80005680:	0e079863          	bnez	a5,80005770 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005684:	100017b7          	lui	a5,0x10001
    80005688:	5bdc                	lw	a5,52(a5)
    8000568a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000568c:	0e078863          	beqz	a5,8000577c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005690:	471d                	li	a4,7
    80005692:	0ef77b63          	bgeu	a4,a5,80005788 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005696:	caefb0ef          	jal	80000b44 <kalloc>
    8000569a:	0001b497          	auipc	s1,0x1b
    8000569e:	5c648493          	addi	s1,s1,1478 # 80020c60 <disk>
    800056a2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800056a4:	ca0fb0ef          	jal	80000b44 <kalloc>
    800056a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800056aa:	c9afb0ef          	jal	80000b44 <kalloc>
    800056ae:	87aa                	mv	a5,a0
    800056b0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800056b2:	6088                	ld	a0,0(s1)
    800056b4:	0e050063          	beqz	a0,80005794 <virtio_disk_init+0x1bc>
    800056b8:	0001b717          	auipc	a4,0x1b
    800056bc:	5b073703          	ld	a4,1456(a4) # 80020c68 <disk+0x8>
    800056c0:	cb71                	beqz	a4,80005794 <virtio_disk_init+0x1bc>
    800056c2:	cbe9                	beqz	a5,80005794 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800056c4:	6605                	lui	a2,0x1
    800056c6:	4581                	li	a1,0
    800056c8:	e30fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800056cc:	0001b497          	auipc	s1,0x1b
    800056d0:	59448493          	addi	s1,s1,1428 # 80020c60 <disk>
    800056d4:	6605                	lui	a2,0x1
    800056d6:	4581                	li	a1,0
    800056d8:	6488                	ld	a0,8(s1)
    800056da:	e1efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    800056de:	6605                	lui	a2,0x1
    800056e0:	4581                	li	a1,0
    800056e2:	6888                	ld	a0,16(s1)
    800056e4:	e14fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056e8:	100017b7          	lui	a5,0x10001
    800056ec:	4721                	li	a4,8
    800056ee:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800056f0:	4098                	lw	a4,0(s1)
    800056f2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056f6:	40d8                	lw	a4,4(s1)
    800056f8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056fc:	649c                	ld	a5,8(s1)
    800056fe:	0007869b          	sext.w	a3,a5
    80005702:	10001737          	lui	a4,0x10001
    80005706:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000570a:	9781                	srai	a5,a5,0x20
    8000570c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005710:	689c                	ld	a5,16(s1)
    80005712:	0007869b          	sext.w	a3,a5
    80005716:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000571a:	9781                	srai	a5,a5,0x20
    8000571c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005720:	4785                	li	a5,1
    80005722:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005724:	00f48c23          	sb	a5,24(s1)
    80005728:	00f48ca3          	sb	a5,25(s1)
    8000572c:	00f48d23          	sb	a5,26(s1)
    80005730:	00f48da3          	sb	a5,27(s1)
    80005734:	00f48e23          	sb	a5,28(s1)
    80005738:	00f48ea3          	sb	a5,29(s1)
    8000573c:	00f48f23          	sb	a5,30(s1)
    80005740:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005744:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005748:	07272823          	sw	s2,112(a4)
}
    8000574c:	60e2                	ld	ra,24(sp)
    8000574e:	6442                	ld	s0,16(sp)
    80005750:	64a2                	ld	s1,8(sp)
    80005752:	6902                	ld	s2,0(sp)
    80005754:	6105                	addi	sp,sp,32
    80005756:	8082                	ret
    panic("could not find virtio disk");
    80005758:	00002517          	auipc	a0,0x2
    8000575c:	ef050513          	addi	a0,a0,-272 # 80007648 <etext+0x648>
    80005760:	8c4fb0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005764:	00002517          	auipc	a0,0x2
    80005768:	f0450513          	addi	a0,a0,-252 # 80007668 <etext+0x668>
    8000576c:	8b8fb0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005770:	00002517          	auipc	a0,0x2
    80005774:	f1850513          	addi	a0,a0,-232 # 80007688 <etext+0x688>
    80005778:	8acfb0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    8000577c:	00002517          	auipc	a0,0x2
    80005780:	f2c50513          	addi	a0,a0,-212 # 800076a8 <etext+0x6a8>
    80005784:	8a0fb0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005788:	00002517          	auipc	a0,0x2
    8000578c:	f4050513          	addi	a0,a0,-192 # 800076c8 <etext+0x6c8>
    80005790:	894fb0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005794:	00002517          	auipc	a0,0x2
    80005798:	f5450513          	addi	a0,a0,-172 # 800076e8 <etext+0x6e8>
    8000579c:	888fb0ef          	jal	80000824 <panic>

00000000800057a0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800057a0:	711d                	addi	sp,sp,-96
    800057a2:	ec86                	sd	ra,88(sp)
    800057a4:	e8a2                	sd	s0,80(sp)
    800057a6:	e4a6                	sd	s1,72(sp)
    800057a8:	e0ca                	sd	s2,64(sp)
    800057aa:	fc4e                	sd	s3,56(sp)
    800057ac:	f852                	sd	s4,48(sp)
    800057ae:	f456                	sd	s5,40(sp)
    800057b0:	f05a                	sd	s6,32(sp)
    800057b2:	ec5e                	sd	s7,24(sp)
    800057b4:	e862                	sd	s8,16(sp)
    800057b6:	1080                	addi	s0,sp,96
    800057b8:	89aa                	mv	s3,a0
    800057ba:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057bc:	00c52b83          	lw	s7,12(a0)
    800057c0:	001b9b9b          	slliw	s7,s7,0x1
    800057c4:	1b82                	slli	s7,s7,0x20
    800057c6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800057ca:	0001b517          	auipc	a0,0x1b
    800057ce:	5be50513          	addi	a0,a0,1470 # 80020d88 <disk+0x128>
    800057d2:	c56fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    800057d6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057d8:	0001ba97          	auipc	s5,0x1b
    800057dc:	488a8a93          	addi	s5,s5,1160 # 80020c60 <disk>
  for(int i = 0; i < 3; i++){
    800057e0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800057e2:	5c7d                	li	s8,-1
    800057e4:	a095                	j	80005848 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800057e6:	00fa8733          	add	a4,s5,a5
    800057ea:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800057ee:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800057f0:	0207c563          	bltz	a5,8000581a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800057f4:	2905                	addiw	s2,s2,1
    800057f6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800057f8:	05490c63          	beq	s2,s4,80005850 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800057fc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800057fe:	0001b717          	auipc	a4,0x1b
    80005802:	46270713          	addi	a4,a4,1122 # 80020c60 <disk>
    80005806:	4781                	li	a5,0
    if(disk.free[i]){
    80005808:	01874683          	lbu	a3,24(a4)
    8000580c:	fee9                	bnez	a3,800057e6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000580e:	2785                	addiw	a5,a5,1
    80005810:	0705                	addi	a4,a4,1
    80005812:	fe979be3          	bne	a5,s1,80005808 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005816:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000581a:	01205d63          	blez	s2,80005834 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000581e:	fa042503          	lw	a0,-96(s0)
    80005822:	d41ff0ef          	jal	80005562 <free_desc>
      for(int j = 0; j < i; j++)
    80005826:	4785                	li	a5,1
    80005828:	0127d663          	bge	a5,s2,80005834 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000582c:	fa442503          	lw	a0,-92(s0)
    80005830:	d33ff0ef          	jal	80005562 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005834:	0001b597          	auipc	a1,0x1b
    80005838:	55458593          	addi	a1,a1,1364 # 80020d88 <disk+0x128>
    8000583c:	0001b517          	auipc	a0,0x1b
    80005840:	43c50513          	addi	a0,a0,1084 # 80020c78 <disk+0x18>
    80005844:	fb2fc0ef          	jal	80001ff6 <sleep>
  for(int i = 0; i < 3; i++){
    80005848:	fa040613          	addi	a2,s0,-96
    8000584c:	4901                	li	s2,0
    8000584e:	b77d                	j	800057fc <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005850:	fa042503          	lw	a0,-96(s0)
    80005854:	00451693          	slli	a3,a0,0x4

  if(write)
    80005858:	0001b797          	auipc	a5,0x1b
    8000585c:	40878793          	addi	a5,a5,1032 # 80020c60 <disk>
    80005860:	00451713          	slli	a4,a0,0x4
    80005864:	0a070713          	addi	a4,a4,160
    80005868:	973e                	add	a4,a4,a5
    8000586a:	01603633          	snez	a2,s6
    8000586e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005870:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005874:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005878:	6398                	ld	a4,0(a5)
    8000587a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000587c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005880:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005882:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005884:	6390                	ld	a2,0(a5)
    80005886:	00d60833          	add	a6,a2,a3
    8000588a:	4741                	li	a4,16
    8000588c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005890:	4585                	li	a1,1
    80005892:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005896:	fa442703          	lw	a4,-92(s0)
    8000589a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000589e:	0712                	slli	a4,a4,0x4
    800058a0:	963a                	add	a2,a2,a4
    800058a2:	05898813          	addi	a6,s3,88
    800058a6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800058aa:	0007b883          	ld	a7,0(a5)
    800058ae:	9746                	add	a4,a4,a7
    800058b0:	40000613          	li	a2,1024
    800058b4:	c710                	sw	a2,8(a4)
  if(write)
    800058b6:	001b3613          	seqz	a2,s6
    800058ba:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058be:	8e4d                	or	a2,a2,a1
    800058c0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800058c4:	fa842603          	lw	a2,-88(s0)
    800058c8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058cc:	00451813          	slli	a6,a0,0x4
    800058d0:	02080813          	addi	a6,a6,32
    800058d4:	983e                	add	a6,a6,a5
    800058d6:	577d                	li	a4,-1
    800058d8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800058dc:	0612                	slli	a2,a2,0x4
    800058de:	98b2                	add	a7,a7,a2
    800058e0:	03068713          	addi	a4,a3,48
    800058e4:	973e                	add	a4,a4,a5
    800058e6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800058ea:	6398                	ld	a4,0(a5)
    800058ec:	9732                	add	a4,a4,a2
    800058ee:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800058f0:	4689                	li	a3,2
    800058f2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800058f6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058fa:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    800058fe:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005902:	6794                	ld	a3,8(a5)
    80005904:	0026d703          	lhu	a4,2(a3)
    80005908:	8b1d                	andi	a4,a4,7
    8000590a:	0706                	slli	a4,a4,0x1
    8000590c:	96ba                	add	a3,a3,a4
    8000590e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005912:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005916:	6798                	ld	a4,8(a5)
    80005918:	00275783          	lhu	a5,2(a4)
    8000591c:	2785                	addiw	a5,a5,1
    8000591e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005922:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005926:	100017b7          	lui	a5,0x10001
    8000592a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000592e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005932:	0001b917          	auipc	s2,0x1b
    80005936:	45690913          	addi	s2,s2,1110 # 80020d88 <disk+0x128>
  while(b->disk == 1) {
    8000593a:	84ae                	mv	s1,a1
    8000593c:	00b79a63          	bne	a5,a1,80005950 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005940:	85ca                	mv	a1,s2
    80005942:	854e                	mv	a0,s3
    80005944:	eb2fc0ef          	jal	80001ff6 <sleep>
  while(b->disk == 1) {
    80005948:	0049a783          	lw	a5,4(s3)
    8000594c:	fe978ae3          	beq	a5,s1,80005940 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005950:	fa042903          	lw	s2,-96(s0)
    80005954:	00491713          	slli	a4,s2,0x4
    80005958:	02070713          	addi	a4,a4,32
    8000595c:	0001b797          	auipc	a5,0x1b
    80005960:	30478793          	addi	a5,a5,772 # 80020c60 <disk>
    80005964:	97ba                	add	a5,a5,a4
    80005966:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000596a:	0001b997          	auipc	s3,0x1b
    8000596e:	2f698993          	addi	s3,s3,758 # 80020c60 <disk>
    80005972:	00491713          	slli	a4,s2,0x4
    80005976:	0009b783          	ld	a5,0(s3)
    8000597a:	97ba                	add	a5,a5,a4
    8000597c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005980:	854a                	mv	a0,s2
    80005982:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005986:	bddff0ef          	jal	80005562 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000598a:	8885                	andi	s1,s1,1
    8000598c:	f0fd                	bnez	s1,80005972 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000598e:	0001b517          	auipc	a0,0x1b
    80005992:	3fa50513          	addi	a0,a0,1018 # 80020d88 <disk+0x128>
    80005996:	b26fb0ef          	jal	80000cbc <release>
}
    8000599a:	60e6                	ld	ra,88(sp)
    8000599c:	6446                	ld	s0,80(sp)
    8000599e:	64a6                	ld	s1,72(sp)
    800059a0:	6906                	ld	s2,64(sp)
    800059a2:	79e2                	ld	s3,56(sp)
    800059a4:	7a42                	ld	s4,48(sp)
    800059a6:	7aa2                	ld	s5,40(sp)
    800059a8:	7b02                	ld	s6,32(sp)
    800059aa:	6be2                	ld	s7,24(sp)
    800059ac:	6c42                	ld	s8,16(sp)
    800059ae:	6125                	addi	sp,sp,96
    800059b0:	8082                	ret

00000000800059b2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059b2:	1101                	addi	sp,sp,-32
    800059b4:	ec06                	sd	ra,24(sp)
    800059b6:	e822                	sd	s0,16(sp)
    800059b8:	e426                	sd	s1,8(sp)
    800059ba:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059bc:	0001b497          	auipc	s1,0x1b
    800059c0:	2a448493          	addi	s1,s1,676 # 80020c60 <disk>
    800059c4:	0001b517          	auipc	a0,0x1b
    800059c8:	3c450513          	addi	a0,a0,964 # 80020d88 <disk+0x128>
    800059cc:	a5cfb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059d0:	100017b7          	lui	a5,0x10001
    800059d4:	53bc                	lw	a5,96(a5)
    800059d6:	8b8d                	andi	a5,a5,3
    800059d8:	10001737          	lui	a4,0x10001
    800059dc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800059de:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059e2:	689c                	ld	a5,16(s1)
    800059e4:	0204d703          	lhu	a4,32(s1)
    800059e8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800059ec:	04f70863          	beq	a4,a5,80005a3c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800059f0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059f4:	6898                	ld	a4,16(s1)
    800059f6:	0204d783          	lhu	a5,32(s1)
    800059fa:	8b9d                	andi	a5,a5,7
    800059fc:	078e                	slli	a5,a5,0x3
    800059fe:	97ba                	add	a5,a5,a4
    80005a00:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a02:	00479713          	slli	a4,a5,0x4
    80005a06:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005a0a:	9726                	add	a4,a4,s1
    80005a0c:	01074703          	lbu	a4,16(a4)
    80005a10:	e329                	bnez	a4,80005a52 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a12:	0792                	slli	a5,a5,0x4
    80005a14:	02078793          	addi	a5,a5,32
    80005a18:	97a6                	add	a5,a5,s1
    80005a1a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a1c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a20:	e22fc0ef          	jal	80002042 <wakeup>

    disk.used_idx += 1;
    80005a24:	0204d783          	lhu	a5,32(s1)
    80005a28:	2785                	addiw	a5,a5,1
    80005a2a:	17c2                	slli	a5,a5,0x30
    80005a2c:	93c1                	srli	a5,a5,0x30
    80005a2e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a32:	6898                	ld	a4,16(s1)
    80005a34:	00275703          	lhu	a4,2(a4)
    80005a38:	faf71ce3          	bne	a4,a5,800059f0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a3c:	0001b517          	auipc	a0,0x1b
    80005a40:	34c50513          	addi	a0,a0,844 # 80020d88 <disk+0x128>
    80005a44:	a78fb0ef          	jal	80000cbc <release>
}
    80005a48:	60e2                	ld	ra,24(sp)
    80005a4a:	6442                	ld	s0,16(sp)
    80005a4c:	64a2                	ld	s1,8(sp)
    80005a4e:	6105                	addi	sp,sp,32
    80005a50:	8082                	ret
      panic("virtio_disk_intr status");
    80005a52:	00002517          	auipc	a0,0x2
    80005a56:	cae50513          	addi	a0,a0,-850 # 80007700 <etext+0x700>
    80005a5a:	dcbfa0ef          	jal	80000824 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
