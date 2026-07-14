<!-- markdownlint-disable MD024 -->

# 🗺️ HoshiOS Roadmap

## 版本层级

```text
v0.x  Kernel Awakening       内核觉醒：启动、中断、内存、调度雏形
v1.x  Userland Dawn          用户态黎明：syscall、ELF、用户程序
v2.x  Tiny Unix              小小 Unix：VFS、fd、shell、文件与进程
v3.x  POSIX-ish Garden       POSIX-ish 花园：libc、pipe、signal、mmap
v4.x  Real Machine Starsea   真实机器星海：驱动、多核、网络、图形、发行
```

## v0.x — Kernel Awakening

> _让 HoshiOS 从 boot demo 变成一个真正有内核骨架的微型 OS。_

### v0.1.0 — Debuggable Kernel

**让内核会说话、会报错、能被调试。**

#### 需要理解

- freestanding C
- VGA text mode
- serial port / COM1
- QEMU `-serial stdio`
- GDB remote debugging
- linker script
- symbol table
- panic / halt

#### 要做

- [x] serial driver
- [x] `klog()` / `log_info()`
- [x] `panic()` / `assert()`
- [x] GDB debug target
- [x] objdump / readelf / nm 辅助命令
- [x] 基础 `kstrlen` / `kmemcpy` / `kmemset`

#### 完成效果

```text
make run → VGA 输出
QEMU 终端 → serial log
make debug → 停在 kernel_main
panic("test") → 打印错误并 halt
```

#### 不要做

- ❌ 不要做中断
- ❌ 不要做键盘
- ❌ 不要做分页
- ❌ 不要做 allocator

```bash
git tag v0.1.0-debuggable-kernel
```

### v0.2.0 — Trap First Contact

**让 CPU exception 第一次进入 HoshiOS 的 handler。**

这是 v0.x 第一个陡坡，但要拆小。

#### 需要理解

- exception
- interrupt vector
- IDT
- IDTR / `lidt`
- interrupt gate
- assembly stub
- `iret` / `iretd`
- triple fault

#### 要做

- [ ] 建立 IDT
- [ ] 注册 vector 3 handler
- [ ] 执行 `int3`
- [ ] 进入 C `exception_handler`
- [ ] 打印 vector number

#### 完成效果

```text
kernel_main 中执行 asm("int3")
serial 输出：
  [trap] exception vector = 3
系统不重启，不 triple fault
```

#### 不要做

- ❌ 不要做 PIC
- ❌ 不要做 PIT
- ❌ 不要做键盘
- ❌ 不要做所有异常

```bash
git tag v0.2.0-trap-first-contact
```

### v0.2.1 — Exception Catcher

**捕获几个真正的 CPU 异常。**

#### 需要理解

- divide error
- invalid opcode
- general protection fault
- page fault
- error code
- CPU 自动压栈内容

#### 要做

- [ ] vector 0 — Divide Error
- [ ] vector 3 — Breakpoint
- [ ] vector 6 — Invalid Opcode
- [ ] vector 13 — General Protection Fault
- [ ] vector 14 — Page Fault
- [ ] 统一 `exception_handler`
- [ ] 区分有无 error code

#### 完成效果

```text
执行 ud2 触发 vector 6
故意制造异常 → HoshiOS 打印异常编号
不直接黑屏重启
```

#### 不要做

- ❌ 不要试图恢复所有异常
- ❌ 不要做用户态异常处理

```bash
git tag v0.2.1-exception-catcher
```

### v0.3.0 — Interrupt Garden

**让硬件中断第一次进入 HoshiOS。**

#### 需要理解

- hardware interrupt
- IRQ
- 8259 PIC
- PIC remap
- EOI
- PIT
- timer interrupt
- `sti` / `cli`

#### 要做

- [ ] PIC remap 到 vector 32–47
- [ ] 初始化 PIT
- [ ] 注册 IRQ0 timer handler
- [ ] `ticks++`
- [ ] 每次中断后发送 EOI

