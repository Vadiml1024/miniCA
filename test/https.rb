# -- parse options ----------------------------------------------------

require 'optparse'

options = {
  :Port               => 12345,
  :SSLCertificate     => "localhost.pem",
  :SSLPrivateKey      => "localhost.priv", 
  :DocumentRoot       => File.expand_path(File.dirname(__FILE__))
}

OptionParser.new do |opts|
  opts.on("-r", "--root DIR", "root directory") do |v|
    options[:DocumentRoot] = v
  end
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

# -- start web server -------------------------------------------------

require "webrick"
require 'webrick/https'
require 'openssl'

options.update :Logger        => WEBrick::Log::new($stderr, WEBrick::Log::INFO),
          :SSLEnable          => true,
          :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
          :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]

options[:SSLCertificate] = OpenSSL::X509::Certificate.new(File.read(options[:SSLCertificate]))
options[:SSLPrivateKey] = OpenSSL::PKey::RSA.new(File.read(options[:SSLPrivateKey]))

$server = WEBrick::HTTPServer.new options
trap('INT') { $server.stop }
File.open("https.pid", "w") { |io| io.write($$) }

$server.start
