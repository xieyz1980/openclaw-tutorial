---
name: video-gen
description: Generate video from text script using video generation API
metadata:
  {
    "openclaw":
      {
        "emoji": "🎬",
        "requires": { 
          "bins": ["curl", "jq"],
          "env": ["VIDEO_API_KEY"]
        },
        "primaryEnv": "VIDEO_API_KEY",
        "install": [
          {
            "id": "apt",
            "kind": "apt",
            "packages": ["curl", "jq"],
            "label": "Install curl and jq"
          }
        ]
      }
  }
---

# video-gen

根据文本脚本生成视频内容。

## 用途

这个 Skill 允许你通过调用视频生成 API，将文本脚本转换为视频文件。支持自定义视频风格、时长和分辨率。

## 前置要求

- 需要 `VIDEO_API_KEY` 环境变量
- 需要安装 `curl` 和 `jq`
- 视频生成 API 账户

## 使用方法

### 1. 生成视频

```bash
# 设置环境变量
export VIDEO_API_KEY="your-api-key-here"

# 调用 API 生成视频
curl -X POST https://api.video-gen.com/v1/generate \
  -H "Authorization: Bearer $VIDEO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "视频标题",
    "script": "视频脚本内容...",
    "duration": 120,
    "style": "professional",
    "resolution": "1080p"
  }'
```

### 2. 检查生成状态

```bash
curl -H "Authorization: Bearer $VIDEO_API_KEY" \
  "https://api.video-gen.com/v1/status/<video_id>"
```

### 3. 下载视频

```bash
curl -L "<download_url>" -o output.mp4
```

## 参数说明

| 参数 | 类型 | 必填 | 说明 |
|-----|------|------|------|
| `title` | string | 是 | 视频标题 |
| `script` | string | 是 | 视频脚本内容 |
| `duration` | number | 否 | 视频时长（秒），默认 60 |
| `style` | string | 否 | 视频风格：`casual`, `professional`, `cinematic` |
| `resolution` | string | 否 | 分辨率：`720p`, `1080p`, `4K` |

## 返回格式

```json
{
  "id": "vid_1234567890",
  "status": "processing",
  "download_url": "",
  "estimated_time": 180
}
```

状态说明：
- `processing`: 正在生成
- `completed`: 已完成
- `failed`: 生成失败

## 完整示例脚本

```bash
#!/bin/bash

# 生成视频
RESPONSE=$(curl -s -X POST https://api.video-gen.com/v1/generate \
  -H "Authorization: Bearer $VIDEO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "OpenClaw 入门教程",
    "script": "本视频介绍 OpenClaw 的基本概念...",
    "duration": 120,
    "style": "professional"
  }')

VIDEO_ID=$(echo "$RESPONSE" | jq -r '.id')
echo "视频任务已创建: $VIDEO_ID"

# 轮询等待完成
while true; do
  STATUS_RESP=$(curl -s -H "Authorization: Bearer $VIDEO_API_KEY" \
    "https://api.video-gen.com/v1/status/$VIDEO_ID")
  
  STATUS=$(echo "$STATUS_RESP" | jq -r '.status')
  
  if [ "$STATUS" == "completed" ]; then
    DOWNLOAD_URL=$(echo "$STATUS_RESP" | jq -r '.download_url')
    echo "视频已生成: $DOWNLOAD_URL"
    curl -L "$DOWNLOAD_URL" -o video.mp4
    break
  elif [ "$STATUS" == "failed" ]; then
    echo "视频生成失败"
    exit 1
  fi
  
  echo "处理中..."
  sleep 10
done
```

## 错误处理

常见错误码：

| 错误码 | 说明 | 解决方法 |
|-------|------|---------|
| 401 | API Key 无效 | 检查 VIDEO_API_KEY 设置 |
| 429 | 请求过于频繁 | 降低请求频率 |
| 500 | 服务器错误 | 稍后重试 |

## 注意事项

1. 视频生成通常需要 2-5 分钟，请耐心等待
2. 脚本长度应与视频时长匹配（每分钟约 150-200 字）
3. 建议使用专业的脚本文案以获得最佳效果
4. 生成的视频可能受版权保护，请遵守相关法律法规
