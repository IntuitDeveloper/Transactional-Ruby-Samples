# Send Email with Attachments - Ruby

This use case demonstrates how to attach files to emails sent via Mailchimp Transactional (Mandrill) and outlines limits and best practices.

## Basic Attachments Example

Attach one or more files by providing Base64-encoded content. The total message size (including attachments) must not exceed 25MB. Because attachments are Base64-encoded, they are roughly 33% larger than their on-disk size.

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

attachments = [
  {
    type: 'application/pdf',
    name: 'sample.pdf',
    content: read_file_as_base64(File.join(__dir__, 'sample.pdf'))
  },
  {
    type: 'text/plain',
    name: 'readme.txt',
    content: Base64.strict_encode64(
      "This is a demo text file created by the Mandrill Use Case File.\n\n" \
      "Generated at: #{Time.now.iso8601}"
    )
  }
]

message = {
  html: %{
    <h1>Your Documents</h1>
    <p>Please find the attached files.</p>
  },
  text: 'Your documents are attached.',
  subject: 'Documents Attached',
  from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
  from_name: ENV['DEFAULT_FROM_NAME'] || 'Test Sender',
  to: [
    {
      email: ENV['DEFAULT_TO_EMAIL'] || 'recipient@example.org',
      name: ENV['DEFAULT_TO_NAME'] || 'Test Recipient',
      type: 'to'
    }
  ],
  attachments: attachments,  # Array of attachments
  tags: ['attachments', 'outbound-documents']
}

def send_with_attachments(mailchimp, message)
  begin
    result = mailchimp.messages.send({ message: message })
    puts 'Email with attachments sent:'
    
    if result.is_a?(Array)
      result.each { |r| puts "#{r['email']}: #{r['status']}" }
    else
      puts "Unexpected result structure: #{result}"
    end
  rescue MailchimpTransactional::ApiError => e
    puts "Mandrill error: #{e.message}"
  end
end

send_with_attachments(mailchimp, message)
```

## Attachments Using Different Data Sources

```ruby
# From a string
def create_text_attachment(content, filename)
  {
    type: 'text/plain',
    name: filename,
    content: Base64.strict_encode64(content)
  }
end

# From CSV data
def create_csv_attachment(data, filename)
  require 'csv'
  csv_string = CSV.generate do |csv|
    data.each { |row| csv << row }
  end
  
  {
    type: 'text/csv',
    name: filename,
    content: Base64.strict_encode64(csv_string)
  }
end

# From JSON data
def create_json_attachment(data, filename)
  require 'json'
  {
    type: 'application/json',
    name: filename,
    content: Base64.strict_encode64(data.to_json)
  }
end

# Example usage
message = {
  html: '<h1>Multiple Attachments</h1>',
  subject: 'Various File Types',
  from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
  to: [{ email: ENV['DEFAULT_TO_EMAIL'] || 'test@example.org', type: 'to' }],
  attachments: [
    create_text_attachment('Hello World', 'hello.txt'),
    create_csv_attachment([['Name', 'Email'], ['John', 'john@example.org']], 'data.csv'),
    create_json_attachment({ status: 'success', count: 42 }, 'data.json')
  ]
}
```

## Working with Different File Types

```ruby
def send_multiple_file_types(mailchimp)
  attachments = []
  
  # PDF file
  pdf_path = File.join(__dir__, 'document.pdf')
  if File.exist?(pdf_path)
    attachments << {
      type: 'application/pdf',
      name: 'document.pdf',
      content: read_file_as_base64(pdf_path)
    }
  end
  
  # Image file
  image_path = File.join(__dir__, 'chart.png')
  if File.exist?(image_path)
    attachments << {
      type: 'image/png',
      name: 'chart.png',
      content: read_file_as_base64(image_path)
    }
  end
  
  # CSV file (generated)
  csv_content = "Name,Email,Status\nJohn,john@example.org,Active\n"
  attachments << {
    type: 'text/csv',
    name: 'report.csv',
    content: Base64.strict_encode64(csv_content)
  }
  
  # JSON file (generated)
  require 'json'
  json_data = { status: 'success', count: 42 }
  attachments << {
    type: 'application/json',
    name: 'data.json',
    content: Base64.strict_encode64(json_data.to_json)
  }
  
  message = {
    html: '<h1>Multiple File Types</h1><p>Various file formats attached.</p>',
    subject: 'Multiple Attachments',
    from_email: ENV['DEFAULT_FROM_EMAIL'] || 'test@example.org',
    to: [{ email: ENV['DEFAULT_TO_EMAIL'] || 'test@example.org', type: 'to' }],
    attachments: attachments
  }
  
  begin
    result = mailchimp.messages.send({ message: message })
    puts "Email with #{attachments.length} attachments sent successfully"
  rescue MailchimpTransactional::ApiError => e
    puts "Error: #{e.message}"
  end
end
```

## Limits and Processing

- **Total Message Size**: Up to 25MB (includes the message body + attachments + headers).
- **Base64 Overhead**: Attachments are Base64-encoded, increasing size by ~33%. A 15MB file on disk becomes ~20MB over the wire.
- **Virus Scanning**: All attachments are scanned by multiple engines to help ensure safety for recipients.
- **No Per-File Limit**: There is no specific limit for individual attachments beyond the total message size.

## Best Practices

- **Keep Attachments Small**: Prefer < 10MB combined to ensure deliverability and reduce scan time.
- **Use Accurate MIME Types**: Set the `type` field properly (e.g., `application/pdf`, `image/png`).
- **Validate Sizes**: Pre-check content size and account for Base64 growth before sending.
- **Fallback Links**: For large or multiple files, consider hosting and linking instead of emailing.
- **Security**: Only attach files from trusted sources; scan files before sending.
- **Tracking**: Add tags and metadata for downstream analytics.

## Common MIME Types

```ruby
MIME_TYPES = {
  '.pdf' => 'application/pdf',
  '.doc' => 'application/msword',
  '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  '.xls' => 'application/vnd.ms-excel',
  '.xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  '.png' => 'image/png',
  '.jpg' => 'image/jpeg',
  '.jpeg' => 'image/jpeg',
  '.gif' => 'image/gif',
  '.txt' => 'text/plain',
  '.csv' => 'text/csv',
  '.json' => 'application/json',
  '.zip' => 'application/zip'
}.freeze

def get_mime_type(filename)
  ext = File.extname(filename).downcase
  MIME_TYPES[ext] || 'application/octet-stream'
end
```

## Notes

- **Attachments Field**: Provide an array of hashes `{ type:, name:, content: }` where `content` is Base64.
- **Inline Images**: Use the `images` array for content intended to render inside the email body.
- **Delivery Timing**: Large attachments can add processing time due to scanning.
- **Error Handling**: Handle `MailchimpTransactional::ApiError` for malformed attachments and runtime errors for oversize messages.
- **Ruby Base64**: Use `Base64.strict_encode64` for proper encoding without line breaks.

