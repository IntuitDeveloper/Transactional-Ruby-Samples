#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
Send an SMS to a Single Recipient using Mandrill API

This script demonstrates how to send an SMS message to a single recipient
using the Mailchimp Transactional (Mandrill) API.

Usage:
    ruby sms_single_recipient.rb

Requirements:
    - dotenv
    - net/http (standard library)

Install with:
    gem install dotenv
    
Or with Bundler:
    bundle install

Note: SMS functionality uses the Mandrill REST API v1.1 directly since the
Ruby SDK doesn't include the send_sms method yet.
=end

require 'dotenv/load'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

# SMS API endpoint (note: uses API version 1.1, not 1.0)
SMS_API_ENDPOINT = 'https://mandrillapp.com/api/1.1/messages/send-sms'

# SSL verification mode - set SSL_VERIFY=false if behind corporate proxy
SSL_VERIFY = ENV['SSL_VERIFY'] != 'false'

# Send an SMS message
def send_sms(options = {})
  api_key = ENV['MANDRILL_API_KEY']
  
  unless api_key
    puts 'Error: MANDRILL_API_KEY not found in environment variables!'
    puts 'Please create a .env file with your Mandrill API key.'
    return nil
  end

  # Build the SMS message payload
  to_phone = options[:to] || ENV['SMS_TO_PHONE'] || '+1234567890'
  from_phone = options[:from] || ENV['SMS_FROM_PHONE'] || '+0987654321'
  message_text = options[:text] || ENV['SMS_MESSAGE'] || 'Hello from Mandrill SMS! This is a test message.'
  consent_type = options[:consent] || ENV['SMS_CONSENT_TYPE'] || 'onetime'
  track_clicks = options[:track_clicks] || ENV['SMS_TRACK_CLICKS'] == 'true'

  payload = {
    key: api_key,
    message: {
      sms: {
        text: message_text,
        to: to_phone,
        from: from_phone,
        consent: consent_type,
        track_clicks: track_clicks
      }
    }
  }

  begin
    # Set up the HTTP request
    uri = URI.parse(SMS_API_ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30
    
    # Configure SSL verification
    if SSL_VERIFY
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    else
      # WARNING: Only use this for testing behind corporate proxies!
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      puts "⚠️  SSL verification disabled (SSL_VERIFY=false)"
    end

    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    request.body = payload.to_json

    # Send the request
    response = http.request(request)

    puts 'SMS Request sent!'
    puts '=' * 50

    if response.code == '200'
      result = JSON.parse(response.body)
      puts 'SMS sent successfully!'
      puts "Response: #{JSON.pretty_generate(result)}"
      
      # Display key details from the response
      if result.is_a?(Array) && result.length > 0
        first_result = result[0]
        puts "\nDetails:"
        puts "  Status: #{first_result['status']}" if first_result['status']
        puts "  To: #{first_result['to']}" if first_result['to']
        puts "  Message ID: #{first_result['_id']}" if first_result['_id']
        
        if first_result['reject_reason']
          puts "  Reject Reason: #{first_result['reject_reason']}"
        end
      elsif result.is_a?(Hash)
        puts "  Status: #{result['status']}" if result['status']
        puts "  Message ID: #{result['_id']}" if result['_id']
      end
      
      puts '=' * 50
      result
    else
      error_body = begin
        JSON.parse(response.body)
      rescue
        response.body
      end
      
      puts 'SMS sending failed!'
      puts "HTTP Status: #{response.code}"
      puts "Error: #{JSON.pretty_generate(error_body)}" rescue puts "Error: #{error_body}"
      puts '=' * 50
      nil
    end
  rescue OpenSSL::SSL::SSLError => e
    puts 'SSL Certificate Error!'
    puts '=' * 50
    puts "Error: #{e.message}"
    puts ''
    puts "💡 TIP: If you're behind a corporate proxy, add this to your .env file:"
    puts "   SSL_VERIFY=false"
    puts '=' * 50
    nil
  rescue StandardError => e
    puts 'Error sending SMS!'
    puts '=' * 50
    puts "Error: #{e.message}"
    puts "Backtrace: #{e.backtrace.first(5).join("\n")}" if ENV['DEBUG']
    puts '=' * 50
    nil
  end
end

# Main execution
if __FILE__ == $0
  # Check if API key is configured
  unless ENV['MANDRILL_API_KEY']
    puts 'Error: MANDRILL_API_KEY not found in environment variables!'
    puts 'Please create a .env file with your Mandrill API key.'
    exit 1
  end

  puts '📱 Sending SMS...'
  puts ''
  
  # Check for custom message from environment (set by web UI)
  custom_message = ENV['SMS_CUSTOM_MESSAGE']
  custom_to = ENV['SMS_CUSTOM_TO']
  
  if custom_message || custom_to
    result = send_sms(
      to: custom_to || ENV['SMS_TO_PHONE'],
      text: custom_message || ENV['SMS_MESSAGE']
    )
  else
    result = send_sms
  end
  
  if result
    puts "\n✅ SMS operation completed!"
  else
    puts "\n❌ SMS operation failed!"
    exit 1
  end
end
