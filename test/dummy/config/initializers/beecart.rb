# Beecart.redis_conf = {
#   host: 'localhost',
#   port: 5555
# }
# 
# Beecart.expire_time = 30

Beecart.configure do |config|
  config.expire_time = 30
  config.redis = {
    host: 'localhost',
    port: 5555
  }
end
