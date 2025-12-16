# Send Email Using Stored Template - Ruby

Send an email using a stored template with `messages.send_template`. Provide the template name, optional `template_content` (for mc:edit regions), and a standard `message` with recipients and merge data.

## Basic Example

```ruby
require 'mailchimp-transactional'
require 'dotenv/load'

# Initialize the API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

def send_with_template(mailchimp)
  template_name = 'hello-template'
  
  message = {
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    subject: 'Welcome, {{fname}}',  # Can be overridden even if template has a default
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
  
  # Replace mc:edit regions in template (works with both Handlebars and Mailchimp)
  template_content = [
    { 
      name: 'welcome_message',
      content: '<p>Thanks for joining <strong>{{company_name}}</strong>! We\'re excited to have you on board.</p>'
    }
  ]
  
  begin
    result = mailchimp.messages.send_template({
      template_name: template_name,
      template_content: template_content,
      message: message
    })
    
    puts 'Template-based emails sent:'
    if result.is_a?(Array)
      result.each do |r|
        puts "   #{r['email']}: #{r['status']}"
      end
    else
      puts "Unexpected result structure: #{result}"
    end
  rescue MailchimpTransactional::ApiError => e
    puts "Mandrill error: #{e.message}"
  end
end

send_with_template(mailchimp)
```

## Advanced Template Usage

```ruby
def send_template_with_multiple_recipients(mailchimp)
  template_name = 'welcome-template'
  
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
      name: 'main_content',
      content: '<p>Your personalized welcome message goes here.</p>'
    }
  ]
  
  begin
    result = mailchimp.messages.send_template({
      template_name: template_name,
      template_content: template_content,
      message: message
    })
    
    puts 'Batch template emails sent:'
    result.each { |r| puts "   #{r['email']}: #{r['status']}" }
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
  end
end
```

## Notes

- **Template name**: Use the template's `name`/slug as shown in the Templates UI or API.
- **Merge language**: Choose `handlebars` or `mailchimp` via `merge_language` per message.
- **Editable regions**: Use `template_content` to replace `mc:edit` regions (only with Mailchimp merge language templates).
- **Overrides**: `subject`, `from_email`, and `from_name` can be overridden at send-time.
- **Method Name**: Ruby uses `send_template` (snake_case) like Python, not JavaScript's `sendTemplate` (camelCase).

## API Mapping

- Send with template: `messages.send_template()`
- Ruby follows snake_case naming convention for methods

