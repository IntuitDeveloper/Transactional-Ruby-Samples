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
# Note: Templates will be automatically created if they don't exist.
#
# Install with:
#   gem install MailchimpTransactional dotenv
# ==============================================================================

require 'MailchimpTransactional'
require 'dotenv/load'

# Initialize the Mandrill API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

# Template definitions matching the Mandrill account
TEMPLATES = {
  'hello-template' => {
    name: 'hello-template',
    subject: 'Hello {{fname}}!',
    code: '<h1>Hello {{fname}}!</h1>
      <div mc:edit="welcome_message">
        <p>Welcome to {{company_name}}.</p>
      </div>
      <p>Your account: {{account_id}}</p>',
    text: "Hello {{fname}}!\n\nWelcome to {{company_name}}.\nYour account: {{account_id}}",
    labels: ['demo', 'hello'],
    mc_edit_region: 'welcome_message'
  },
  'qbo-invoice-template' => {
    name: 'qbo-invoice-template',
    subject: 'Payment for invoice is requested',
    code: '<h1>Hi {{fname}},</h1><br/>DUE End of this month<br/>Bill to:{{fname}} 
      <div mc:edit="welcome_message">
        <p>Welcome to {{company_name}}.</p>
      </div>
      <br/>Powered by QuickBooks<br/>We appreciate your business! Payment for this invoice is due on month end for account {{account_id}}.<br/>If you have any questions or need help, just let us know.<br/>Best,<br/>QBO team',
    text: "Hi {{fname}},\nDUE End of this month\nBill to:{{fname}}\n\nWelcome to {{company_name}}.\n\nPowered by QuickBooks\nWe appreciate your business! Payment for this invoice is due on month end for account {{account_id}}.\nIf you have any questions or need help, just let us know.\nBest,\nQBO team",
    labels: ['html', 'invoice', 'qbo'],
    mc_edit_region: 'welcome_message'
  }
}.freeze

##
# Check if a template exists in Mandrill.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name of the template to check
# @return [Boolean] True if template exists
#
def template_exists?(mailchimp, template_name)
  templates = mailchimp.templates.list({ label: '' })
  templates.any? { |t| t['name'] == template_name }
rescue MailchimpTransactional::ApiError
  false
end

##
# Ensure a template exists, creating it if necessary.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name of the template to ensure exists
# @return [Boolean] True if template exists or was created successfully
#
def ensure_template_exists(mailchimp, template_name)
  if template_exists?(mailchimp, template_name)
    puts "Template '#{template_name}' already exists."
    return true
  end

  template_def = TEMPLATES[template_name]
  unless template_def
    puts "Unknown template: #{template_name}"
    return false
  end

  template_data = {
    name: template_def[:name],
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    subject: template_def[:subject],
    code: template_def[:code],
    text: template_def[:text],
    publish: false,
    labels: template_def[:labels]
  }

  begin
    mailchimp.templates.add(template_data)
    puts "Template '#{template_name}' created successfully!"
    true
  rescue MailchimpTransactional::ApiError => e
    puts "Error creating template: #{e.message}"
    false
  end
end

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
#   result = send_with_template(mailchimp, 'template1')
#   result[0]['status'] #=> "sent"
#
def send_with_template(mailchimp, template_name)
  # Ensure template exists before sending
  unless ensure_template_exists(mailchimp, template_name)
    puts "Failed to ensure template '#{template_name}' exists."
    return nil
  end

  template_def = TEMPLATES[template_name] || TEMPLATES['template1']

  # Message configuration - can override template defaults
  message = {
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    subject: 'Welcome, {{fname}}',
    to: [
      {
        email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
        type: 'to'
      }
    ],
    global_merge_vars: [
      { name: 'company_name', content: 'Intuit Developer Program' }
    ],
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

  # Template content - replaces mc:edit regions in the template
  # Both templates use welcome_message as the mc:edit region
  template_content = if template_name == 'hello-template'
    [
      {
        name: 'welcome_message',
        content: '<p>Thanks for joining <strong>{{company_name}}</strong>! We\'re excited to have you on board.</p>'
      }
    ]
  else
    [
      {
        name: 'welcome_message',
        content: '<p>Welcome to <strong>{{company_name}}</strong>! This is a test invoice email for account {{account_id}}.</p>'
      }
    ]
  end

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
def send_template_to_multiple_recipients(mailchimp, template_name = 'template1')
  # Ensure template exists before sending
  unless ensure_template_exists(mailchimp, template_name)
    puts "Failed to ensure template '#{template_name}' exists."
    return nil
  end

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
  template_name = ENV['SELECTED_TEMPLATE'] || 'template1'

  puts "Sending email with stored template: #{template_name}"
  puts ''
  send_with_template(mailchimp, template_name)

  # Uncomment to test multiple recipients
  # puts "\n\nSending template to multiple recipients..."
  # puts ''
  # send_template_to_multiple_recipients(mailchimp, template_name)
end
