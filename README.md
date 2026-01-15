# Mandrill Email Demo - Ruby Implementation

A comprehensive Ruby implementation for testing Mailchimp's Mandrill Transactional API with both command-line scripts and a web-based UI.

## 🚀 Quick Start

### Prerequisites
- Ruby 3.0+ (3.4+ recommended)
- Bundler
- A Mandrill API key from [Mailchimp](https://mandrillapp.com/)

### Installation

```bash
# Clone or navigate to the project
cd sampleapp-mandrill-mailchimp-transactional-ruby

# Install dependencies (Gemfile is in scripts directory)
cd scripts
bundle install

# Configure environment variables
cp env.example .env
# Edit .env with your Mandrill API key and email settings
```

## 💻 Two Ways to Use This Project

### Option 1: Web UI (Recommended for Testing)

Start the web server:

```bash
cd scripts
ruby app.rb
```

Then open your browser to:
```
http://localhost:4567
```

The web UI provides:
- ✨ Beautiful, modern interface
- 📋 Dropdown menu to select email operations
- 🎨 Dynamic forms and previews
- ✅ Instant feedback on email sending

**[Read the Web UI Guide →](WEB_UI_GUIDE.md)**

### Option 2: Command Line Scripts

Run individual Ruby scripts directly:

```bash
cd scripts

# Send a basic email
ruby email_with_single_recipient.rb

# Send with merge tags
ruby email_with_merge_tags.rb

# Send with attachments
ruby email_with_attachments.rb

# Send using a template
ruby email_with_template.rb

# Kitchen sink - all features
ruby kitchen_sink_email.rb
```

**[Read the Setup Guide →](README_USECASES_RUBY.md)**

## 📋 Available Features

### 1. **Single Email to Single Recipient**
Send a basic email with subject, body, and recipient.

### 2. **Email with Merge Tags**
Personalize emails with dynamic content using merge variables.

### 3. **Email with Attachments**
Attach files (PDF, CSV, images, etc.) to your emails.

### 4. **Email Using Templates**
Use pre-created Mandrill templates for consistent branding.

### 5. **Kitchen Sink**
Comprehensive example using all features combined.

## 📁 Project Structure

```
sampleapp-mandrill-mailchimp-transactional-ruby/
├── views/
│   └── index.erb                   # Web UI template
├── public/
│   └── styles.css                  # Web UI styles
├── scripts/
│   ├── app.rb                      # Web UI application (Sinatra)
│   ├── Gemfile                     # Ruby dependencies
│   ├── .env                        # Your configuration (create from env.example)
│   ├── email_with_single_recipient.rb
│   ├── email_with_merge_tags.rb
│   ├── email_with_attachments.rb
│   ├── email_with_template.rb
│   └── kitchen_sink_email.rb
├── use-cases/                      # Detailed documentation for each use case
├── WEB_UI_GUIDE.md                 # Web UI documentation
└── README.md                       # This file
```

## 🔧 Configuration

Create a `.env` file in the `scripts` directory:

```env
MANDRILL_API_KEY=your_mandrill_api_key_here
DEFAULT_FROM_EMAIL=sender@yourdomain.com
DEFAULT_FROM_NAME="Your Name"
DEFAULT_TO_EMAIL=recipient@example.com
DEFAULT_TO_NAME="Recipient Name"
```

> **Note:** Always quote values that contain spaces or special characters.

## 🎯 Use Cases

Each script demonstrates a specific use case:

| Script | Description | Documentation |
|--------|-------------|---------------|
| `email_with_single_recipient.rb` | Basic email sending | [Docs](use-cases/send-single-email-single-recipient-ruby.md) |
| `email_with_merge_tags.rb` | Personalized emails | [Docs](use-cases/send-email-with-merge-tags-ruby.md) |
| `email_with_attachments.rb` | Emails with files | [Docs](use-cases/send-email-with-attachments-ruby.md) |
| `email_with_template.rb` | Template-based emails | [Docs](use-cases/send-email-using-template-ruby.md) |
| `kitchen_sink_email.rb` | All features combined | [Docs](use-cases/kitchen-sink-ruby.md) |

## 📚 Documentation

- **[WEB_UI_GUIDE.md](WEB_UI_GUIDE.md)** - Complete web UI documentation
- **[scripts/README_USECASES_RUBY.md](scripts/README_USECASES_RUBY.md)** - Script-specific documentation
- **[use-cases/](use-cases/)** - Individual use case guides

## 🌟 Key Features

### Web UI Features
- 🎨 Modern, responsive design
- 📱 Mobile-friendly interface
- 🔄 Real-time form validation
- 📊 Visual template previews
- ✅ Instant success/error feedback

### Script Features
- 💎 Clean, idiomatic Ruby code
- 📝 Comprehensive inline documentation
- 🛡️ Robust error handling
- 🔧 Easy to customize and extend
- 📖 RDoc-style documentation

## 🐛 Troubleshooting

### Gem Installation Issues

```bash
# If you see: "Could not find gem 'MailchimpTransactional'"
bundle install

# If bundler version mismatch:
rm Gemfile.lock
bundle install
```

### Ruby 3.4+ Missing Gems

The Gemfile includes `base64` and `logger` which are required for Ruby 3.4+.

### Web Server Issues

```bash
# Port already in use:
lsof -ti:4567 | xargs kill -9

# Then restart:
ruby app.rb
```

## 🔐 Security Notes

⚠️ **Never commit your `.env` file or API keys to version control!**

The `.env` file is in `.gitignore` by default. Keep your API keys secure.

## 🎓 Learning Resources

- [Mandrill API Documentation](https://mailchimp.com/developer/transactional/api/)
- [Ruby Gem: MailchimpTransactional](https://rubygems.org/gems/MailchimpTransactional)
- [Sinatra Documentation](http://sinatrarb.com/)
- [Ruby Style Guide](https://rubystyle.guide/)

## 💡 Tips

1. **Start with the Web UI** - It's the easiest way to test all features
2. **Review the scripts** - Learn how each feature works
3. **Check the use-cases** - Detailed documentation for each scenario
4. **Customize templates** - Make them your own
5. **Monitor your API usage** - Check your Mandrill dashboard

## 🤝 Contributing

This is a demo/sample project. Feel free to:
- Fork and customize for your needs
- Report issues or suggestions
- Share improvements

## 📄 License

See the LICENSE file in the root directory.

## 🚦 Getting Started Now

### For Quick Testing (Web UI):

```bash
cd scripts
bundle install
ruby app.rb
# Open http://localhost:4567
```

### For Development (Scripts):

```bash
cd scripts
bundle install
ruby email_with_single_recipient.rb
```

---

**Ready to send your first email?** 🚀

Choose your preferred method above and get started!

For questions or issues, refer to the documentation files or check the script comments.

Happy emailing! 📧✨

