# frozen_string_literal: true

require 'open3'

module Wgconf
  module Utils
    # https://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      throw "Couldn't find `wg`."
    end

    def wg_genpsk
      stdout_str, _status = Open3.capture2("#{which('wg')} genpsk")
      stdout_str.strip
    end

    def wg_genkey
      stdout_str, _status = Open3.capture2("#{which('wg')} genkey")
      stdout_str.strip
    end

    def wg_pubkey(private_key)
      stdout_str = ''
      Open3.popen2("#{which('wg')} pubkey") do |stdin, stdout, _wait_thr|
        stdin.print(private_key)
        stdin.close
        stdout_str = stdout.gets
      end
      stdout_str.strip
    end
  end
end
