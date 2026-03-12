#!/bin/bash

# =============================================================================
# OpenClaw 实战案例：自动生成视频并推送到 GitHub
# 
# 描述：根据用户输入的主题自动生成视频，并推送到指定的 GitHub 仓库
# 作者：小煤球
# 日期：2026-03-12
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# 配置参数
# =============================================================================

# API 配置（从环境变量读取，也可在此硬编码）
VIDEO_API_KEY="${VIDEO_API_KEY:-}"
VIDEO_API_URL="${VIDEO_API_URL:-https://api.example-video-gen.com/v1/generate}"

# GitHub 配置
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
DEFAULT_REPO="${DEFAULT_REPO:-xieyz1980/auto-videos}"

# 视频生成参数
DEFAULT_DURATION="${DEFAULT_DURATION:-120}"
DEFAULT_STYLE="${DEFAULT_STYLE:-professional}"

# =============================================================================
# 帮助信息
# =============================================================================

show_help() {
    cat << EOF
OpenClaw 视频自动生成工具

用法: $0 [选项] <主题> [仓库]

参数:
  主题              视频主题/标题 (必需)
  仓库              GitHub 仓库地址 (可选, 默认: $DEFAULT_REPO)

选项:
  -d, --duration    视频时长(秒) (默认: $DEFAULT_DURATION)
  -s, --style       视频风格 (默认: $DEFAULT_STYLE)
                    可选: casual, professional, cinematic
  -h, --help        显示此帮助信息

示例:
  $0 "OpenClaw 入门教程"
  $0 "Python 异步编程" "myusername/videos"
  $0 -d 180 -s cinematic "AI 的未来"

环境变量:
  VIDEO_API_KEY     视频生成 API 密钥 (必需)
  VIDEO_API_URL     视频生成 API 地址
  GITHUB_TOKEN      GitHub Personal Access Token (必需)

EOF
}

# =============================================================================
# 日志函数
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# 检查依赖
# =============================================================================

check_dependencies() {
    local missing=()
    
    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if ! command -v gh &> /dev/null; then
        missing+=("gh (GitHub CLI)")
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "缺少以下依赖: ${missing[*]}"
        log_info "请安装:"
        log_info "  - curl, jq, git: 使用系统包管理器"
        log_info "  - gh: https://cli.github.com/"
        exit 1
    fi
}

# =============================================================================
# 检查环境变量
# =============================================================================

check_env() {
    if [ -z "$VIDEO_API_KEY" ]; then
        log_error "未设置 VIDEO_API_KEY 环境变量"
        log_info "请执行: export VIDEO_API_KEY='your-api-key'"
        exit 1
    fi
    
    if [ -z "$GITHUB_TOKEN" ]; then
        log_warning "未设置 GITHUB_TOKEN，将尝试使用 gh CLI 的已登录账号"
    fi
}

# =============================================================================
# 生成视频脚本
# =============================================================================

generate_script() {
    local topic="$1"
    local duration="$2"
    
    log_info "正在为主题生成视频脚本: $topic"
    
    # 根据时长计算大概的段落数
    local sections=$((duration / 30))
    if [ $sections -lt 3 ]; then
        sections=3
    fi
    
    # 生成结构化脚本
    cat << EOF
{
  "title": "$topic",
  "sections": [
    {
      "section": 1,
      "title": "什么是$topic",
      "content": "介绍$topic的基本概念和背景知识"
    },
    {
      "section": 2,
      "title": "核心要点",
      "content": "讲解$topic的关键概念和重要知识点"
    },
    {
      "section": 3,
      "title": "实际应用",
      "content": "展示$topic在实际场景中的应用案例"
    }
  ],
  "conclusion": "总结$topic的核心价值，并展望未来发展"
}
EOF
}

# =============================================================================
# 调用视频生成 API
# =============================================================================