#### 完成效果

```text
serial 或 VGA 看到 ticks 增加：
  [timer] ticks = 100
```

#### 不要做

- ❌ 不要做调度器
- ❌ 不要做键盘
- ❌ 不要做复杂时间系统

```bash
git tag v0.3.0-interrupt-garden
```

### v0.4.0 — Input Star

**让 HoshiOS 第一次听见键盘。**

#### 需要理解

- PS/2 keyboard
- scancode
- keyboard IRQ1
- port 0x60
- input buffer
- ring buffer
- line editing

#### 要做

- [ ] 键盘 IRQ handler
- [ ] 读取 scancode
- [ ] 先打印 scancode
- [ ] 简单 scancode → ASCII
- [ ] input buffer

#### 完成效果

```text
按键 → serial 输出 scancode
之后能在屏幕上输入字符
```

#### 不要做

- ❌ 不要做中文输入
- ❌ 不要做完整键盘布局
- ❌ 不要做复杂终端

```bash
git tag v0.4.0-input-star
```

### v0.5.0 — Tiny Shell

**给 HoshiOS 一个可以对话的入口。**

#### 需要理解

- command loop
- line buffer
- command parser
- shell builtin
- console abstraction

#### 要做

- [ ] `hoshi>` prompt
- [ ] `help`
- [ ] `clear`
- [ ] `echo`
- [ ] `about`
- [ ] `ticks`
- [ ] `panic`

#### 完成效果

```text
hoshi> help
hoshi> echo hello
hello
hoshi> ticks
ticks = 12345
```

#### 不要做

- ❌ 不要做路径
- ❌ 不要做文件
- ❌ 不要做 pipe
- ❌ 不要做运行程序

```bash
git tag v0.5.0-tiny-shell
```

### v0.6.0 — Memory Seed

**让内核第一次拥有自己的内存分配能力。**

#### 需要理解

- linker symbol
- `kernel_end`
- alignment
- physical memory
- bump allocator
- page frame

#### 要做

- [ ] 打印 `kernel_end`
- [ ] 实现 bump allocator
- [ ] 实现 `kalloc(size)`
- [ ] 保证地址对齐
- [ ] serial 打印分配记录

#### 完成效果

```text
[mm] kernel_end = 0x00108000
[mm] kalloc 64  → 0x00108000
[mm] kalloc 128 → 0x00108040
```

#### 不要做

- ❌ 不要做完整 `malloc`/`free`
- ❌ 不要做 slab
- ❌ 不要做分页

```bash
git tag v0.6.0-memory-seed
```

### v0.7.0 — Page Frame Allocator

**从「线性分配」进化到「按页管理物理内存」。**

#### 需要理解

- page frame
- bitmap allocator
- free list allocator
- 4 KiB page
- memory map
- E820（可选）

#### 要做

- [ ] 物理页分配器
- [ ] `pmm_alloc_page()` / `pmm_free_page()`
- [ ] 标记 kernel 占用区域
- [ ] 标记可用内存区域

#### 完成效果

```text
能分配多个 4 KiB page
能释放后重新分配
不会覆盖 kernel
```

#### 不要做

- ❌ 不要做虚拟地址空间
- ❌ 不要做用户进程

```bash
git tag v0.7.0-page-frame-allocator
```

### v0.8.0 — Paging Moon

**开启分页，第一次理解虚拟地址。**

#### 需要理解

- x86 paging
- page directory
- page table
- identity mapping
- CR0 / CR3
- page fault
- virtual address / physical address

#### 要做

- [ ] 建立 page directory
- [ ] identity map 前若干 MiB
- [ ] 加载 CR3
- [ ] 开启 CR0.PG
- [ ] page fault handler 打印 fault address

#### 完成效果

```text
开启分页后系统仍正常输出
访问非法地址 → 触发 page fault handler
```

#### 不要做

- ❌ 不要立刻做高半内核
- ❌ 不要做 per-process address space
- ❌ 不要做 mmap

