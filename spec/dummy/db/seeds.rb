puts "building payment gateway"

gateway = OddPay::PaymentGateway.create_or_find_by!(
  gateway_provider: 'NewebPay',
  gateway_info: {
    "hash_iv" => "ChcIXEFtZWudHfuP",
    "hash_key" => "fnRbrn8C5Q0YLEJ0WVBFYrUPqJKORMlb",
    "merchant_id" => "MS344441353"
  }
)

gateway.available_payment_types.each do |payment_type|
  puts "building payment method: #{payment_type}"
  gateway.payment_methods.create_or_find_by!(
    name: payment_type,
    description: payment_type,
    payment_type: payment_type,
    enabled: true
  )
end
