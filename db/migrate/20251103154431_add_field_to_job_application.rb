class AddFieldToJobApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :rejected_at, :datetime
    add_column :job_applications, :reapply_allowed, :boolean, default: false
  end
end
