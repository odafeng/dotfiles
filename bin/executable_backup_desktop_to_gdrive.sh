#!/bin/bash
# 備份重要資料到 Google Drive 的 Macbook_Backup 資料夾。
# rclone sync = 鏡像；但加了 --backup-dir，被刪除/被覆蓋的舊檔不會直接消失，
# 而是搬到 Macbook_Backup_versions/<時間戳>/ 保留下來（誤刪可救回，30 天後自動清理）。
# 每天 02:00 由 launchd 執行 (com.huangshifeng.backup-desktop-gdrive)。
#
# 備份範圍：桌面 + 桌面以外的重要資料夾(~/bin、~/code、~/Projects、~/.config、~/Documents)。
# 桌面備到 Macbook_Backup 根目錄(沿用既有結構)；其餘放到 Macbook_Backup/_home/ 下。
# 注意：~/.ssh 私鑰刻意「不」納入(避免明文上雲)，靠 Time Machine 等本機備份保護。

LOG_FILE="$HOME/Library/Logs/backup_desktop.log"
DEST_ROOT="gdrive:Macbook_Backup"
VERS_ROOT="gdrive:Macbook_Backup_versions"
STAMP="$(date '+%Y-%m-%d_%H%M%S')"

# 要備份的來源；格式 "本機路徑|雲端子路徑"。子路徑留空 = 備到 Macbook_Backup 根(桌面)。
SOURCES=(
  "$HOME/Desktop|"
  "$HOME/bin|_home/bin"
  "$HOME/code|_home/code"
  "$HOME/Projects|_home/Projects"
  "$HOME/.config|_home/.config"
  "$HOME/Documents|_home/Documents"
)

# 所有來源共用的排除清單(開發暫存檔/快取/虛擬環境等不需備份)。
EXCLUDES=(
  --exclude "System Scripts/backup_desktop.log"
  --exclude "No Backup/**"
  --exclude "node_modules/**"
  --exclude ".venv/**"
  --exclude ".venv*/**"
  --exclude "venv/**"
  --exclude "venv*/**"
  --exclude "**/site-packages/**"
  --exclude "__pycache__/**"
  --exclude ".next/**"
  --exclude ".turbo/**"
  --exclude ".cache/**"
  --exclude ".mypy_cache/**"
  --exclude ".pytest_cache/**"
  --exclude ".ruff_cache/**"
  --exclude ".tox/**"
  --exclude "*.egg-info/**"
  --exclude "dist/**"
  --exclude "build/**"
  --exclude "*.pyc"
)

# 互動式執行(從終端機跑 bkup)時，額外把進度條顯示在螢幕；
# 由 launchd 排程執行(無 TTY)時維持原本只寫 log 的安靜行為。
if [ -t 1 ]; then
  INTERACTIVE=1
  RCLONE_PROGRESS=(--progress)
else
  INTERACTIVE=0
  RCLONE_PROGRESS=()
fi

# 訊息一律寫入 log；互動模式下同時印到螢幕。
say() {
  echo "$@" >> "$LOG_FILE"
  [ "$INTERACTIVE" = 1 ] && echo "$@"
}

say "===== 備份開始: $(date '+%Y-%m-%d %H:%M:%S')  (versions→$STAMP) ====="

for entry in "${SOURCES[@]}"; do
  src="${entry%%|*}"
  sub="${entry#*|}"
  if [ ! -e "$src" ]; then
    say "  跳過(來源不存在): $src"
    continue
  fi
  if [ -n "$sub" ]; then
    dest="$DEST_ROOT/$sub"
    vdir="$VERS_ROOT/$STAMP/$sub"
  else
    dest="$DEST_ROOT"
    vdir="$VERS_ROOT/$STAMP"
  fi
  say "  → sync $src  →  $dest"
  /opt/homebrew/bin/rclone sync "$src" "$dest" \
    --backup-dir "$vdir" \
    "${EXCLUDES[@]}" \
    --log-file "$LOG_FILE" \
    --log-level INFO \
    --transfers 8 \
    --checkers 16 \
    "${RCLONE_PROGRESS[@]}"
done

# 清理 30 天前的舊版本快照，避免 Macbook_Backup_versions 無限膨脹。
# 依「版本資料夾的時間戳名稱」判斷年齡（= 歸檔當下的時間），而非檔案本身的 mtime，
# 否則剛歸檔的舊檔會因 mtime 久遠而被立刻刪掉，失去誤刪救回的意義。
RETAIN_DAYS=30
CUTOFF_DIGITS="$(date -v-${RETAIN_DAYS}d '+%Y%m%d%H%M%S')"
say "===== 清理 ${RETAIN_DAYS} 天前舊版本快照 (cutoff=$CUTOFF_DIGITS): $(date '+%Y-%m-%d %H:%M:%S') ====="
/opt/homebrew/bin/rclone lsf --dirs-only "$VERS_ROOT" 2>>"$LOG_FILE" | while read -r dir; do
  name="${dir%/}"
  # 只處理符合時間戳格式的資料夾，避免誤刪其他東西
  if [[ "$name" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{6}$ ]]; then
    name_digits="${name//[^0-9]/}"
    if [ "$name_digits" -lt "$CUTOFF_DIGITS" ]; then
      say "  → purge 舊版本: $name"
      /opt/homebrew/bin/rclone purge "$VERS_ROOT/$name" \
        --log-file "$LOG_FILE" --log-level INFO
    fi
  fi
done

say "===== 備份完成: $(date '+%Y-%m-%d %H:%M:%S') ====="
