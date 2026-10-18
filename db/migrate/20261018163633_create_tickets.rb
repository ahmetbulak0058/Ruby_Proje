class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :reference_code, null: false
      t.string :customer_name, null: false
      t.string :customer_email, null: false
      t.string :subject, null: false
      t.text :description
      t.string :status, default: "new", null: false
      t.string :priority, default: "normal", null: false
      t.string :assigned_agent
      t.datetime :sla_due_at
      t.datetime :first_responded_at
      t.datetime :resolved_at
      t.boolean :reopen_prevented, default: false, null: false

      t.timestamps
    end
    add_index :tickets, :reference_code, unique: true
    add_index :tickets, :status
    add_index :tickets, :priority
    add_index :tickets, :sla_due_at
  end
end
