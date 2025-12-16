#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
Send a Single Email to a Single Recipient using Mandrill API

This script demonstrates how to send a single email to a single recipient
using the mailchimp-transactional Ruby gem.

Usage:
    ruby email_with_single_recipient.rb

Requirements:
    - MailchimpTransactional
    - dotenv

Install with:
    gem install MailchimpTransactional dotenv
    
Or with Bundler:
    bundle install
=end

require 'MailchimpTransactional'
require 'dotenv/load'
require 'json'

# Initialize the Mandrill API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

# Construct the message
message = {
  html: '<p>Hello HTML world!</p>',
  text: 'Hello plain world!',
  subject: 'Hello world',
  from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
  from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
  to: [{
    email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
    name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
    type: 'to'
  }],
  headers: {
    'Reply-To': ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org'
  }
}

# Send a single email to a single recipient
def send_email(mailchimp, message)
  begin
    # Send the message
    result = mailchimp.messages.send({ message: message })
    
    puts 'Email sent successfully!'
    puts '=' * 50
    
    # Display the response details
    if result && result.length > 0
      first_result = result[0]
      puts "Status: #{first_result['status']}"
      puts "Email: #{first_result['email']}"
      puts "Message ID: #{first_result['_id']}"
      
      if first_result['reject_reason']
        puts "Reject Reason: #{first_result['reject_reason']}"
      end
    else
      puts "Unexpected result structure: #{result}"
    end
    
    puts '=' * 50
    result
  rescue MailchimpTransactional::ApiError => e
    puts 'Error sending email!'
    puts '=' * 50
    puts "Mandrill API Error: #{e.message}"
    puts "Error details: #{e.response_body}" if e.respond_to?(:response_body)
    puts '=' * 50
    nil
  end
end

# Send an email with advanced tracking and metadata options
def send_email_with_advanced_options(mailchimp)
  message = {
    html: '<p>Hello <strong>HTML</strong> world!</p>',
    text: 'Hello plain world!',
    subject: 'Advanced Email Test',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    to: [{
      email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
      name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
      type: 'to'
    }],
    headers: {
      'Reply-To': ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
      'X-MC-Track': 'opens,clicks'
    },
    important: true,
    track_opens: true,
    track_clicks: true,
    auto_text: true,
    auto_html: false,
    inline_css: true,
    tags: ['welcome', 'single-recipient', 'ruby'],
    metadata: {
      user_id: '12345',
      campaign: 'welcome-series',
      language: 'ruby'
    }
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    
    puts 'Advanced email sent successfully!'
    puts '=' * 50
    
    if result && result.length > 0
      first_result = result[0]
      puts "Status: #{first_result['status']}"
      puts "Email: #{first_result['email']}"
      puts "Message ID: #{first_result['_id']}"
    end
    
    puts '=' * 50
    result
  rescue MailchimpTransactional::ApiError => e
    puts 'Error sending advanced email!'
    puts '=' * 50
    puts "Mandrill API Error: #{e.message}"
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
  
  puts 'Sending basic email...'
  send_email(mailchimp, message)
  
  puts "\n"
  
  # Uncomment to test advanced options
  # puts 'Sending email with advanced options...'
  # send_email_with_advanced_options(mailchimp)
end

