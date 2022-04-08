# == Schema Information
#
# Table name: now_payments
#
#  id                :bigint           not null, primary key
#  payment_id        :string
#  payment_status    :string
#  price_amount      :string
#  price_currency    :string
#  pay_amount        :string
#  pay_currency      :string
#  order_id          :string
#  order_description :string
#  ipn_callback_url  :string
#  purchase_id       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class NowPayment < ApplicationRecord

end