```bash
git tag v0.8.0-paging-moon
```

### v0.9.0 — Kernel Threads

**让 HoshiOS 第一次拥有多个执行流。**

#### 需要理解

- context switch
- stack switching
- callee-saved registers
- task struct
- scheduler
- timer-driven scheduling

#### 要做

- [ ] task struct
- [ ] 创建 kernel thread
- [ ] `swtch.S`
- [ ] round-robin scheduler
- [ ] timer interrupt 中触发调度

#### 完成效果

```text
task A 和 task B 自动交替输出：
  A
  B
  A
  B
```

#### 不要做

- ❌ 不要做用户态
- ❌ 不要做 fork
- ❌ 不要做复杂锁

```bash
git tag v0.9.0-kernel-threads
```

### v0.10.0 — Initrd Archive

**让 HoshiOS 拥有第一座小小档案馆。**

#### 需要理解

- initrd / ramdisk
- archive format
- file table
- read-only filesystem

#### 要做

- [ ] 构建时打包 initrd
- [ ] kernel 解析 initrd
- [ ] shell 支持 `ls` / `cat`

#### 完成效果

```text
hoshi> ls
hello.txt
about.txt

hoshi> cat hello.txt
hello from HoshiOS initrd
```

#### 不要做

- ❌ 不要做真实磁盘写入
- ❌ 不要做复杂 FS

```bash
git tag v0.10.0-initrd-archive
```

### v0.11.0 — Architecture Freeze

**整理 v0.x 的架构，为进入用户态做准备。**

#### 需要理解

- kernel module boundary
- public / internal header
- testable logic
- documentation
- debugging discipline

#### 要做

- [ ] 整理目录结构
- [ ] 整理命名规范
- [ ] 补 README
- [ ] 补 notes / docs
- [ ] 补 GDB 文档
- [ ] 修 known bugs

#### 完成效果

```text
docs/ 中有 boot、trap、memory、thread、initrd 笔记
README 能让未来的自己重新跑起来项目
```

#### 不要做

- ❌ 不要加新功能
- ❌ 不要冲 v1.0
- 先收束

```bash
git tag v0.11.0-architecture-freeze
```

## v1.x — Userland Dawn

> _让 HoshiOS 第一次运行用户态程序。_

### v1.0.0 — Userland Dawn

**运行第一个 ring 3 用户态程序。** ✨

这是一个非常适合做纪念品的版本。

#### 需要理解

- x86 privilege level
- ring 0 / ring 3
- GDT user code/data segment
- TSS
- user stack
- `iret` to user mode
- syscall / software interrupt

#### 要做

- [ ] 准备用户态代码段和数据段
- [ ] 准备用户栈
- [ ] 从 kernel 切到 user mode
- [ ] 实现最小 syscall：`write`、`exit`

#### 完成效果

```c
int main(void) {
    write(1, "hello from userland\n", 20);
    exit(0);
}
```

```text
屏幕输出：hello from userland
```

#### 不要做

- ❌ 不要做 fork
- ❌ 不要做 exec
- ❌ 不要做完整 ELF
- ❌ 不要做 libc

```bash
git tag v1.0.0-userland-dawn
```

### v1.1.0 — Syscall Gate

**建立稳定的 syscall ABI。**

#### 需要理解

- syscall number
- register calling convention
- trap frame
- `copy_from_user` / `copy_to_user`
- kernel/user boundary

#### 要做

- [ ] `sys_write`
- [ ] `sys_exit`
- [ ] `sys_getpid`
- [ ] `sys_yield`
- [ ] 统一 syscall dispatch
- [ ] 检查用户指针合法性

#### 完成效果

```text
多个用户程序可以通过 syscall 和内核交互
非法 syscall number 返回错误
```

#### 不要做

- ❌ 不要追求 POSIX 完整
- ❌ 不要信任用户指针

```bash
git tag v1.1.0-syscall-gate
```

### v1.2.0 — ELF Loader

