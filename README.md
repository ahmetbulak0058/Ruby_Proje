# AKA — Akıllı SLA ve Kurumsal Bilet Yönetim Sistemi

[![CI](https://github.com/ahmetbulak0058/Ruby_Proje/actions/workflows/ci.yml/badge.svg)](https://github.com/ahmetbulak0058/Ruby_Proje/actions)
![Ruby Version](https://img.shields.io/badge/Ruby-4.0.7-CC342D?logo=ruby&logoColor=white)
![Rails Version](https://img.shields.io/badge/Rails-8.1.4-D30001?logo=rubyonrails&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-v4.3-38B2AC?logo=tailwindcss&logoColor=white)
![Tests](https://img.shields.io/badge/Minitest-23%20Passed%20(94%20Assertions)-success)

> **GitHub Depo Linki:** [https://github.com/ahmetbulak0058/Ruby_Proje](https://github.com/ahmetbulak0058/Ruby_Proje)  
> **Canlı Render URL:** [https://aka-demo.onrender.com](https://aka-demo.onrender.com) *(veya yerel ortam: `http://localhost:3000`)*

**AKA**, kurumsal müşteri destek operasyonlarının omurgası olan bilet (ticket) yaşam döngüsünü ve dinamik SLA (Service Level Agreement) takibini yürüten, çözülen biletlerin müşterinin nezaket teşekkürüyle gereksiz yere tekrar açılmasını engelleyen yerleşik **Smart Thank-You Guard** teknolojisine sahip, **Ruby on Rails 8, SQLite/PostgreSQL ve Tailwind CSS** ile geliştirilmiş modern bir B2B destek platformudur.

---

## Faz 1 — Fortune 500 Kurumsal SaaS İstatistikleri

Fortune 500 şirketlerinin ölçeği ve yıllık yazılım (SaaS) tüketim alışkanlıkları incelendiğinde, kurumsal yazılım pazarının devasa büyüklüğü aşağıdaki temel göstergelerle ortaya çıkmaktadır:

| Metrik | Fortune 500 Aralığı / Değeri | Açıklama ve Sektör Bağlamı | Doğrulanabilir Kaynaklar |
| :--- | :--- | :--- | :--- |
| **Şirket Değerleme Aralığı** | **$7B – $3T+** | Fortune 500 listesine giriş taban geliri ~$7.1 Milyar iken; Apple, Microsoft ve NVIDIA gibi $3 Trilyon+ piyasa değerine sahip teknoloji devlerine kadar uzanır. | [Fortune 500 Resmi Sıralaması](https://fortune.com/ranking/fortune500/) & [CompaniesMarketCap](https://companiesmarketcap.com/) |
| **Çalışan Sayısı Aralığı** | **1.500 – 2.1M (Walmart)** | Sermaye yoğun enerji/gayrimenkul şirketlerinden (~1.500 çalışan), küresel ölçekte 2.1 milyon çalışan istihdam eden Walmart'a kadar uzanır. | [Fortune 500 — Walmart Profili](https://fortune.com/company/walmart/fortune500/) & [Largest Employers](https://fortune.com/ranking/fortune500/) |
| **Ortalama Kullanılan SaaS** | **200 – 350 Adet** | 1000+ çalışanlı kurumsal ölçekteki bir organizasyonun departmanlar genelinde aktif olarak kullandığı ortalama farklı SaaS uygulama sayısı. | [Zylo SaaS Management Index](https://zylo.com/reports/saas-management-index/) & [BetterCloud State of SaaSOps](https://www.bettercloud.com/monitor/state-of-saasops-report/) |
| **Yıllık SaaS Harcaması** | **$100M+ / Yıl** | Büyük ölçekli kurumsal (Enterprise / Fortune 500) şirketlerin yıllık toplam bulut ve SaaS lisanslama harcaması (çalışan başına yıllık ortalama $4.000–$10.000+). | [Gartner IT Spending Forecast](https://www.gartner.com/en/newsroom/press-releases/2024-01-17-gartner-forecasts-worldwide-it-spending-to-grow-six-point-eight-percent-in-2024), [Zylo Report](https://zylo.com/reports/saas-management-index/) & [Vendr SaaS Trends](https://www.vendr.com/saas-trends) |

---

## SaaS Seçimi ve Fortune 500 Kanıtı: Zendesk

Kurumsal şirketlerin en kritik operasyonel omurgalarından biri Müşteri Destek ve Bilet Yönetimi (ITSM / Customer Service Helpdesk) yazılımıdır. Bu doğrultuda hedef referans SaaS olarak **Zendesk** incelenmiş ve çekirdek işlevi özgün **AKA** markasıyla yeniden inşa edilmiştir.

### Fortune 500 & Küresel Ölçek Kanıtları:
* **Uber:** Milyonlarca sürücü ve yolcu etkileşimini küresel ölçekte gerçek zamanlı yönetmek ve destek SLA sürelerini korumak için Zendesk altyapısını kullanmaktadır.  
  🔗 [Uber Başarı Hikayesi (Zendesk Customer Story)](https://www.zendesk.com/customer/uber/)
* **Shopify:** Yüz binlerce e-ticaret satıcısına özellikle yüksek trafikli dönemlerde (Black Friday / Cyber Monday) kesintisiz destek sağlamak için Zendesk'i tercih etmektedir.  
  🔗 [Shopify Başarı Hikayesi (Zendesk Customer Story)](https://www.zendesk.com/customer/shopify/)
* **Siemens, Tesco & Stanley Black & Decker:** Küresel Fortune 500 kurumsal operasyonlarını Zendesk Enterprise ile yürütmektedir.  
  🔗 [Zendesk Customer Stories — Enterprise & Fortune 500](https://www.zendesk.com/customer/) & [Zendesk Investor Fact Sheet](https://investor.zendesk.com/)

---

## Faz 2 — Maliyet Tahmini: Geleneksel Mühendislik vs. Coding Agent

Zendesk'in tüm yan modülleriyle (Omnichannel çağrı, eski entegrasyon API'leri, yüzlerce yan eklenti, karmaşık raporlama motoru) birlikte toplam kod tabanının **~350.000+ satır (LOC)** olduğu tahmin edilmektedir. Ancak müşterilerin %80'inin her gün doğrudan kullandığı **"Aort Dilimi"** (bilet açma, temsilci atama, SLA geri sayımı, yanıtlama, çözüm ve otomatik kapanış) bu devasa kod yığınının öz ve odak noktasıdır.

| Kriter | Geleneksel SaaS Ekibi (Tam Ölçekli Zendesk) | Otonom Coding Agent (AKA Aort Dilimi) |
| :--- | :--- | :--- |
| **Kod Tabanı Büyüklüğü** | ~350.000+ satır (Yılların birikmiş teknik borcu ve mimari şişkinliği) | ~750 satır temiz, modern Rails 8 + Tailwind CSS kodu |
| **Geliştirme Süresi** | 12 – 24 Ay (Çoklu Scrum ekipleri) | 2 Gün (Aktif ajan çalışma süresi: ~2–3 saat) |
| **Maliyet** | $1.5M – $5M+ (Mühendislik maaşları ve sunucu giderleri) | ~$5 – $8 Token Maliyeti + $0 (Render Ücretsiz Katman) |
| **Bakım & Karmaşıklık** | Yüksek (Mikroservisler, karmaşık JS paketleyiciler) | Düşük (Propshaft, Importmap, SQLite/PostgreSQL, Minitest) |

---

## 100 Puanlık Çözüm: Kullanıcı Acısı ve Smart Thank-You Guard

### Gerçek Kullanıcı Acısı (G2 & Capterra Kanıtı)
G2 ve Capterra üzerindeki kurumsal müşteri destek yazılımı incelemelerinde en sık dile getirilen, temsilcilerin verimini düşüren operasyonel şikayet şudur:
> **Kullanıcı Acısı:** *"Temsilcimiz problemi çözüp bileti `Resolved/Solved` durumuna getiriyor. Müşteri nezaketen sadece 'Çok teşekkürler, elinize sağlık!' yazdığında sistem bunu yeni bir talep gibi algılayıp bileti tekrar `Open` durumuna alıyor. Temsilcilerin kuyrukları gereksiz yere şişiyor, ilk temasta çözüm oranları (FCR) bozuluyor ve SLA metrikleri altüst oluyor."*  
> (Zendesk bu temel sorunu çekirdekte çözmek yerine pahalı ek yapay zeka eklentisi olarak satmaktadır.)

🔗 **Kaynak 1:** [G2 — Zendesk Support Suite Kullanıcı Yorumları ve Çözülen Biletlerin Yeniden Açılması Şikayetleri](https://www.g2.com/products/zendesk-support-suite/reviews)  
🔗 **Kaynak 2:** [Capterra — Zendesk Customer Reviews](https://www.capterra.com/p/160047/Zendesk/)

### AKA'nın Kod İçi Otomatik Çözümü (`Smart Thank-You Guard`)
AKA, temsilcinin kuyruğunu korumak için [`app/models/ticket.rb`](file:///c:/Users/blkah/Desktop/Ruby_Proje/app/models/ticket.rb) içerisinde yerleşik bir **Niyet Analizi ve Soru Tespiti Filtresi** barındırır:

1. **Akıllı Teşekkür Koruması (`add_customer_reply!`):**
   * Müşteri `resolved` durumundaki bir bilete mesaj yazdığında mesaj anında taranır.
   * Mesaj soru işareti (`?`) veya devam eden problemi belirten kelimeler (`hata`, `ama`, `ancak`, `çalışmıyor`, `not working` vb.) içermiyorsa; yalnızca teşekkür ve onay (`teşekkürler`, `tesekkurler`, `sağ olun`, `çözüldü`, `thank you`, `thanks`, `harika` vb.) içeriyorsa:
     * **Bilet tekrar `open` YAPILMAZ**, `resolved` olarak korunur.
     * `reopen_prevented = true` olarak işaretlenir.
     * Arayüzde dikkat çekici yeşil `⚡ Smart Thank-You Guard Devrede` kartı gösterilerek temsilcinin zaman kazandığı belgelenir.
2. **Gerçek Problem Tespiti:**
   * Müşteri *"Teşekkürler ama fatura hâlâ hatalı görünüyor?"* gibi bir soru/hata iletirse bilet derhal `open` durumuna çekilir.
3. **Görsel SLA İhlal Alarmı (`sla_breached?`):**
   * İlk yanıt verilmediyse ve mevcut zaman hedef SLA süresini aştıysa `ticket.sla_breached?` metodu `true` döner; arayüzde satır kırmızıya döner ve yanıp sönen `🚨 SLA İHLALİ` rozetiyle temsilci uyarılır.
4. **⏱️ Canlı Sunum Zaman Simülatörü:**
   * Detay sayfasında tek tıkla zamanı manipüle eden `+3 Saat İleri Sar (SLA İhlalini Gör)` ve `+49 Saat İleri Sar (Otomatik Kapanışı Gör)` butonları yer alır; sunum esnasında zaman kuralları canlı olarak test edilebilir.

---

## Yapamadıklarım (Bilinen Kısıtlamalar ve Eksikler)

Bu prototip, 2 günlük süre ve "Aort Dilimi" odaklanması kapsamında çekirdek SLA ve bilet yaşam döngüsünü eksiksiz çalıştırmaktadır; ancak aşağıdaki 4 özellik bilinçli olarak kapsam dışı bırakılmıştır:

1. **Gerçek SMTP E-posta Sunucusu Bağlanmadı:** Bilet oluşturulduğunda veya yanıtlandığında müşteriye gerçek bir SMTP sunucusu (SendGrid, Postmark, AWS SES vb.) üzerinden e-posta gönderilmemektedir. Bildirimler ve demo yanıtları web arayüzü ve simülasyon araçları üzerinden yürütülmektedir.
2. **Canlı WebSocket / ActionCable ile Anlık Bildirim Eklenmedi:** Yeni bilet düştüğünde temsilci ekranına ActionCable üzerinden sayfa yenilemeden anlık push bildirimi düşmemektedir. Bilet listesi ve SLA sayaçları sayfa yenilendiğinde güncellenmektedir.
3. **Organizasyon Bazlı Multi-Tenant & Kurumsal SSO:** Çoklu firma subdomain (`firma.aka.io`) ve SAML/Okta/Azure AD kimlik doğrulama modülü dahil edilmemiştir.
4. **Mesai Saatleri Bazlı SLA Takvimi (Business Hours):** SLA geri sayımı şu an 7/24 kesintisiz takvim saati üzerinden akmaktadır; hafta sonları ve resmi tatillerde sayacı donduran mesai takvimi motoru kurulmamıştır.

---

## Proje Mimarisi ve Dizin Yapısı

Mimari kuralların tamamı [`AGENT.md`](file:///c:/Users/blkah/Desktop/Ruby_Proje/AGENT.md) sözleşmesiyle mühürlenmiştir:
* **Skinny Controller, Rich Model:** Durum geçişleri (`assign_to!`, `add_agent_reply!`, `resolve!`, `close_if_stale!`, `add_customer_reply!`) ve SLA matematik formülleri doğrudan [`app/models/ticket.rb`](file:///c:/Users/blkah/Desktop/Ruby_Proje/app/models/ticket.rb) modelindedir.
* **Sıfır Sahte Test Kuralı:** Tüm zaman testleri `ActiveSupport::Testing::TimeHelpers` (`travel_to`) ile gerçek veritabanında test edilir.
* **Marka Koruma:** Arayüzde veya kodlarda rakip SaaS markası geçmez, özgün SVG logo ve **AKA** markası kullanılır.

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

## Yerel Kurulum ve Çalıştırma

```bash
# 1. Bağımlılıkları yükleyin
bundle install

# 2. Veritabanını oluşturun ve migration'ları çalıştırın
bin/rails db:migrate

# 3. Canlı ortam tohum verilerini yükleyin
bin/rails db:seed

# 4. Birim ve entegrasyon testlerini çalıştırın (travel_to zaman testleri dahil)
bin/rails test

# 5. Sunucuyu başlatın (http://localhost:3000)
bin/dev # veya: bin/rails server
```

---

## Gerçek Minitest Test Çıktısı

Minitest test paketinin terminalde doğrudan çalıştırılmasıyla elde edilen gerçek çıktı:

```text
≈ tailwindcss v4.3.3

Done in 90ms
Running 23 tests in a single process (parallelization threshold is 50)
Run options: --seed 31744

# Running:

.......................

Finished in 0.494836s, 46.4800 runs/s, 189.9619 assertions/s.
23 runs, 94 assertions, 0 failures, 0 errors, 0 skips
```
*Tüm durum akışları, SLA zaman kuralları (`travel_to`) ve Smart Thank-You Guard testleri %100 yeşildir.*
