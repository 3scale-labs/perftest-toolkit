module ServerSpecHelpers
  def server_build_request(path)
    msg = <<-_END_OF_REQUEST_
      GET #{path} HTTP/1.1
      Host: test.ruby-lang.org:8080

    _END_OF_REQUEST_
    WEBrick::HTTPRequest.new(WEBrick::Config::HTTP).tap do |req|
      req.parse(StringIO.new(msg.gsub(/^ {6}/, '')))
    end
  end
end

RSpec.configure do |config|
  config.include ServerSpecHelpers
end