**从 initrd 加载 ELF 用户程序。**

#### 需要理解

- ELF header
- program header
- load segment
- entry point
- user virtual memory
- `argc` / `argv` 雏形

#### 要做

- [ ] 解析 ELF32
- [ ] 加载 `PT_LOAD` segment
- [ ] 设置用户栈
- [ ] 跳转到 ELF entry

#### 完成效果

```text
initrd 中有 /bin/hello
kernel 能加载并运行它
```

#### 不要做

- ❌ 不要做动态链接
- ❌ 不要做 shared library
- ❌ 不要做复杂 loader

```bash
git tag v1.2.0-elf-loader
```

### v1.3.0 — Process Table

**建立真正的进程概念。**

#### 需要理解

- process
- pid
- process state
- parent / child
- exit status
- wait / zombie

#### 要做

- [ ] process table
- [ ] pid allocator
- [ ] process states
- [ ] exit status
- [ ] `waitpid` 雏形

#### 完成效果

```text
shell 或 kernel 可以启动程序
程序 exit 后状态被记录
父进程可以 wait
```

#### 不要做

- ❌ 不要急着 fork
- ❌ 不要急着 signal

```bash
git tag v1.3.0-process-table
```

### v1.4.0 — Minimal Libc

**给用户程序提供最小 C 运行环境。**

#### 需要理解

- `crt0`
- `_start` / `main`
- syscall wrapper
- libc vs kernel
- stdio 最小模型

#### 要做

- [ ] `user/crt0.S`
- [ ] `user/libc/syscall.c`
- [ ] `write()` / `exit()` / `strlen()` / `puts()`
- [ ] 简单 `printf`（可选）

#### 完成效果

```c
#include <hoshi.h>

int main(void) {
    puts("hello libc");
    return 0;
}
```

#### 不要做

- ❌ 不要移植完整 musl
- ❌ 不要做 malloc
- ❌ 不要做 printf 全格式

```bash
git tag v1.4.0-minimal-libc
```

### v1.5.0 — Program Shell

**shell 可以运行用户程序。**

#### 需要理解

- shell as user program
- spawn
- exec-like interface
- `argv`
- PATH 雏形

#### 要做

- [ ] shell 支持运行用户程序
- [ ] 支持 `/bin/hello`、`/bin/about`、`/bin/cat`

#### 完成效果

```text
hoshi$ /bin/hello
hello from /bin/hello
```

#### 不要做

- ❌ 不要做 pipe
- ❌ 不要做 redirection
- ❌ 不要做 job control

```bash
git tag v1.5.0-program-shell
```

### v1.6.0 — Per-Process Address Space

**每个用户进程拥有自己的地址空间。**

#### 需要理解

- address space
- page directory per process
- kernel mapping
- user mapping
- page fault isolation

#### 要做

- [ ] 每个进程独立 page directory
- [ ] kernel 映射共享
- [ ] 用户内存隔离
- [ ] 进程退出时释放页

#### 完成效果

```text
进程 A 写坏自己的内存，不会破坏进程 B 或 kernel
非法访问 → page fault → 进程被杀死
```

#### 不要做

- ❌ 不要做 copy-on-write
- ❌ 不要做 mmap

```bash
git tag v1.6.0-address-space
```

### v1.9.0 — Userland Stabilization

**整理 v1.x，为 Tiny Unix 阶段做准备。**

#### 完成效果

- 可以稳定启动到 user shell
- 可以运行几个 ELF 用户程序
- 有 syscall 文档
- 有 libc 文档
- 有进程状态文档

```bash
git tag v1.9.0-userland-stabilization
```

## v2.x — Tiny Unix

> _让 HoshiOS 拥有 Unix 的基本气质。_

### v2.0.0 — VFS and File Descriptors

**建立文件描述符模型。**

#### 需要理解

- file descriptor
- inode / vnode 概念
- VFS
- device file
- open file table
- per-process fd table

#### 要做