generate_video() {
    local topic="$1"
    local script_content="$2"
    local duration="$3"
    local style="$4"
    
    log_info "正在调用视频生成 API..."
    log_info "主题: $topic"
    log_info "时长: ${duration}秒"
    log_info "风格: $style"
    
    # 创建临时文件存储响应
    local response_file=$(mktemp)
    
    # 构建 API 请求
    local payload=$(cat << EOF
{
  "title": "$topic",
  "script": $(echo "$script_content" | jq -Rs '.'),
  "duration": $duration,
  "style": "$style",
  "resolution": "1080p",
  "format": "mp4"
}
EOF
)
    
    log_info "发送 API 请求..."
    
    # 模拟 API 调用（实际使用时替换为真实 API）
    # curl -s -X POST "$VIDEO_API_URL" \
    #   -H "Authorization: Bearer $VIDEO_API_KEY" \
    #   -H "Content-Type: application/json" \
    #   -d "$payload" > "$response_file"
    
    # 模拟响应（演示用）
    cat > "$response_file" << EOF
{
  "id": "vid_$(date +%s)",
  "status": "processing",
  "download_url": "",
  "estimated_time": 180
}
EOF
    
    # 解析响应
    local video_id=$(jq -r '.id' "$response_file")
    local status=$(jq -r '.status' "$response_file")
    local estimated_time=$(jq -r '.estimated_time // 180' "$response_file")
    
    log_info "视频任务已创建: $video_id"
    log_info "预计处理时间: ${estimated_time}秒"
    
    # 轮询等待视频生成完成
    log_info "等待视频生成完成..."
    local wait_time=0
    local max_wait=600  # 最多等待10分钟
    
    while [ "$status" == "processing" ] && [ $wait_time -lt $max_wait ]; do
        sleep 10
        wait_time=$((wait_time + 10))
        
        # 模拟状态检查（实际使用时替换为真实 API）
        # curl -s -H "Authorization: Bearer $VIDEO_API_KEY" \
        #   "${VIDEO_API_URL}/status/${video_id}" > "$response_file"
        
        # 模拟完成
        if [ $wait_time -ge 30 ]; then
            cat > "$response_file" << EOF
{
  "id": "$video_id",
  "status": "completed",
  "download_url": "https://example.com/download/${video_id}.mp4"
}
EOF
        fi
        
        status=$(jq -r '.status' "$response_file")
        log_info "状态: $status (${wait_time}s/${max_wait}s)"
    done
    
    if [ "$status" != "completed" ]; then
        log_error "视频生成超时或失败"
        rm -f "$response_file"
        exit 1
    fi
    
    local download_url=$(jq -r '.download_url' "$response_file")
    rm -f "$response_file"
    
    log_success "视频生成完成！"
    echo "$download_url"
}

# =============================================================================
# 下载视频
# =============================================================================

download_video() {
    local url="$1"
    local output_path="$2"
    
    log_info "正在下载视频..."
    
    # 实际下载（如果 URL 有效）
    if [[ "$url" == http* ]]; then
        curl -L --progress-bar "$url" -o "$output_path"
    else
        # 模拟：创建一个占位文件
        log_warning "使用模拟模式，创建占位文件"
        echo "模拟视频文件: $(date)" > "$output_path.txt"
        mv "$output_path.txt" "$output_path"
    fi
    
    if [ -f "$output_path" ]; then
        log_success "视频已下载到: $output_path"
    else
        log_error "下载失败"
        exit 1
    fi
}

# =============================================================================
# 创建元数据文件
# =============================================================================

create_metadata() {
    local topic="$1"
    local video_path="$2"
    local script_content="$3"
    local duration="$4"
    local style="$5"
    
    local metadata_path="${video_path}.json"
    
    log_info "创建元数据文件..."
    
    cat > "$metadata_path" << EOF
{
  "title": "$topic",
  "created_at": "$(date -Iseconds)",
  "filename": "$(basename "$video_path")",
  "duration_seconds": $duration,
  "style": "$style",
  "script": $(echo "$script_content" | jq -Rs '.'),
  "generator": "OpenClaw Auto-Video Tool",
  "version": "1.0.0"
}
EOF
    
    log_success "元数据已保存: $metadata_path"
    echo "$metadata_path"
}

# =============================================================================
# 推送到 GitHub
# =============================================================================

