# 升級到 Rails 7 指南

## 版本 1.0.0 更新

OddPay v1.0.0 已升級支援 Rails 7.0+。

### 系統需求

- **Ruby**: 2.7.0 或更高版本
- **Rails**: 7.0.0 或更高版本（支援到 < 8.0）

### 主要變更

1. **Rails 版本支援**

   - 升級支援 Rails 7.0+
   - 移除對 Rails 6.1 的支援

2. **Migration 版本**

   - 所有 migration 文件已更新到 `ActiveRecord::Migration[7.0]`

3. **Ruby 版本要求**
   - 最低 Ruby 版本提升到 2.7.0

### 升級步驟

1. **更新 Gemfile**

   ```ruby
   gem 'odd_pay', '~> 1.0.0'
   ```

2. **執行 bundle update**

   ```bash
   bundle update odd_pay
   ```

3. **檢查 Zeitwerk 兼容性**（如果你的應用使用 Zeitwerk autoloading）

   ```bash
   rails zeitwerk:check
   ```

4. **運行測試**
   確保所有測試通過
   ```bash
   bundle exec rspec
   ```

### 相容性

- 所有現有的 API 保持不變
- 模型、控制器和服務類別的接口沒有變更
- 現有的回調和驗證規則繼續正常工作

### 已知問題

目前沒有已知的相容性問題。如果遇到問題，請在 GitHub 上提交 issue。

### 支援

如需協助，請：

1. 查看 [GitHub Issues](https://github.com/Dylan0203/odd_pay/issues)
2. 提交新的 issue 報告問題
