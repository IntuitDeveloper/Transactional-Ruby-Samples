# Ruby Scripts for Mandrill API Use Cases

This directory contains Ruby implementations of Mandrill API use cases using the `mailchimp-transactional` gem.

## Prerequisites

- Ruby 2.7 or higher (Ruby 3.0+ recommended)
- Bundler gem manager
- A Mandrill API key from [Mailchimp](https://mandrillapp.com/)

## Installation

### Option 1: Using Bundler (Recommended)

1. Install Bundler if you haven't already:

```bash
gem install bundler
```

2. Install the required gems:

```bash
cd scripts
bundle install
```

### Option 2: Manual Installation

Install the required gems individually:

```bash
gem install MailchimpTransactional dotenv
```

## Configuration

1. Copy the `.env.example` file to `.env` in the scripts directory:

```bash
cp env.example .env
```

2. Edit the `.env` file and add your credentials:

```
MANDRILL_API_KEY=your_mandrill_api_key_here
DEFAULT_FROM_EMAIL=sender@yourdomain.com
DEFAULT_FROM_NAME=Your Name
DEFAULT_TO_EMAIL=recipient@example.com
DEFAULT_TO_NAME=Recipient Name
```

## Available Ruby Scripts

### 1. Send Single Email to Single Recipient

**File:** `email_with_single_recipient.rb`

Demonstrates how to send a basic email to a single recipient.

```bash
ruby email_with_single_recipient.rb
# Or with Bundler:
bundle exec ruby email_with_single_recipient.rb
# Or make executable:
./email_with_single_recipient.rb
```

**Features:**
- Basic email sending
- HTML and plain text content
- Custom headers
- Advanced options with tracking and metadata
- Comprehensive error handling

### 2. Send Email with Merge Tags

**File:** `email_with_merge_tags.rb`

Personalize emails using merge tags for dynamic content.

```bash
ruby email_with_merge_tags.rb
```

**Features:**
- Global merge variables (apply to all recipients)
- Recipient-specific merge variables
- Handlebars template syntax
- Multiple recipient personalization
- Full RDoc documentation

### 3. Send Email Using Template

**File:** `email_with_template.rb`

Send emails using pre-created Mandrill templates.

```bash
ruby email_with_template.rb
```

**Features:**
- Use stored templates
- Override template defaults
- Dynamic content with merge tags
- mc:edit region replacement
- Batch sending with templates

**Note:** You must first create a template using `create_template.rb` or via the Mandrill UI.

### 4. Send Email with Attachments

**File:** `email_with_attachments.rb`

Attach files (PDF, CSV, JSON, etc.) to your emails.

```bash
ruby email_with_attachments.rb
```

**Features:**
- Attach local files (PDF, images, etc.)
- Create dynamic attachments (CSV, JSON, text)
- Base64 encoding handling
- Multiple attachment types
- MIME type helpers

### 5. Create Template

**File:** `create_template.rb`

Create and manage reusable email templates.

```bash
ruby create_template.rb
```

**Features:**
- Create new templates
- List all templates
- Get template information
- Update and delete templates
- mc:edit regions for dynamic content
- Advanced template with responsive design

### 6. Kitchen Sink - All Features

**File:** `kitchen_sink_email.rb`

Comprehensive example demonstrating all Mandrill features.

```bash
ruby kitchen_sink_email.rb
```

**Features:**
- All message options in one example
- Attachments, tracking, metadata
- Multiple recipient types (TO, CC, BCC)
- Scheduled sending
- Advanced headers and custom fields
- Complete documentation with RDoc

## Script Structure

Each Ruby script follows this structure:

1. **Shebang and encoding** - Ruby interpreter declaration
2. **Documentation block** - Usage and requirements
3. **Require statements** - Required gems and libraries
4. **Client initialization** - Configure Mandrill API client
5. **Method definitions** - Reusable email sending methods
6. **Main execution block** - Run the example when script is executed directly

## Error Handling

All scripts include error handling for:
- Missing API credentials
- API client errors (`MailchimpTransactional::ApiError`)
- Network issues
- Invalid email addresses

Example error handling pattern:

```ruby
begin
  result = mailchimp.messages.send(message: message)
  # Handle success
rescue MailchimpTransactional::ApiError => e
  puts "Mandrill API Error: #{e.message}"
  puts "Error details: #{e.response_body}" if e.respond_to?(:response_body)
end
```

## API Response

A successful API response is an array of hashes:

```ruby
[
  {
    "email" => "recipient@example.org",
    "status" => "sent",  # or "queued", "rejected", "invalid"
    "_id" => "abc123",
    "reject_reason" => nil  # or reason if rejected
  }
]
```

## Common Status Values

- `sent` - Message was successfully sent
- `queued` - Message is queued for sending
- `scheduled` - Message is scheduled for future sending
- `rejected` - Message was rejected
- `invalid` - Invalid recipient email address

## Ruby Conventions

### Hash Keys

Ruby allows both symbols and strings as hash keys. The Mandrill API accepts both:

```ruby
# Using symbols (Ruby convention)
message = {
  subject: 'Hello',
  from_email: 'test@example.org'
}

# Using strings (also works)
message = {
  'subject' => 'Hello',
  'from_email' => 'test@example.org'
}
```

### Method Naming

Ruby uses snake_case for method names:

```ruby
mailchimp.messages.send()        # Send message
mailchimp.messages.send_template() # Send with template
mailchimp.templates.add()        # Create template
```

### Boolean Values

Ruby uses `true` and `false` (lowercase):

```ruby
message = {
  track_opens: true,
  track_clicks: false
}
```

## Running Scripts

### Direct Execution

Make the script executable:

```bash
chmod +x email_with_single_recipient.rb
./email_with_single_recipient.rb
```

### With Ruby Command

```bash
ruby email_with_single_recipient.rb
```

### With Bundler (Recommended)

Ensures correct gem versions are used:

```bash
bundle exec ruby email_with_single_recipient.rb
```

## Testing

To test without sending real emails, you can:

1. Use print statements to inspect the message structure:

```ruby
puts "Message structure:"
puts JSON.pretty_generate(message)
```

2. Create a dry-run mode:

```ruby
DRY_RUN = ENV['DRY_RUN'] == 'true'

if DRY_RUN
  puts "DRY RUN - Would send:"
  puts JSON.pretty_generate(message)
else
  result = mailchimp.messages.send(message: message)
end
```

## Bundler Usage

### Creating a Gemfile

A `Gemfile` is included in the scripts directory:

```ruby
source 'https://rubygems.org'

gem 'MailchimpTransactional', '~> 1.0'
gem 'dotenv', '~> 2.8'
```

### Installing Dependencies

```bash
bundle install
```

### Updating Dependencies

```bash
bundle update
```

### Checking Installed Gems

```bash
bundle list
```

## Project Structure

```
scripts/
├── Gemfile                          # Ruby dependencies
├── Gemfile.lock                     # Locked gem versions (created by bundler)
├── .env                             # Environment variables (create from env.example)
├── env.example                      # Example environment variables
├── email_with_single_recipient.rb   # Ruby script for sending email
└── README_USECASES_RUBY.md          # This file
```

## Resources

- [Mandrill API Documentation](https://mailchimp.com/developer/transactional/api/)
- [Ruby SDK on GitHub](https://github.com/mailchimp/mailchimp-transactional-ruby)
- [Ruby Dotenv Documentation](https://github.com/bkeepers/dotenv)
- [Ruby Style Guide](https://rubystyle.guide/)

## Common Issues

### Issue 1: Gem Not Found

```
LoadError: cannot load such file -- MailchimpTransactional
```

**Solution:**
```bash
gem install MailchimpTransactional
# or
bundle install
```

### Issue 2: Permission Denied

```
Permission denied @ rb_sysopen - .env
```

**Solution:**
Check file permissions and ensure `.env` exists:
```bash
ls -la .env
chmod 644 .env
```

### Issue 3: Ruby Version

```
Your Ruby version is X.X.X, but your Gemfile specified >= Y.Y.Y
```

**Solution:**
Install a compatible Ruby version using rbenv or rvm:
```bash
# Using rbenv
rbenv install 3.2.0
rbenv local 3.2.0

# Using rvm
rvm install 3.2.0
rvm use 3.2.0
```

## Support

For issues with:
- **Mandrill API**: Contact Mailchimp support
- **Ruby SDK**: Open an issue on the GitHub repository
- **These examples**: Check the use-cases documentation

## License

See the LICENSE file in the root directory.

