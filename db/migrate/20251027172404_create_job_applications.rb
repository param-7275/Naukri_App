class CreateJobApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :job_applications do |t|
      t.references :job, null: false, foreign_key: true
      t.references :jobseeker, null: false, foreign_key: { to_table: :users }
      t.string :status
      t.text :about_yourself
      t.timestamps
    end
  end
end
