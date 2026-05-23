# オトデール

音波療法アプリ。特定の周波数の正弦波を再生し、乗り物酔い緩和・耳鳴り緩和・睡眠補助などの用途に使用する。

## 対応プラットフォーム

- iOS（主ターゲット）
- Android

## 技術スタック

| 項目 | 内容 |
|---|---|
| フレームワーク | Flutter 3.41.4（FVM管理） |
| 音声エンジン | flutter_soloud 4.0.6 |
| 状態管理 | ChangeNotifier + ListenableBuilder |
| Bundle ID | com.safetravels.app |
| 最低iOS版本 | 13.0 |

## 機能

- 周波数スライダー（40Hz〜20kHz）
- 再生時間スライダー（1秒〜3600秒）
- 残り時間のリアルタイム表示
- 再生中はスライダーをロック

## 将来のユースケース

[docs/future/PLAN.md](docs/future/PLAN.md) を参照。

## セットアップ

```bash
# FVMのインストール（未インストールの場合）
dart pub global activate fvm

# Flutter バージョンをセット
fvm use 3.41.4

# 依存パッケージの取得
fvm flutter pub get

# iOSシミュレーターで起動
fvm flutter run
```

## プロジェクト構成

```
lib/
├── main.dart                    # エントリーポイント
├── models/
│   └── sound_status.dart        # 再生状態モデル
├── services/
│   └── sound_service.dart       # flutter_soloud による音波生成
├── view_models/
│   └── main_view_model.dart     # 状態管理（ChangeNotifier）
└── screens/
    └── home_screen.dart         # メイン画面UI
```
