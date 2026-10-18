module TicketsHelper
  def priority_badge(priority)
    case priority.to_s
    when "urgent"
      content_tag :span, "🔴 Acil (Urgent)", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-rose-50 text-rose-700 border border-rose-200 shadow-sm"
    when "high"
      content_tag :span, "🟠 Yüksek (High)", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200 shadow-sm"
    when "normal"
      content_tag :span, "🔵 Normal", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-200 shadow-sm"
    when "low"
      content_tag :span, "⚪ Düşük (Low)", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-slate-100 text-slate-700 border border-slate-200 shadow-sm"
    else
      content_tag :span, priority.to_s.humanize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end

  def status_badge(status)
    case status.to_s
    when "new"
      content_tag :span, "Yeni", class: "inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider bg-indigo-100 text-indigo-700 border border-indigo-200"
    when "open"
      content_tag :span, "Açık", class: "inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider bg-sky-100 text-sky-700 border border-sky-200"
    when "pending"
      content_tag :span, "Müşteri Bekleniyor", class: "inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider bg-amber-100 text-amber-800 border border-amber-200"
    when "resolved"
      content_tag :span, "Çözüldü", class: "inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider bg-emerald-100 text-emerald-800 border border-emerald-200"
    when "closed"
      content_tag :span, "Kapatıldı", class: "inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider bg-slate-200 text-slate-700 border border-slate-300"
    else
      content_tag :span, status.to_s.humanize, class: "inline-flex items-center px-2.5 py-1 rounded-md text-xs font-medium bg-gray-100 text-gray-700"
    end
  end

  def sla_badge(ticket)
    if ticket.sla_breached?
      content_tag :span, class: "inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-rose-600 text-white shadow-sm ring-2 ring-rose-300 animate-pulse" do
        concat "🚨 SLA İHLALİ"
      end
    elsif ticket.first_responded_at.present?
      content_tag :span, class: "inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200" do
        concat "✓ İlk Yanıt SLA Başarılı"
      end
    else
      rem = ticket.sla_remaining_seconds
      hours = rem / 3600
      minutes = (rem % 3600) / 60

      color_classes = if rem < 1.hour
                        "bg-amber-500 text-white font-bold animate-pulse ring-2 ring-amber-300"
                      else
                        "bg-slate-100 text-slate-700 border border-slate-300 font-medium"
                      end

      content_tag :span, class: "inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs #{color_classes}" do
        concat "⏳ #{hours}s #{minutes}dk kaldı"
      end
    end
  end
end
