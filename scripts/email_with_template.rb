#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# Send Email Using Stored Template with Mandrill API
# ==============================================================================
#
# This script demonstrates how to send emails using pre-created templates
# with merge tags and dynamic content.
#
# @author Mandrill Use Cases
# @version 1.0.0
#
# Usage:
#   ruby email_with_template.rb
#   bundle exec ruby email_with_template.rb
#
# Requirements:
#   - mailchimp-transactional (~> 1.0)
#   - dotenv (~> 2.8)
#
# Note: You must first create a template using create_template.rb or via the
#       Mandrill UI before running this script.
#
# Install with:
#   gem install MailchimpTransactional dotenv
# ==============================================================================

require 'MailchimpTransactional'
require 'dotenv/load'

# Initialize the Mandrill API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

##
# Send an email using a stored Mandrill template.
#
# This method demonstrates how to use pre-created templates with merge tags
# and editable content regions (mc:edit).
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name/slug of the template to use
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
# @example Send with template
#   result = send_with_template(mailchimp, 'hello-template')
#   result[0]['status'] #=> "sent"
#
def send_with_template(mailchimp, template_name)
  # Message configuration - can override template defaults
  message = {
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    subject: (
      if template_name == 'hello-template'
        'Welcome, {{fname}}'
      else
        'Payment for invoice is requested'
      end),
    
    to: [
      {
        email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
        type: 'to'
      }
    ],
    # If template_name is 'hello-template', use the standard demo values
    global_merge_vars: (
      if template_name == 'hello-template'
        [
          { name: 'company_name', content: 'Intuit Developer Program' }
        ]
      else
        [
          { name: 'company_name', content: 'Quickbooks Online for Developers' }
        ]
      end
    ),
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
    tags: ['onboarding', 'welcome']
  }
  #--------------------------------------------------
  # Template content - replaces mc:edit regions in the template
  template_content = [
    if template_name == 'hello-template'
      {
        name: 'welcome_message',
        content: '<p>Thanks for joining <strong>{{company_name}}</strong>! We\'re excited to have you on board.</p>'
      }
    else
      {
        name: 'welcome_message',
        content: '<p>Welcome to <strong>{{company_name}}</strong>! This is a test invoice email.</p>'
      }
    end
  ]
  
  begin
    # Send using the template
    result = mailchimp.messages.send_template({
      template_name: template_name,
      template_content: template_content,
      message: message
    })
    
    puts 'Template-based email sent successfully!'
    puts '=' * 50
    
    if result.is_a?(Array)
      result.each do |r|
        puts "   #{r['email']}: #{r['status']}"
        puts "      Message ID: #{r['_id']}" if r['_id']
        puts "      Reject Reason: #{r['reject_reason']}" if r['reject_reason']
      end
    else
      puts "Unexpected result structure: #{result}"
    end
    
    puts '=' * 50
    result
  rescue MailchimpTransactional::ApiError => e
    puts 'Error sending template-based email!'
    puts '=' * 50
    puts "Mandrill API Error: #{e.message}"
    
    # Provide helpful error message for missing templates
    if e.message.include?('Unknown_Template')
      puts ''
      puts "Template '#{template_name}' does not exist."
      puts 'Please create it first using create_template.rb or via the Mandrill UI.'
    end
    
    puts '=' * 50
    nil
  end
end

##
# Send a template-based email to multiple recipients with personalized data.
#
# Each recipient receives the same template but with their own merge variables
# for personalization.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name/slug of the template to use
# @return [Array<Hash>, nil] Array of result hashes or nil on error
#
def send_template_to_multiple_recipients(mailchimp, template_name = 'hello-template')
  message = {
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: 'Welcome Team',
    subject: 'Welcome {{fname}} to {{company_name}}',
    to: [
      { email: 'user1@example.org', name: 'User One', type: 'to' },
      { email: 'user2@example.org', name: 'User Two', type: 'to' }
    ],
    global_merge_vars: [
      { name: 'company_name', content: 'Intuit Developer Program' }
    ],
    merge_vars: [
      {
        rcpt: 'user1@example.org',
        vars: [
          { name: 'fname', content: 'Alice' },
          { name: 'account_id', content: 'ACC-101' }
        ]
      },
      {
        rcpt: 'user2@example.org',
        vars: [
          { name: 'fname', content: 'Bob' },
          { name: 'account_id', content: 'ACC-102' }
        ]
      }
    ],
    merge_language: 'handlebars',
    track_opens: true,
    track_clicks: true,
    tags: ['welcome', 'batch-send']
  }
  
  template_content = [
    {
      name: 'welcome_message',
      content: '<p>Your personalized welcome message!</p>'
    }
  ]
  
  begin
    result = mailchimp.messages.send_template({
      template_name: template_name,
      template_content: template_content,
      message: message
    })
    
    puts 'Batch template emails sent!'
    puts '=' * 50
    
    result.each { |r| puts "   #{r['email']}: #{r['status']}" }
    
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
  
  # Use SELECTED_TEMPLATE from environment (set by web UI) or default
  template_name = ENV['SELECTED_TEMPLATE'] || 'hello-template'
  
  puts "Sending email with stored template: #{template_name}"
  puts ''
  send_with_template(mailchimp, template_name)
  
  # Uncomment to test multiple recipients
  # puts "\n\nSending template to multiple recipients..."
  # puts ''
  # send_template_to_multiple_recipients(mailchimp, template_name)
end

