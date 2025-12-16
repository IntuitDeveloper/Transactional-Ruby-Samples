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

##
# Create a basic email template in Mandrill.
#
# Templates can include merge tags and editable regions (mc:edit) for
# dynamic content when sending emails.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Hash, nil] The created template hash or nil on error
#
# @example Create a template
#   template = create_template(mailchimp)
#   template['name'] #=> "hello-template"
#
def create_template(mailchimp)
  template_data = {
    name: 'hello-template',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    subject: 'Hello {{fname}}!',
    # HTML code with merge tags and editable regions
    code: %{
      <h1>Hello {{fname}}!</h1>
      <div mc:edit="welcome_message">
        <p>Welcome to {{company_name}}.</p>
      </div>
      <p>Your account: {{account_id}}</p>
    },
    # Plain text version
    text: "Hello {{fname}}!\n\nWelcome to {{company_name}}.\nYour account: {{account_id}}",
    # false = draft, true = published
    publish: false,
    # Labels for organization
    labels: ['hello', 'demo']
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
    response
  rescue MailchimpTransactional::ApiError => e
    puts 'Error creating template!'
    puts '=' * 50
    puts "Mandrill API Error: #{e.message}"
    
    # Provide helpful error message for duplicate templates
    if e.message.include?('A template with that name already exists')
      puts ''
      puts 'A template with this name already exists.'
      puts 'Try using a different name or delete the existing template.'
    end
    
    puts '=' * 50
    nil
  end
end

##
# Create a template with advanced features and styling.
#
# Includes responsive CSS, multiple editable regions, and comprehensive
# HTML structure.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @return [Hash, nil] The created template hash or nil on error
#
def create_advanced_template(mailchimp)
  template_data = {
    name: 'welcome-email-advanced',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'welcome@example.org',
    from_name: 'Welcome Team',
    subject: 'Welcome {{fname}} - Get Started with {{company_name}}',
    code: %{
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; }
          .header { background: #007bff; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; max-width: 600px; margin: 0 auto; }
          .button { 
            background: #28a745; 
            color: white; 
            padding: 12px 24px; 
            text-decoration: none;
            border-radius: 5px;
            display: inline-block;
            margin: 10px 0;
          }
          .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; }
          @media only screen and (max-width: 600px) {
            .content { padding: 10px; }
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Welcome to {{company_name}}!</h1>
        </div>
        <div class="content">
          <h2>Hi {{fname}} {{lname}},</h2>
          <div mc:edit="main_content">
            <p>We're thrilled to have you join us! Your account is now active and ready to use.</p>
            <p>Account ID: <strong>{{account_id}}</strong></p>
          </div>
          <div mc:edit="cta_section">
            <p><a href="{{dashboard_url}}" class="button">Go to Dashboard</a></p>
          </div>
        </div>
        <div class="footer">
          <p>&copy; {{current_year}} {{company_name}}. All rights reserved.</p>
          <p><a href="{{unsubscribe_url}}" style="color: #666;">Unsubscribe</a></p>
        </div>
      </body>
      </html>
    },
    text: %{
      Welcome to {{company_name}}!
      
      Hi {{fname}} {{lname}},
      
      We're thrilled to have you join us! Your account is now active and ready to use.
      Account ID: {{account_id}}
      
      Go to your dashboard: {{dashboard_url}}
      
      © {{current_year}} {{company_name}}. All rights reserved.
      Unsubscribe: {{unsubscribe_url}}
    },
    publish: false,
    labels: ['welcome', 'onboarding', 'advanced']
  }
  
  begin
    response = mailchimp.templates.add(template_data)
    puts "Advanced template created: #{response['name']}"
    response
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
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
# Update an existing template.
#
# @param mailchimp [MailchimpTransactional::Client] The initialized Mandrill client
# @param template_name [String] The name/slug of the template to update
# @param updates [Hash] Hash of fields to update
# @return [Hash, nil] Updated template hash or nil on error
#
def update_template(mailchimp, template_name, updates)
  begin
    update_data = { name: template_name }.merge(updates)
    response = mailchimp.templates.update(update_data)
    puts "Template updated: #{response['name']}"
    response
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
  
  puts 'Creating email template...'
  puts ''
  create_template(mailchimp)
  
  puts "\n\nListing all templates..."
  puts ''
  list_templates(mailchimp)
  
  # Uncomment to create an advanced template
  # puts "\n\nCreating advanced template..."
  # puts ''
  # create_advanced_template(mailchimp)
  
  # Uncomment to get info about a specific template
  # puts "\n\nGetting template info..."
  # puts ''
  # get_template_info(mailchimp, 'hello-template')
  
  # Uncomment to delete a template (use with caution!)
  # puts "\n\nDeleting template..."
  # puts ''
  # delete_template(mailchimp, 'hello-template')
end

