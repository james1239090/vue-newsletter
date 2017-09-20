class Newsletter < ApplicationRecord
  validates :subject, presence: true
  validates :content, presence: true

  validates :mail_to_list, presence: true,email: true
  validates :mail_cc_list ,email: true
  validates :mail_bcc_list ,email: true

  serialize :mail_to_list, Array
  serialize :mail_cc_list, Array
  serialize :mail_bcc_list, Array
end
