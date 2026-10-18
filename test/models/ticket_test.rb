require "test_helper"

class TicketTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def valid_attributes(overrides = {})
    {
      customer_name: "Ahmet Yılmaz",
      customer_email: "ahmet@acme.corp",
      subject: "API Entegrasyon Bağlantı Hatası",
      description: "Prod ortamında 500 hatası alıyoruz.",
      priority: "normal"
    }.merge(overrides)
  end

  # =========================================================================
  # 1. TEMEL ALANLAR VE VARSAYILANLAR
  # =========================================================================

  test "creates ticket with valid attributes and automatic reference code" do
    ticket = Ticket.create!(valid_attributes)

    assert ticket.persisted?
    assert_match(/\AAKA-\d{4}\z/, ticket.reference_code)
    assert_equal "new", ticket.status
    assert_equal "normal", ticket.priority
    assert_equal false, ticket.reopen_prevented
    assert ticket.sla_due_at.present?
  end

  test "validates required fields" do
    ticket = Ticket.new
    assert_not ticket.valid?
    assert_includes ticket.errors[:customer_name], "can't be blank"
    assert_includes ticket.errors[:customer_email], "can't be blank"
    assert_includes ticket.errors[:subject], "can't be blank"
  end

  # =========================================================================
  # 2. DURUM GEÇİŞİ TESTİ (Ödev Kriteri 1)
  # new -> open -> pending -> resolved
  # =========================================================================

  test "durum gecisi: new olarak baslayan talep, temsilci atanınca open, temsilci yanıtlayınca pending, cozulunce resolved olur" do
    # 1. Başlangıç: new
    ticket = Ticket.create!(valid_attributes)
    assert_equal "new", ticket.status, "Talep başlangıçta 'new' olmalı"

    # 2. Temsilci atanınca: open
    ticket.assign_to!("Selin Temsilci")
    assert_equal "open", ticket.status, "Temsilci atanınca durum 'open' olmalı"
    assert_equal "Selin Temsilci", ticket.assigned_agent

    # 3. Temsilci yanıtlayınca: pending (ve first_responded_at mühürlenir)
    ticket.add_agent_reply!("Selin Temsilci", "Logları incelemeye başladık.")
    assert_equal "pending", ticket.status, "Temsilci yanıtlayınca durum 'pending' olmalı"
    assert_not_nil ticket.first_responded_at, "İlk yanıt zamanı kaydedilmeli"

    # 4. Çözülünce: resolved (ve resolved_at mühürlenir)
    ticket.resolve!
    assert_equal "resolved", ticket.status, "Çözülünce durum 'resolved' olmalı"
    assert_not_nil ticket.resolved_at, "Çözüm zamanı kaydedilmeli"
  end

  # =========================================================================
  # 3. ZAMAN KURALI 1: travel_to İLE SLA TESTİ (Ödev Kriteri 2)
  # urgent talep 1 saatte sla_breached? false; 3 saatte sla_breached? true
  # =========================================================================

  test "zaman kurali 1: urgent talep 1 saat sonra ihlal edilmemeli, 3 saat sonra ihlal edilmeli" do
    ticket = Ticket.create!(valid_attributes(priority: "urgent")) # Hedef: 2 saat

    # 1 saat ileri gidildiğinde (travel_to 1.hour.from_now) sla_breached? false dönmeli
    travel_to 1.hour.from_now do
      assert_equal false, ticket.sla_breached?, "1 saat sonra SLA ihlal edilmemiş olmalı (hedef 2 saat)"
      assert ticket.sla_remaining_seconds > 0, "Kalan süre pozitif olmalı"
    end

    # 3 saat ileri gidildiğinde (travel_to 3.hours.from_now) sla_breached? true dönmeli
    travel_to 3.hours.from_now do
      assert_equal true, ticket.sla_breached?, "3 saat sonra yanıt verilmediği için SLA ihlal edilmiş olmalı"
      assert_equal 0, ticket.sla_remaining_seconds, "İhlalde kalan süre 0 olmalı"
      assert ticket.sla_remaining_seconds(allow_negative: true).negative?, "İhlalde negatif süre dönmeli"
    end
  end

  # =========================================================================
  # 4. ZAMAN KURALI 2: travel_to İLE OTOMATİK KAPANIŞ TESTİ (Ödev Kriteri 3)
  # resolved talep 24 saat sonra resolved kalmalı, 49 saat sonra closed olmalı
  # =========================================================================

  test "zaman kurali 2: resolved talep 24 saat sonra close_if_stale ile resolved kalmali, 49 saat sonra closed olmali" do
    ticket = Ticket.create!(valid_attributes)
    ticket.resolve!
    assert_equal "resolved", ticket.status

    # 24 saat sonra close_if_stale! çağrıldığında hâlâ resolved kalmalı
    travel_to 24.hours.from_now do
      result = ticket.close_if_stale!
      assert_equal false, result, "24 saat dolmadığı için stale sayılmamalı"
      assert_equal "resolved", ticket.reload.status, "24 saat sonra durum hâlâ 'resolved' kalmalı"
    end

    # 49 saat sonra close_if_stale! çağrıldığında durumu closed olmalı
    travel_to 49.hours.from_now do
      result = ticket.close_if_stale!
      assert_equal true, result, "49 saat sonra stale sayılıp kapanmalı"
      assert_equal "closed", ticket.reload.status, "49 saat sonra durum 'closed' olmalı"
    end
  end

  # =========================================================================
  # 5. 100 PUANLIK ÖZELLİK TESTİ: SMART THANK-YOU GUARD (Ödev Kriteri 4)
  # =========================================================================

  test "smart thank you guard: resolved talebe musteri tesekkur yazarsa resolved kalir ve reopen_prevented true olur" do
    ticket = Ticket.create!(valid_attributes)
    ticket.resolve!
    assert_equal "resolved", ticket.status
    assert_equal false, ticket.reopen_prevented

    # Müşteri "Çok teşekkürler, elinize sağlık" yazar
    ticket.add_customer_reply!("Ahmet Yılmaz", "Çok teşekkürler, elinize sağlık")

    ticket.reload
    assert_equal "resolved", ticket.status, "Teşekkür mesajı bilet durumunu 'resolved' olarak korumalıdır"
    assert_equal true, ticket.reopen_prevented, "reopen_prevented alanı true olmalıdır"
    assert_equal 1, ticket.comments.count
  end

  test "smart thank you guard: musteri tesekkurler ama fatura hala hatali gorunuyor yazarsa acilir (open olur)" do
    ticket = Ticket.create!(valid_attributes)
    ticket.resolve!
    assert_equal "resolved", ticket.status

    # Müşteri soru işareti ve hata içeren mesaj yazar
    ticket.add_customer_reply!("Ahmet Yılmaz", "Teşekkürler ama fatura hâlâ hatalı görünüyor?")

    ticket.reload
    assert_equal "open", ticket.status, "Soru işareti ve sorun içeren mesaj bileti 'open' yapmalıdır"
    assert_equal false, ticket.reopen_prevented, "reopen_prevented false kalmalıdır"
  end

  # =========================================================================
  # 6. DİĞER ÖNCELİK VE YARDIMCI TESTLER
  # =========================================================================

  test "sets correct initial sla_due_at for all priority levels" do
    freeze_time do
      urgent = Ticket.create!(valid_attributes(priority: "urgent"))
      high   = Ticket.create!(valid_attributes(priority: "high"))
      normal = Ticket.create!(valid_attributes(priority: "normal"))
      low    = Ticket.create!(valid_attributes(priority: "low"))

      assert_in_delta 2.hours.from_now, urgent.sla_due_at, 1.second
      assert_in_delta 8.hours.from_now, high.sla_due_at, 1.second
      assert_in_delta 24.hours.from_now, normal.sla_due_at, 1.second
      assert_in_delta 48.hours.from_now, low.sla_due_at, 1.second
    end
  end

  test "sla is fulfilled and not breached if agent responded in time" do
    ticket = Ticket.create!(valid_attributes(priority: "urgent"))

    # 30. dakikada temsilci yanıt verir
    travel_to 30.minutes.from_now do
      ticket.add_agent_reply!("Destek Temsilcisi", "İnceliyoruz.")
      assert_not ticket.sla_breached?
    end

    # 5 saat sonra bile biletin ilk yanıt SLA'i başarıyla karşılanmış kalır
    travel_to 5.hours.from_now do
      assert_not ticket.sla_breached?, "Zamanında yanıtlanan bilet sonradan ihlale düşmemeli"
    end
  end
end
