# SafeTravels（オトデール）プロジェクト

## 基本情報

| 項目 | 値 |
|---|---|
| アプリ名 | オトデール |
| Bundle ID | com.safetravels.app |
| Flutter管理 | FVM（`fvm flutter ...` を使う。`flutter` 直接実行は禁止） |
| Flutterバージョン | 3.41.4（`.fvm/fvm_config.json` で管理） |

## TestFlight配信

### 実行コマンド

```bash
# 1. pubspec.yaml のバージョンコードをインクリメント（+N の部分）
# 2. ios/ ディレクトリで実行
cd ios
fastlane beta
```

### fastlane構成

| ファイル | 場所 |
|---|---|
| Appfile | `ios/fastlane/Appfile` |
| Fastfile | `ios/fastlane/Fastfile` |

- IPAファイル名は **`オトデール.ipa`**（アプリ表示名で生成される）
- APIキーは環境変数から取得（`~/.zshrc` に設定済み）
- `.p8` ファイルは `~/.appstoreconnect/private_keys/` に配置

### 必要な環境変数（~/.zshrc）

```bash
export APPLE_ID="your@email.com"
export APP_STORE_CONNECT_API_KEY_KEY_ID="..."
export APP_STORE_CONNECT_API_KEY_ISSUER_ID="..."
```

### 配信手順まとめ

1. `pubspec.yaml` の `version:` のビルド番号（`+N`）をインクリメント
2. `cd ios && fastlane beta` を実行
3. ビルド〜アップロード〜内部テスター配信まで自動完了

## 注意事項

- `api_key.json` と `*.p8` は `.gitignore` 除外済み。絶対にコミットしない
- `ios/fastlane/` 配下の認証ファイルは Git 管理外
