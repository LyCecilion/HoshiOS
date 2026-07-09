<!-- markdownlint-disable MD033 MD036 MD041 -->

<div align="center">

![banner](./assets/banner.png)

# 🪐 HoshiOS 🌌

A tiny OS written in Assembly and C,<br/>
for learning how a little universe boots.

[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&duration=4000&pause=1000&color=FFA664&center=true&vCenter=true&width=435&lines=%E5%90%9B%E3%81%A8%E9%9B%86%E3%81%BE%E3%81%A3%E3%81%A6%E6%98%9F%E5%BA%A7%E3%81%AB%E3%81%AA%E3%82%8C%E3%81%9F%E3%82%89;%E6%98%9F%E9%99%8D%E3%82%8B%E5%A4%9C+%E4%B8%80%E7%9E%AC%E3%81%AE%E9%A1%98%E3%81%84%E4%BA%8B;%E3%81%8D%E3%82%89%E3%82%81%E3%81%84%E3%81%A6+%E3%82%86%E3%82%89%E3%82%81%E3%81%84%E3%81%A6+%E9%9C%87%E3%81%88%E3%81%A6%E3%82%8B%E3%82%B7%E3%82%B0%E3%83%8A%E3%83%AB;%E5%90%9B%E3%81%A8%E9%9B%86%E3%81%BE%E3%81%A3%E3%81%A6%E6%98%9F%E5%BA%A7%E3%81%AB%E3%81%AA%E3%82%8C%E3%81%9F%E3%82%89;%E7%A9%BA%E8%A6%8B%E4%B8%8A%E3%81%92%E3%81%A6+%E6%8C%87%E3%82%92%E5%B7%AE%E3%81%95%E3%82%8C%E3%82%8B%E3%82%88%E3%81%86%E3%81%AA;%E3%81%A4%E3%81%AA%E3%81%84%E3%81%A0%E7%B7%9A+%E8%A7%A3%E3%81%8B%E3%81%AA%E3%81%84%E3%81%A7;%E5%83%95%E3%81%8C%E3%81%A9%E3%82%93%E3%81%AA%E3%81%AB%E7%9C%A9%E3%81%97%E3%81%8F%E3%81%A6%E3%82%82)](https://git.io/typing-svg)

</div>

---

## 📖 关于

HoshiOS 是零音从零开始编写的小型操作系统，用以研究操作系统的结构和原理。

HoshiOS 基于 x86 架构，其主线将完全使用汇编和 C 语言完成。HoshiOS 正处于构想和稳步开发阶段。

---

## 🚀 快速开始

### 依赖

使用 Nix，在项目根目录执行 `nix develop` 进入开发环境，或手动安装 `qemu-system-i386`、`clang` / `lld`、`nasm`、`make` 等工具。

### 构建

```bash
git clone https://github.com/LyCecilion/HoshiOS.git
cd HoshiOS/HoshiOS
make
```

### 运行

```bash
make run
```

这会启动 QEMU，在一个图形窗口中显示 VGA 输出，将串口日志打印到终端。

---

## 📁 项目结构

```text
HoshiOS/
├── HoshiOS/          ← 主源码树
│   ├── arch/i386/    ← x86 架构相关（端口 I/O、halt 等）
│   ├── boot/         ← 引导扇区 + 内核入口跳板
│   ├── drivers/      ← 设备驱动
│   ├── kernel/       ← 内核核心
│   ├── lib/          ← 工具函数
│   ├── tools/        ← 调试脚本
│   ├── Makefile      ← 构建系统
│   └── linker.ld     ← 内核链接脚本
├── assets/           ← 图片、banner 等静态资源
├── flake.nix         ← Nix 开发环境
├── .clangd           ← LSP 配置（clangd）
├── .clang-tidy       ← 静态分析规则
├── .clang-format     ← 代码格式化规则
├── .editorconfig     ← 编辑器配置
├── CONTRIBUTING.md   ← 贡献指南
├── CONVENTION.md     ← 开发规范
├── CHANGELOG.md      ← 变更日志
├── ROADMAP.md        ← 路线图
├── LICENSE           ← MIT
└── README.md         ← README
```

---

## 💻 开发

### 日常命令

所有命令都在 `HoshiOS/HoshiOS/` 目录下运行。

| 命令           | 说明                                            |
| -------------- | ----------------------------------------------- |
| `make`         | 编译内核镜像 `build/hoshios.img`                |
| `make run`     | 在 QEMU 中运行（VGA 图形窗口 + 串口输出到终端） |
| `make debug`   | QEMU 启动并暂停，等待 GDB 连接（端口 `:1234`）  |
| `make format`  | 格式化所有 C 代码 + Nix 文件                    |
| `make tidy`    | 运行 clang-tidy 静态检查                        |
| `make lint`    | 完整检查（clang-tidy + nixfmt check）           |
| `make compdb`  | 生成 `compile_commands.json`（供 clangd 使用）  |
| `make disasm`  | 反汇编内核，输出到 `build/kernel.disasm`        |
| `make symbols` | 导出符号表到 `build/kernel.symbols`             |
| `make clean`   | 清空构建目录                                    |

### 使用 gdb/pwndbg 调试

终端 1 — 启动 QEMU（挂起等待调试器）：

```bash
make debug
```

终端 2 — 连接调试器：

```bash
# gdb
gdb -x tools/gdbinit

# pwndbg
pwndbg -x tools/gdbinit
```

`tools/gdbinit` 自动加载内核符号表、连接 QEMU、在 `kernel_main` 处设断点。

常用 gdb/pwndbg 命令：

```text
layout src       # 源码级调试视图
layout asm       # 反汇编视图
info registers   # 查看所有寄存器
stepi            # 单步执行一条机器指令
x/16xb 0xB8000   # 查看 VGA 显存内容
p/x $cr0         # 打印 CR0 控制寄存器
```

---

## 🗺️ 路线图

详见 [ROADMAP.md](./ROADMAP.md)。

---

## 📰 变更日志

详见 [CHANGELOG.md](./CHANGELOG.md)。

---

## 🤝 参与贡献

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)。所有贡献必须遵循 [CONVENTION.md](./CONVENTION.md)。

---

## 📄 许可证

HoshiOS 使用 [MIT License](./LICENSE) 发布。

© 2026 LyCecilion
