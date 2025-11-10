# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.string :location
      t.string :industry_type
      t.integer :vacany
      t.references :recruiter, null: false, foreign_key: { to_table: :users }
      t.string :company_name

      t.timestamps
    end
  end
end