push_to_github() {
    local repo="$1"
    local video_path="$2"
    local metadata_path="$3"
    local topic="$4"
    
    log_info "准备推送到 GitHub: $repo"
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    local repo_dir="$temp_dir/repo"
    
    # 克隆仓库
    log_info "克隆仓库..."
    if ! gh repo clone "$repo" "$repo_dir" 2>/dev/null; then
        log_info "仓库不存在，尝试创建..."
        
        # 解析用户名和仓库名
        local username=$(echo "$repo" | cut -d'/' -f1)
        local reponame=$(echo "$repo" | cut -d'/' -f2)
        
        # 创建新仓库
        gh repo create "$repo" --public --description "Auto-generated videos" || true
        
        # 初始化本地仓库
        mkdir -p "$repo_dir"
        cd "$repo_dir"
        git init
        git remote add origin "https://github.com/$repo.git"
        
        # 创建初始提交
        echo "# Auto-Generated Videos" > README.md
        git add README.md
        git commit -m "Initial commit"
        git push -u origin main || git push -u origin master
    fi
    
    cd "$repo_dir"
    
    # 创建目录结构：auto-videos/YYYY/MM/
    local target_dir="auto-videos/$(date +%Y/%m)"
    mkdir -p "$target_dir"
    
    # 复制文件
    local video_name="video_$(date +%Y%m%d_%H%M%S).mp4"
    cp "$video_path" "$target_dir/$video_name"
    cp "$metadata_path" "$target_dir/${video_name}.json"
    
    # 提交并推送
    log_info "提交更改..."
    git add .
    git commit -m "Add auto-generated video: $topic ($(date +%Y-%m-%d))"
    git push
    
    log_success "已成功推送到 GitHub！"
    log_info "仓库地址: https://github.com/$repo/tree/main/$target_dir"
    
    # 清理临时目录
    rm -rf "$temp_dir"
}

# =============================================================================
# 主函数
# =============================================================================

main() {
    # 解析参数
    local topic=""
    local repo="$DEFAULT_REPO"
    local duration="$DEFAULT_DURATION"
    local style="$DEFAULT_STYLE"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--duration)
                duration="$2"
                shift 2
                ;;
            -s|--style)
                style="$2"
                shift 2
                ;;
            -*)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                if [ -z "$topic" ]; then
                    topic="$1"
                else
                    repo="$1"
                fi
                shift
                ;;
        esac
    done
    
    # 验证参数
    if [ -z "$topic" ]; then
        log_error "请提供视频主题"
        show_help
        exit 1
    fi
    
    # 打印配置信息
    echo ""
    echo "========================================"
    echo "  OpenClaw 视频自动生成工具"
    echo "========================================"
    echo ""
    log_info "视频主题: $topic"
    log_info "目标仓库: $repo"
    log_info "视频时长: ${duration}秒"
    log_info "视频风格: $style"
    echo ""
    
    # 检查依赖和环境
    check_dependencies
    check_env
    
    # 创建工作目录
    local work_dir=$(mktemp -d)
    log_info "工作目录: $work_dir"
    
    # 步骤 1: 生成脚本
    echo ""
    log_info "步骤 1/5: 生成视频脚本..."
    local script_content=$(generate_script "$topic" "$duration")
    echo "$script_content" | jq .
    
    # 步骤 2: 生成视频
    echo ""
    log_info "步骤 2/5: 生成视频（这可能需要几分钟）..."
    local download_url=$(generate_video "$topic" "$script_content" "$duration" "$style")
    
    # 步骤 3: 下载视频
    echo ""
    log_info "步骤 3/5: 下载视频..."
    local video_path="$work_dir/video.mp4"
    download_video "$download_url" "$video_path"
    
    # 步骤 4: 创建元数据
    echo ""
    log_info "步骤 4/5: 创建元数据..."
    local metadata_path=$(create_metadata "$topic" "$video_path" "$script_content" "$duration" "$style")
    
    # 步骤 5: 推送到 GitHub
    echo ""
    log_info "步骤 5/5: 推送到 GitHub..."
    push_to_github "$repo" "$video_path" "$metadata_path" "$topic"
    
    # 完成
    echo ""
    echo "========================================"
    log_success "视频生成和推送完成！"
    echo "========================================"
    echo ""
    log_info "主题: $topic"
    log_info "仓库: https://github.com/$repo"
    log_info "目录: auto-videos/$(date +%Y/%m)/"
    echo ""
    
    # 清理
    rm -rf "$work_dir"
}

# 运行主函数
main "$@"
