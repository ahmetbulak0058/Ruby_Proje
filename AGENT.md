# PulseDesk — Agent Çalışma İlkeleri ve Mimari Standartlar

> **Proje Adı:** PulseDesk  
> **Tanım:** Kurumsal B2B Müşteri Destek, Bilet (Ticket) ve Dinamik SLA Takip Platformu  
> **Teknoloji:** Ruby on Rails 8+, SQLite3, TailwindCSS v4, Hotwire (Turbo 8 & Stimulus), Minitest  

---

## 1. Proje Vizyonu ve Kimliği

PulseDesk, kurumsal organizasyonların yüksek tempolu müşteri destek operasyonlarını, acil taleplerini ve hizmet seviyesi taahhütlerini (SLA - Service Level Agreement) anlık olarak yönetebileceği modern, reaktif ve yüksek performanslı bir B2B SaaS platformudur.

### Temel Yetkinlikler:
1. **Talep (Ticket) Yaşam Döngüsü Yönetimi:** Yeni taleplerin oluşturulması, önceliklendirilmesi, durum geçişleri ve kapatılması.
2. **Dinamik SLA Takip & İhlal Yönetimi:** Öncelik seviyelerine (`urgent`, `high`, `medium`, `low`) göre ilk yanıt süresi (First Response Time) ve çözüm süresi (Resolution Time) hesaplamaları, geri sayım ve ihlal (`breached`) tespiti.
3. **Reaktif Müşteri Destek Ekranları:** Hotwire (Turbo Streams & Turbo Frames) ile sayfa yenilenmeden canlı güncellenen agent ve yönetici panelleri.
4. **Kurumsal Denetlenebilirlik:** Zaman damgalı durum hareketleri, yanıt geçmişi ve şeffaf metrikler.

---

## 2. Kesin Marka ve İsimlendirme Kuralları (Brand Policy)

* **Özgün Marka Kuralı:** Projenin tek ve yegane markası **"PulseDesk"**tir.
* **Sıfır Referans İlkesi:** Kod tabanında, commit mesajlarında, değişken/sınıf adlarında, CSS sınıflarında, arayüz metinlerinde, yorum satırlarında veya dokümantasyonlarda rakip/orijinal SaaS sistemlerinin (örn. Zendesk) ismi, kısaltması veya logosu **KESİNLİKLE YER ALAMAZ**.
* **Görsel Kimlik:** PulseDesk'e özel vektörel (SVG) logosu ve modern kurumsal renk paleti (Modern Indigo/Cyan/Slate/Emerald aksanları) kullanılacaktır.

---

## 3. Mimari Kurallar ve Domain Mantığı (Architecture & Logic)

### 3.1. "Skinny Controller, Rich Domain Model"
* Controller sınıfları yalnızca HTTP isteklerini karşılamak, güçlü parametreleri (strong params) doğrulamak ve ilgili model/servis metodunu çağırıp uygun görünümü (HTML/Turbo Stream/JSON) render etmekle sınırlıdır.
* **Controller içinde doğrudan iş mantığı, SLA hesabı veya durum değişimi yazmak yasaktır.**

### 3.2. Tek Noktadan Yönetim (`app/models/ticket.rb`)
Sunum ve kod incelemelerinde jüriye/ekiplere sistemin çekirdek mantığı tek bir odak noktası üzerinden net olarak gösterilebilmelidir.

* **Durum Geçişleri (State Transitions):**
  - Tüm durumlar (`new`, `open`, `pending`, `solved`, `closed`) ve geçerli geçişler `Ticket` modelinde (`app/models/ticket.rb`) tanımlanacaktır.
  - Örnek temiz metodlar: `assign_to!(agent)`, `mark_as_pending!`, `resolve!`, `close!`, `reopen!`.
  - Geçersiz bir durum geçişi yapılmak istendiğinde model düzeyinde hata fırlatılmalı veya doğrulamaya (validation) takılmalıdır.

* **SLA ve Zaman Hesaplamaları (SLA & Time Rules):**
  - İlk yanıt hedef süresi (`first_response_due_at`), çözüm hedef süresi (`resolution_due_at`) hesaplamaları,
  - İhlal durumu kontrolleri (`first_response_breached?`, `resolution_breached?`, `sla_status`),
  - Kalan süre hesaplamaları (`time_remaining_for_response`, `time_remaining_for_resolution`),
  - Öncelik bazlı SLA matrisi doğrudan `Ticket` modeli (`app/models/ticket.rb`) ve ilgili SLA modülleri içinde açık, anlaşılır ve bakımı kolay metodlarla bulunacaktır.

