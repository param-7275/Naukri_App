class RenamefieldToJob < ActiveRecord::Migration[7.1]
  def change
    rename_column :jobs, :vacany, :vacancy
  end
end
