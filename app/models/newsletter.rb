class Newsletter < ApplicationRecord
  validates :subject, presence: true
  validates :content, presence: true

  serialize :mail_to_list, Array
  serialize :mail_cc_list, Array
  serialize :mail_bcc_list, Array
end
