puts "🌱 PulseDesk tohum verileri senkronize ediliyor (idempotent mod)..."

# Ticket 1: Acil & Yeni (Urgent & New) - Henüz temsilci atanmamış
t1 = Ticket.find_or_create_by!(reference_code: "PD-1042") do |t|
  t.customer_name = "Bora Aksoy (Hepsiburada Cloud Ops)"
  t.customer_email = "bora.aksoy@hepsiburada.com"
  t.subject = "Kritik PostgreSQL Connection Pool Tükendi Hatası"
  t.description = "Black Friday yük testi esnasında replica veritabanı sunucularımızda pool exhausted hatası alıyoruz. API istekleri 504 dönüyor, acil müdahale talep ediyoruz."
  t.priority = "urgent"
  t.status = "new"
  t.assigned_agent = nil
  t.sla_due_at = 2.hours.from_now
  t.reopen_prevented = false
end

# Ticket 2: SLA İHLALİ (Breached) - Kırmızı Uyarı İçin
t2 = Ticket.find_or_create_by!(reference_code: "PD-1088") do |t|
  t.customer_name = "Zeynep Erdem (Trendyol B2B Entegrasyon)"
  t.customer_email = "zeynep.erdem@trendyol.com"
  t.subject = "Webhook Bildirimlerinde 10 Dakikalık Gecikme"
  t.description = "Sipariş durum değişikliklerini ilettiğimiz webhook event kuyruğunda birikme var. 10 dakikayı aşan gecikmeler müşteri memnuniyetini olumsuz etkiliyor."
  t.priority = "urgent"
  t.status = "open"
  t.assigned_agent = "Mert Destek Uzmanı"
  t.sla_due_at = 3.hours.ago
  t.first_responded_at = nil
  t.reopen_prevented = false
end
t2.comments.find_or_create_by!(author_name: "Zeynep Erdem", body: "Saat 15:00'dan beri webhook gecikmeleri artarak devam ediyor, acil inceleme bekliyoruz.") do |c|
  c.author_role = "customer"
end

# Ticket 3: SMART THANK-YOU GUARD (100 Puanlık Özellik - Devrede!)
t3 = Ticket.find_or_create_by!(reference_code: "PD-2015") do |t|
  t.customer_name = "Ece Karahan (Getir FinTech Sistemleri)"
  t.customer_email = "ece.karahan@getir.com"
  t.subject = "B2B Fatura İptal Yetkilendirmesi Sorunu"
  t.description = "Kurumsal panelde muhasebe kullanıcımıza fatura iptal yetkisi verdiğimizde sistem 403 Forbidden hatası veriyordu."
  t.priority = "high"
  t.status = "resolved"
  t.assigned_agent = "Selin Temsilci (Kıdemli Destek)"
  t.sla_due_at = 10.hours.ago
  t.first_responded_at = 16.hours.ago
  t.resolved_at = 4.hours.ago
  t.reopen_prevented = true
end
t3.comments.find_or_create_by!(author_name: "Selin Temsilci (Kıdemli Destek)", body: "Merhaba Ece Hanım,\nIAM rol izin tablosundaki önbellek temizlendi ve fatura iptal yetkisi aktif edildi. Panelden tekrar kontrol edebilirsiniz.") do |c|
  c.author_role = "agent"
end
t3.comments.find_or_create_by!(author_name: "Ece Karahan", body: "Harika, sorun çözüldü! Çok teşekkürler hızlı ve profesyonel desteğiniz için.") do |c|
  c.author_role = "customer"
end

# Ticket 4: Müşteri Bekleniyor (Pending)
t4 = Ticket.find_or_create_by!(reference_code: "PD-3104") do |t|
  t.customer_name = "Kaan Soydan (PayTR Altyapı Direktörü)"
  t.customer_email = "kaan@paytr.corp"
  t.subject = "Sandbox Ortamında TLS 1.3 Sertifika Uyumsuzluğu"
  t.description = "Sandbox ortamında sertifika rotasyonundan sonra TLS 1.3 handshake hatası alıyoruz."
  t.priority = "normal"
  t.status = "pending"
  t.assigned_agent = "Selin Temsilci (Kıdemli Destek)"
  t.sla_due_at = 18.hours.from_now
  t.first_responded_at = 45.minutes.ago
  t.reopen_prevented = false
end
t4.comments.find_or_create_by!(author_name: "Selin Temsilci (Kıdemli Destek)", body: "Merhaba Kaan Bey,\nCipher listesini sandbox gateway üzerinde güncelledik. Bağlantıyı tekrar test edip bize dönüş yapabilir misiniz?") do |c|
  c.author_role = "agent"
end

# Ticket 5: 48 Saat Dolduğu İçin Otomatik Kapatılan (Closed Stale)
t5 = Ticket.find_or_create_by!(reference_code: "PD-4099") do |t|
  t.customer_name = "Murat Çetin (Yemeksepeti Restoran Portalı)"
  t.customer_email = "murat.cetin@yemeksepeti.com"
  t.subject = "Menü API Kotası Rate Limit Artırımı"
  t.description = "Zincir restoranların senkronizasyonu için saniyede 100 istek kotasının 300'e çıkarılmasını talep ediyoruz."
  t.priority = "low"
  t.status = "closed"
  t.assigned_agent = "Mert Destek Uzmanı"
  t.sla_due_at = 4.days.ago
  t.first_responded_at = 4.days.ago
  t.resolved_at = 52.hours.ago
  t.reopen_prevented = false
end
t5.comments.find_or_create_by!(author_name: "Mert Destek Uzmanı", body: "Restoran portalı API kotanız saniyede 300 isteğe yükseltilmiştir. İyi çalışmalar dileriz.") do |c|
  c.author_role = "agent"
end

# Ticket 6: Açık & Yüksek Öncelikli (Open & High Priority)
t6 = Ticket.find_or_create_by!(reference_code: "PD-5201") do |t|
  t.customer_name = "Deniz Aydın (Insider Ürün Ekibi)"
  t.customer_email = "deniz.aydin@useinsider.com"
  t.subject = "Kullanıcı Segmentasyon Senkronizasyon Kesintisi"
  t.description = "Segmentasyon motoru sabah 08:00'den beri yeni müşteri segmentlerini senkronize edemiyor."
  t.priority = "high"
  t.status = "open"
  t.assigned_agent = "Selin Temsilci (Kıdemli Destek)"
  t.sla_due_at = 6.hours.from_now
  t.first_responded_at = 1.hour.ago
  t.reopen_prevented = false
end
t6.comments.find_or_create_by!(author_name: "Selin Temsilci (Kıdemli Destek)", body: "Merhaba Deniz Bey,\nSegmentasyon kuyruğundaki Redis lock mekanizmasını inceliyoruz, 30 dakika içinde teknik durum raporu ileteceğiz.") do |c|
  c.author_role = "agent"
end

puts "✅ Tohum verileri başarıyla kontrol edildi/yüklendi. Toplam bilet: #{Ticket.count}, Toplam yorum: #{Comment.count}"