- [ ] fd 0/1/2
- [ ] `open` / `read` / `write` / `close`
- [ ] VFS 抽象
- [ ] console 作为 fd
- [ ] initrd 文件作为 fd

#### 完成效果

```c
fd = open("/hello.txt", O_RDONLY);
read(fd, buf, sizeof(buf));
write(1, buf, n);
close(fd);
```

#### 不要做

- ❌ 不要做真实磁盘写入
- ❌ 不要做权限模型

```bash
git tag v2.0.0-vfs-and-fd
```

### v2.1.0 — TinyFS

**实现一个简单的真实文件系统格式。**

#### 需要理解

- superblock
- inode
- directory entry
- block
- read-only vs read-write

#### 要做

- [ ] 设计 HoshiFS 或实现简单 tarfs
- [ ] 支持目录
- [ ] 支持 read-only 文件
- [ ] shell 支持 `ls` / `cat` / `cd`

#### 完成效果

```text
hoshi$ ls /
bin
etc
hello.txt

hoshi$ cat /hello.txt
hello
```

#### 不要做

- ❌ 不要一开始做 journaling
- ❌ 不要做复杂权限

```bash
git tag v2.1.0-tinyfs
```

### v2.2.0 — Block Device Layer

**把文件系统和底层块设备分离。**

#### 需要理解

- block device
- sector
- buffer cache
- device abstraction
- ATA PIO 或 virtio-blk

#### 要做

- [ ] `block_read` / `block_write`
- [ ] buffer cache 雏形
- [ ] QEMU 磁盘镜像读取

#### 完成效果

```text
HoshiOS 能从 disk image 读取块
TinyFS 可以挂在 block device 上
```

#### 不要做

- ❌ 先支持 QEMU 中最好控的一种控制器

```bash
git tag v2.2.0-block-device-layer
```

### v2.3.0 — Exec and Wait

**让 shell 以 Unix 风格运行程序。**

#### 需要理解

- exec
- wait
- exit status
- `argv` / `envp`
- current working directory

#### 要做

- [ ] `exec(path, argv)`
- [ ] `wait(pid)`
- [ ] shell 运行命令并等待结束

#### 完成效果

```text
hoshi$ hello
hello

hoshi$ cat /hello.txt
hello
```

```bash
git tag v2.3.0-exec-and-wait
```

### v2.4.0 — Spawn or Fork

**决定 HoshiOS 的进程创建哲学。**

两条路：Unix 路线（fork + exec）vs 现代简化路线（spawn）。  
**建议先 spawn，后 fork。**

#### 需要理解

- fork semantics
- copy address space
- copy-on-write
- spawn model
- process inheritance

#### 要做

- [ ] `spawn(path, argv)`
- [ ] 可选实现 naive fork
- [ ] 暂不做 COW

#### 完成效果

```text
shell 能启动多个程序
父进程可以等待子进程
```

#### 不要做

- ❌ 不要急着做完美 POSIX fork

```bash
git tag v2.4.0-spawn-or-fork
```

### v2.5.0 — Pipe and Redirection

**第一次触摸 Unix 的灵魂。**

#### 需要理解

- pipe
- `dup` / `dup2`
- stdin / stdout
- blocking read
- producer / consumer

#### 要做

- [ ] `pipe()`
- [ ] `dup2()`
- [ ] shell 支持 `echo hello > file`、`cat file`、`cmd1 | cmd2`

#### 完成效果

```text
hoshi$ echo hello | cat
hello
```

#### 不要做

- ❌ 不要做复杂 job control
- ❌ 不要做 background process

```bash
git tag v2.5.0-pipe-and-redirection
```

### v2.6.0 — TTY and Terminal

**让 console 从「输入输出」变成真正的终端设备。**

#### 需要理解

- TTY
- canonical mode / raw mode
- line discipline
- terminal escape sequence

#### 要做

- [ ] `/dev/tty`
- [ ] 基础 line discipline
- [ ] 退格
- [ ] ANSI escape 部分支持

