class CreateWorkers < ActiveRecord::Migration[5.1]
  def change
    create_table :workers do |t|
      t.string :first_name
      t.string :status

      t.timestamps
    end
  end
end
