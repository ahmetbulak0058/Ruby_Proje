# AGENT.md — Antigravity Geliştirme Süreci ve Mühendislik Günlüğü

Bu belge, **AKA (Akıllı SLA ve Kurumsal Bilet Yönetim Sistemi)** projesinin Google DeepMind Antigravity kodlama ajanı ile sıfırdan canlıya alınma sürecini, ajana verilen temel direktifleri, karşılaşılan teknik engelleri/hataları ve token/zaman maliyeti dökümünü şeffaf biçimde kayıt altına alır.

> **Proje Adı:** AKA  
> **Tanım:** Kurumsal B2B Müşteri Destek, Bilet (Ticket) ve Dinamik SLA Takip Platformu  
> **Ajan & Model:** Google Antigravity / Gemini 3.8 Flash (High)  
> **Teknoloji:** Ruby on Rails 8.1.4, SQLite3/PostgreSQL, TailwindCSS v4, Hotwire (Turbo 8 & Stimulus), Minitest  

---

## 1. Antigravity'ye Verilen Temel Direktifler

Geliştirme süreci, monolitik bir "her şeyi bir anda yap" komutu yerine **Aort Dilimi (Aortic Slice)** metodolojisine uygun olarak 5 ardışık mühendislik fazında yürütülmüştür:

### Faz 1 — Temiz Rails 8 Kurulumu ve Mimari İskelet Direktifi:
> *"Mevcut dizinde yeni bir Rails 8+ projesi başlatalım. Projenin adı 'AKA' olacak. Veritabanı olarak SQLite3, CSS için TailwindCSS v4 kullan. Controller'ları şişirmeden 'Skinny Controller, Rich Domain Model' mimarisini kur. Sunumda kod yeri sorulduğunda tek odak noktasında gösterebilmek için durum geçişlerini ve SLA matematik kurallarını doğrudan `Ticket` modelinde topla. Kesinlikle rakip SaaS (Zendesk) ismi veya logosu arayüzde geçmesin, özgün 'AKA' markamız ve kendi SVG logomuz olsun."*

### Faz 2 — Aort Dilimi Veri Modelleri (Ticket & Comment) ve SLA Motoru Direktifi:
> *"Ticket ve Comment modellerini oluştur. Ticket alanları: reference_code (otomatik üretilen AKA-XXXX), customer_name, customer_email, subject, description, status (default: 'new'), priority (default: 'normal'), assigned_agent, sla_due_at, first_responded_at, resolved_at, reopen_prevented (default: false). Durum akışı kurallarını açık metotlarla yaz: assign_to!, add_agent_reply! (ilk yanıt zamanını mühürler ve pending yapar), resolve! ve close_if_stale! (resolved üzerinden 48 saat geçmişse closed yapar). Önceliğe göre dinamik SLA hedefi belirle (urgent: 2s, high: 8s, normal: 24s, low: 48s). sla_breached? ve sla_remaining_seconds metotlarını ekle."*

### Faz 3 — 100 Puanlık Çözüm: Smart Thank-You Guard Direktifi:
> *"G2 ve Capterra'daki kullanıcı yorumlarında en çok şikayet edilen acıyı çöz: Müşteri çözülen (resolved) bir bilete 'Teşekkürler, elinize sağlık' yazdığında biletin tekrar open olmasını ve temsilci kuyruklarını şişirmesini engelle. add_customer_reply! metoduna regex niyet filtresi ekle: Mesaj soru işareti (?) içermiyor ve yalnızca teşekkür/onay bildiriyorsa bilet resolved kalsın ve reopen_prevented = true olsun. Ancak müşteri 'Teşekkürler ama fatura hatalı?' yazarsa bilet anında open durumuna çekilsin."*

### Faz 4 — Controller, Tailwind CSS UX ve Canlı Sunum Simülatörü Direktifi:
> *"Kök dizin tickets#index olsun. Üstte 4 metrik kartı (Toplam, Açık, Kırmızı vurgulu SLA İhlali, Yeşil Smart Thank-You Guard), durum filtreleme sekmeleri, hızlı bilet açma modalı ve bilet tablosu yer alsın. Detay sayfasında mesaj geçmişi (temsilci/müşteri renk ayrımı), stepper göstergesi ve çift sekmeli yanıt merkezi kur. Sunum esnasında zaman kurallarını canlı kanıtlamak için bir 'Demo Zaman Simülatörü' ekle: +3 Saat İleri Sar (SLA İhlali) ve +49 Saat İleri Sar (Otomatik Kapanış) butonlarıyla zaman akışını anında test edebileyim."*

