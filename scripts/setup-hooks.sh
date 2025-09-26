#!/bin/bash

# Git hooks セットアップスクリプト

echo "🔧 Git hooksをセットアップしています..."

# hooksディレクトリが存在するかチェック
if [ ! -d "hooks" ]; then
    echo "❌ hooksディレクトリが見つかりません。"
    exit 1
fi

# pre-commitフックをコピー
if [ -f "hooks/pre-commit" ]; then
    cp hooks/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "✅ pre-commitフックをセットアップしました。"
else
    echo "❌ hooks/pre-commitファイルが見つかりません。"
    exit 1
fi

echo "🎉 Git hooksのセットアップが完了しました！"
echo "これで、コミット時に自動的にコードフォーマットと文法チェックが実行されます。"
