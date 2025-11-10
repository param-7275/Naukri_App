# frozen_string_literal: true

class AddFieldToJob < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :experience_range, :string
    add_column :jobs, :salary, :string
    add_column :jobs, :work_mode, :string
    add_column :jobs, :employment_type, :string
    add_column :jobs, :role_category, :string
    add_column :jobs, :education, :string
    add_column :jobs, :skills, :text
    add_column :jobs, :company_description, :text
  end
end
