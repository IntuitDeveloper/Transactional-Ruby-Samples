#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# Send Email with Attachments using Mandrill API
# ==============================================================================
#
# This script demonstrates how to attach files to emails sent via
# Mailchimp Transactional (Mandrill).
#
# @author Mandrill Use Cases
# @version 1.0.0
#
# Usage:
#   ruby email_with_attachments.rb
#   bundle exec ruby email_with_attachments.rb
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
# @return [String, nil] Base64-encoded string of the file contents, or nil if file not found
#
# @example Read and encode a PDF file
#   content = read_file_as_base64('document.pdf')
#
def read_file_as_base64(file_path)
  return nil unless File.exist?(file_path)
  
  File.open(file_path, 'rb') do |file|
    Base64.strict_encode64(file.read)
  end
rescue => e
  puts "Warning: Could not read file #{file_path}: #{e.message}"
  nil
end

##
# Send an email with file attachments.
#
# Demonstrates attaching both local files and dynamically generated content.
# Total message size (including attachments) must not exceed 25MB.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
def send_with_attachments(mailchimp)
  # Prepare attachments array
  attachments = []
  
  # Attach a local PDF file if it exists
  sample_pdf_path = File.join(__dir__, 'sample.pdf')
  if File.exist?(sample_pdf_path)
    pdf_content = read_file_as_base64(sample_pdf_path)
    if pdf_content
      attachments << {
        type: 'application/pdf',
        name: 'sample.pdf',
        content: pdf_content
      }
      puts "Added PDF attachment: sample.pdf"
    end
  else
    puts "Note: sample.pdf not found, skipping PDF attachment"
  end
  
  # Create a text file attachment dynamically
  text_content = [
    'This is a demo text file created by the Mandrill Use Case.',
    '',
    "Generated at: #{Time.now.iso8601}",
    'This file was created using Ruby.',
    '',
    'Thank you for using Mandrill!'
  ].join("\n")
  
  attachments << {
    type: 'text/plain',
    name: 'readme.txt',
    content: Base64.strict_encode64(text_content)
  }
  
  # Construct the message with attachments
  message = {
    html: %{
      <h1>Your Documents</h1>
      <p>Please find the attached files for your review.</p>
      <ul>
        <li>Sample PDF document (if available)</li>
        <li>Readme text file</li>
      </ul>
      <p>These files have been sent via Mandrill Transactional Email.</p>
    },
    text: 'Your documents are attached. Please review them at your convenience.',
    subject: 'Documents Attached',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    to: [
      {
        email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
        type: 'to'
      }
    ],
    attachments: attachments,
    tags: ['attachments', 'outbound-documents']
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    
    puts ''
    puts 'Email with attachments sent successfully!'
    puts '=' * 50
    puts "Number of attachments: #{attachments.length}"
    puts ''
    
    if result.is_a?(Array)
      result.each do |r|
        puts "#{r['email']}: #{r['status']}"
        puts "  Message ID: #{r['_id']}" if r['_id']
      end
    else
      puts "Unexpected result structure: #{result}"
    end
    
    puts '=' * 50
    result
  rescue MailchimpTransactional::ApiError => e
    puts 'Error sending email with attachments!'
    puts '=' * 50
    puts "Mandrill API Error: #{e.message}"
    puts '=' * 50
    nil
  end
end

##
# Send an email with a dynamically created CSV attachment.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
def send_csv_attachment(mailchimp)
  # Create CSV content
  csv_content = [
    'Name,Email,Status,Joined',
    'John Smith,john@example.org,Active,2024-01-15',
    'Jane Doe,jane@example.org,Active,2024-02-20',
    'Bob Johnson,bob@example.org,Pending,2024-03-10'
  ].join("\n")
  
  attachments = [{
    type: 'text/csv',
    name: 'user_report.csv',
    content: Base64.strict_encode64(csv_content)
  }]
  
  message = {
    html: '<h1>User Report</h1><p>Please find the attached CSV report.</p>',
    text: 'User Report - CSV file attached.',
    subject: 'User Report - CSV Attached',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: 'Report Service',
    to: [
      {
        email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        type: 'to'
      }
    ],
    attachments: attachments,
    tags: ['report', 'csv']
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    puts 'CSV report email sent successfully!'
    result.each { |r| puts "#{r['email']}: #{r['status']}" }
    result
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
end

##
# Send an email with a JSON attachment.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
def send_json_attachment(mailchimp)
  require 'json'
  
  # Create JSON data
  data = {
    status: 'success',
    total_users: 42,
    active_users: 38,
    timestamp: Time.now.iso8601,
    users: [
      { name: 'John', email: 'john@example.org' },
      { name: 'Jane', email: 'jane@example.org' }
    ]
  }
  
  json_content = JSON.pretty_generate(data)
  
  attachments = [{
    type: 'application/json',
    name: 'data.json',
    content: Base64.strict_encode64(json_content)
  }]
  
  message = {
    html: '<h1>API Response Data</h1><p>JSON data file attached.</p>',
    subject: 'API Data Export',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    to: [{ email: ENV['DEFAULT_TO_EMAIL'] || 'test@example.org', type: 'to' }],
    attachments: attachments,
    tags: ['api', 'json']
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    puts 'JSON attachment email sent successfully!'
    result.each { |r| puts "#{r['email']}: #{r['status']}" }
    result
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
end

# ==============================================================================
# MIME Type Helper
# ==============================================================================

##
# Hash mapping file extensions to MIME types.
# Use for determining the correct MIME type based on file extension.
#
MIME_TYPES = {
  '.pdf' => 'application/pdf',
  '.doc' => 'application/msword',
  '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  '.xls' => 'application/vnd.ms-excel',
  '.xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  '.png' => 'image/png',
  '.jpg' => 'image/jpeg',
  '.jpeg' => 'image/jpeg',
  '.gif' => 'image/gif',
  '.txt' => 'text/plain',
  '.csv' => 'text/csv',
  '.json' => 'application/json',
  '.zip' => 'application/zip'
}.freeze

##
# Get the MIME type for a given filename based on its extension.
#
# @param filename [String] The filename with extension
# @return [String] The MIME type string
#
# @example Get MIME type
#   get_mime_type('document.pdf') #=> 'application/pdf'
#
def get_mime_type(filename)
  ext = File.extname(filename).downcase
  MIME_TYPES[ext] || 'application/octet-stream'
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
  
  puts 'Sending email with attachments...'
  send_with_attachments(mailchimp)
  
  # Uncomment to test CSV attachment
  # puts "\n\nSending CSV attachment..."
  # send_csv_attachment(mailchimp)
  
  # Uncomment to test JSON attachment
  # puts "\n\nSending JSON attachment..."
  # send_json_attachment(mailchimp)
end

