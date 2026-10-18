require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = Ticket.create!(
      customer_name: "Test Müşteri",
      customer_email: "test@musteri.com",
      subject: "Test Talep Konusu",
      description: "Test açıklaması",
      priority: "normal"
    )
  end

  test "should get index" do
    get root_url
    assert_response :success
    assert_select "h1", text: /SLA & Destek Operasyon Merkezi/
    assert_select "p", text: "PulseDesk © #{Time.current.year} — Enterprise SLA & Incident Operations Platform"
  end

  test "should filter tickets by status" do
    get root_url(status: "new")
    assert_response :success
  end

  test "should get show" do
    get ticket_url(@ticket)
    assert_response :success
    assert_includes response.body, @ticket.reference_code
    assert_includes response.body, "Demo Zaman Simülatörü"
  end

  test "should create ticket via simulation form" do
    assert_difference("Ticket.count", 1) do
      post tickets_url, params: {
        ticket: {
          customer_name: "Yeni Müşteri",
          customer_email: "yeni@sirket.com",
          subject: "Yeni Acil Talep",
          description: "Sistemde kesinti var.",
          priority: "urgent"
        }
      }
    end

    created_ticket = Ticket.last
    assert_redirected_to ticket_url(created_ticket)
    assert_equal "urgent", created_ticket.priority
  end

  test "should assign agent" do
    post assign_ticket_url(@ticket), params: { agent_name: "Selin Temsilci" }
    assert_redirected_to ticket_url(@ticket)
    assert_equal "Selin Temsilci", @ticket.reload.assigned_agent
    assert_equal "open", @ticket.status
  end

  test "should record agent reply and seal first response" do
    post reply_agent_ticket_url(@ticket), params: { author_name: "Selin Temsilci", body: "İnceliyoruz." }
    assert_redirected_to ticket_url(@ticket)
    assert_equal "pending", @ticket.reload.status
    assert_not_nil @ticket.first_responded_at
  end

  test "should handle customer thank you reply without reopening (Smart Thank-You Guard)" do
    @ticket.resolve!
    assert_equal "resolved", @ticket.status

    post reply_customer_ticket_url(@ticket), params: {
      author_name: "Test Müşteri",
      body: "Harika, sorun çözüldü! Çok teşekkürler."
    }

    assert_redirected_to ticket_url(@ticket)
    assert_equal "resolved", @ticket.reload.status
    assert_equal true, @ticket.reopen_prevented
  end

  test "should resolve ticket" do
    post resolve_ticket_url(@ticket)
    assert_redirected_to ticket_url(@ticket)
    assert_equal "resolved", @ticket.reload.status
    assert_not_nil @ticket.resolved_at
  end

  test "should simulate SLA breach via fast_forward_sla" do
    post simulate_time_ticket_url(@ticket), params: { simulation_type: "fast_forward_sla" }
    assert_redirected_to ticket_url(@ticket)
    assert @ticket.reload.sla_breached?
  end

  test "should simulate stale close via fast_forward_stale" do
    post simulate_time_ticket_url(@ticket), params: { simulation_type: "fast_forward_stale" }
    assert_redirected_to ticket_url(@ticket)
    assert_equal "closed", @ticket.reload.status
  end
end