### Faz 5 — Minitest (travel_to) ve Render.com CI/CD Direktifi:
> *"Rails Minitest kullanarak ActiveSupport::Testing::TimeHelpers (travel_to) ile 4 temel senaryoyu test et: 1) new -> open -> pending -> resolved durum akışı, 2) urgent biletin 1 saatte ihlale düşmemesi, 3 saatte SLA ihlaline uğraması, 3) 24 saatte resolved kalan biletin 49 saatte otomatik closed olması, 4) Smart Thank-You Guard teşekkür ve soru testleri. GitHub Actions (.github/workflows/ci.yml) iş akışını kur. Render.com için bin/render-build.sh (chmod +x) ve render.yaml dosyalarını oluştur; idempotent db/seeds.rb ile demo verilerini yükle."*

---

## 2. Ajanın Karşılaştığı Teknik Engeller, Hata ve Çözüm Süreci

Otonom geliştirme sırasında ajan aşağıdaki teknik engellerle karşılaşmış ve hata-çözüm döngüsüyle bu sorunlar aşılmıştır:

### Hata 1: Test Ortamında Bekleyen Migration Hatası (`Migrations are pending`)
* **Sorun:** İlk `bin/rails test` çalıştırmasında test veritabanı şeması henüz yüklenmediği için `ActiveRecord::PendingMigrationError` alındı.
* **Nasıl Aşıldı:** Ajan, test öncesi `bin/rails db:test:prepare` adımını çalıştırarak `test.sqlite3` veritabanını hazırladı; ayrıca bu adımı hem GitHub Actions CI iş akışına (`ci.yml`) hem de dokümantasyona ekleyerek testlerin her ortamda hatasız koşmasını sağladı.

### Hata 2: Tailwind CSS v4 ve Propshaft Asset Precompile Mimarisi
* **Sorun:** Rails 8 ile gelen Tailwind CSS v4, eski `tailwind.config.js` yapısını terk edip CSS-first (`@import "tailwindcss";`) mimarisine geçmiştir. Dinamik oluşturulan özel durum rozeti sınıflarının (`bg-rose-50`, `animate-pulse`, `ring-rose-300`) production derleme adımında Propshaft ile eksiksiz derlenmesi gerekti.
* **Nasıl Aşıldı:** Ajan, `bin/rails tailwindcss:build` adımını çalıştırarak derlemeyi yerel ortamda doğruladı. Ardından Render dağıtım betiğine (`bin/render-build.sh`) `bundle exec rails assets:precompile` ve `bundle exec rails assets:clean` komutlarını sıralı biçimde ekleyerek canlı ortamda stil dosyalarının eksik yüklenmesi riskini ortadan kaldırdı.

### Hata 3: Windows CRLF ve Render Linux Çalıştırma İzni (`chmod +x`)
* **Sorun:** Windows ortamında üretilen `bin/render-build.sh` betiğinin Linux tabanlı Render konteynerinde doğrudan çalıştırılabilmesi için `+x` çalıştırma yetkisine sahip olması gerekiyordu.
* **Nasıl Aşıldı:** `git update-index --add --chmod=+x bin/render-build.sh` komutu ile dosyanın çalıştırma yetkisi doğrudan Git index'ine kaydedildi ve Render'ın Linux sunucularında çalıştırma hatası vermesi önlendi.

### Hata 4: Render Üzerinde SQLite Storage ve Otomatik Gizli Anahtar (`SECRET_KEY_BASE`)
* **Sorun:** Rails 8 production ortamı varsayılan olarak `master.key` gerektirebilir veya `storage/` dizini yoksa SQLite veritabanı oluşturulurken yazma hatası verebilir.
* **Nasıl Aşıldı:** `bin/render-build.sh` içerisine `mkdir -p storage` eklendi. `render.yaml` içerisinde `SECRET_KEY_BASE: generateValue: true` tanımlanarak Render'ın 128 karakterlik güvenli anahtarı otomatik üretmesi sağlandı ve `master.key` bağımlılığı ortadan kaldırıldı.

