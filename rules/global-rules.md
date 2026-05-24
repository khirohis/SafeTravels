# プロジェクト SafeTravels

## 1. プロジェクト概要
`SafeTravels` は100Hzの正弦波を鳴らすアプリケーションです。
英語と日本語のUIに対応しています。

## 2. 使用言語
- Kotlin

## 3. 使用フレームワーク
- Jetpack Compose

## 4. 使用ライブラリ
- Kotlin Coroutines
- Material Design 3
- Material Icons Extended
- Hilt
- AndroidX Media (Notification MediaStyle)

## 5. 完成形
- ユーザは正弦波の再生時間を指定することができます。
  再生時間の範囲は1秒から180秒までです。
  デフォルト値は60秒です。
- バックグラウンド再生に対応しており、Notificationで一時停止/再開/停止の操作が可能です。

## 6. アーキテクチャ方針
レイヤードアーキテクチャ (UI, Domain, Data) に準拠しつつ、過度な複雑さを避けてシンプルさを保持することを基本方針とします。
DI を導入し各レイヤ間の依存関係を整理し疎結合を保ちます。
リポジトリは基本的に Singleton 管理し状態の一貫性を保ちます。
状態管理は StateFlow を使いリアクティブな管理をします。
- **UI Layer**: Jetpack Compose, ViewModel
- **Domain Layer**: Model, UseCase (必要に応じて)
- **Data Layer**: Repository
- **Dependency Injection**: Hilt

## 7. クラス仕様
- **SoundRepository**: 正弦波を鳴らすリポジトリです。
  このアプリでは100Hz固定としていますが、周波数は可変とします。
  再生時間も可変とします。
  周波数、再生時間、再生状況を管理します。
  基本的な Audio Focus 管理を実装し、他アプリとの競合を制御します。
- **MainViewModel**: UI状態の管理とユーザ操作からのリポジトリアクセスを仲介します。
- **SoundForegroundService**: バックグラウンド再生に対応し、Notificationによるリモート操作インターフェースを提供します。
  リポジトリを介してUIと同期した状態管理を行います。
