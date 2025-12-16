# Kitchen Sink - Example with Broad Settings (Ruby)

This use case demonstrates a comprehensive Mailchimp Transactional (Mandrill) message exercising many available settings in one example.

## Comprehensive Example

```ruby
require 'mailchimp-transactional'
require 'dotenv/load'
require 'base64'

# Initialize the API client
mailchimp = MailchimpTransactional::Client.new(ENV['MANDRILL_API_KEY'])

# Helper to read a local file and return a Base64 string
def read_file_as_base64(file_path)
  File.open(file_path, 'rb') do |file|
    Base64.strict_encode64(file.read)
  end
end

def send_kitchen_sink(mailchimp)
  # Simple attachments
  attachments = []
  sample_pdf = File.join(__dir__, 'sample.pdf')
  if File.exist?(sample_pdf)
    attachments << {
      type: 'application/pdf',
      name: 'sample.pdf',
      content: read_file_as_base64(sample_pdf)
    }
  end
  
  # Inline images (empty for this demo)
  images = []
  
  # Complete Mandrill message with ALL features
  message = {
    # Basic content
    html: %{
      <h1>Hello {{fname}}!</h1>
      <p>This email demonstrates multiple Transactional API features.</p>
      <p>Company: {{company_name}}</p>
      <p>Account: {{account_id}}</p>
      <div style="width: 50px; height: 50px; background: #007bff; border: 2px solid #0056b3; display: inline-block;"></div>
    },
    text: %{Hello {{fname}}!

This email demonstrates multiple Transactional API features.
Company: {{company_name}}
Account: {{account_id}}
    },
    
    # Basic fields
    subject: 'Hello {{fname}} - Mandrill Features Demo',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
    
    # All recipient types
    to: [
      {
        email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
        type: 'to'
      }
    ],
    # Uncomment to add CC and BCC recipients
    # cc: [
    #   { email: 'cc@example.com', name: 'CC User', type: 'cc' }
    # ],
    # bcc: [
    #   { email: 'bcc@example.com', name: 'BCC User', type: 'bcc' }
    # ],
    
    # Headers
    headers: {
      'Reply-To' => ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
      'X-Custom-Header' => 'Mandrill-Demo-Ruby'
    },
    
    # Merge variables
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
    
    # Attachments and images
    attachments: attachments,
    images: images,
    
    # Tracking
    track_opens: true,
    track_clicks: true,
    auto_text: true,
    auto_html: false,
    inline_css: true,
    
    # Tags and metadata
    tags: ['demo', 'kitchen-sink', 'features', 'ruby'],
    metadata: {
      campaign: 'mandrill-demo',
      version: '1.0',
      language: 'ruby'
    },
    
    # Advanced options
    important: true,
    view_content_link: true,
    preserve_recipients: false,
    async: false
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    
    puts 'Kitchen Sink email sent!'
    puts '=' * 50
    
    if result.is_a?(Array)
      result.each do |r|
        puts "#{r['email']}: #{r['status']}"
        puts "  Message ID: #{r['_id']}" if r['_id']
        puts "  Reject Reason: #{r['reject_reason']}" if r['reject_reason']
      end
    else
      puts "Unexpected result structure: #{result}"
    end
    
    puts '=' * 50
  rescue MailchimpTransactional::ApiError => e
    puts 'Error sending kitchen sink email!'
    puts '=' * 50
    puts "Mandrill error: #{e.message}"
    puts '=' * 50
  end
end

send_kitchen_sink(mailchimp)
```

## Advanced Kitchen Sink with Scheduling

