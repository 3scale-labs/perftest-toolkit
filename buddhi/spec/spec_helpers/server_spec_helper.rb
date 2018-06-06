module ServerSpecHelpers
  def server_build_get_request(path)
    msg = <<-_END_OF_REQUEST_
      GET #{path} HTTP/1.1
      Host: test.ruby-lang.org:8080

    _END_OF_REQUEST_
    WEBrick::HTTPRequest.new(WEBrick::Config::HTTP).tap do |req|
      req.parse(StringIO.new(msg.gsub(/^ {6}/, '')))
    end
  end

  def server_build_post_request(path, body)
    msg = %(POST #{path} HTTP/1.1
Host: test.ruby-lang.org:8080
Content-Type: text/plain
Content-Length: #{body.size}

#{body}
)
    WEBrick::HTTPRequest.new(WEBrick::Config::HTTP).tap do |req|
      req.parse(StringIO.new(msg))
    end
  end
end

RSpec.configure do |config|
  config.include ServerSpecHelpers
end
