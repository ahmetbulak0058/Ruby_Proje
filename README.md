# AKA — Enterprise SLA & Incident Operations Engine

[![CI](https://github.com/KULLANICI_ADIN/REPO_ADIN/actions/workflows/ci.yml/badge.svg)](https://github.com/KULLANICI_ADIN/REPO_ADIN/actions)
![Ruby Version](https://img.shields.io/badge/Ruby-4.0.7-CC342D?logo=ruby&logoColor=white)
![Rails Version](https://img.shields.io/badge/Rails-8.1.4-D30001?logo=rubyonrails&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-v4.3-38B2AC?logo=tailwindcss&logoColor=white)
![Tests](https://img.shields.io/badge/Minitest-23%20Passed%20(94%20Assertions)-success)

> **Canlı Uygulama URL:** [https://aka-demo.onrender.com](https://aka-demo.onrender.com) *(veya yerel ortam: `http://localhost:3000`)*

---

## 1. Proje Özeti ve İlham Kaynağı

* **Ürün Adı:** **AKA**
* **İlham Kaynağı:** **Zendesk Support** platformunun kurumsal çekirdek iş akışı olan **"Aort Dilimi"** modellenmiştir:
  $$\text{Talep Oluşturma} \longrightarrow \text{Temsilci Atama} \longrightarrow \text{SLA Geri Sayımı \& Yanıtlama} \longrightarrow \text{Çözüm (Resolve)} \longrightarrow \text{48s Otomatik Kapanış (Closed)}$$
* **Fortune 500 Kanıtı:**
  Zendesk, Fortune 500 ve Global Enterprise şirketlerinin önemli bir kısmı (ör. **Siemens, Tesco, Stanley Black & Decker, Uber, Airbnb**) tarafından kritik müşteri ve çalışan operasyonlarını yönetmek üzere ücretli SaaS altyapısı olarak kullanılmaktadır.
  * 🔗 **Kanıt Linki 1:** [Zendesk Customer Stories — Enterprise & Fortune 500](https://www.zendesk.com/customer/)
  * 🔗 **Kanıt Linki 2:** [Zendesk ESG & Investor Fact Sheet (Fortune 100 & 500 Penetrasyonu)](https://investor.zendesk.com/)

---

## 2. Faz 1 — Fortune 500 ve SaaS Ekonomisi Araştırması

Kurumsal B2B pazarının dinamiklerini, ölçeğini ve SaaS harcama alışkanlıklarını ortaya koyan sektör verileri:

### a. Değerleme ve Gelir Aralığı
* Fortune 500 (2024/2025) listesine girebilmek için taban yıllık ciro eşiği yaklaşık **$7.1 Milyar**'dır. Listenin zirvesindeki en yüksek cirolu şirket olan Walmart yıllık **~$648 Milyar** gelir beyan ederken; Apple, Microsoft ve Nvidia gibi teknoloji liderlerinin piyasa değerlemeleri **$3 Trilyon — $3.5 Trilyon+** bandındadır. Listenin en alt sırasındaki firmaların piyasa değerlemeleri birkaç milyar dolardan başlar.
  * 🔗 **Kaynak:** [Fortune 500 Methodology & Financial Highlights](https://fortune.com/franchise-list-page/fortune-500-methodology/)
  * 🔗 **Kaynak:** [CompaniesMarketCap — Global Market Cap Data](https://companiesmarketcap.com/)

### b. Çalışan Sayısı Aralığı
* Fortune 500 bünyesinde sermaye/gayrimenkul yoğun finans veya enerji ortaklıklarında çalışan sayısı **~500 ile 1.500** seviyesine kadar düşebilmektedir (ör. Host Hotels & Resorts ~160 kurumsal merkez çalışanı). Buna karşılık listenin en büyük işvereni olan Walmart bünyesinde yaklaşık **2.100.000 çalışan** bulunmaktadır.
  * 🔗 **Kaynak:** [Fortune 500 Largest Employers Dataset](https://fortune.com/ranking/fortune500/)

### c. Bir Firmanın Kullandığı Yaklaşık SaaS Ürünü Sayısı
* 1000+ çalışanı olan tipik bir kurumsal şirket ortalama **130 ila 364 arasında farklı SaaS uygulaması** kullanmaktadır. Departman başına düşen yazılım sayısı her yıl artış göstermektedir.
  * 🔗 **Kaynak 1:** [BetterCloud State of SaaSOps Report](https://www.bettercloud.com/monitor/state-of-saasops-report/) *(Büyük kurumlarda ortalama 130+ SaaS)*
  * 🔗 **Kaynak 2:** [Productiv State of SaaS Sprawl Report](https://productiv.com/) & [Zylo SaaS Management Index](https://zylo.com/reports/saas-management-index/) *(Büyük kurumsal yapılarda ortalama 275 – 364 aktif uygulama)*

### d. SaaS Aboneliklerine Yıllık Ödenen Para
* Kurumsal firmalarda çalışan başına yıllık ortalama **$4.000 – $9.000** SaaS lisans maliyeti oluşmaktadır. Tipik bir Fortune 500 / Enterprise şirketinin yıllık toplam SaaS yazılım faturası **$20 Milyon ile $100+ Milyon** arasındadır (medyan ortalama ~$45M – $50M).
  * 🔗 **Kaynak 1:** [Zylo SaaS Management Index Report](https://zylo.com/reports/saas-management-index/)
  * 🔗 **Kaynak 2:** [Vendr SaaS Pricing & Purchasing Trends Report](https://www.vendr.com/saas-trends)

---

## 3. Faz 2 — Maliyet Tahmini ve Kod Ölçeği

### Orijinal Zendesk Yaklaşık Satır Sayısı ve Tahmin Yöntemi
* **Tahmin:** Zendesk'in çekirdek Ruby on Rails monoliti ve bağlı mikroservis mimarisinin toplamda **~500.000 – 1.500.000+ satır kod (LOC)**; sadece çekirdek biletleme (Ticket/Support/SLA) modülünün ise **~300.000 – 400.000 satır kod** içerdiği tahmin edilmektedir.
* **Tahmin Yöntemi:**
  1. Zendesk Engineering teknik bloglarında paylaşılan mimari makaleler (yüzlerce tabloluk Rails şeması, Event Bus ve SLA engine mimarisi),
  2. Zendesk'in GitHub üzerindeki açık kaynaklı kütüphaneleri ve SDK ekosistemi ([github.com/zendesk](https://github.com/zendesk)),
  3. Benzer ölçekte biletleme yapan kurumsal açık kaynak platformlarının (ör. **Chatwoot** ~250.000 LOC, **Zammad** ~320.000 LOC) `cloc` analizleri referans alınarak oranlanmıştır.

### Coding Agent ile Üretim Tahmini vs. Gerçekleşen
| Metrik | Ön Tahmin | Gerçekleşen |
| :--- | :--- | :--- |
| **Geliştirme Süresi** | ~2 gün (16 çalışma saati) | ~4 – 6 saat aktif iterasyon (1 gün) |
| **LLM Token & API Maliyeti** | ~$10 – $15 API harcaması (veya $20 Pro abonelik payı) | ~$5 – $8 eşdeğer token tüketimi (Mevcut IDE aboneliği dahilinde) |
| **Hata & Regresyon Oranı** | Testlerin %15-20'sinde ilk çalıştırmada revizyon | Minitest ile yazılan 23 test ilk denemede **%100 yeşil** geçti |

---

## 4. 100 Puanlık "Ayağa Pas" — Smart Thank-You Guard

### Kimin Acısı?
Müşteri destek temsilcileri (Agent), destek operasyon müdürleri (Support Leads) ve SLA performans analistleri.

### Hangi Kullanıcı Şikayetinden Çıktı?
G2, Capterra ve Zendesk topluluk forumlarında yıllardır en çok dile getirilen şikayetlerden biri:
> *"Temsilci problemi çözüp bileti `Solved` yapıyor. Müşteri nezaketen 'Teşekkürler, harika çalıştı!' yazdığında sistem bunu yeni bir soru gibi algılayıp bileti tekrar `Open` durumuna çekiyor. Temsilcilerin kuyruğu şişiyor, ilk çözümde bitirilen işler bozuluyor ve SLA metrikleri altüst oluyor."*  
> (Zendesk bu temel sorunu çözmek yerine pahalı ek yapay zeka eklentisi satmaktadır.)

* 🔗 **Kanıt Linki 1:** [G2 Zendesk Support Reviews — Reopening Solved Tickets Pain Point](https://www.g2.com/products/zendesk-support-suite/reviews)
* 🔗 **Kanıt Linki 2:** [Capterra Zendesk Customer Reviews](https://www.capterra.com/p/160047/Zendesk/)

### AKA'nın Çözümü (`Smart Thank-You Guard`)
AKA, [`app/models/ticket.rb`](file:///c:/Users/blkah/Desktop/Ruby_Proje/app/models/ticket.rb) içerisinde yerleşik bir **Niyet ve Soru Tespiti Filtresi** barındırır:
1. Çözülmüş (`resolved`) bir bilete müşteri yanıt verdiğinde mesaj taranır.
2. Eğer mesaj soru işareti (`?`) ya da problemin devam ettiğine dair olumsuz kelimeler (`hata`, `ama`, `çalışmıyor`, `not working` vb.) içermiyor; yalnızca teşekkür/onay (`teşekkürler`, `tesekkurler`, `sağ olun`, `çözüldü`, `thank you`, `thanks`, `harika` vb.) içeriyorsa:
   * **Bilet tekrar `open` YAPILMAZ**, `resolved` durumunda korunur.
   * `reopen_prevented = true` bayrağı işaretlenir.
   * Dashboard ve detay sayfasında yeşil `⚡ Smart Thank-You Guard Devrede` rozeti gösterilerek temsilcinin zaman kazandığı belgelenir.
3. Ancak müşteri *"Teşekkürler ama fatura hâlâ hatalı görünüyor?"* gibi bir soru/devam eden sorun iletirse, bilet anında `open` durumuna çekilir.

---

## 5. Yapamadıklarım (Şeffaflık Listesi)

Aort dilimine odaklanma stratejisi ve süre kısıtları nedeniyle bu versiyonda kapsam dışı bırakılan unsurlar:

1. **Gerçek Zamanlı Gelen E-Posta Dinleyici (IMAP/SMTP Ingestion):** Gelen kutusundaki e-postaları doğrudan parse edip bilete dönüştüren arka plan servisi yazılmadı (bunun yerine web UI ve hızlı simülasyon modalı kuruldu).
2. **Multi-Tenant (Çoklu Kiracı) İzolasyonu & Kurumsal SSO:** Organizasyon bazlı subdomain (`firma.aka.io`) ve SAML/Okta/Azure AD oturum açma entegrasyonu eklenmedi.
3. **Ek Dosya (Attachment / AWS S3) & Zengin Metin (WYSIWYG) Editörü:** Yanıtlara PDF/PNG gibi dosyalar ekleme altyapısı kurulmadı.
4. **Çalışma Takvimi Bazlı SLA Hesabı (Business Hours Calendar):** Şu anda SLA 7/24 kesintisiz takvim saati üzerinden akmaktadır; hafta sonları ve resmi tatillerde sayacı donduran mesai takvimi motoru dahil edilmedi.

---

## 6. Mimari Kurallar ve Dizin Yapısı

Mimari kuralların tamamı [`AGENT.md`](file:///c:/Users/blkah/Desktop/Ruby_Proje/AGENT.md) sözleşmesiyle mühürlenmiştir:
* **Skinny Controller, Rich Model:** Durum geçişleri (`assign_to!`, `add_agent_reply!`, `resolve!`, `close_if_stale!`, `add_customer_reply!`) ve SLA matematik formülleri doğrudan [`app/models/ticket.rb`](file:///c:/Users/blkah/Desktop/Ruby_Proje/app/models/ticket.rb) dosyasındadır.
* **Sıfır Sahte Test Kuralı:** Tüm zaman testleri `ActiveSupport::Testing::TimeHelpers` (`travel_to`) ile gerçek veritabanında test edilir.
* **Marka Koruma Kuralı:** Arayüzde veya kodlarda rakip SaaS markası geçmez, özgün SVG logo ve **AKA** markası kullanılır.

```
AKA/
├── AGENT.md                       # Ajan çalışma ilkeleri ve mimari sorumluluk matrisi
├── README.md                      # Kapsamlı proje dokümantasyonu ve kaynaklar
├── render.yaml                    # Render.com Blueprint dağıtım yapılandırması
├── .github/workflows/ci.yml       # GitHub Actions otomatik CI test iş akışı
├── app/
│   ├── models/
│   │   ├── ticket.rb              # Çekirdek durum akışı, SLA motoru & Smart Guard
│   │   └── comment.rb             # Temsilci / Müşteri mesajları modeli
│   ├── controllers/
│   │   └── tickets_controller.rb  # İnce (Skinny) denetleyici
│   ├── helpers/
│   │   └── tickets_helper.rb      # SLA geri sayım ve Tailwind rozet yardımcıları
│   ├── views/tickets/
│   │   ├── index.html.erb         # Dashboard metrikleri, filtreler & hızlı modal
│   │   └── show.html.erb          # Detay, Stepper, Mesajlaşma & Demo Simülatörü
│   └── assets/images/
│       └── aka_logo.svg           # Özgün SVG vektör marka logosu
├── bin/
│   └── render-build.sh            # Render.com üretim derleme ve tohum betiği
├── db/
│   ├── migrate/                   # Veritabanı migrasyonları (varsayılanlar & indeksler)
│   ├── schema.rb                  # SQLite veritabanı şeması
│   └── seeds.rb                   # İdempotent 6 adet kurumsal senaryo tohum verisi
└── test/
    ├── models/
    │   ├── ticket_test.rb         # travel_to ile zaman ve durum akışı testleri
    │   └── comment_test.rb        # Yorum modeli testleri
    └── controllers/
        └── tickets_controller_test.rb # Uçtan uca entegrasyon testleri
```

---

## 7. Kurulum ve Çalıştırma

### Gereksinimler
* Ruby 4.0+ (veya 3.2+)
* Rails 8.1+
* SQLite3

### Adımlar
```bash
# 1. Depoyu klonlayın ve dizine gidin
git clone https://github.com/KULLANICI_ADIN/REPO_ADIN.git
cd REPO_ADIN

# 2. Ruby bağımlılıklarını kurun
bundle install

# 3. Veritabanını oluşturun ve migrasyonları uygulayın
bin/rails db:migrate

# 4. Kurumsal örnek verileri yükleyin
bin/rails db:seed

# 5. Sunucuyu başlatın
bin/dev # veya: bin/rails server
```
Tarayıcınızda `http://localhost:3000` adresini açarak uygulamayı kullanabilirsiniz.

---

## 8. Testleri Çalıştırma ve Doğrulama

Minitest test paketini ve SLA zaman kaydırma testlerini çalıştırmak için:

```bash
bin/rails test
```

### Gerçek Terminal Test Çıktısı:
```text
≈ tailwindcss v4.3.3

Done in 75ms
Running 23 tests in a single process (parallelization threshold is 50)
Run options: --seed 29868

# Running:

.......................

Finished in 0.496540s, 46.3205 runs/s, 189.3099 assertions/s.
23 runs, 94 assertions, 0 failures, 0 errors, 0 skips
```
*Tüm modeller, durum akışları, SLA kuralları ve kontrol paneli akışları %100 yeşildir.*
