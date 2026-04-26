# 麻雀点数記録アプリ (JanTotal) 仕様書

## 概要

4人打ち麻雀の対局点数を記録・閲覧できるFlutterアプリケーション。
Web、iOS、Androidで動作し、ローカルストレージにデータを保存します。

## 技術スタック

- **フレームワーク**: Flutter
- **状態管理**: Provider
- **データベース**: Hive (ローカルストレージ)
- **対応プラットフォーム**: Web, iOS, Android

## 依存パッケージ

```yaml
dependencies:
  hive: ^2.2.3           # ローカルデータベース
  hive_flutter: ^1.1.0   # Hive Flutter統合
  provider: ^6.1.5       # 状態管理
  intl: ^0.20.2          # 日付フォーマット
  uuid: ^4.5.3           # ユニークID生成
```

## データモデル

### Player（プレイヤー）
```dart
class Player {
  String id;           // ユニークID (UUID)
  String name;         // プレイヤー名
  DateTime createdAt;  // 作成日時
}
```

### Round（局）
```dart
class Round {
  String id;                    // ユニークID (UUID)
  int roundNumber;              // 局番号（1局目、2局目...）
  Map<String, int> scores;      // プレイヤーID => 点数のマップ
  String? notes;                // メモ（任意）
  DateTime createdAt;           // 作成日時
}
```

### Game（対局）
```dart
class Game {
  String id;                // ユニークID (UUID)
  DateTime date;            // 対局日時
  List<String> playerIds;   // 参加プレイヤーのID（4人分）
  List<Round> rounds;       // 局のリスト
  DateTime createdAt;       // 作成日時

  // メソッド
  Map<String, int> getTotalScores();  // 各プレイヤーの合計点数を計算
  Map<String, int> getRankings();     // 順位を計算（0=1位、1=2位...）
}
```

## 機能仕様

### 1. プレイヤー管理機能

**画面**: `PlayersScreen`

**機能**:
- プレイヤー一覧表示
- プレイヤー追加
- プレイヤー編集（名前変更）
- プレイヤー削除

**操作**:
- 右下FAB（+ボタン）でプレイヤー追加ダイアログを表示
- 各プレイヤーカードの編集アイコンで編集ダイアログを表示
- 各プレイヤーカードの削除アイコンで削除確認ダイアログを表示

**表示**:
- プレイヤーがいない場合: 空状態メッセージを表示
- プレイヤーがいる場合: カードリストで一覧表示（作成日順）

### 2. 対局記録機能

**画面**: `NewGameScreen`

**機能**:
- 新規対局の記録（3ステップ）
  1. プレイヤー選択（4人）
  2. 局ごとの点数入力
  3. 確認画面

**ステップ1: プレイヤー選択**
- 4つのドロップダウンで4人のプレイヤーを選択
- 最低4人のプレイヤーが登録されている必要がある
- 同じプレイヤーを複数回選択できない

**ステップ2: 点数記録**
- 「新しい局を追加」ボタンで局追加ダイアログを表示
- 各プレイヤーの点数を入力（±数値）
- 点数の合計が0になる必要がある
- 追加した局のリストを表示
- 各局は削除可能

**ステップ3: 確認**
- 最終結果（各プレイヤーの合計点数）を表示
- 総局数を表示

**制約**:
- 最低1局の記録が必要

### 3. 対局履歴機能

**画面**: `GamesScreen`, `GameDetailScreen`

**機能**:
- 対局一覧表示（新しい順）
- 対局詳細表示
- 対局削除

**一覧画面 (GamesScreen)**:
- 各対局をカード形式で表示
  - 日時（yyyy/MM/dd HH:mm）
  - 総局数
  - 順位順にプレイヤー名と点数を表示
- カードタップで詳細画面に遷移
- 右下FAB（+ボタン）で新規対局記録画面に遷移

**詳細画面 (GameDetailScreen)**:
- 日時表示
- 最終結果（順位順）
  - 順位、プレイヤー名、合計点数
  - 1位は金色で強調表示
- 局ごとの詳細
  - 局番号
  - 各プレイヤーの点数
  - メモ（あれば）
- 削除ボタン（AppBar右上）

### 4. 統計表示機能

**画面**: `StatsScreen`

**機能**:
- プレイヤーごとの統計情報表示

