# プロジェクト SafeTravels

## 1. プロジェクト概要
`SafeTravels`は正弦波の音を鳴らすアプリケーションです

## 2. 使用言語
- Kotlin

## 3. 使用フレームワーク
- Jetpack Compose

## 4. 使用ライブラリ
- Jetpack Compose
- Kotlin Coroutines
- Material Design 3
- Material Icons Extended

## 5. 完成形
- ユーザは正弦波の周波数を指定することができます
  周波数の範囲は100Hzから20000Hzまでです
  デフォルト値は440Hzです
- ユーザは正弦波の再生時間を指定することができます
  再生時間の範囲は1秒から180秒までです
  デフォルト値は60秒です

## 6. アーキテクチャ方針
レイヤードアーキテクチャ（UI、Domain、Data）に準拠しつつ、過度な複雑さを避けてシンプルさを保持することを基本方針とします。
- **UI Layer**: Jetpack Compose, ViewModel
- **Domain Layer**: Model, UseCase (必要に応じて)
- **Data Layer**: Repository
