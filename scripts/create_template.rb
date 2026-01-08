#!/usr/bin/env ruby
# frozen_string_literal: true

# ==============================================================================
# Create Email Template using Mandrill API
# ==============================================================================
#
# This script demonstrates how to create reusable email templates
# in Mandrill that can be used with messages.send_template().
#
# @author Mandrill Use Cases
# @version 1.0.0
#
# Usage:
#   ruby create_template.rb
#   bundle exec ruby create_template.rb
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
    labels: ['demo', 'hello']
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
    labels: ['html', 'invoice', 'qbo']
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
# Create a template if it doesn't already exist.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name of the template to create
# @return [Hash] Result hash with success status
#
def create_template(mailchimp, template_name)
  if template_exists?(mailchimp, template_name)
    puts "Template '#{template_name}' already exists."
    return { success: true, exists: true }
  end

  template_def = TEMPLATES[template_name]
  unless template_def
    puts "Unknown template: #{template_name}"
    return { success: false, error: "Unknown template: #{template_name}" }
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
    response = mailchimp.templates.add(template_data)

    puts 'Template created successfully!'
    puts '=' * 50
    puts "Name: #{response['name']}"
    puts "Slug: #{response['slug']}"
    puts "Created at: #{response['created_at'] || 'N/A'}"

    if response['publish_name']
      puts "Published as: #{response['publish_name']}"
    else
      puts 'Status: Draft (not published)'
    end

    puts '=' * 50
    { success: true, exists: false, result: response }
  rescue MailchimpTransactional::ApiError => e
    puts 'Error creating template!'
    puts '=' * 50
    puts "Mandrill API Error: #{e.message}"
    puts '=' * 50
    { success: false, error: e.message }
  end
end

##
# Ensure a template exists, creating it if necessary.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name of the template to ensure exists
# @return [Boolean] True if template exists or was created successfully
#
def ensure_template_exists(mailchimp, template_name)
  result = create_template(mailchimp, template_name)
  result[:success]
end

##
# List all templates in your Mandrill account.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Array<Hash>, nil] Array of template hashes or nil on error
#
def list_templates(mailchimp)
  begin
    templates = mailchimp.templates.list({ label: '' })

    puts 'Your Mandrill Templates:'
    puts '=' * 50
    puts "Total templates: #{templates.length}"
    puts ''

    templates.each do |template|
      puts "  • #{template['name']}"
      puts "    Slug: #{template['slug']}"
      puts "    Labels: #{template['labels'].join(', ')}" if template['labels']&.any?
      puts ''
    end

    puts '=' * 50
    templates
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
end

##
# Get detailed information about a specific template.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name/slug of the template
# @return [Hash, nil] Template information hash or nil on error
#
def get_template_info(mailchimp, template_name)
  begin
    info = mailchimp.templates.info({ name: template_name })

    puts 'Template Information:'
    puts '=' * 50
    puts "Name: #{info['name']}"
    puts "Subject: #{info['subject']}"
    puts "From: #{info['from_name']} <#{info['from_email']}>"
    puts "Created: #{info['created_at'] || 'N/A'}"
    puts "Updated: #{info['updated_at'] || 'N/A'}"

    if info['labels']&.any?
      puts "Labels: #{info['labels'].join(', ')}"
    end

    puts '=' * 50
    info
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
end

##
# Delete a template (use with caution).
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name/slug of the template to delete
# @return [Hash, nil] Deletion response or nil on error
#
def delete_template(mailchimp, template_name)
  begin
    response = mailchimp.templates.delete({ name: template_name })
    puts "Template deleted: #{template_name}"
    response
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

  puts 'Creating email templates...'
  puts ''

  # Create hello-template
  puts 'Creating hello-template...'
  create_template(mailchimp, 'hello-template')

  # Create qbo-invoice-template
  puts "\nCreating qbo-invoice-template..."
  create_template(mailchimp, 'qbo-invoice-template')

  puts "\n\nListing all templates..."
  puts ''
  list_templates(mailchimp)
end
