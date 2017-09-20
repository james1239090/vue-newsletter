class ChangeMailListType < ActiveRecord::Migration[5.1]
  def change
    change_column :newsletters, :mail_to_list, :text
    change_column :newsletters, :mail_cc_list, :text
    change_column :newsletters, :mail_bcc_list, :text
  end
end