---

## 4. Test Kuralları ve Standartları (Testing Standards)

### 4.1. Minitest Standartları
* Projede test altyapısı olarak Rails'ın yerleşik **Minitest** çatısı (`ActiveSupport::TestCase`, `ActionDispatch::IntegrationTest`) kullanılır.
* **Sahte / Uydurma Test Raporları Kesinlikle Yasaktır:** Tüm testler gerçek veritabanı işlemlerini ve model metodlarını doğrudan çalıştırmalı, assertions (`assert`, `assert_equal`, `assert_changes` vb.) ile %100 gerçek sonuçları doğrulamalıdır.

### 4.2. Zaman Manipülasyonu (`ActiveSupport::Testing::TimeHelpers`)
* SLA hesaplamaları ve zaman aşımı durumları test edilirken rastgele bekleme (`sleep`) veya sahte stub'lar KULLANILMAZ.
* Tüm zaman testleri `ActiveSupport::Testing::TimeHelpers` (`travel_to`, `travel`, `freeze_time`) kullanılarak deterministik olarak test edilir:

```ruby
# Örnek Test Standardı:
test "urgent ticket breaches SLA if first response is not sent within 1 hour" do
  ticket = Ticket.create!(title: "Kritik Sunucu Kesintisi", priority: :urgent, status: :new)
  
  travel_to 61.minutes.from_now do
    assert ticket.first_response_breached?, "1 saat geçtiğinde acil biletin SLA'i ihlal edilmiş olmalı"
    assert_equal :breached, ticket.sla_status
  end
end
```

---

## 5. UI / UX ve Tasarım Prensipleri

* **Tasarım Dili:** TailwindCSS v4 ile hazırlanmış, yüksek kontrastlı, kurumsal ve ferah B2B kontrol paneli arayüzü.
* **Bileşenler:** Durum rozetleri (badges), SLA geri sayım sayaçları, öncelik indikatörleri ve dinamik filtreleme kartları.
* **Gerçekçi Veri:** Uygulamada test veya tohum verileri oluşturulurken kurumsal B2B senaryolarına uygun gerçekçi Türkçe/İngilizce veriler (`db/seeds.rb`) kullanılmalıdır.

---

## 6. Mimari Sorumluluk ve Dosya Haritası

Tekrarlayan dosya ağaçları yerine, her katmanın sınırları ve yetki alanı aşağıdaki matris ile netleştirilmiştir (Fiziksel proje ağacı ve kurulum adımları için [README.md](file:///c:/Users/blkah/Desktop/Ruby_Proje/README.md) referans alınmalıdır):

| Katman / Dosya | Temel Sorumluluk | İzin Verilen Kod / Mantık | Kesinlikle Yasak Olanlar |
| :--- | :--- | :--- | :--- |
| **`app/models/ticket.rb`** | Çekirdek Domain, Durum Makinesi & SLA Motoru | Durum geçişleri (`assign_to!`, `add_agent_reply!`, `resolve!`, `close_if_stale!`), SLA hesapları (`sla_breached?`), Smart Thank-You Guard | HTTP parametrelerini ayrıştırma, view render etme, UI formatlama |
| **`app/models/comment.rb`** | Mesajlaşma & Not Varlığı | Yorum doğrulama, roller (`customer`/`agent`), görünürlük kapsamları | Ticket durumunu kontrolsüz/doğrulamasız değiştirme |
| **`app/controllers/tickets_controller.rb`** | İnce Denetleyici (Skinny Controller) | Strong parameters kontrolü, model metodlarını çağırma, Turbo Stream/redirect yönlendirme | Doğrudan durum değiştirme (`status = 'open'`), SLA süresi veya matematik hesabı yapma |
| **`app/helpers/tickets_helper.rb`** | Görsel Rozet & Sunum Katmanı | Tailwind rozetleri, kalan süre metin formatlama (`2s 14dk`) | Veritabanı sorguları veya model mutasyonları |
| **`test/models/ticket_test.rb`** | Çekirdek Kural Doğrulama | `travel_to` ile deterministik SLA ve stale testleri, %100 gerçek assertion'lar | Sahte test üretmek, stub'lar ile zamanı bypass etmek |
| **`test/controllers/`** | Uçtan Uca Entegrasyon Testleri | Kullanıcı akışları, yönlendirmeler, flash mesajları | - |