```ruby
require 'time'

def send_scheduled_kitchen_sink(mailchimp)
  # Schedule for 1 hour from now
  send_at = (Time.now + 3600).utc.strftime('%Y-%m-%d %H:%M:%S')
  
  message = {
    html: '<h1>Scheduled Email</h1><p>This was scheduled in advance, {{fname}}!</p>',
    text: "Scheduled Email\n\nThis was scheduled in advance, {{fname}}!",
    subject: 'Scheduled: {{subject_line}}',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    from_name: 'Scheduled Sender',
    to: [
      {
        email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        type: 'to'
      }
    ],
    global_merge_vars: [
      { name: 'subject_line', content: 'Your Scheduled Message' }
    ],
    merge_vars: [
      {
        rcpt: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
        vars: [
          { name: 'fname', content: 'Future Reader' }
        ]
      }
    ],
    merge_language: 'handlebars',
    track_opens: true,
    track_clicks: true,
    tags: ['scheduled', 'kitchen-sink'],
    send_at: send_at  # Schedule for future delivery
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    puts "Email scheduled for: #{send_at}"
    result.each { |r| puts "#{r['email']}: #{r['status']}" }
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
  end
end
```

## All Available Message Options

```ruby
# Returns a hash showing all available message options
# This is a reference - not all options are required
def complete_message_structure
  {
    # Content
    html: '<p>HTML content</p>',
    text: 'Plain text content',
    subject: 'Email subject',
    
    # Sender
    from_email: 'sender@example.org',
    from_name: 'Sender Name',
    
    # Recipients
    to: [
      { email: 'recipient@example.org', name: 'Name', type: 'to' }
    ],
    
    # Headers
    headers: { 'Reply-To' => 'reply@example.org' },
    
    # Merge variables
    global_merge_vars: [{ name: 'var', content: 'value' }],
    merge_vars: [{
      rcpt: 'recipient@example.org',
      vars: [{ name: 'var', content: 'value' }]
    }],
    merge_language: 'handlebars',  # or 'mailchimp'
    
    # Attachments
    attachments: [
      { type: 'text/plain', name: 'file.txt', content: 'base64...' }
    ],
    images: [
      { type: 'image/png', name: 'image.png', content: 'base64...' }
    ],
    
    # Tracking and rendering
    track_opens: true,
    track_clicks: true,
    auto_text: true,
    auto_html: false,
    inline_css: true,
    url_strip_qs: false,
    preserve_recipients: false,
    view_content_link: true,
    
    # Delivery options
    important: false,
    async: false,
    ip_pool: 'Main Pool',
    send_at: '2024-12-31 23:59:59',  # UTC datetime string
    
    # Metadata and tagging
    tags: ['tag1', 'tag2'],
    subaccount: 'subaccount_id',
    google_analytics_domains: ['example.org'],
    google_analytics_campaign: 'campaign_name',
    metadata: { key: 'value' },
    recipient_metadata: [{
      rcpt: 'recipient@example.org',
      values: { key: 'value' }
    }],
    
    # Return path
    return_path_domain: 'example.org',
    
    # Signing
    signing_domain: 'example.org',
    
    # Tracking domain
    tracking_domain: 'track.example.org',
    
    # Merge tag behavior
    merge: true
  }
end
```

## Notes

- **Recipients**: Use `to` with `type: 'to' | 'cc' | 'bcc'` per recipient.
- **Merge**: Combine `global_merge_vars` and `merge_vars`; set `merge_language` to `handlebars` or `mailchimp`.
- **Templates**: Switch to `messages.send_template` and pass `template_name`. Use `template_content` to replace mc:edit regions.
- **Attachments/Images**: Use `attachments` for files and `images` for inline CID images. Total message size max ~25MB (Base64 grows size ~33%).
- **Headers**: Add standard headers (e.g., `Reply-To`) and custom `X-` headers. Use hash rocket `=>` or symbols.
- **Tracking**: Enable `track_opens` and `track_clicks` for analytics.
- **Metadata/Tags**: Useful for analytics and grouping in the UI.
- **Scheduling**: Provide `send_at` as a UTC datetime string for future sends.
- **IP Pool**: If you use dedicated IPs, set `ip_pool` accordingly.
- **Boolean Values**: Ruby uses `true`/`false` (lowercase) like JavaScript.
- **String Literals**: Use `%{...}` for multi-line strings to avoid escaping quotes.

## API Mapping

- Send: `messages.send()`
- Send with template: `messages.send_template()`
- Ruby uses snake_case naming convention for methods