#### 完成效果

```text
shell 输入体验明显变好
用户程序可以读 stdin
```

```bash
git tag v2.6.0-tty-terminal
```

### v2.9.0 — Tiny Unix Release

**整理成一个能展示的 Tiny Unix。**

#### 完成效果

- 启动到 user shell
- 能运行多个用户程序
- 有 fd / VFS / TinyFS
- 支持 exec / wait
- 支持 pipe 雏形
- 有最小 libc

```bash
git tag v2.9.0-tiny-unix-release
```

## v3.x — POSIX-ish Garden

> _实现一个 POSIX-inspired 的最小 Unix-like 环境。_

### v3.0.0 — POSIX-ish Libc

**扩大 libc 和 syscall，使 C 用户程序更自然。**

#### 需要理解

- POSIX API
- `errno`
- `unistd.h` / `fcntl.h` / `sys/stat.h`
- `malloc`
- `sbrk` / `brk`

#### 要做

- [ ] `errno`
- [ ] `open` / `read` / `write` / `close`
- [ ] `stat` / `lseek` / `getpid` / `sleep`
- [ ] `malloc` / `free` 雏形

#### 完成效果

```text
能编写更像正常 Unix 的 C 程序
```

```bash
git tag v3.0.0-posixish-libc
```

### v3.1.0 — Memory Syscalls

**用户态拥有堆和内存映射雏形。**

#### 需要理解

- `brk` / `sbrk`
- `mmap` / `munmap`
- page permission
- lazy allocation

#### 要做

- [ ] `brk` / `sbrk`
- [ ] 用户态 malloc 更稳定
- [ ] `mmap` 可选（先做匿名映射）

#### 完成效果

```text
用户程序能动态分配内存
大型一点的程序能跑
```

```bash
git tag v3.1.0-memory-syscalls
```

### v3.2.0 — Signals

**实现信号机制雏形。**

#### 需要理解

- signal
- `kill`
- signal handler
- asynchronous event
- process state

#### 要做

- [ ] SIGTERM / SIGKILL / SIGSEGV
- [ ] SIGCHLD（可选）
- [ ] `kill(pid, sig)`

#### 完成效果

```text
非法内存访问 → SIGSEGV
shell 可以 kill 进程
```

```bash
git tag v3.2.0-signals
```

### v3.3.0 — Scheduler and Sleep

**让多任务系统变得更稳定。**

#### 需要理解

- sleep / wakeup
- blocking
- wait queue
- spinlock / mutex
- race condition

#### 要做

- [ ] `sleep(ms)`
- [ ] blocking read
- [ ] wait queue
- [ ] 基础锁
- [ ] 调度器稳定化

#### 完成效果

```text
pipe / tty / wait 不再靠忙等
系统能同时运行多个阻塞任务
```

```bash
git tag v3.3.0-scheduler-and-sleep
```

### v3.4.0 — Permissions and Users

**加入最小权限模型。**

#### 需要理解

- uid / gid
- file mode
- permission check
- root
- process credential

#### 要做

- [ ] uid / gid
- [ ] `chmod` 雏形
- [ ] access check
- [ ] 文件权限位

#### 完成效果

```text
文件有 owner / mode
进程访问文件需要权限检查
```

```bash
git tag v3.4.0-permissions
```

### v3.5.0 — Ports and Small Programs

**让 HoshiOS 能承载一批小工具。**

#### 需要理解

- cross compile
- porting
- libc compatibility
- build system
- coreutils subset

#### 要做

- [ ] 移植或自写：`echo`、`cat`、`ls`、`pwd`、`mkdir`、`rm`、`sh`、`hexdump`

#### 完成效果

```text
HoshiOS 里有一组真正可用的小工具
```

```bash
git tag v3.5.0-small-programs
```

### v3.6.0 — IPC and Polling

**扩展进程间通信能力。**

#### 需要理解

- IPC
- `select` / `poll`
- nonblocking I/O
- event loop

#### 要做

