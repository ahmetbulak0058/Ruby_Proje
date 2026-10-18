#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -o errexit

echo "🚀 [AKA] Render Build Başlatılıyor..."

# 1. Ruby bağımlılıklarını yükle
echo "📦 Bundle install çalıştırılıyor..."
bundle install

# 2. Tailwind CSS ve Asset'leri derle
echo "🎨 Asset'ler derleniyor (TailwindCSS v4)..."
bundle exec rails assets:precompile
bundle exec rails assets:clean

# 3. SQLite Storage klasörünün varlığından emin ol
mkdir -p storage

# 4. Veritabanı migrasyonlarını çalıştır
echo "🗄️ Veritabanı migrasyonları uygulanıyor..."
bundle exec rails db:migrate

# 5. İdempotent demo tohum verilerini yükle
echo "🌱 Canlı ortam demo verileri yükleniyor..."
bundle exec rails db:seed

echo "✅ [AKA] Render Build başarıyla tamamlandı!"
