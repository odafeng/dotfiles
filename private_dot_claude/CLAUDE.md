# 全域指令

## 語言與溝通
- 回答一律使用繁體中文
- 專有名詞與技術名詞保留英文（如 API、middleware、hook、component）
- commit message 用英文，遵循 Conventional Commits（feat:, fix:, chore:, test:）

## 測試規範
- 應用程式型專案（web app、CLI tool、API server 等）在新增或修改功能時，必須同步撰寫測試
- 測試層級：
  - Unit test：針對個別函式、模組的邏輯
  - Smoke test：確認應用程式能正常啟動、主要路徑不會崩潰
  - E2E test：模擬使用者操作的完整流程測試
- 純 library 或 utility 專案至少要有 unit test
- 測試框架依專案既有設定為準，若無既有設定則建議使用主流框架

## 行為邊界
- 不要自動執行 git push，讓我確認後再推
- 遇到不確定的事情先問我，不要猜
- 不知道的事情就直接說不知道，不准自己inference或hallucinate
