#!/usr/bin/env ruby
# frozen_string_literal: true

=begin
Mandrill Email Demo Web Application

This is a Sinatra web application that provides a UI for testing
different Mandrill email sending features.

Usage:
    cd scripts
    ruby app.rb

Then open your browser to: http://localhost:4567
=end

require 'sinatra'
require 'sinatra/json'
require 'json'
require 'dotenv/load'
require 'net/http'
require 'uri'

# Set Sinatra configuration
set :port, 4567
set :bind, '0.0.0.0'
set :views, File.join(File.dirname(__dir__), 'views')
set :public_folder, File.join(File.dirname(__dir__), 'public')

# Home page - Show the form
get '/' do
  #templates = fetch_mandrill_templates
  erb :index, locals: { 
    script_run_status: nil,
    description: get_description('single'),
    #templates: templates
  }
end

# Handle form submission
post '/testEmailbasedOnScriptID' do
  script_name = params['Script_name']
  puts "Script name: #{script_name}......................"
  begin
    result = case script_name
    when 'single'
      run_script('email_with_single_recipient.rb')
    when 'mergeTags'
      run_script_with_merge_tags(params)
    when 'attachments'
      run_script('email_with_attachments.rb')
    when 'templates'
      run_script_with_template(params['template_name'])
    when 'allInOne'
      run_script('kitchen_sink_email.rb')
    else
      { success: false, message: 'Unknown script type' }
    end
    
    status_html = if result[:success]
      "<div class='status-success'>✅ #{result[:message]}</div>"
    else
      "<div class='status-error'>❌ #{result[:message]}</div>"
    end
    
    templates = fetch_mandrill_templates
    erb :index, locals: { 
      script_run_status: status_html,
      description: get_description(script_name),
      templates: templates
    }
  rescue StandardError => e
    templates = fetch_mandrill_templates
    erb :index, locals: { 
      script_run_status: "<div class='status-error'>❌ Error: #{e.message}</div>",
      description: get_description(script_name),
      templates: templates
    }
  end
end

# Helper method to run a Ruby script
def run_script(script_file)
  script_path = File.join(__dir__, script_file)
  
  unless File.exist?(script_path)
    return { success: false, message: "Script not found: #{script_file}" }
  end
  
  # Execute the script and capture output
  # Use Shellwords.escape to properly handle spaces in directory paths
  require 'shellwords'
  escaped_dir = Shellwords.escape(__dir__)
  escaped_file = Shellwords.escape(script_file)
  
  output = `cd #{escaped_dir} && ruby #{escaped_file} 2>&1`
  exit_status = $?.exitstatus
  
  if exit_status == 0
    { success: true, message: "Email sent successfully! Output: #{output}" }
  else
    { success: false, message: "Script failed: #{output}" }
  end
end

# Run script with merge tags (custom parameters)
def run_script_with_merge_tags(params)
  first_name = params['firstName']
  last_name = params['lastName']
  company_name = params['companyName']
  membership_level = params['membershipLevel']
  
  # Set environment variables for the script
  ENV['MERGE_FIRST_NAME'] = first_name
  ENV['MERGE_LAST_NAME'] = last_name
  ENV['MERGE_COMPANY_NAME'] = company_name
  ENV['MERGE_MEMBERSHIP_LEVEL'] = membership_level
  
  run_script('email_with_merge_tags.rb')
end

# Run script with template selection
def run_script_with_template(template_name)
  # Store the selected template name/slug in environment variable
  # The email_with_template.rb script will use this to send with the selected template
  ENV['SELECTED_TEMPLATE'] = template_name  || 'hello-template'
  run_script('email_with_template.rb')
end

# Get description for each script type
def get_description(script_type)
  descriptions = {
    'single' => 'Send a single email to a single recipient. This script uses the Mailchimp Transactional API to send a simple email with a subject, from name, from email, to name, to email, and content. This script is a good starting point for understanding how to use the Mailchimp Transactional API. You can use this script to send a single email to a single recipient, such as a welcome email or a password reset email. For this demo all values will be used from config files.',
    
    'mergeTags' => 'Send an email with merge tags. This script uses the Mailchimp Transactional API to send an email with merge tags. Merge tags are placeholders in your email content that are replaced with dynamic data when the email is sent. This script is a good starting point for understanding how to use merge tags with the Mailchimp Transactional API. You can use this script to send personalized emails to your recipients, such as a promotional email with their name and a discount code.',
    
    'attachments' => 'Send an email with attachments. This script uses the Mailchimp Transactional API to send an email with attachments. Attachments can be added to your email by providing a URL to the file or by providing the file as a base64 encoded string. This script is a good starting point for understanding how to use attachments with the Mailchimp Transactional API. You can use this script to send emails with attachments, such as a monthly newsletter with a PDF attachment. For simplicity, this demo uses a dynamic text file and sample attachments.',
    
    'templates' => 'Send an email with a template. This script uses the Mailchimp Transactional API to send an email with a template. Templates allow you to create reusable email layouts that can be populated with dynamic content. This script is a good starting point for understanding how to use templates with the Mailchimp Transactional API. You can use this script to send emails with a consistent look and feel, such as a branded newsletter or a promotional email. For this demo pre-defined email template will be used from the code.',
    
    'allInOne' => 'Send an email with all the supported features. This script uses the Mailchimp Transactional API to send an email with all the supported features. This script is a good starting point for understanding how to use all the features with the Mailchimp Transactional API. You can use this script to send emails with all the supported features, such as a promotional email with merge tags, attachments, and a template.'
  }
  
  descriptions[script_type] || ''
end

# Fetch templates from Mandrill API
def fetch_mandrill_templates
  begin
    api_key = ENV['MANDRILL_API_KEY']
    
    unless api_key
      return [] # Return empty array if no API key
    end
    
    # Mandrill API endpoint
    uri = URI.parse('https://mandrillapp.com/api/1.0/templates/list')
    
    # Prepare the request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = { key: api_key }.to_json
    
    # Make the API call
    response = http.request(request)
    
    if response.code == '200'
      templates = JSON.parse(response.body)
      # Return first two templates
      templates.first(2)
    else
      puts "⚠️  Failed to fetch templates: #{response.code} - #{response.body}"
      []
    end
  rescue StandardError => e
    puts "⚠️  Error fetching templates: #{e.message}"
    [] # Return empty array on error
  end
end

# Start the server
if __FILE__ == $0
  puts "\n" + "="*60
  puts "🚀 Mandrill Email Demo Web Application"
  puts "="*60
  puts "\n📧 Starting web server..."
  puts "🌐 Open your browser to: http://localhost:4567"
  puts "\n💡 Press Ctrl+C to stop the server\n\n"
end