**表示内容**:
- プレイヤー選択ドロップダウン
- 選択したプレイヤーの統計:
  - 総対局数
  - 総収支（合計点数）
  - 平均収支
  - 平均順位
  - 順位分布
    - 各順位の回数と割合
    - プログレスバーで視覚化

**計算ロジック**:
```dart
// 統計情報の計算
- 総対局数: プレイヤーが参加した対局の数
- 総収支: 全対局の点数合計
- 平均収支: 総収支 / 総対局数
- 平均順位: (1位回数×1 + 2位回数×2 + 3位回数×3 + 4位回数×4) / 総対局数
- 順位分布: 各順位（1位〜4位）の出現回数と割合
```

### 5. ナビゲーション

**画面**: `HomeScreen`

**機能**:
- BottomNavigationBarで3つの画面を切り替え
  1. 対局（GamesScreen）
  2. プレイヤー（PlayersScreen）
  3. 統計（StatsScreen）

## データ永続化

**ストレージ**: Hive（ローカルNoSQLデータベース）

**ボックス構成**:
- `players`: プレイヤー情報（JSON文字列として保存）
- `games`: 対局情報（JSON文字列として保存）

**データフロー**:
1. アプリ起動時に`StorageService`を初期化
2. `AppProvider`が`StorageService`を使用してデータをロード
3. UI操作時に`AppProvider`経由でデータを更新
4. `StorageService`が自動的にHiveに保存

## ディレクトリ構成

```
lib/
├── main.dart                    # アプリエントリーポイント
├── models/                      # データモデル
│   ├── player.dart             # Playerモデル
│   ├── game.dart               # Gameモデル
│   └── round.dart              # Roundモデル
├── services/                    # ビジネスロジック層
│   ├── storage_service.dart    # ローカルストレージ管理
│   └── app_provider.dart       # 状態管理（Provider）
├── screens/                     # UI画面
│   ├── home_screen.dart        # ホーム画面（ナビゲーション）
│   ├── players_screen.dart     # プレイヤー管理画面
│   ├── games_screen.dart       # 対局履歴画面
│   ├── game_detail_screen.dart # 対局詳細画面
│   ├── new_game_screen.dart    # 新規対局記録画面
│   └── stats_screen.dart       # 統計画面
└── widgets/                     # 共通ウィジェット（将来的に使用）
```

## UI/UX仕様

### テーマ
- Material Design 3
- プライマリカラー: Green
- ダークモード: 未対応

### カラーリング
- プラス点数: 緑色
- マイナス点数: 赤色
- 1位: 金色（amber[700]）
- 2位: グレー（grey[400]）
- 3位: オレンジ（orange[300]）
- 4位: ブルー（blue[300]）

### 空状態
各画面で対応するデータがない場合、適切な空状態メッセージとアイコンを表示

## バリデーション

### プレイヤー管理
- プレイヤー名は必須（空文字不可）

### 対局記録
- 4人のプレイヤーが選択されていること
- 同じプレイヤーを重複選択していないこと
- 最低1局の記録があること
- 各局の点数合計が0であること

## 制約事項

### 現在の制約
- 4人打ち専用（3人打ちなど他の形式は非対応）
- ローカルストレージのみ（クラウド同期なし）
- 点数は整数のみ（小数点なし）
- ウマやオカの計算機能なし
- 役や点数計算の補助機能なし

### 将来的な拡張可能性
- クラウド同期機能
- データエクスポート/インポート
- 詳細な統計グラフ（折れ線グラフ、円グラフなど）
- ウマ・オカの設定と自動計算
- 役や点数計算の補助機能
- プレイヤーアイコン設定
- 対局のタグ付けやフィルター機能

## ビルド・実行方法

### 開発環境での実行

```bash
# Web版
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android
```

### プロダクションビルド

```bash
# Web版
flutter build web

# iOS
flutter build ios

# Android
flutter build apk
```

## テスト

基本的なスモークテストを実装済み（`test/widget_test.dart`）

```bash
flutter test
```

## 既知の問題

特になし

## 更新履歴

### v1.0.0 (2026-04-26)
- 初回リリース
- 基本機能実装完了
  - プレイヤー管理
  - 対局記録
  - 対局履歴
  - 統計表示
