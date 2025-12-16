# Send Email with Merge Tags (Dynamic Content) - Ruby

This use case demonstrates how to personalize emails using merge tags for dynamic content like names, order information, and custom data.

## Basic Merge Tags Example

Use merge tags to personalize content for each recipient:

```ruby
require 'mailchimp-transactional'
require 'dotenv/load'

# Initialize the API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

message = {
  html: %{
    <h1>Welcome {{fname}}!</h1>
    <p>Hi {{fname}} {{lname}},</p>
    <p>Thanks for joining the {{company_name}}! Your account is now active.</p>
    <p>Your membership level: {{membership_level}}</p>
    <p>Best regards,<br>The {{company_name}} Team</p>
  },
  text: %{
    Welcome {{fname}}!
    
    Hi {{fname}} {{lname}},
    
    Thanks for joining the {{company_name}}! Your account is now active.
    Your membership level: {{membership_level}}
    
    Best regards,
    The {{company_name}} Team
  },
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
  # Global merge variables (apply to all recipients)
  global_merge_vars: [
    {
      name: 'company_name',
      content: 'Intuit Developer Program'
    },
    {
      name: 'membership_level',
      content: 'Premium'
    }
  ],
  # Recipient-specific merge variables
  merge_vars: [
    {
      rcpt: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
      vars: [
        {
          name: 'fname',
          content: 'John'
        },
        {
          name: 'lname',
          content: 'Smith'
        }
      ]
    }
  ],
  merge_language: 'handlebars'  # or 'mailchimp'
}

def send_personalized_email(mailchimp, message)
  begin
    result = mailchimp.messages.send({ message: message })
    puts 'Personalized emails sent:'
    
    if result.is_a?(Array)
      result.each do |recipient|
        puts "#{recipient['email']}: #{recipient['status']}"
      end
    else
      puts "Unexpected result structure: #{result}"
    end
  rescue MailchimpTransactional::ApiError => e
    puts "Mandrill error: #{e.message}"
  end
end

send_personalized_email(mailchimp, message)
```

## Merge Language Options

| Language | Syntax | Example | Use Case |
|---|---|---|---|
| handlebars | {{variable}} | Hello {{name}}! | Complex logic, loops, conditionals |
| mailchimp | `*|VARIABLE|*` | Hello *|NAME|*! | Simple substitutions, legacy compatibility |

## Key Features

| Feature | Description | Example |
|---|---|---|
| Global Merge Vars | Apply to all recipients | Company name, promotion details |
| Recipient Merge Vars | Specific to each recipient | Personal names, order details |
| Merge Language | Choose syntax style | handlebars or mailchimp |
| Complex Data | Hashes and arrays | Order items, address objects |
| Fallback Values | Default when data missing | {{name 'Customer'}} |

## Multiple Recipients Example

```ruby
def send_to_multiple_recipients(mailchimp)
  message = {
    html: '<h1>Welcome {{fname}}!</h1><p>Your account {{account_id}} is active.</p>',
    subject: 'Welcome {{fname}}!',
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
    merge_vars: [
      {
        rcpt: 'john@example.org',
        vars: [
          { name: 'fname', content: 'John' },
          { name: 'account_id', content: 'ACC-001' }
        ]
      },
      {
        rcpt: 'jane@example.org',
        vars: [
          { name: 'fname', content: 'Jane' },
          { name: 'account_id', content: 'ACC-002' }
        ]
      }
    ],
    merge_language: 'handlebars'
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    result.each do |recipient|
      puts "#{recipient['email']}: #{recipient['status']}"
    end
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
  end
end
```

## Notes

- **Merge Tag Format**: Use alphanumeric characters and underscores only (no colons)
- **Content Length**: Generally unlimited for API usage
- **Global vs Recipient**: Global vars apply to all; recipient vars are specific to each email
- **Language Setting**: Can be set globally in account or per-message via `merge_language`
- **Handlebars Benefits**: Supports loops, conditionals, and complex logic
- **Template Conversion**: Mailchimp templates auto-convert to Handlebars when imported
- **Error Handling**: Always handle cases where merge data might be missing
- **Ruby String Literals**: Use `%{...}` for multi-line strings with interpolation

