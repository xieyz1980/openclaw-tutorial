# OpenClaw 教程实战案例

本目录包含 OpenClaw 自动视频生成并推送到 GitHub 的完整实现。

## 文件结构

```
examples/
├── auto-video-github.sh      # 主自动化脚本
├── skills/
│   └── video-gen/
│       └── SKILL.md          # 视频生成 Skill
└── config-example.json       # OpenClaw 配置示例
```

## 快速开始

### 1. 环境准备

```bash
# 安装依赖
sudo apt-get install curl jq git

# 安装 GitHub CLI
# macOS
brew install gh

# Ubuntu/Debian
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# 登录 GitHub
gh auth login
```

### 2. 配置环境变量

```bash
export VIDEO_API_KEY="your-video-api-key"
export VIDEO_API_URL="https://api.video-gen.com/v1/generate"
```

### 3. 运行脚本

```bash
./auto-video-github.sh "OpenClaw 入门教程"
```

## 高级用法

### 指定仓库和参数

```bash
./auto-video-github.sh \
  -d 180 \
  -s cinematic \
  "AI 的未来发展" \
  "myusername/my-videos-repo"
```

参数说明：
- `-d, --duration`: 视频时长（秒）
- `-s, --style`: 视频风格（casual/professional/cinematic）
- 第一个参数: 视频主题
- 第二个参数: GitHub 仓库（可选）

### 作为 OpenClaw Skill 使用

将 `skills/video-gen/` 目录复制到你的 OpenClaw 工作空间：

```bash
cp -r skills/video-gen ~/.openclaw/workspace/skills/
```

然后在 OpenClaw 中即可使用该 Skill。

## 工作原理

```
用户输入主题
    ↓
生成视频脚本
    ↓
调用视频生成 API
    ↓
轮询等待完成
    ↓
下载视频文件
    ↓
创建元数据
    ↓
推送到 GitHub
    ↓
返回结果链接
```

## 故障排除

### 依赖缺失

```bash
# 检查依赖
which curl jq gh git

# 安装缺失的依赖
sudo apt-get install curl jq git
# 安装 gh CLI (见快速开始)
```

### API Key 错误

```bash
# 检查环境变量
echo $VIDEO_API_KEY

# 设置环境变量
export VIDEO_API_KEY="your-api-key"
```

### GitHub 推送失败

```bash
# 检查 gh 登录状态
gh auth status

# 重新登录
gh auth login
```

## 扩展开发

你可以基于这个案例进行扩展：

1. **添加更多视频源**：支持多个视频生成 API
2. **添加字幕生成**：自动生成视频字幕
3. **添加缩略图生成**：为视频生成封面图
4. **添加通知功能**：完成后发送邮件/消息通知
5. **添加队列系统**：支持批量生成视频

## 许可证

MIT License

## 作者

小煤球 - OpenClaw 社区
