# Create Template - Ruby

Create a reusable email template in Mandrill using Ruby.

## Basic Example

```ruby
require 'mailchimp-transactional'
require 'dotenv/load'

# Initialize the API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

def create_template(mailchimp)
  template_data = {
    name: 'hello-template',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    subject: 'Hello {{fname}}!',
    code: %{
      <h1>Hello {{fname}}!</h1>
      <div mc:edit="welcome_message">
        <p>Welcome to {{company_name}}.</p>
      </div>
      <p>Your account: {{account_id}}</p>
    },
    text: "Hello {{fname}}!\n\nWelcome to {{company_name}}.\nYour account: {{account_id}}",
    publish: false,
    labels: ['hello', 'demo']
  }
  
  begin
    response = mailchimp.templates.add(template_data)
    puts "Template created: #{response['name']}"
    puts "Slug: #{response['slug']}" if response['slug']
    puts "Published name: #{response['publish_name']}" if response['publish_name']
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
  end
end

create_template(mailchimp)
```

## Key Fields

- `name` - Unique template identifier
- `code` - HTML content with merge tags
- `text` - Plain text version
- `subject` - Default subject line
- `from_email`/`from_name` - Default sender
- `publish` - false = draft, true = published
- `labels` - Array of labels for organization

## Advanced Template Creation

```ruby
def create_advanced_template(mailchimp)
  template_data = {
    name: 'welcome-email-v2',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'welcome@example.org',
    from_name: 'Welcome Team',
    subject: 'Welcome {{fname}} - Get Started with {{company_name}}',
    code: %{
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; }
          .header { background: #007bff; color: white; padding: 20px; }
          .content { padding: 20px; }
          .button { 
            background: #28a745; 
            color: white; 
            padding: 10px 20px; 
            text-decoration: none;
            border-radius: 5px;
            display: inline-block;
          }
          .footer { background: #f8f9fa; padding: 20px; text-align: center; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Welcome to {{company_name}}!</h1>
        </div>
        <div class="content">
          <h2>Hi {{fname}} {{lname}},</h2>
          <div mc:edit="main_content">
            <p>We're thrilled to have you join us! Your account is now active.</p>
            <p>Account ID: {{account_id}}</p>
          </div>
          <div mc:edit="cta_section">
            <p><a href="{{dashboard_url}}" class="button">Go to Dashboard</a></p>
          </div>
        </div>
        <div class="footer">
          <p>&copy; {{current_year}} {{company_name}}. All rights reserved.</p>
          <p><a href="{{unsubscribe_url}}">Unsubscribe</a></p>
        </div>
      </body>
      </html>
    },
    text: %{
      Welcome to {{company_name}}!
      
      Hi {{fname}} {{lname}},
      
      We're thrilled to have you join us! Your account is now active.
      Account ID: {{account_id}}
      
      Go to your dashboard: {{dashboard_url}}
      
      © {{current_year}} {{company_name}}. All rights reserved.
      Unsubscribe: {{unsubscribe_url}}
    },
    publish: false,
    labels: ['welcome', 'onboarding', 'v2']
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
```

## Template Management Methods

```ruby
# List all templates
def list_templates(mailchimp)
  begin
    templates = mailchimp.templates.list({ label: '' })
    puts "Total templates: #{templates.length}"
    templates.each do |template|
      puts "  - #{template['name']} (slug: #{template['slug']})"
    end
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
  end
end

# Get template information
def get_template_info(mailchimp, template_name)
  begin
    info = mailchimp.templates.info({ name: template_name })
    puts "Template: #{info['name']}"
    puts "Subject: #{info['subject']}"
    puts "Created: #{info['created_at']}" if info['created_at']
    puts "Updated: #{info['updated_at']}" if info['updated_at']
    info
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
end

# Update an existing template
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

# Delete a template
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
```

## Create and Publish Template

```ruby
def create_and_publish_template(mailchimp)
  template_data = {
    name: 'quick-notification',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'notify@example.org',
    from_name: 'Notification Service',
    subject: '{{notification_type}}: {{title}}',
    code: %{
      <h2>{{notification_type}}</h2>
      <h3>{{title}}</h3>
      <p>{{message}}</p>
      <p>Time: {{timestamp}}</p>
    },
    text: '{{notification_type}}: {{title}}\n\n{{message}}\n\nTime: {{timestamp}}',
    publish: true,  # Publish immediately
    labels: ['notifications', 'system']
  }
  
  begin
    response = mailchimp.templates.add(template_data)
    puts "Template created and published: #{response['name']}"
    puts "Published as: #{response['publish_name']}" if response['publish_name']
    response
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
    nil
  end
end
```

## Template Best Practices

- **Use Descriptive Names**: Make template names clear and version them (e.g., `welcome-email-v2`)
- **Test Before Publishing**: Create as draft (`publish: false`) and test thoroughly
- **Use mc:edit Regions**: Define editable regions for flexible content updates
- **Include Plain Text**: Always provide a text version for better deliverability
- **Add Labels**: Organize templates with labels for easy management
- **Version Control**: Keep track of template versions in your naming convention
- **Responsive Design**: Use responsive HTML/CSS for mobile compatibility

## Notes

- **Template Name**: Must be unique within your account
- **mc:edit Regions**: Areas that can be customized when sending via `template_content`
- **Merge Tags**: Use Handlebars (`{{variable}}`) or Mailchimp (`*|VARIABLE|*`) syntax
- **Publishing**: Draft templates can be tested; published templates are ready for production
- **Updates**: Use `templates.update()` to modify existing templates
- **Ruby String Literals**: Use `%{...}` for multi-line strings without escaping quotes

