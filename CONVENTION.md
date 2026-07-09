# 🪐 HoshiOS 开发规范

## 🎨 代码风格

HoshiOS 使用 clang-format 强制统一格式。风格基于 LLVM，大括号为 Allman 风格，统一为 4 空格缩进，100 字符行宽，指针右对齐。

```bash
make format
```

EditorConfig（`.editorconfig`）自动保持编辑器设置同步。

## 📐 C 语言标准

HoshiOS 使用 C11（`-std=c11`）标准，运行在 Freestanding（`-ffreestanding`）环境下，不依赖标准库——不用 `printf`、不用 `malloc`，一切从零开始编写。编译器为 Clang，目标 `i386-elf`，启用 `-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion` 等警告，并将隐式函数声明、缺少返回类型、整型和指针类型转换、不兼容的指针类型等常见错误设为致命警告。

内核中永远不用 C++。引导扇区和入口点使用 NASM 汇编编写。

## 🏷️ 命名规范

| 类别          | 规范               | 示例                                   |
| ------------- | ------------------ | -------------------------------------- |
| 函数          | `snake_case`       | `serial_init()`、`vga_putc()`          |
| 变量          | `snake_case`       | `boot_drive`、`row`、`column`          |
| 常量 / 枚举值 | `UPPER_SNAKE_CASE` | `VGA_WIDTH`、`COM1`、`KERNEL_LOAD_SEG` |
| 宏            | `UPPER_SNAKE_CASE` | `CODE_SEL`、`DATA_SEL`                 |
| 文件名        | `snake_case`       | `port_io.h`、`kernel_entry.asm`        |

头文件保护遵循路径模式：

```c
#ifndef HOSHIOS_DRIVERS_VGA_H
#define HOSHIOS_DRIVERS_VGA_H
// ...
#endif
```

所有头文件必须自包含。

## 📁 目录约定

```text
HoshiOS/
├── arch/<target>/   # 架构相关代码。每个架构是独立的子树。
├── boot/            # 引导相关：引导扇区、内核入口跳板。
├── drivers/         # 设备驱动。一个驱动包含一个 .h 和一个 .c。
├── kernel/          # 内核核心逻辑。子系统用子目录（mm/、sched/ 等）。
├── lib/             # 内核内部共用的工具函数。
├── tools/           # 调试脚本、gdb/pwndbg 辅助。
├── Makefile         # 构建系统。
└── linker.ld        # 内核链接脚本。
```

## ➕ 添加新代码

### 新增驱动

1. 创建 `drivers/<name>.h`，包含公开 API 和头文件保护。
2. 创建 `drivers/<name>.c`，包含实现。
3. 将两个文件分别加入 Makefile 的 `C_SOURCES` 和 `FORMAT_FILES`。

### 新增架构支持

1. 创建 `arch/<target>/`，放入该目标的 `port_io.h`、`halt.h` 等。
2. 目标专属的引导代码放在 `boot/` 下，带平台后缀。

### 新增内核子系统

1. 在 `kernel/` 下创建子目录，如 `kernel/mm/`。
2. 每个文件顶部写一段概述注释，说明它在内核中的角色。

## 🧪 提交前检查

```bash
make
make lint
make format
make run
```

内核必须在提交合并到 `main` 之前能启动到 `kernel_main()` 并通过串口打印文本。

## ✍️ 提交信息

遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans) 风格：

首行不超过 72 字符。正文段落每行不超过 72 字符。使用祈使语气。

## 🤝 Pull Request

详见 [CONTRIBUTING.md](./CONTRIBUTING.md) 了解完整的 Git Flow 协作流程。