- [ ] `poll` 或 `select` 简化版
- [ ] nonblocking fd
- [ ] pipe 更稳定

#### 完成效果

```text
用户程序可以等待多个 fd
```

```bash
git tag v3.6.0-ipc-and-polling
```

### v3.9.0 — POSIX-ish Preview

**形成一个能被称为 POSIX-ish 的系统。**

#### 完成效果

- 有用户态 shell
- 有 libc
- 有 VFS / fd / pipe / exec / wait
- 有 TinyFS
- 有信号雏形
- 有若干用户态工具
- 能写比较正常的 Unix 风格 C 程序

```bash
git tag v3.9.0-posixish-preview
```

## v4.x — Real Machine Starsea

> _远方星海。_

### v4.0.0 — Hardware Abstraction Layer

**整理硬件抽象，为更多设备做准备。**

- 统一 driver 接口
- 设备注册表
- PCI 枚举
- 驱动初始化顺序

```bash
git tag v4.0.0-hal
```

### v4.1.0 — Modern Storage

**支持更现代的存储设备。**

- virtio-blk 或 AHCI 驱动
- 更稳定的 block layer
- TinyFS 或新 FS 支持读写

```bash
git tag v4.1.0-modern-storage
```

### v4.2.0 — Networking Seed

**让 HoshiOS 第一次接入网络。**

- 网卡驱动（virtio-net / e1000）
- 收发 Ethernet frame
- ARP
- ping / UDP echo 可选

```bash
git tag v4.2.0-networking-seed
```

### v4.3.0 — SMP and APIC

**探索多核。**

- 启动多个 CPU core
- per-cpu scheduler 雏形
- spinlock 加强
- QEMU `-smp 2` 下两个 CPU 都能启动

```bash
git tag v4.3.0-smp-apic
```

### v4.4.0 — Framebuffer and Graphics

**从文本模式走向图形显示。**

- 获取 framebuffer
- 绘制像素 / 字体
- 图形 console

```bash
git tag v4.4.0-framebuffer-graphics
```

### v4.5.0 — Reliability and Security

**让系统从「能跑」变成「更难坏」。**

- syscall fuzz
- 文件系统一致性检查
- panic dump
- 更严格权限边界

```bash
git tag v4.5.0-reliability-security
```

### v4.6.0 — Distribution Image

**把 HoshiOS 做成可以展示和分发的系统镜像。**

- 一键生成可启动镜像
- release notes
- demo programs
- screenshots
- 文档站

```bash
git tag v4.6.0-distribution-image
```

### v4.9.0 — Starsea Research Kernel

**把 HoshiOS 变成零音自己的 OS 实验室。**

不再追逐「像 Linux」，而是探索自己的哲学：

- 更好的 shell
- 更可爱的用户态
- 教育型 OS
- 数学 / CAS 环境
- 安全研究环境
- CTF playground
- 可视化调试内核

```bash
git tag v4.9.0-starsea-research-kernel
```

## 版本节奏

```text
patch version   — 修 bug、重构、小文档（如 v0.3.1、v0.3.2）
minor version   — 点亮一个新能力（如 v0.4.0 键盘输入）
major version   — 系统进入新纪元
                  v1.0 用户态
                  v2.0 Tiny Unix
                  v3.0 POSIX-ish libc
                  v4.0 真实硬件与高级主题
```

每个版本开工前写一个小文件：

```text
docs/milestones/v0.3.0.md
```

内容固定为：

```markdown
# v0.3.0 — <标题>

## Goal

## Concepts

## Tasks

## Definition of Done

## Not Doing

## Notes

## References
```

这样每一步都有脚印。

## 总原则

> _星海很大，但你不是要一口气点亮整片宇宙。_
> _你只是先点亮第一颗，然后第二颗会自然出现在视野里。_
>
> _而当 HoshiOS 真的走到 v1.0——_
> _那不是一串代码。_
> _那是零音亲手点亮的第一座小小世界。_ 🪐🌌