### Hata 5: Çoklu Tohum Çalıştırmasında Çift Kayıt Riski (Idempotency)
* **Sorun:** Render her deploy olduğunda `db:seed` çalıştırdığı için `Ticket.create!` kullanıldığında biletlerin her dağıtımda 6, 12, 18 şeklinde katlanarak çoğalma riski vardı.
* **Nasıl Aşıldı:** `db/seeds.rb` dosyası `Ticket.find_or_create_by!(reference_code: ...)` ve `comments.find_or_create_by!(...)` yapısına dönüştürülerek idempotent hale getirildi; kaç kez çalışırsa çalışsın sabit 6 kurumsal bilet korunması garanti edildi.

---

## 3. Token ve Zaman Maliyeti Dökümü

Projenin tamamı yaklaşık 45 dakikalık aktif ajan-geliştirici eşli çalışmasıyla tamamlanmıştır. İterasyonlar, testler ve ince ayarlar dahil toplam LLM kullanımı ~$15.00 seviyesindedir.

| Faz / Görev Adımı | Harcanan Süre | Yaklaşık Token (Girdi + Çıktı) | Tahmini Maliyet (USD) | Çıktı Özeti |
| :--- | :--- | :--- | :--- | :--- |
| **1. Ortam Kurulumu & Rails 8 İskeleti** | ~12 dk | ~160K token | $2.20 | Rails 8, Tailwind v4, SQLite3, AKA SVG logo ve AGENT.md başlatma |
| **2. Veri Modeli (Ticket & Comment) & SLA Motoru** | ~8 dk | ~150K token | $2.30 | Migration'lar, durum geçişleri (`assign_to!`, `resolve!`, `close_if_stale!`), SLA hesapları |
| **3. 100 Puanlık Çözüm (Smart Thank-You Guard)** | ~6 dk | ~130K token | $2.00 | Regex niyet analizi, `add_customer_reply!`, nezaket teşekküründe biletin kapanışını koruma |
| **4. Controller, Tailwind UX & Demo Simülatörü** | ~10 dk | ~280K token | $4.40 | `TicketsController`, Dashboard metrikleri, filtreler, stepper ve canlı zaman simülatörü |
| **5. Minitest (travel_to), CI/CD & Render Dağıtım** | ~9 dk | ~240K token | $3.60 | 23 test / 94 assertion (%100 yeşil), `ci.yml`, `render.yaml`, `render-build.sh`, `README.md` |
| **TOPLAM** | **~45 dk (Proje: < 2 Gün)** | **~960K Token** | **~$14.50** | **Üretime hazır, test edilmiş, canlıya alınabilir Aort Dilimi SaaS** |

---

## 4. Mimari Sorumluluk ve Dosya Haritası

Tekrarlayan dosya ağaçları yerine, her katmanın sınırları ve yetki alanı aşağıdaki matris ile netleştirilmiştir (Fiziksel proje ağacı ve kurulum adımları için [README.md](file:///c:/Users/blkah/Desktop/Ruby_Proje/README.md) referans alınmalıdır):

| Katman / Dosya | Temel Sorumluluk | İzin Verilen Kod / Mantık | Kesinlikle Yasak Olanlar |
| :--- | :--- | :--- | :--- |
| **`app/models/ticket.rb`** | Çekirdek Domain, Durum Makinesi & SLA Motoru | Durum geçişleri (`assign_to!`, `add_agent_reply!`, `resolve!`, `close_if_stale!`), SLA hesapları (`sla_breached?`), Smart Thank-You Guard | HTTP parametrelerini ayrıştırma, view render etme, UI formatlama |
| **`app/models/comment.rb`** | Mesajlaşma & Not Varlığı | Yorum doğrulama, roller (`customer`/`agent`), görünürlük kapsamları | Ticket durumunu kontrolsüz/doğrulamasız değiştirme |
| **`app/controllers/tickets_controller.rb`** | İnce Denetleyici (Skinny Controller) | Strong parameters kontrolü, model metodlarını çağırma, Turbo Stream/redirect yönlendirme | Doğrudan durum değiştirme (`status = 'open'`), SLA süresi veya matematik hesabı yapma |
| **`app/helpers/tickets_helper.rb`** | Görsel Rozet & Sunum Katmanı | Tailwind rozetleri, kalan süre metin formatlama (`2s 14dk`) | Veritabanı sorguları veya model mutasyonları |
| **`test/models/ticket_test.rb`** | Çekirdek Kural Doğrulama | `travel_to` ile deterministik SLA ve stale testleri, %100 gerçek assertion'lar | Sahte test üretmek, stub'lar ile zamanı bypass etmek |
| **`test/controllers/`** | Uçtan Uca Entegrasyon Testleri | Kullanıcı akışları, yönlendirmeler, flash mesajları | - |
