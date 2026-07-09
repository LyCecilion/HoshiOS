# 🤝 参与贡献

谢谢你漂流进这片小宇宙。在向 HoshiOS 贡献代码前，请务必阅读下面的贡献规范。

## 🌊 Git 分支规范说明

HoshiOS 使用 [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)，包含两条长期分支，加上用于功能和发布的短期分支。

```text
main                    ← 生产就绪。带版本 tag。
  └── develop           ← 集成分支。所有功能在此汇合。
        ├── feature/*   ← 每个功能一个分支。从 develop 拉出。
        └── release/*   ← 发布候选。从 develop 拉出。
  └── hotfix/*          ← 紧急修复。从 main 拉出。
```

| 分支             | 从哪拉    | 合到哪             | 用途                                            |
| ---------------- | --------- | ------------------ | ----------------------------------------------- |
| `main`           | —         | —                  | 仅稳定发布。从 `release/*` 或 `hotfix/*` 合入。 |
| `develop`        | `main`    | —                  | 集成分支。所有功能先合到这里。                  |
| `feature/<name>` | `develop` | `develop`          | 一个功能或修复一个分支。                        |
| `release/vX.Y.Z` | `develop` | `main` + `develop` | 发布前冻结：更新版本号、最后润色。              |
| `hotfix/<name>`  | `main`    | `main` + `develop` | 线上紧急修复。                                  |

## 🚀 Git 分支规范流程

### 1. Fork 并 Clone 本仓库

```bash
git clone git@github.com:<username>/HoshiOS.git
cd HoshiOS
git remote add upstream git@github.com:LyCecilion/HoshiOS.git
```

### 2. 创建功能分支

始终从 `develop` 拉分支：

```bash
git checkout develop
git pull upstream develop
git checkout -b feature/<name>
```

### 3. 写代码并提交

```bash
make format
make lint
make run

git add -A
git commit -m "<message>"

git pull --rebase upstream develop
```

### 4. 发起 Pull Request

推送后向 `upstream/develop` 发起 PR：

```bash
git push origin feature/<name>
```

### 5. 发布流程

当 `develop` 积累了足够内容可以发布时，由维护者切出发布分支：

```bash
git checkout develop
git pull upstream develop
git checkout -b release/vX.Y.Z

# 更新版本号、完善 CHANGELOG.md、最终润色

git add -A
git commit -m "chore: release vX.Y.Z"

git push upstream release/vX.Y.Z
```

合入 `main` 后，发布分支还要合回 `develop`，保持集成分支同步：

```bash
git checkout main
git pull upstream main
git tag -a vX.Y.Z -m "HoshiOS vX.Y.Z"
git push upstream --tags

git checkout develop
git pull upstream develop
git merge release/vX.Y.Z
git push upstream develop

git branch -d release/vX.Y.Z
git push upstream --delete release/vX.Y.Z
```

### 6. 紧急修复流程

`main` 上的紧急 bug 直接修复：

```bash
git checkout main
git pull upstream main
git checkout -b hotfix/<name>
```

修复结束后：

```bash
git add -A
git commit -m "fix: <message>"
```

合入 `main` 后，也要合回 `develop`：

```bash
git checkout develop
git pull upstream develop
git merge hotfix/<name>
git push upstream develop
```

## 📋 Pull Request 之前

1. 请先阅读 [CONVENTION.md](./CONVENTION.md)，并确保你的 Pull Request 符合该文档的规范。
2. `make`，并确保 0 warnings 通过编译。
3. `make lint`，并确保 clang-tidy + nixfmt 全部通过。
4. `make run`，并确保 HoshiOS 能够启动、工作正常，且你的 feature 或 hotfix 运行正常。
5. `make format` — 自动格式化所有代码。
6. 基于目标分支 rebase（功能请 rebase 到 `develop`，修复请 rebase 到 `main`）。

## 🌟 注意事项

- 一个 Pull Request 应当仅包含一个逻辑变更，并确保其小而可审阅。
- PR 标题使用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans) 格式。如果有，在 PR 描述中关联相关 Issue。
- 确保合入正确的目标分支，将 feature 合入 `develop`、release 合入 `main`、hotfix 合入 `main`。

## 🧪 测试

在贡献前请首先进行测试，以确保 HoshiOS 能够启动、主要功能工作正常，且你的 feature 工作正常，或 hotfix 修复了相关问题。

## 💬 获取帮助

可以发送 Issues 或 Discussions，或在 Project Hazelita 社群询问零音以获得帮助。
