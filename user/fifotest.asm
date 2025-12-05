
user/_fifotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run_child>:
#include "kernel/types.h"
#include "user/user.h"

void run_child(int id)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
    printf("Child %d running\n", id);
   c:	85aa                	mv	a1,a0
   e:	00001517          	auipc	a0,0x1
  12:	91a50513          	addi	a0,a0,-1766 # 928 <malloc+0xf0>
  16:	76a000ef          	jal	780 <printf>
  1a:	0bebc7b7          	lui	a5,0xbebc
  1e:	20078793          	addi	a5,a5,512 # bebc200 <__global_pointer$+0xbebb08f>

    // Busy loop to simulate work
    for (int i = 0; i < 200000000; i++)
  22:	37fd                	addiw	a5,a5,-1
  24:	fffd                	bnez	a5,22 <run_child+0x22>
        ;

    printf("Child %d finished\n", id);
  26:	85a6                	mv	a1,s1
  28:	00001517          	auipc	a0,0x1
  2c:	91850513          	addi	a0,a0,-1768 # 940 <malloc+0x108>
  30:	750000ef          	jal	780 <printf>
    exit(0);
  34:	4501                	li	a0,0
  36:	304000ef          	jal	33a <exit>

000000000000003a <main>:
}

int main()
{
  3a:	1101                	addi	sp,sp,-32
  3c:	ec06                	sd	ra,24(sp)
  3e:	e822                	sd	s0,16(sp)
  40:	1000                	addi	s0,sp,32
    int pid1 = fork();
  42:	2f0000ef          	jal	332 <fork>
    if (pid1 == 0)
  46:	e501                	bnez	a0,4e <main+0x14>
        run_child(1);
  48:	4505                	li	a0,1
  4a:	fb7ff0ef          	jal	0 <run_child>

    int pid2 = fork();
  4e:	2e4000ef          	jal	332 <fork>
    if (pid2 == 0)
  52:	e501                	bnez	a0,5a <main+0x20>
        run_child(2);
  54:	4509                	li	a0,2
  56:	fabff0ef          	jal	0 <run_child>

    int pid3 = fork();
  5a:	2d8000ef          	jal	332 <fork>
    if (pid3 == 0)
  5e:	e501                	bnez	a0,66 <main+0x2c>
        run_child(3);
  60:	450d                	li	a0,3
  62:	f9fff0ef          	jal	0 <run_child>

    // Parent waits for children in FIFO order
    int status;
    wait(&status);
  66:	fec40513          	addi	a0,s0,-20
  6a:	2d8000ef          	jal	342 <wait>
    wait(&status);
  6e:	fec40513          	addi	a0,s0,-20
  72:	2d0000ef          	jal	342 <wait>
    wait(&status);
  76:	fec40513          	addi	a0,s0,-20
  7a:	2c8000ef          	jal	342 <wait>

    exit(0);
  7e:	4501                	li	a0,0
  80:	2ba000ef          	jal	33a <exit>

0000000000000084 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  84:	1141                	addi	sp,sp,-16
  86:	e406                	sd	ra,8(sp)
  88:	e022                	sd	s0,0(sp)
  8a:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  8c:	fafff0ef          	jal	3a <main>
  exit(r);
  90:	2aa000ef          	jal	33a <exit>

0000000000000094 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  94:	1141                	addi	sp,sp,-16
  96:	e406                	sd	ra,8(sp)
  98:	e022                	sd	s0,0(sp)
  9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9c:	87aa                	mv	a5,a0
  9e:	0585                	addi	a1,a1,1
  a0:	0785                	addi	a5,a5,1
  a2:	fff5c703          	lbu	a4,-1(a1)
  a6:	fee78fa3          	sb	a4,-1(a5)
  aa:	fb75                	bnez	a4,9e <strcpy+0xa>
    ;
  return os;
}
  ac:	60a2                	ld	ra,8(sp)
  ae:	6402                	ld	s0,0(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret

00000000000000b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e406                	sd	ra,8(sp)
  b8:	e022                	sd	s0,0(sp)
  ba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cb91                	beqz	a5,d4 <strcmp+0x20>
  c2:	0005c703          	lbu	a4,0(a1)
  c6:	00f71763          	bne	a4,a5,d4 <strcmp+0x20>
    p++, q++;
  ca:	0505                	addi	a0,a0,1
  cc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	fbe5                	bnez	a5,c2 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  d4:	0005c503          	lbu	a0,0(a1)
}
  d8:	40a7853b          	subw	a0,a5,a0
  dc:	60a2                	ld	ra,8(sp)
  de:	6402                	ld	s0,0(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strlen>:

uint
strlen(const char *s)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e406                	sd	ra,8(sp)
  e8:	e022                	sd	s0,0(sp)
  ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cf91                	beqz	a5,10c <strlen+0x28>
  f2:	00150793          	addi	a5,a0,1
  f6:	86be                	mv	a3,a5
  f8:	0785                	addi	a5,a5,1
  fa:	fff7c703          	lbu	a4,-1(a5)
  fe:	ff65                	bnez	a4,f6 <strlen+0x12>
 100:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 104:	60a2                	ld	ra,8(sp)
 106:	6402                	ld	s0,0(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
  for(n = 0; s[n]; n++)
 10c:	4501                	li	a0,0
 10e:	bfdd                	j	104 <strlen+0x20>

0000000000000110 <memset>:

void*
memset(void *dst, int c, uint n)
{
 110:	1141                	addi	sp,sp,-16
 112:	e406                	sd	ra,8(sp)
 114:	e022                	sd	s0,0(sp)
 116:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 118:	ca19                	beqz	a2,12e <memset+0x1e>
 11a:	87aa                	mv	a5,a0
 11c:	1602                	slli	a2,a2,0x20
 11e:	9201                	srli	a2,a2,0x20
 120:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 124:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 128:	0785                	addi	a5,a5,1
 12a:	fee79de3          	bne	a5,a4,124 <memset+0x14>
  }
  return dst;
}
 12e:	60a2                	ld	ra,8(sp)
 130:	6402                	ld	s0,0(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strchr>:

char*
strchr(const char *s, char c)
{
 136:	1141                	addi	sp,sp,-16
 138:	e406                	sd	ra,8(sp)
 13a:	e022                	sd	s0,0(sp)
 13c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13e:	00054783          	lbu	a5,0(a0)
 142:	cf81                	beqz	a5,15a <strchr+0x24>
    if(*s == c)
 144:	00f58763          	beq	a1,a5,152 <strchr+0x1c>
  for(; *s; s++)
 148:	0505                	addi	a0,a0,1
 14a:	00054783          	lbu	a5,0(a0)
 14e:	fbfd                	bnez	a5,144 <strchr+0xe>
      return (char*)s;
  return 0;
 150:	4501                	li	a0,0
}
 152:	60a2                	ld	ra,8(sp)
 154:	6402                	ld	s0,0(sp)
 156:	0141                	addi	sp,sp,16
 158:	8082                	ret
  return 0;
 15a:	4501                	li	a0,0
 15c:	bfdd                	j	152 <strchr+0x1c>

000000000000015e <gets>:

char*
gets(char *buf, int max)
{
 15e:	711d                	addi	sp,sp,-96
 160:	ec86                	sd	ra,88(sp)
 162:	e8a2                	sd	s0,80(sp)
 164:	e4a6                	sd	s1,72(sp)
 166:	e0ca                	sd	s2,64(sp)
 168:	fc4e                	sd	s3,56(sp)
 16a:	f852                	sd	s4,48(sp)
 16c:	f456                	sd	s5,40(sp)
 16e:	f05a                	sd	s6,32(sp)
 170:	ec5e                	sd	s7,24(sp)
 172:	e862                	sd	s8,16(sp)
 174:	1080                	addi	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
 17e:	faf40b13          	addi	s6,s0,-81
 182:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 184:	8c26                	mv	s8,s1
 186:	0014899b          	addiw	s3,s1,1
 18a:	84ce                	mv	s1,s3
 18c:	0349d463          	bge	s3,s4,1b4 <gets+0x56>
    cc = read(0, &c, 1);
 190:	8656                	mv	a2,s5
 192:	85da                	mv	a1,s6
 194:	4501                	li	a0,0
 196:	1bc000ef          	jal	352 <read>
    if(cc < 1)
 19a:	00a05d63          	blez	a0,1b4 <gets+0x56>
      break;
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	0905                	addi	s2,s2,1
 1a8:	ff678713          	addi	a4,a5,-10
 1ac:	c319                	beqz	a4,1b2 <gets+0x54>
 1ae:	17cd                	addi	a5,a5,-13
 1b0:	fbf1                	bnez	a5,184 <gets+0x26>
    buf[i++] = c;
 1b2:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1b4:	9c5e                	add	s8,s8,s7
 1b6:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1ba:	855e                	mv	a0,s7
 1bc:	60e6                	ld	ra,88(sp)
 1be:	6446                	ld	s0,80(sp)
 1c0:	64a6                	ld	s1,72(sp)
 1c2:	6906                	ld	s2,64(sp)
 1c4:	79e2                	ld	s3,56(sp)
 1c6:	7a42                	ld	s4,48(sp)
 1c8:	7aa2                	ld	s5,40(sp)
 1ca:	7b02                	ld	s6,32(sp)
 1cc:	6be2                	ld	s7,24(sp)
 1ce:	6c42                	ld	s8,16(sp)
 1d0:	6125                	addi	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	addi	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e04a                	sd	s2,0(sp)
 1dc:	1000                	addi	s0,sp,32
 1de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e0:	4581                	li	a1,0
 1e2:	198000ef          	jal	37a <open>
  if(fd < 0)
 1e6:	02054263          	bltz	a0,20a <stat+0x36>
 1ea:	e426                	sd	s1,8(sp)
 1ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ee:	85ca                	mv	a1,s2
 1f0:	1a2000ef          	jal	392 <fstat>
 1f4:	892a                	mv	s2,a0
  close(fd);
 1f6:	8526                	mv	a0,s1
 1f8:	16a000ef          	jal	362 <close>
  return r;
 1fc:	64a2                	ld	s1,8(sp)
}
 1fe:	854a                	mv	a0,s2
 200:	60e2                	ld	ra,24(sp)
 202:	6442                	ld	s0,16(sp)
 204:	6902                	ld	s2,0(sp)
 206:	6105                	addi	sp,sp,32
 208:	8082                	ret
    return -1;
 20a:	57fd                	li	a5,-1
 20c:	893e                	mv	s2,a5
 20e:	bfc5                	j	1fe <stat+0x2a>

0000000000000210 <atoi>:

int
atoi(const char *s)
{
 210:	1141                	addi	sp,sp,-16
 212:	e406                	sd	ra,8(sp)
 214:	e022                	sd	s0,0(sp)
 216:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 218:	00054683          	lbu	a3,0(a0)
 21c:	fd06879b          	addiw	a5,a3,-48
 220:	0ff7f793          	zext.b	a5,a5
 224:	4625                	li	a2,9
 226:	02f66963          	bltu	a2,a5,258 <atoi+0x48>
 22a:	872a                	mv	a4,a0
  n = 0;
 22c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 22e:	0705                	addi	a4,a4,1
 230:	0025179b          	slliw	a5,a0,0x2
 234:	9fa9                	addw	a5,a5,a0
 236:	0017979b          	slliw	a5,a5,0x1
 23a:	9fb5                	addw	a5,a5,a3
 23c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 240:	00074683          	lbu	a3,0(a4)
 244:	fd06879b          	addiw	a5,a3,-48
 248:	0ff7f793          	zext.b	a5,a5
 24c:	fef671e3          	bgeu	a2,a5,22e <atoi+0x1e>
  return n;
}
 250:	60a2                	ld	ra,8(sp)
 252:	6402                	ld	s0,0(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  n = 0;
 258:	4501                	li	a0,0
 25a:	bfdd                	j	250 <atoi+0x40>

000000000000025c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e406                	sd	ra,8(sp)
 260:	e022                	sd	s0,0(sp)
 262:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 264:	02b57563          	bgeu	a0,a1,28e <memmove+0x32>
    while(n-- > 0)
 268:	00c05f63          	blez	a2,286 <memmove+0x2a>
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 274:	872a                	mv	a4,a0
      *dst++ = *src++;
 276:	0585                	addi	a1,a1,1
 278:	0705                	addi	a4,a4,1
 27a:	fff5c683          	lbu	a3,-1(a1)
 27e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 282:	fee79ae3          	bne	a5,a4,276 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 286:	60a2                	ld	ra,8(sp)
 288:	6402                	ld	s0,0(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
    while(n-- > 0)
 28e:	fec05ce3          	blez	a2,286 <memmove+0x2a>
    dst += n;
 292:	00c50733          	add	a4,a0,a2
    src += n;
 296:	95b2                	add	a1,a1,a2
 298:	fff6079b          	addiw	a5,a2,-1
 29c:	1782                	slli	a5,a5,0x20
 29e:	9381                	srli	a5,a5,0x20
 2a0:	fff7c793          	not	a5,a5
 2a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a6:	15fd                	addi	a1,a1,-1
 2a8:	177d                	addi	a4,a4,-1
 2aa:	0005c683          	lbu	a3,0(a1)
 2ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b2:	fef71ae3          	bne	a4,a5,2a6 <memmove+0x4a>
 2b6:	bfc1                	j	286 <memmove+0x2a>

00000000000002b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c0:	c61d                	beqz	a2,2ee <memcmp+0x36>
 2c2:	1602                	slli	a2,a2,0x20
 2c4:	9201                	srli	a2,a2,0x20
 2c6:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	0005c703          	lbu	a4,0(a1)
 2d2:	00e79863          	bne	a5,a4,2e2 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2d6:	0505                	addi	a0,a0,1
    p2++;
 2d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2da:	fed518e3          	bne	a0,a3,2ca <memcmp+0x12>
  }
  return 0;
 2de:	4501                	li	a0,0
 2e0:	a019                	j	2e6 <memcmp+0x2e>
      return *p1 - *p2;
 2e2:	40e7853b          	subw	a0,a5,a4
}
 2e6:	60a2                	ld	ra,8(sp)
 2e8:	6402                	ld	s0,0(sp)
 2ea:	0141                	addi	sp,sp,16
 2ec:	8082                	ret
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	bfdd                	j	2e6 <memcmp+0x2e>

00000000000002f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e406                	sd	ra,8(sp)
 2f6:	e022                	sd	s0,0(sp)
 2f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fa:	f63ff0ef          	jal	25c <memmove>
}
 2fe:	60a2                	ld	ra,8(sp)
 300:	6402                	ld	s0,0(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <sbrk>:

char *
sbrk(int n) {
 306:	1141                	addi	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 30e:	4585                	li	a1,1
 310:	0b2000ef          	jal	3c2 <sys_sbrk>
}
 314:	60a2                	ld	ra,8(sp)
 316:	6402                	ld	s0,0(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <sbrklazy>:

char *
sbrklazy(int n) {
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 324:	4589                	li	a1,2
 326:	09c000ef          	jal	3c2 <sys_sbrk>
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 332:	4885                	li	a7,1
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <exit>:
.global exit
exit:
 li a7, SYS_exit
 33a:	4889                	li	a7,2
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <wait>:
.global wait
wait:
 li a7, SYS_wait
 342:	488d                	li	a7,3
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34a:	4891                	li	a7,4
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <read>:
.global read
read:
 li a7, SYS_read
 352:	4895                	li	a7,5
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <write>:
.global write
write:
 li a7, SYS_write
 35a:	48c1                	li	a7,16
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <close>:
.global close
close:
 li a7, SYS_close
 362:	48d5                	li	a7,21
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <kill>:
.global kill
kill:
 li a7, SYS_kill
 36a:	4899                	li	a7,6
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exec>:
.global exec
exec:
 li a7, SYS_exec
 372:	489d                	li	a7,7
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <open>:
.global open
open:
 li a7, SYS_open
 37a:	48bd                	li	a7,15
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 382:	48c5                	li	a7,17
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38a:	48c9                	li	a7,18
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 392:	48a1                	li	a7,8
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <link>:
.global link
link:
 li a7, SYS_link
 39a:	48cd                	li	a7,19
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a2:	48d1                	li	a7,20
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3aa:	48a5                	li	a7,9
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b2:	48a9                	li	a7,10
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ba:	48ad                	li	a7,11
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c2:	48b1                	li	a7,12
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ca:	48b5                	li	a7,13
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d2:	48b9                	li	a7,14
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3da:	1101                	addi	sp,sp,-32
 3dc:	ec06                	sd	ra,24(sp)
 3de:	e822                	sd	s0,16(sp)
 3e0:	1000                	addi	s0,sp,32
 3e2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e6:	4605                	li	a2,1
 3e8:	fef40593          	addi	a1,s0,-17
 3ec:	f6fff0ef          	jal	35a <write>
}
 3f0:	60e2                	ld	ra,24(sp)
 3f2:	6442                	ld	s0,16(sp)
 3f4:	6105                	addi	sp,sp,32
 3f6:	8082                	ret

00000000000003f8 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3f8:	715d                	addi	sp,sp,-80
 3fa:	e486                	sd	ra,72(sp)
 3fc:	e0a2                	sd	s0,64(sp)
 3fe:	f84a                	sd	s2,48(sp)
 400:	f44e                	sd	s3,40(sp)
 402:	0880                	addi	s0,sp,80
 404:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 406:	c6d1                	beqz	a3,492 <printint+0x9a>
 408:	0805d563          	bgez	a1,492 <printint+0x9a>
    neg = 1;
    x = -xx;
 40c:	40b005b3          	neg	a1,a1
    neg = 1;
 410:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 412:	fb840993          	addi	s3,s0,-72
  neg = 0;
 416:	86ce                	mv	a3,s3
  i = 0;
 418:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 41a:	00000817          	auipc	a6,0x0
 41e:	54680813          	addi	a6,a6,1350 # 960 <digits>
 422:	88ba                	mv	a7,a4
 424:	0017051b          	addiw	a0,a4,1
 428:	872a                	mv	a4,a0
 42a:	02c5f7b3          	remu	a5,a1,a2
 42e:	97c2                	add	a5,a5,a6
 430:	0007c783          	lbu	a5,0(a5)
 434:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 438:	87ae                	mv	a5,a1
 43a:	02c5d5b3          	divu	a1,a1,a2
 43e:	0685                	addi	a3,a3,1
 440:	fec7f1e3          	bgeu	a5,a2,422 <printint+0x2a>
  if(neg)
 444:	00030c63          	beqz	t1,45c <printint+0x64>
    buf[i++] = '-';
 448:	fd050793          	addi	a5,a0,-48
 44c:	00878533          	add	a0,a5,s0
 450:	02d00793          	li	a5,45
 454:	fef50423          	sb	a5,-24(a0)
 458:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 45c:	02e05563          	blez	a4,486 <printint+0x8e>
 460:	fc26                	sd	s1,56(sp)
 462:	377d                	addiw	a4,a4,-1
 464:	00e984b3          	add	s1,s3,a4
 468:	19fd                	addi	s3,s3,-1
 46a:	99ba                	add	s3,s3,a4
 46c:	1702                	slli	a4,a4,0x20
 46e:	9301                	srli	a4,a4,0x20
 470:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 474:	0004c583          	lbu	a1,0(s1)
 478:	854a                	mv	a0,s2
 47a:	f61ff0ef          	jal	3da <putc>
  while(--i >= 0)
 47e:	14fd                	addi	s1,s1,-1
 480:	ff349ae3          	bne	s1,s3,474 <printint+0x7c>
 484:	74e2                	ld	s1,56(sp)
}
 486:	60a6                	ld	ra,72(sp)
 488:	6406                	ld	s0,64(sp)
 48a:	7942                	ld	s2,48(sp)
 48c:	79a2                	ld	s3,40(sp)
 48e:	6161                	addi	sp,sp,80
 490:	8082                	ret
  neg = 0;
 492:	4301                	li	t1,0
 494:	bfbd                	j	412 <printint+0x1a>

0000000000000496 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 496:	711d                	addi	sp,sp,-96
 498:	ec86                	sd	ra,88(sp)
 49a:	e8a2                	sd	s0,80(sp)
 49c:	e4a6                	sd	s1,72(sp)
 49e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a0:	0005c483          	lbu	s1,0(a1)
 4a4:	22048363          	beqz	s1,6ca <vprintf+0x234>
 4a8:	e0ca                	sd	s2,64(sp)
 4aa:	fc4e                	sd	s3,56(sp)
 4ac:	f852                	sd	s4,48(sp)
 4ae:	f456                	sd	s5,40(sp)
 4b0:	f05a                	sd	s6,32(sp)
 4b2:	ec5e                	sd	s7,24(sp)
 4b4:	e862                	sd	s8,16(sp)
 4b6:	8b2a                	mv	s6,a0
 4b8:	8a2e                	mv	s4,a1
 4ba:	8bb2                	mv	s7,a2
  state = 0;
 4bc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4be:	4901                	li	s2,0
 4c0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4c2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4c6:	06400c13          	li	s8,100
 4ca:	a00d                	j	4ec <vprintf+0x56>
        putc(fd, c0);
 4cc:	85a6                	mv	a1,s1
 4ce:	855a                	mv	a0,s6
 4d0:	f0bff0ef          	jal	3da <putc>
 4d4:	a019                	j	4da <vprintf+0x44>
    } else if(state == '%'){
 4d6:	03598363          	beq	s3,s5,4fc <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4da:	0019079b          	addiw	a5,s2,1
 4de:	893e                	mv	s2,a5
 4e0:	873e                	mv	a4,a5
 4e2:	97d2                	add	a5,a5,s4
 4e4:	0007c483          	lbu	s1,0(a5)
 4e8:	1c048a63          	beqz	s1,6bc <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4ec:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4f0:	fe0993e3          	bnez	s3,4d6 <vprintf+0x40>
      if(c0 == '%'){
 4f4:	fd579ce3          	bne	a5,s5,4cc <vprintf+0x36>
        state = '%';
 4f8:	89be                	mv	s3,a5
 4fa:	b7c5                	j	4da <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4fc:	00ea06b3          	add	a3,s4,a4
 500:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 504:	1c060863          	beqz	a2,6d4 <vprintf+0x23e>
      if(c0 == 'd'){
 508:	03878763          	beq	a5,s8,536 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 50c:	f9478693          	addi	a3,a5,-108
 510:	0016b693          	seqz	a3,a3
 514:	f9c60593          	addi	a1,a2,-100
 518:	e99d                	bnez	a1,54e <vprintf+0xb8>
 51a:	ca95                	beqz	a3,54e <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 51c:	008b8493          	addi	s1,s7,8
 520:	4685                	li	a3,1
 522:	4629                	li	a2,10
 524:	000bb583          	ld	a1,0(s7)
 528:	855a                	mv	a0,s6
 52a:	ecfff0ef          	jal	3f8 <printint>
        i += 1;
 52e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 530:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 532:	4981                	li	s3,0
 534:	b75d                	j	4da <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 536:	008b8493          	addi	s1,s7,8
 53a:	4685                	li	a3,1
 53c:	4629                	li	a2,10
 53e:	000ba583          	lw	a1,0(s7)
 542:	855a                	mv	a0,s6
 544:	eb5ff0ef          	jal	3f8 <printint>
 548:	8ba6                	mv	s7,s1
      state = 0;
 54a:	4981                	li	s3,0
 54c:	b779                	j	4da <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 54e:	9752                	add	a4,a4,s4
 550:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 554:	f9460713          	addi	a4,a2,-108
 558:	00173713          	seqz	a4,a4
 55c:	8f75                	and	a4,a4,a3
 55e:	f9c58513          	addi	a0,a1,-100
 562:	18051363          	bnez	a0,6e8 <vprintf+0x252>
 566:	18070163          	beqz	a4,6e8 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 56a:	008b8493          	addi	s1,s7,8
 56e:	4685                	li	a3,1
 570:	4629                	li	a2,10
 572:	000bb583          	ld	a1,0(s7)
 576:	855a                	mv	a0,s6
 578:	e81ff0ef          	jal	3f8 <printint>
        i += 2;
 57c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 57e:	8ba6                	mv	s7,s1
      state = 0;
 580:	4981                	li	s3,0
        i += 2;
 582:	bfa1                	j	4da <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 584:	008b8493          	addi	s1,s7,8
 588:	4681                	li	a3,0
 58a:	4629                	li	a2,10
 58c:	000be583          	lwu	a1,0(s7)
 590:	855a                	mv	a0,s6
 592:	e67ff0ef          	jal	3f8 <printint>
 596:	8ba6                	mv	s7,s1
      state = 0;
 598:	4981                	li	s3,0
 59a:	b781                	j	4da <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 59c:	008b8493          	addi	s1,s7,8
 5a0:	4681                	li	a3,0
 5a2:	4629                	li	a2,10
 5a4:	000bb583          	ld	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	e4fff0ef          	jal	3f8 <printint>
        i += 1;
 5ae:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b0:	8ba6                	mv	s7,s1
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b71d                	j	4da <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b6:	008b8493          	addi	s1,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4629                	li	a2,10
 5be:	000bb583          	ld	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	e35ff0ef          	jal	3f8 <printint>
        i += 2;
 5c8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ca:	8ba6                	mv	s7,s1
      state = 0;
 5cc:	4981                	li	s3,0
        i += 2;
 5ce:	b731                	j	4da <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5d0:	008b8493          	addi	s1,s7,8
 5d4:	4681                	li	a3,0
 5d6:	4641                	li	a2,16
 5d8:	000be583          	lwu	a1,0(s7)
 5dc:	855a                	mv	a0,s6
 5de:	e1bff0ef          	jal	3f8 <printint>
 5e2:	8ba6                	mv	s7,s1
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	bdd5                	j	4da <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e8:	008b8493          	addi	s1,s7,8
 5ec:	4681                	li	a3,0
 5ee:	4641                	li	a2,16
 5f0:	000bb583          	ld	a1,0(s7)
 5f4:	855a                	mv	a0,s6
 5f6:	e03ff0ef          	jal	3f8 <printint>
        i += 1;
 5fa:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fc:	8ba6                	mv	s7,s1
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bde9                	j	4da <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 602:	008b8493          	addi	s1,s7,8
 606:	4681                	li	a3,0
 608:	4641                	li	a2,16
 60a:	000bb583          	ld	a1,0(s7)
 60e:	855a                	mv	a0,s6
 610:	de9ff0ef          	jal	3f8 <printint>
        i += 2;
 614:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 616:	8ba6                	mv	s7,s1
      state = 0;
 618:	4981                	li	s3,0
        i += 2;
 61a:	b5c1                	j	4da <vprintf+0x44>
 61c:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 61e:	008b8793          	addi	a5,s7,8
 622:	8cbe                	mv	s9,a5
 624:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 628:	03000593          	li	a1,48
 62c:	855a                	mv	a0,s6
 62e:	dadff0ef          	jal	3da <putc>
  putc(fd, 'x');
 632:	07800593          	li	a1,120
 636:	855a                	mv	a0,s6
 638:	da3ff0ef          	jal	3da <putc>
 63c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63e:	00000b97          	auipc	s7,0x0
 642:	322b8b93          	addi	s7,s7,802 # 960 <digits>
 646:	03c9d793          	srli	a5,s3,0x3c
 64a:	97de                	add	a5,a5,s7
 64c:	0007c583          	lbu	a1,0(a5)
 650:	855a                	mv	a0,s6
 652:	d89ff0ef          	jal	3da <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 656:	0992                	slli	s3,s3,0x4
 658:	34fd                	addiw	s1,s1,-1
 65a:	f4f5                	bnez	s1,646 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 65c:	8be6                	mv	s7,s9
      state = 0;
 65e:	4981                	li	s3,0
 660:	6ca2                	ld	s9,8(sp)
 662:	bda5                	j	4da <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 664:	008b8493          	addi	s1,s7,8
 668:	000bc583          	lbu	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	d6dff0ef          	jal	3da <putc>
 672:	8ba6                	mv	s7,s1
      state = 0;
 674:	4981                	li	s3,0
 676:	b595                	j	4da <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 678:	008b8993          	addi	s3,s7,8
 67c:	000bb483          	ld	s1,0(s7)
 680:	cc91                	beqz	s1,69c <vprintf+0x206>
        for(; *s; s++)
 682:	0004c583          	lbu	a1,0(s1)
 686:	c985                	beqz	a1,6b6 <vprintf+0x220>
          putc(fd, *s);
 688:	855a                	mv	a0,s6
 68a:	d51ff0ef          	jal	3da <putc>
        for(; *s; s++)
 68e:	0485                	addi	s1,s1,1
 690:	0004c583          	lbu	a1,0(s1)
 694:	f9f5                	bnez	a1,688 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 696:	8bce                	mv	s7,s3
      state = 0;
 698:	4981                	li	s3,0
 69a:	b581                	j	4da <vprintf+0x44>
          s = "(null)";
 69c:	00000497          	auipc	s1,0x0
 6a0:	2bc48493          	addi	s1,s1,700 # 958 <malloc+0x120>
        for(; *s; s++)
 6a4:	02800593          	li	a1,40
 6a8:	b7c5                	j	688 <vprintf+0x1f2>
        putc(fd, '%');
 6aa:	85be                	mv	a1,a5
 6ac:	855a                	mv	a0,s6
 6ae:	d2dff0ef          	jal	3da <putc>
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b51d                	j	4da <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6b6:	8bce                	mv	s7,s3
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b505                	j	4da <vprintf+0x44>
 6bc:	6906                	ld	s2,64(sp)
 6be:	79e2                	ld	s3,56(sp)
 6c0:	7a42                	ld	s4,48(sp)
 6c2:	7aa2                	ld	s5,40(sp)
 6c4:	7b02                	ld	s6,32(sp)
 6c6:	6be2                	ld	s7,24(sp)
 6c8:	6c42                	ld	s8,16(sp)
    }
  }
}
 6ca:	60e6                	ld	ra,88(sp)
 6cc:	6446                	ld	s0,80(sp)
 6ce:	64a6                	ld	s1,72(sp)
 6d0:	6125                	addi	sp,sp,96
 6d2:	8082                	ret
      if(c0 == 'd'){
 6d4:	06400713          	li	a4,100
 6d8:	e4e78fe3          	beq	a5,a4,536 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6dc:	f9478693          	addi	a3,a5,-108
 6e0:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6e4:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6e6:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6e8:	07500513          	li	a0,117
 6ec:	e8a78ce3          	beq	a5,a0,584 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6f0:	f8b60513          	addi	a0,a2,-117
 6f4:	e119                	bnez	a0,6fa <vprintf+0x264>
 6f6:	ea0693e3          	bnez	a3,59c <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6fa:	f8b58513          	addi	a0,a1,-117
 6fe:	e119                	bnez	a0,704 <vprintf+0x26e>
 700:	ea071be3          	bnez	a4,5b6 <vprintf+0x120>
      } else if(c0 == 'x'){
 704:	07800513          	li	a0,120
 708:	eca784e3          	beq	a5,a0,5d0 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 70c:	f8860613          	addi	a2,a2,-120
 710:	e219                	bnez	a2,716 <vprintf+0x280>
 712:	ec069be3          	bnez	a3,5e8 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 716:	f8858593          	addi	a1,a1,-120
 71a:	e199                	bnez	a1,720 <vprintf+0x28a>
 71c:	ee0713e3          	bnez	a4,602 <vprintf+0x16c>
      } else if(c0 == 'p'){
 720:	07000713          	li	a4,112
 724:	eee78ce3          	beq	a5,a4,61c <vprintf+0x186>
      } else if(c0 == 'c'){
 728:	06300713          	li	a4,99
 72c:	f2e78ce3          	beq	a5,a4,664 <vprintf+0x1ce>
      } else if(c0 == 's'){
 730:	07300713          	li	a4,115
 734:	f4e782e3          	beq	a5,a4,678 <vprintf+0x1e2>
      } else if(c0 == '%'){
 738:	02500713          	li	a4,37
 73c:	f6e787e3          	beq	a5,a4,6aa <vprintf+0x214>
        putc(fd, '%');
 740:	02500593          	li	a1,37
 744:	855a                	mv	a0,s6
 746:	c95ff0ef          	jal	3da <putc>
        putc(fd, c0);
 74a:	85a6                	mv	a1,s1
 74c:	855a                	mv	a0,s6
 74e:	c8dff0ef          	jal	3da <putc>
      state = 0;
 752:	4981                	li	s3,0
 754:	b359                	j	4da <vprintf+0x44>

0000000000000756 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 756:	715d                	addi	sp,sp,-80
 758:	ec06                	sd	ra,24(sp)
 75a:	e822                	sd	s0,16(sp)
 75c:	1000                	addi	s0,sp,32
 75e:	e010                	sd	a2,0(s0)
 760:	e414                	sd	a3,8(s0)
 762:	e818                	sd	a4,16(s0)
 764:	ec1c                	sd	a5,24(s0)
 766:	03043023          	sd	a6,32(s0)
 76a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 76e:	8622                	mv	a2,s0
 770:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 774:	d23ff0ef          	jal	496 <vprintf>
}
 778:	60e2                	ld	ra,24(sp)
 77a:	6442                	ld	s0,16(sp)
 77c:	6161                	addi	sp,sp,80
 77e:	8082                	ret

0000000000000780 <printf>:

void
printf(const char *fmt, ...)
{
 780:	711d                	addi	sp,sp,-96
 782:	ec06                	sd	ra,24(sp)
 784:	e822                	sd	s0,16(sp)
 786:	1000                	addi	s0,sp,32
 788:	e40c                	sd	a1,8(s0)
 78a:	e810                	sd	a2,16(s0)
 78c:	ec14                	sd	a3,24(s0)
 78e:	f018                	sd	a4,32(s0)
 790:	f41c                	sd	a5,40(s0)
 792:	03043823          	sd	a6,48(s0)
 796:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 79a:	00840613          	addi	a2,s0,8
 79e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a2:	85aa                	mv	a1,a0
 7a4:	4505                	li	a0,1
 7a6:	cf1ff0ef          	jal	496 <vprintf>
}
 7aa:	60e2                	ld	ra,24(sp)
 7ac:	6442                	ld	s0,16(sp)
 7ae:	6125                	addi	sp,sp,96
 7b0:	8082                	ret

00000000000007b2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b2:	1141                	addi	sp,sp,-16
 7b4:	e406                	sd	ra,8(sp)
 7b6:	e022                	sd	s0,0(sp)
 7b8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ba:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7be:	00000797          	auipc	a5,0x0
 7c2:	1ba7b783          	ld	a5,442(a5) # 978 <freep>
 7c6:	a039                	j	7d4 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c8:	6398                	ld	a4,0(a5)
 7ca:	00e7e463          	bltu	a5,a4,7d2 <free+0x20>
 7ce:	00e6ea63          	bltu	a3,a4,7e2 <free+0x30>
{
 7d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d4:	fed7fae3          	bgeu	a5,a3,7c8 <free+0x16>
 7d8:	6398                	ld	a4,0(a5)
 7da:	00e6e463          	bltu	a3,a4,7e2 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7de:	fee7eae3          	bltu	a5,a4,7d2 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7e2:	ff852583          	lw	a1,-8(a0)
 7e6:	6390                	ld	a2,0(a5)
 7e8:	02059813          	slli	a6,a1,0x20
 7ec:	01c85713          	srli	a4,a6,0x1c
 7f0:	9736                	add	a4,a4,a3
 7f2:	02e60563          	beq	a2,a4,81c <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7f6:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7fa:	4790                	lw	a2,8(a5)
 7fc:	02061593          	slli	a1,a2,0x20
 800:	01c5d713          	srli	a4,a1,0x1c
 804:	973e                	add	a4,a4,a5
 806:	02e68263          	beq	a3,a4,82a <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 80a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 80c:	00000717          	auipc	a4,0x0
 810:	16f73623          	sd	a5,364(a4) # 978 <freep>
}
 814:	60a2                	ld	ra,8(sp)
 816:	6402                	ld	s0,0(sp)
 818:	0141                	addi	sp,sp,16
 81a:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 81c:	4618                	lw	a4,8(a2)
 81e:	9f2d                	addw	a4,a4,a1
 820:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 824:	6398                	ld	a4,0(a5)
 826:	6310                	ld	a2,0(a4)
 828:	b7f9                	j	7f6 <free+0x44>
    p->s.size += bp->s.size;
 82a:	ff852703          	lw	a4,-8(a0)
 82e:	9f31                	addw	a4,a4,a2
 830:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 832:	ff053683          	ld	a3,-16(a0)
 836:	bfd1                	j	80a <free+0x58>

0000000000000838 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 838:	7139                	addi	sp,sp,-64
 83a:	fc06                	sd	ra,56(sp)
 83c:	f822                	sd	s0,48(sp)
 83e:	f04a                	sd	s2,32(sp)
 840:	ec4e                	sd	s3,24(sp)
 842:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 844:	02051993          	slli	s3,a0,0x20
 848:	0209d993          	srli	s3,s3,0x20
 84c:	09bd                	addi	s3,s3,15
 84e:	0049d993          	srli	s3,s3,0x4
 852:	2985                	addiw	s3,s3,1
 854:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 856:	00000517          	auipc	a0,0x0
 85a:	12253503          	ld	a0,290(a0) # 978 <freep>
 85e:	c905                	beqz	a0,88e <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 860:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 862:	4798                	lw	a4,8(a5)
 864:	09377463          	bgeu	a4,s3,8ec <malloc+0xb4>
 868:	f426                	sd	s1,40(sp)
 86a:	e852                	sd	s4,16(sp)
 86c:	e456                	sd	s5,8(sp)
 86e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 870:	8a4e                	mv	s4,s3
 872:	6705                	lui	a4,0x1
 874:	00e9f363          	bgeu	s3,a4,87a <malloc+0x42>
 878:	6a05                	lui	s4,0x1
 87a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 87e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 882:	00000497          	auipc	s1,0x0
 886:	0f648493          	addi	s1,s1,246 # 978 <freep>
  if(p == SBRK_ERROR)
 88a:	5afd                	li	s5,-1
 88c:	a82d                	j	8c6 <malloc+0x8e>
 88e:	f426                	sd	s1,40(sp)
 890:	e852                	sd	s4,16(sp)
 892:	e456                	sd	s5,8(sp)
 894:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 896:	80f18793          	addi	a5,gp,-2033 # 980 <base>
 89a:	00000717          	auipc	a4,0x0
 89e:	0cf73f23          	sd	a5,222(a4) # 978 <freep>
 8a2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a8:	b7e1                	j	870 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8aa:	6398                	ld	a4,0(a5)
 8ac:	e118                	sd	a4,0(a0)
 8ae:	a899                	j	904 <malloc+0xcc>
  hp->s.size = nu;
 8b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b4:	0541                	addi	a0,a0,16
 8b6:	efdff0ef          	jal	7b2 <free>
  return freep;
 8ba:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8bc:	c125                	beqz	a0,91c <malloc+0xe4>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c0:	4798                	lw	a4,8(a5)
 8c2:	03277163          	bgeu	a4,s2,8e4 <malloc+0xac>
    if(p == freep)
 8c6:	6098                	ld	a4,0(s1)
 8c8:	853e                	mv	a0,a5
 8ca:	fef71ae3          	bne	a4,a5,8be <malloc+0x86>
  p = sbrk(nu * sizeof(Header));
 8ce:	8552                	mv	a0,s4
 8d0:	a37ff0ef          	jal	306 <sbrk>
  if(p == SBRK_ERROR)
 8d4:	fd551ee3          	bne	a0,s5,8b0 <malloc+0x78>
        return 0;
 8d8:	4501                	li	a0,0
 8da:	74a2                	ld	s1,40(sp)
 8dc:	6a42                	ld	s4,16(sp)
 8de:	6aa2                	ld	s5,8(sp)
 8e0:	6b02                	ld	s6,0(sp)
 8e2:	a03d                	j	910 <malloc+0xd8>
 8e4:	74a2                	ld	s1,40(sp)
 8e6:	6a42                	ld	s4,16(sp)
 8e8:	6aa2                	ld	s5,8(sp)
 8ea:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8ec:	fae90fe3          	beq	s2,a4,8aa <malloc+0x72>
        p->s.size -= nunits;
 8f0:	4137073b          	subw	a4,a4,s3
 8f4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f6:	02071693          	slli	a3,a4,0x20
 8fa:	01c6d713          	srli	a4,a3,0x1c
 8fe:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 900:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 904:	00000717          	auipc	a4,0x0
 908:	06a73a23          	sd	a0,116(a4) # 978 <freep>
      return (void*)(p + 1);
 90c:	01078513          	addi	a0,a5,16
  }
}
 910:	70e2                	ld	ra,56(sp)
 912:	7442                	ld	s0,48(sp)
 914:	7902                	ld	s2,32(sp)
 916:	69e2                	ld	s3,24(sp)
 918:	6121                	addi	sp,sp,64
 91a:	8082                	ret
 91c:	74a2                	ld	s1,40(sp)
 91e:	6a42                	ld	s4,16(sp)
 920:	6aa2                	ld	s5,8(sp)
 922:	6b02                	ld	s6,0(sp)
 924:	b7f5                	j	910 <malloc+0xd8>
