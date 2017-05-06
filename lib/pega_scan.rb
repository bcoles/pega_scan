# coding: utf-8
#
# This file is part of PegaScan
# https://github.com/bcoles/pega_scan
#

require 'uri'
require 'cgi'
require 'net/http'
require 'openssl'

class PegaScan
  VERSION = '0.0.1'.freeze

  #
  # Check if PegaRules
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.isPega(url)
    url += '/' unless url.match(%r{/$})
    ['prweb/', 'prweb/sso', 'prweb/PRServletCustom'].each do |path|
      res = sendHttpRequest("#{url}#{path}")
      next unless res
      return true if res['set-cookie'] =~ /Pega-RULES/
      return true if res['location'] =~ /prweb/
      return true if res['location'] =~ /!STANDARD/
    end
    false
  end

  #
  # Get PegaRules version
  #
  # @param [String] URL
  #
  # @return [String] Pega version
  #
  def self.getVersion(url)
    url += '/' unless url.match(%r{/$})
    # PRhelp home.htm page title
    res = sendHttpRequest("#{url}prhelp/home.htm")
    if res && res.code.to_i == 200 && res.body =~ %r{<title>What's new in Pega ([\d\.]+)</title>}
      return $1
    end
    # PRweb error.jsp page
    res = sendHttpRequest("#{url}prweb/diagnostic/error.jsp")
    if res && res.code.to_i == 200 && res.body =~ %r{<span class="sys_info">PegaRULES (.+?)</span>}
      return $1
    end
    nil
  end

  #
  # Check if documentation is available
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.documentation(url)
    url += '/' unless url.match(%r{/$})
    res = sendHttpRequest("#{url}prhelp/home.htm")
    if res && res.code.to_i == 200 && res.body =~ /What's new in Pega/
      return true
    end
    false
  end

  #
  # Check if SAMLAuth SSO is enabled
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.samlAuth(url)
    url += '/' unless url.match(%r{/$})
    res = sendHttpRequest("#{url}prweb/sso/")
    if res && res.code.to_i == 303 && (res['set-cookie'] =~ /Pega-RULES/ || res['location'] =~ /!STANDARD/)
      return true
    end
    false
  end

  #
  # Check if remote access to the SOAP API is allowed
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.remoteSoapApi(url)
    url += '/' unless url.match(%r{/$})
    res = sendHttpRequest("#{url}prweb/PRSOAPServlet")
    if res && res.code.to_i == 405 && res.body =~ /Invalid HTTP method: GET/
      return true
    end
    false
  end

  #
  # Check if remote access to the REST API is allowed
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.remoteRestApi(url)
    url += '/' unless url.match(%r{/$})
    res = sendHttpRequest("#{url}prweb/PRRestService/")
    if res && res.body =~ /Request URI must contain service package, class, and method keys/
      return true
    end
    false
  end

  #
  # Check if System Management Console is available
  #
  # @param [String] URL
  #
  # @return [Boolean]
  #
  def self.systemManagementConsole(url)
    url += '/' unless url.match(%r{/$})
    res = sendHttpRequest("#{url}/prsysmgmt/")
    if res && (res.code.to_i == 401 && res['www-authenticate'] =~ /Authentication required/) || (res.code.to_i == 200 && res.body =~ /getnodes\.action/)
      return true
    end
    false
  end

  #
  # Retrieve list of node names from System Management Console
  #
  # @param [String] URL
  #
  # @return [Array] list of Pega node names
  #
  def self.getSystemManagementNodes(url)
    url += '/' unless url.match(%r{/$})
    res = sendHttpRequest("#{url}/prsysmgmt/SystemDetails.action")
    if res && res.code.to_i == 200 && res.body =~ /PRPC Management Console/
      return res.body.scan(/"authenticate\.action\?action=authenticate&nodename=(.+?)"/).flatten
    end
    []
  end

  private

  #
  # Fetch URL
  #
  # @param [String] URL
  #
  # @return [Net::HTTPResponse] HTTP response
  #
  def self.sendHttpRequest(url)
    target = URI.parse(url)
    puts "* Fetching #{target}" if $VERBOSE
    http = Net::HTTP.new(target.host, target.port)
    if target.scheme.to_s.eql?('https')
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      #http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    http.open_timeout = 20
    http.read_timeout = 20
    headers = {}
    headers['User-Agent'] = "PegaScan/#{VERSION}"
    headers['Accept-Encoding'] = 'gzip,deflate'

    begin
      res = http.request(Net::HTTP::Get.new(target, headers.to_hash))
      if res.body && res['Content-Encoding'].eql?('gzip')
        sio = StringIO.new(res.body)
        gz = Zlib::GzipReader.new(sio)
        res.body = gz.read
      end
    rescue Timeout::Error, Errno::ETIMEDOUT
      puts "- Error: Timeout retrieving #{target}" if $VERBOSE
    rescue => e
      puts "- Error: Could not retrieve URL #{target}\n#{e}" if $VERBOSE
    end
    puts "+ Received reply (#{res.body.length} bytes)" if $VERBOSE
    res
  end
end
