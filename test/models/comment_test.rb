require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @ticket = Ticket.create!(
      customer_name: "Ayşe Kaya",
      customer_email: "ayse@example.com",
      subject: "Fatura İtirazı",
      description: "Son faturamda fazla çekim var.",
      priority: "normal"
    )
  end

  test "validates required comment attributes" do
    comment = Comment.new
    assert_not comment.valid?
    assert_includes comment.errors[:ticket], "must exist"
    assert_includes comment.errors[:author_name], "can't be blank"
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "validates author_role inclusion" do
    comment = @ticket.comments.build(author_name: "Ali", body: "Test", author_role: "invalid_role")
    assert_not comment.valid?
    assert_includes comment.errors[:author_role], "is not included in the list"
  end

  test "creates valid comment with default internal_note false" do
    comment = @ticket.comments.create!(
      author_name: "Ahmet Müşteri",
      author_role: "customer",
      body: "Ekran görüntüsünü ekliyorum."
    )

    assert comment.persisted?
    assert_equal false, comment.internal_note
    assert comment.customer?
    assert_not comment.agent?
  end

  test "creates internal note for agents" do
    comment = @ticket.comments.create!(
      author_name: "Mehmet Uzman",
      author_role: "agent",
      body: "Muhasebe departmanı ile görüşüldü, iade onaylandı.",
      internal_note: true
    )

    assert comment.persisted?
    assert_equal true, comment.internal_note
    assert comment.agent?
  end
end
