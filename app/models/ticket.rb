class Ticket < ApplicationRecord
  # --- Associations ---
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy

  # --- Constants ---
  STATUSES = %w[new open pending resolved closed].freeze
  PRIORITIES = %w[low normal high urgent].freeze

  SLA_TARGETS = {
    "urgent" => 2.hours,
    "high"   => 8.hours,
    "normal" => 24.hours,
    "low"    => 48.hours
  }.freeze

  # Smart Thank-You Guard Regex Patterns
  THANK_YOU_REGEX = /\b(te[sş]ekk[uü]r(ler|[\s_-]*ederim)?|sa[gğ][\s_-]*ol(un)?|ç[oö]z[uü]ld[uü]|cozuldu|tamamd[ıi]r|halledildi|ellerinize?\s*sa[gğ]l[ıi]k|thank(s|\s+you)?|thx|solved|great|awesome|perfect)\b/i
  NEGATIVE_REGEX = /\b(ama|fakat|ancak|lakin|henüz|çözülmedi|cozulmedi|olmadı|olmadi|hata|çalışmıyor|calismiyor|devam ediyor|not solved|not working|still|broken|issue persists|doesn't work|does not work)\b/i

  # --- Validations ---
  validates :reference_code, presence: true, uniqueness: true
  validates :customer_name, presence: true
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :priority, presence: true, inclusion: { in: PRIORITIES }

  # --- Callbacks ---
  before_validation :generate_reference_code, on: :create
  before_create :set_initial_sla

  # --- Scopes ---
  scope :recent, -> { order(created_at: :desc) }
  scope :unresolved, -> { where.not(status: %w[resolved closed]) }
  scope :by_status, ->(s) { where(status: s) }
  scope :by_priority, ->(p) { where(priority: p) }

  # =========================================================================
  # 1. DURUM AKIŞI (STATE FLOW) METOTLARI
  # =========================================================================

  # Temsilci atandığında eğer durum 'new' ise otomatik 'open' yap
  def assign_to!(agent_name)
    self.assigned_agent = agent_name
    self.status = "open" if status == "new"
    save!
  end

  # Temsilci yanıt yazdığında:
  # - Yorumu kaydet
  # - first_responded_at boşsa Time.current olarak kaydet
  # - Durumu 'pending' (müşteri yanıtı bekleniyor) yap
  def add_agent_reply!(author_name, body)
    transaction do
      comments.create!(
        author_name: author_name,
        author_role: "agent",
        body: body,
        internal_note: false
      )
      self.first_responded_at ||= Time.current
      self.status = "pending"
      save!
    end
  end

  # Durumu 'resolved' yap ve resolved_at = Time.current kaydet
  def resolve!
    self.status = "resolved"
    self.resolved_at = Time.current
    save!
  end

  # ZAMAN KURALI 1:
  # Eğer ticket 'resolved' durumundaysa ve resolved_at üzerinden 48 saat geçmişse durumu 'closed' yap
  def close_if_stale!
    return false unless status == "resolved" && resolved_at.present?

    if resolved_at <= 48.hours.ago
      self.status = "closed"
      save!
      true
    else
      false
    end
  end

  # =========================================================================
  # 2. ZAMAN KURALI (SLA TIME RULE) METOTLARI
  # =========================================================================

  # Ticket oluşturulurken önceliğe göre sla_due_at belirlenir
  def set_initial_sla
    return if sla_due_at.present?

    duration = SLA_TARGETS[priority] || 24.hours
    self.sla_due_at = duration.from_now
  end

  # SLA İhlal Kontrolü:
  # - İlk yanıt verildiyse: first_responded_at > sla_due_at
  # - Henüz yanıt verilmediyse: Time.current > sla_due_at
  def sla_breached?
    return false if sla_due_at.blank?

    if first_responded_at.present?
      first_responded_at > sla_due_at
    else
      Time.current > sla_due_at
    end
  end

  # Kalan SLA süresini saniye olarak döndürür
  # (allow_negative: true verilirse ihlal süresi eksi değer olarak döner)
  def sla_remaining_seconds(allow_negative: false)
    return 0 if sla_due_at.blank?

    effective_time = first_responded_at || Time.current
    diff = (sla_due_at - effective_time).to_i
    allow_negative ? diff : [diff, 0].max
  end

  # =========================================================================
  # 3. SMART THANK-YOU GUARD (Kullanılabilir Pas Koruması)
  # =========================================================================

  # Normalde müşteri resolved olan bir talebe mesaj yazarsa durum 'open' olur.
  # ANCAK müşteri mesajı kısa bir teşekkür/onay mesajıysa ve soru işareti '?' içermiyorsa:
  # Durumu 'open' YAPMA, 'resolved' bırak ve reopen_prevented = true olarak işaretle.
  def add_customer_reply!(author_name, body)
    transaction do
      comments.create!(
        author_name: author_name,
        author_role: "customer",
        body: body,
        internal_note: false
      )

      if status == "resolved"
        if self.class.thank_you_message?(body)
          self.reopen_prevented = true
        else
          self.status = "open"
          self.reopen_prevented = false
          self.resolved_at = nil
        end
      elsif status == "pending"
        self.status = "open"
      end

      save!
    end
  end

  # Akıllı Teşekkür / Onay Mesajı Tespiti
  def self.thank_you_message?(text)
    clean_text = text.to_s.strip
    return false if clean_text.include?("?")
    return false if clean_text.match?(NEGATIVE_REGEX)

    clean_text.match?(THANK_YOU_REGEX).present?
  end

  # =========================================================================
  # 4. YARDIMCI METOTLAR
  # =========================================================================

  def new?
    status == "new"
  end

  def open?
    status == "open"
  end

  def pending?
    status == "pending"
  end

  def resolved?
    status == "resolved"
  end

  def closed?
    status == "closed"
  end

  def urgent?
    priority == "urgent"
  end

  # =========================================================================
  # 5. SUNUM & DEMO ZAMAN SİMÜLATÖRÜ METOTLARI
  # =========================================================================

  # SLA süresini geriye çekerek anında ihlal durumunu tetikler
  def simulate_sla_breach!
    self.sla_due_at = 3.hours.ago
    save!
  end

  # 49 saat ileri sararak close_if_stale! zaman kuralını tetikler
  def simulate_stale_close!
    self.status = "resolved" if status != "resolved"
    self.resolved_at = 49.hours.ago
    close_if_stale!
  end

  # Canlı demo sırasında bileti tekrar açarak testi tekrarlamayı sağlar
  def reopen!
    self.status = "open"
    self.reopen_prevented = false
    save!
  end

  private

  def generate_reference_code
    return if reference_code.present?

    loop do
      candidate = "PD-#{rand(1000..9999)}"
      unless Ticket.exists?(reference_code: candidate)
        self.reference_code = candidate
        break
      end
    end
  end
end
