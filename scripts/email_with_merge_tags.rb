#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# Send Email with Merge Tags using Mandrill API
# ==============================================================================
#
# This script demonstrates how to personalize emails using merge tags for
# dynamic content like names, order information, and custom data.
#
# @author Mandrill Use Cases
# @version 1.0.0
#
# Usage:
#   ruby email_with_merge_tags.rb
#   bundle exec ruby email_with_merge_tags.rb
#
# Requirements:
#   - mailchimp-transactional (~> 1.0)
#   - dotenv (~> 2.8)
#
# Install with:
#   gem install MailchimpTransactional dotenv
#   
# Or with Bundler:
#   bundle install
# ==============================================================================

require 'MailchimpTransactional'
require 'dotenv/load'

# Initialize the Mandrill API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

##
# Send a personalized email using merge tags for dynamic content.
#
# This method demonstrates both global merge variables (applied to all recipients)
# and recipient-specific merge variables (unique to each recipient).
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param message [Hash] The message hash containing email content and merge data
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
# @example Send personalized email
#   result = send_personalized_email(mailchimp, message)
#   result[0]['status'] #=> "sent"
#
def send_personalized_email(mailchimp, message)
  begin
    # Send the message with merge variables
    result = mailchimp.messages.send({ message: message })
    
    puts 'Personalized email sent successfully!'
    puts '=' * 50
    
    # Process results for each recipient
    if result.is_a?(Array)
      result.each do |recipient|
        puts "#{recipient['email']}: #{recipient['status']}"
        puts "  Message ID: #{recipient['_id']}" if recipient['_id']
        puts "  Reject Reason: #{recipient['reject_reason']}" if recipient['reject_reason']
      end
    else
      puts "Unexpected result structure: #{result}"
    end
    
    puts '=' * 50
    result
  rescue MailchimpTransactional::ApiError => e
    puts 'Error sending personalized email!'
    puts '=' * 50
    puts "Mandrill API Error: #{e.message}"
    puts '=' * 50
    nil
  end
end

##
# Send personalized emails to multiple recipients with different merge data.
#
# Each recipient receives an email with their own personalized content based
# on their recipient-specific merge variables, while sharing global variables.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
def send_to_multiple_recipients(mailchimp)
  message = {
    html: %{
      <h1>Welcome {{fname}}!</h1>
      <p>Your account {{account_id}} is now active.</p>
      <p>Membership: {{membership_level}}</p>
      <p>Join us at {{company_name}}!</p>
    },
    subject: 'Welcome {{fname}} to {{company_name}}!',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    to: [
      {
        email: 'john@example.org',
        name: 'John Smith',
        type: 'to'
      },
      {
        email: 'jane@example.org',
        name: 'Jane Doe',
        type: 'to'
      }
    ],
    # Global variables apply to all recipients
    global_merge_vars: [
      { name: 'company_name', content: 'Intuit Developer Program' }
    ],
    # Recipient-specific variables - unique to each recipient
    merge_vars: [
      {
        rcpt: 'john@example.org',
        vars: [
          { name: 'fname', content: 'John' },
          { name: 'account_id', content: 'ACC-001' },
          { name: 'membership_level', content: 'Premium' }
        ]
      },
      {
        rcpt: 'jane@example.org',
        vars: [
          { name: 'fname', content: 'Jane' },
          { name: 'account_id', content: 'ACC-002' },
          { name: 'membership_level', content: 'Standard' }
        ]
      }
    ],
    merge_language: 'handlebars'
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    
    puts 'Batch personalized emails sent!'
    puts '=' * 50
    
    result.each do |recipient|
      puts "#{recipient['email']}: #{recipient['status']}"
    end
    
    puts '=' * 50
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
  
  # Construct the personalized message with merge tags
  message = {
    # HTML content with merge tags using Handlebars syntax
    html: %{
      <h1>Welcome {{fname}}!</h1>
      <p>Hi {{fname}} {{lname}},</p>
      <p>Thanks for joining the {{company_name}}! Your account is now active.</p>
      <p>Your membership level: {{membership_level}}</p>
      <p>Best regards,<br>The {{company_name}} Team</p>
    },
    # Plain text version with merge tags
    text: %{
      Welcome {{fname}}!
      
      Hi {{fname}} {{lname}},
      
      Thanks for joining the {{company_name}}! Your account is now active.
      Your membership level: {{membership_level}}
      
      Best regards,
      The {{company_name}} Team
    },
    # Subject line with merge tags
    subject: 'Welcome to {{company_name}}, {{fname}}!',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    to: [{
      email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
      name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
      type: 'to'
    }],
    headers: {
      'Reply-To' => ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org'
    },
    # Global merge variables - applied to all recipients
    global_merge_vars: [
      {
        name: 'company_name',
        content: ENV['MERGE_COMPANY_NAME'] || 'Intuit Developer Program'
      },
      {
        name: 'membership_level',
        content: ENV['MERGE_MEMBERSHIP_LEVEL'] || 'Premium'
      }
    ],
    # Recipient-specific merge variables - unique to each recipient
    merge_vars: [
      {
        rcpt: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        vars: [
          {
            name: 'fname',
            content: ENV['MERGE_FIRST_NAME'] || 'John'
          },
          {
            name: 'lname',
            content: ENV['MERGE_LAST_NAME'] || 'Smith'
          }
        ]
      }
    ],
    # Merge language: 'handlebars' (recommended) or 'mailchimp'
    merge_language: 'handlebars'
  }
  
  puts 'Sending personalized email with merge tags...'
  puts ''
  send_personalized_email(mailchimp, message)
  
  # Uncomment to test multiple recipients
  # puts "\n\nSending to multiple recipients..."
  # puts ''
  # send_to_multiple_recipients(mailchimp)
end

