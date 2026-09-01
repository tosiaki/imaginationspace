class Ahoy::Store < Ahoy::DatabaseStore
  # Keep historical analytics readable without growing the analytics tables.
  def track_visit(_data); end

  def track_event(_data); end
end

# set to true for JavaScript tracking
Ahoy.api = false

# Do not create visits automatically from application requests.
Ahoy.server_side_visits = false

# better user agent parsing
Ahoy.user_agent_parser = :device_detector
