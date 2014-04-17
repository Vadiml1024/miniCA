# -- parse options ----------------------------------------------------

require 'optparse'

options = {
  :Port               => 12345,
  :SSLCertificate     => "localhost.pem",
  :SSLPrivateKey      => "localhost.priv"
}

OptionParser.new do |opts|
  opts.on("-p", "--port PORT", Integer, "Port to listen on") do |v|
    options[:Port] = v
  end
  opts.on("-c", "--certificate CERTIFICATE", "certificate file") do |v|
    options[:SSLCertificate] = v
  end
  opts.on("-k", "--key PRIVATEKEY", "private key") do |v|
    options[:SSLPrivateKey] = v
  end
end.parse!

# -- a simple web server controller -----------------------------------

require "webrick"

class Simple < WEBrick::HTTPServlet::AbstractServlet
  def do_GET request, response
    response.status = 200
    response['Content-Type'] = 'text/plain'
    response.body = "helloworld\n"
  end
end

# -- start web server -------------------------------------------------

require 'webrick/https'
require 'openssl'

options.update :Logger        => WEBrick::Log::new($stderr, WEBrick::Log::INFO),
          :SSLEnable          => true,
          :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
          :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]

options[:SSLCertificate] = OpenSSL::X509::Certificate.new(File.read(options[:SSLCertificate]))
options[:SSLPrivateKey] = OpenSSL::PKey::RSA.new(File.read(options[:SSLPrivateKey]))

$server = WEBrick::HTTPServer.new options
$server.mount "/", Simple

trap('INT') { $server.stop }
File.open("https.pid", "w") { |io| io.write($$) }

$server.start
