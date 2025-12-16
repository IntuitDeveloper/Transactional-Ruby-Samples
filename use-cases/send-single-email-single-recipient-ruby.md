# Send a Single Email to a Single Recipient (Ruby)

This use case demonstrates how to send a single email to a single recipient using the Mandrill API with Ruby.

## Basic Example

Here's how to send a single email to a single recipient using the Mandrill API:

```ruby
require 'mailchimp-transactional'
require 'dotenv/load'

# Initialize the API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

message = {
  html: '<p>Hello HTML world!</p>',
  text: 'Hello plain world!',
  subject: 'Hello world',
  from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
  from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
  to: [{
    email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
    name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
    type: 'to'
  }],
  headers: {
    'Reply-To': ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org'
  }
}

def send_email(mailchimp, message)
  begin
    result = mailchimp.messages.send({ message: message })
    puts 'Email sent successfully:'
    puts "Full result: #{result.to_json}"
    
    if result && result.length > 0
      puts "Status: #{result[0]['status']}"
      puts "Email: #{result[0]['email']}"
      puts "Message ID: #{result[0]['_id']}"
    else
      puts "Unexpected result structure: #{result}"
    end
  rescue MailchimpTransactional::ApiError => e
    puts "Mandrill error: #{e.message}"
    puts "Error details: #{e.response_body}" if e.respond_to?(:response_body)
  end
end

send_email(mailchimp, message)
```

## API Features

| Feature | Mandrill Implementation |
|---------|-------------------------|
| **Recipients** | `to: [{email: 'email@example.org', name: 'Name', type: 'to'}]` |
| **Sender** | `from_email: 'email@example.org', from_name: 'Name'` |
| **Send Method** | `mailchimp.messages.send(message: msg)` |

## Message Structure

The Mandrill message hash requires these key properties:

- **html**: HTML content of the email
- **text**: Plain text content (optional, but recommended)
- **subject**: Email subject line
- **from_email**: Sender's email address
- **from_name**: Sender's display name (optional)
- **to**: Array of recipient hashes

### Recipient Hash Structure

Each recipient in the `to` array must be a hash with:

- **email**: Recipient's email address (required)
- **name**: Recipient's display name (optional)
- **type**: Recipient type - `'to'`, `'cc'`, or `'bcc'` (required)

## Advanced Options

You can enhance your email with additional options:

```ruby
message = {
  html: '<p>Hello HTML world!</p>',
  text: 'Hello plain world!',
  subject: 'Hello world',
  from_email: 'sender@example.org',
  from_name: 'Sender Name',
  to: [{
    email: 'recipient@example.org',
    name: 'Recipient Name',
    type: 'to'
  }],
  headers: {
    'Reply-To': 'replyto@example.org',
    'X-MC-Track': 'opens,clicks'
  },
  important: true,
  track_opens: true,
  track_clicks: true,
  auto_text: true,
  auto_html: false,
  inline_css: true,
  tags: ['welcome', 'single-recipient'],
  metadata: {
    user_id: '12345',
    campaign: 'welcome-series'
  }
}
```

## Installation

Before running this code, install the required gems:

```bash
gem install MailchimpTransactional dotenv
```

Or add to your Gemfile:

```ruby
gem 'MailchimpTransactional'
gem 'dotenv'
```

Then run:

```bash
bundle install
```

## Environment Variables

Create a `.env` file in your project root with:

```
MANDRILL_API_KEY=your_api_key_here
DEFAULT_FROM_EMAIL=sender@example.org
DEFAULT_FROM_NAME=Sender Name
DEFAULT_TO_EMAIL=recipient@example.org
DEFAULT_TO_NAME=Recipient Name
```

## Notes

- **Async Parameter**: Set `async: false` for immediate sending, `async: true` for background processing
- **IP Pool**: Specify `ip_pool` for dedicated IP addresses (optional)
- **Headers**: Use the `headers` hash for custom email headers
- **Tracking**: Enable `track_opens` and `track_clicks` for email analytics
- **Error Handling**: Use `MailchimpTransactional::ApiError` to catch Mandrill API errors
- **Ruby Conventions**: Use symbols (`:key`) or strings (`'key'`) for hash keys - Mandrill accepts both

