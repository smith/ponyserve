require "mixlib/shellout"
require "rack"
require "rack/server"
require "toml"

class PonyServe
  def response
    [
      200,
      {},
      [wrap(ponysay_output)],
    ]
  end

  def list
    [
      200,
      {},
      [wrap(ponysay_list, true)],
    ]
  end

  private

  def ponysay_list
    Mixlib::ShellOut.new("ponysay", "--list").run_command.stdout
  end

  def ponysay_output
    Mixlib::ShellOut.new(*ponysay_args.unshift("ponysay")).run_command.stdout
  end

  def ponysay_args
    [
      (config["pony"].empty? ? "" : ["--pony", config["pony"]]),
      (config["quote"].empty? ? "" : ["--quote", config["quote"]]),
      ["--balloon", config["balloon"]],
      config["message"],
    ].flatten.compact.reject(&:empty?)
  end

  def config
    @config ||= TOML.load_file("config/ponyserve.toml")
  end

  def wrap(output, black = false)
    "<html><head><meta charset='utf8' /></head><style>pre { #{"color: #dddddd; background-color: #000000;" if black} line-height: 0.9; }</style><script src='/data/ansi_up.js'></script><body><pre id='pony'>#{output}</pre><script>var ansiUp = new AnsiUp; ansiUp.escape_for_html = false;  var div = document.getElementById('pony'); div.innerHTML = ansiUp.ansi_to_html(div.innerHTML);</script></body></html>"
  end
end

class PonyServeApp
  def self.call(env)
    if Rack::Request.new(env).path_info == "/list"
      p PonyServe.new.list
      PonyServe.new.list
    else
      PonyServe.new.response
    end
  end
end

use Rack::Static, urls: ["/data"]
run PonyServeApp
