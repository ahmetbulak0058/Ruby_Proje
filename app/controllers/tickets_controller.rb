class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[show assign reply_agent reply_customer resolve simulate_time]

  # GET /
  def index
    @total_count = Ticket.count
    @open_count = Ticket.where(status: %w[new open pending]).count
    @breached_count = Ticket.all.count(&:sla_breached?)
    @reopen_prevented_count = Ticket.where(reopen_prevented: true).count

    @current_status = params[:status].presence || "all"

    @tickets = case @current_status
               when "breached"
                 Ticket.all.select(&:sla_breached?)
               when "new", "open", "pending", "resolved", "closed"
                 Ticket.where(status: @current_status).order(created_at: :desc)
               else
                 Ticket.order(created_at: :desc)
               end

    @new_ticket = Ticket.new(priority: "normal")
  end

  # GET /tickets/:id
  def show
    @comments = @ticket.comments.chronological
  end

  # POST /tickets
  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      redirect_to ticket_path(@ticket), notice: "Talep başarıyla oluşturuldu (#{@ticket.reference_code})."
    else
      @total_count = Ticket.count
      @open_count = Ticket.where(status: %w[new open pending]).count
      @breached_count = Ticket.all.count(&:sla_breached?)
      @reopen_prevented_count = Ticket.where(reopen_prevented: true).count
      @current_status = "all"
      @tickets = Ticket.order(created_at: :desc)
      @new_ticket = @ticket
      flash.now[:alert] = "Talep oluşturulurken bir hata oluştu: #{@ticket.errors.full_messages.join(', ')}"
      render :index, status: :unprocessable_entity
    end
  end

  # POST /tickets/:id/assign
  def assign
    agent_name = params[:agent_name].presence || "Selin Temsilci (Kıdemli Destek)"
    @ticket.assign_to!(agent_name)
    redirect_to ticket_path(@ticket), notice: "Temsilci #{agent_name} başarıyla atandı. Durum: #{@ticket.status.upcase}"
  end

  # POST /tickets/:id/reply_agent
  def reply_agent
    author_name = params[:author_name].presence || @ticket.assigned_agent.presence || "Destek Ekibi"
    body = params[:body].to_s.strip

    if body.present?
      @ticket.add_agent_reply!(author_name, body)
      redirect_to ticket_path(@ticket), notice: "Temsilci yanıtı kaydedildi ve ilk yanıt SLA süresi mühürlendi."
    else
      redirect_to ticket_path(@ticket), alert: "Yanıt metni boş bırakılamaz."
    end
  end

  # POST /tickets/:id/reply_customer
  def reply_customer
    author_name = params[:author_name].presence || @ticket.customer_name
    body = params[:body].to_s.strip

    if body.present?
      was_prevented_before = @ticket.reopen_prevented
      @ticket.add_customer_reply!(author_name, body)

      if @ticket.reopen_prevented && !was_prevented_before
        redirect_to ticket_path(@ticket), notice: "⚡ Smart Thank-You Guard DEVREDE! Teşekkür mesajı algılandı; talep yeniden açılmadı ve SLA metrikleriniz korundu."
      else
        redirect_to ticket_path(@ticket), notice: "Müşteri yanıtı eklendi. Talep durumu: #{@ticket.status.upcase}"
      end
    else
      redirect_to ticket_path(@ticket), alert: "Mesaj metni boş bırakılamaz."
    end
  end

  # POST /tickets/:id/resolve
  def resolve
    @ticket.resolve!
    redirect_to ticket_path(@ticket), notice: "Talep başarıyla çözüldü (RESOLVED) olarak işaretlendi."
  end

  # POST /tickets/:id/simulate_time
  def simulate_time
    case params[:simulation_type]
    when "fast_forward_sla"
      @ticket.simulate_sla_breach!
      redirect_to ticket_path(@ticket), alert: "⏱️ Zaman Simülatörü: SLA süresi geriye çekildi! Talep SLA İHLALİ durumuna düştü."
    when "fast_forward_stale"
      @ticket.simulate_stale_close!
      redirect_to ticket_path(@ticket), notice: "⏱️ Zaman Simülatörü: 49 saat ileri sarıldı ve close_if_stale! çalıştırıldı. Talep otomatik KAPANDI (closed)."
    when "reopen"
      @ticket.reopen!
      redirect_to ticket_path(@ticket), notice: "Talep tekrar açık (OPEN) durumuna getirildi."
    else
      redirect_to ticket_path(@ticket)
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:customer_name, :customer_email, :subject, :description, :priority)
  end
end
