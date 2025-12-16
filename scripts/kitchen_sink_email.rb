#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# Kitchen Sink - Comprehensive Email with All Features
# ==============================================================================
#
# This script demonstrates a comprehensive Mailchimp Transactional (Mandrill)
# message exercising many available settings in one example.
#
# @author Mandrill Use Cases
# @version 1.0.0
#
# Usage:
#   ruby kitchen_sink_email.rb
#   bundle exec ruby kitchen_sink_email.rb
#
# Requirements:
#   - mailchimp-transactional (~> 1.0)
#   - dotenv (~> 2.8)
#
# Install with:
#   gem install MailchimpTransactional dotenv
# ==============================================================================

require 'MailchimpTransactional'
require 'dotenv/load'
require 'base64'
require 'time'

# Initialize the Mandrill API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

##
# Read a local file and return a Base64-encoded string.
#
# @param file_path [String] Path to the file to read
# @return [String, nil] Base64-encoded string or nil if file not found
#
def read_file_as_base64(file_path)
  return nil unless File.exist?(file_path)
  
  File.open(file_path, 'rb') do |file|
    Base64.strict_encode64(file.read)
  end
rescue => e
  puts "Warning: Could not read #{file_path}: #{e.message}"
  nil
end

##
# Send a comprehensive email demonstrating all major Mandrill features.
#
# This method showcases:
# - HTML and plain text content
# - Merge variables (global and recipient-specific)
# - Attachments
# - Tracking options
# - Tags and metadata
# - Custom headers
# - Advanced options
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
def send_kitchen_sink(mailchimp)
  # Prepare attachments
  attachments = []
  sample_pdf_path = File.join(__dir__, 'sample.pdf')
  if File.exist?(sample_pdf_path)
    pdf_content = read_file_as_base64(sample_pdf_path)
    attachments << {
      type: 'application/pdf',
      name: 'sample.pdf',
      content: pdf_content
    } if pdf_content
  end
  
  # Inline images (empty for this demo)
  images = []
  
  # Complete Mandrill message with ALL features
  message = {
    # ========== Content ==========
    html: %{
      <h1>Hello {{fname}}!</h1>
      <p>This email demonstrates multiple Transactional API features.</p>
      <p><strong>Company:</strong> {{company_name}}</p>
      <p><strong>Account:</strong> {{account_id}}</p>
      <div style="width: 50px; height: 50px; background: #007bff; border: 2px solid #0056b3; display: inline-block;"></div>
      <p>This is a comprehensive demonstration of the Mandrill API capabilities in Ruby.</p>
    },
    text: %{Hello {{fname}}!

This email demonstrates multiple Transactional API features.
Company: {{company_name}}
Account: {{account_id}}

This is a comprehensive demonstration of the Mandrill API capabilities in Ruby.
    },
    
    # ========== Basic Fields ==========
    subject: 'Hello {{fname}} - Mandrill Features Demo',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    
    # ========== All Recipient Types ==========
    to: [
      {
        email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
        type: 'to'
      }
    ],
    # Uncomment to add CC and BCC recipients
    # cc: [
    #   { email: 'cc@example.com', name: 'CC User', type: 'cc' }
    # ],
    # bcc: [
    #   { email: 'bcc@example.com', name: 'BCC User', type: 'bcc' }
    # ],
    
    # ========== Headers ==========
    headers: {
      'Reply-To' => ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
      'X-Custom-Header' => 'Mandrill-Demo-Ruby',
      'X-Priority' => '1'
    },
    
    # ========== Merge Variables ==========
    # Global variables - apply to all recipients
    global_merge_vars: [
      { name: 'company_name', content: 'Intuit Developer Program' }
    ],
    # Recipient-specific variables
    merge_vars: [
      {
        rcpt: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        vars: [
          { name: 'fname', content: 'John' },
          { name: 'account_id', content: 'ACC-001' }
        ]
      }
    ],
    merge_language: 'handlebars',
    
    # ========== Attachments and Images ==========
    attachments: attachments,
    images: images,
    
    # ========== Tracking Options ==========
    track_opens: true,           # Track email opens
    track_clicks: true,          # Track link clicks
    auto_text: true,             # Auto-generate text version from HTML
    auto_html: false,            # Don't auto-generate HTML from text
    inline_css: true,            # Inline CSS for better email client support
    url_strip_qs: false,         # Keep query strings in URLs
    preserve_recipients: false,  # Don't show all recipients to each other
    view_content_link: true,     # Include "view in browser" link
    
    # ========== Tags and Metadata ==========
    tags: ['demo', 'kitchen-sink', 'features', 'ruby'],
    metadata: {
      campaign: 'mandrill-demo',
      version: '2.0',
      language: 'ruby',
      environment: 'development'
    },
    
    # ========== Advanced Options ==========
    important: true,             # Mark as important
    async: false                 # Send synchronously (wait for result)
    # ip_pool: 'Main Pool',      # Specify IP pool (if using dedicated IPs)
    # subaccount: 'subacct_id',  # Specify subaccount
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    
    puts 'Kitchen Sink email sent successfully!'
    puts '=' * 70
    
    if result.is_a?(Array)
      result.each do |r|
        puts "Recipient: #{r['email']}"
        puts "  Status: #{r['status']}"
        puts "  Message ID: #{r['_id']}" if r['_id']
        puts "  Reject Reason: #{r['reject_reason']}" if r['reject_reason']
        puts ''
      end
    else
      puts "Unexpected result structure: #{result}"
    end
    
    puts '=' * 70
    result
  rescue MailchimpTransactional::ApiError => e
    puts 'Error sending kitchen sink email!'
    puts '=' * 70
    puts "Mandrill API Error: #{e.message}"
    puts '=' * 70
    nil
  end
end

##
# Send a comprehensive email scheduled for future delivery.
#
# Demonstrates the send_at parameter for scheduling emails.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
def send_scheduled_kitchen_sink(mailchimp)
  # Schedule for 1 hour from now (3600 seconds)
  send_at_time = Time.now.utc + 3600
  send_at = send_at_time.strftime('%Y-%m-%d %H:%M:%S')
  
  message = {
    html: '<h1>Scheduled Email</h1><p>This was scheduled in advance, {{fname}}!</p>',
    text: "Scheduled Email\n\nThis was scheduled in advance, {{fname}}!",
    subject: 'Scheduled: {{subject_line}}',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: 'Scheduled Sender',
    to: [
      {
        email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        type: 'to'
      }
    ],
    global_merge_vars: [
      { name: 'subject_line', content: 'Your Scheduled Message' }
    ],
    merge_vars: [
      {
        rcpt: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        vars: [
          { name: 'fname', content: 'Future Reader' }
        ]
      }
    ],
    merge_language: 'handlebars',
    track_opens: true,
    track_clicks: true,
    tags: ['scheduled', 'kitchen-sink', 'ruby'],
    send_at: send_at  # UTC datetime string
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    
    puts 'Email scheduled successfully!'
    puts '=' * 70
    puts "Scheduled for: #{send_at} UTC"
    puts "Local time: #{send_at_time.localtime}"
    puts ''
    
    result.each { |r| puts "#{r['email']}: #{r['status']}" }
    
    puts '=' * 70
    result
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
end

##
# Send email with all recipient types: TO, CC, and BCC.
#
# Demonstrates how to send to multiple recipients with different visibility.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
def send_with_all_recipient_types(mailchimp)
  message = {
    html: '<h1>Email with Multiple Recipient Types</h1><p>This demonstrates TO, CC, and BCC.</p>',
    subject: 'Multiple Recipient Types Demo',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: 'Demo Sender',
    # Primary recipient
    to: [
      { email: 'primary@example.org', name: 'Primary Recipient', type: 'to' }
    ],
    # Carbon copy - visible to all
    cc: [
      { email: 'cc@example.org', name: 'CC Recipient', type: 'cc' }
    ],
    # Blind carbon copy - hidden from others
    bcc: [
      { email: 'bcc@example.org', name: 'BCC Recipient', type: 'bcc' }
    ],
    tags: ['demo', 'multiple-recipients'],
    preserve_recipients: true  # Show all recipients (except BCC) in headers
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    puts 'Email with multiple recipient types sent!'
    result.each { |r| puts "  #{r['email']}: #{r['status']}" }
    result
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
end

# ==============================================================================
# Main Execution
# ==============================================================================

if __FILE__ == $0
  # Validate API key configuration
  unless ENV['MANDRILL_API_KEY']
    puts 'Error: MANDRILL_API_KEY not found in environment variables!'
    puts 'Please create a .env file with your Mandrill API key.'
    exit 1
  end
  
  puts 'Sending comprehensive kitchen sink email...'
  puts ''
  send_kitchen_sink(mailchimp)
  
  # Uncomment to test scheduled sending
  # puts "\n\nScheduling kitchen sink email..."
  # puts ''
  # send_scheduled_kitchen_sink(mailchimp)
  
  # Uncomment to test all recipient types
  # puts "\n\nSending with all recipient types..."
  # puts ''
  # send_with_all_recipient_types(mailchimp)
end

