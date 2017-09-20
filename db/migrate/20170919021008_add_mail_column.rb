class AddMailColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :newsletters, :mail_to_list, :string
    add_column :newsletters, :mail_cc_list, :string
    add_column :newsletters, :mail_bcc_list, :string

  end
end
