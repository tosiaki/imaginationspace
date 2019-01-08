module UsersHelper
  def valid_url(url)
    uri = URI(url)
    if uri.instance_of?(URI::Generic)
        uri = URI::HTTP.build({:host => uri.to_s}) 
    end
    uri.to_s
  end
end
