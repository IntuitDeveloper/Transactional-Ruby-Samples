# Web UI Guide - Mandrill Email Demo

This guide explains how to use the web-based user interface for testing Mandrill email sending features.

## 🌐 Overview

The web UI provides an easy-to-use interface for testing all Mandrill email features without running Ruby scripts directly from the command line. Built with Sinatra, it offers a modern, responsive design.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
# Install all required gems including web server dependencies
cd scripts
bundle install
```

### 2. Configure Environment

Make sure your `.env` file is configured in the `scripts` directory:

```bash
cd scripts
cp env.example .env
```

Edit the `.env` file with your credentials:

```env
MANDRILL_API_KEY=your_mandrill_api_key_here
DEFAULT_FROM_EMAIL=sender@yourdomain.com
DEFAULT_FROM_NAME=Your Name
DEFAULT_TO_EMAIL=recipient@example.com
DEFAULT_TO_NAME=Recipient Name
```

### 3. Start the Web Server

From the project root directory:

```bash
# Navigate to scripts directory
cd scripts

# Option 1: Direct execution
ruby app.rb

# Option 2: With Bundler (recommended)
bundle exec ruby app.rb
```

You should see:

```
============================================================
🚀 Mandrill Email Demo Web Application
============================================================

📧 Starting web server...
🌐 Open your browser to: http://localhost:4567

💡 Press Ctrl+C to stop the server
```

### 4. Open Your Browser

Navigate to:
```
http://localhost:4567
```

## 📋 Features

### Available Email Operations

The web UI provides access to all five email sending operations:

#### 1. **Send a Single Email to a Single Recipient**
- Basic email sending demonstration
- Uses values from your `.env` configuration
- Perfect for testing basic setup

#### 2. **Send Email with Merge Tags**
- Dynamic form fields for personalization
- Enter: First Name, Last Name, Company Name, Membership Level
- Demonstrates dynamic content replacement

#### 3. **Send Email with Attachments**
- Sends emails with file attachments
- Demo includes PDF, CSV, and text files
- Shows base64 encoding in action

#### 4. **Send Email Using Template**
- Choose between two pre-defined templates
- Visual template preview
- Demonstrates template-based email sending

#### 5. **Kitchen Sink - All Features**
- Comprehensive demo of all features combined
- Attachments, merge tags, metadata, tracking, etc.
- Shows the full power of the Mandrill API

## 🎨 User Interface

### Main Screen

The home page displays:
- **Dropdown Menu**: Select which email operation to test
- **Description Box**: Dynamic description of the selected operation
- **Conditional Inputs**: Form fields appear based on your selection
- **Generate Button**: Triggers the email sending process

### Dynamic Form Fields

#### For Merge Tags:
- Input fields for First Name, Last Name, Company Name, and Membership Level
- All fields are required
- Values are passed to the email script as environment variables

#### For Templates:
- Radio buttons to select between Template 1 and Template 2
- Visual preview of each template
- Shows how merge tags will be replaced

#### For Attachments:
- Info box explaining what attachments will be included
- No additional input required

### Result Display

After sending an email:
- **Success Message**: Green banner with success status
- **Error Message**: Red banner with error details
- **Call to Action**: Reminder to check your inbox

## 🏗️ Project Structure

```
sampleapp-mandrill-mailchimp-transactional-ruby/
├── views/
│   └── index.erb                   # HTML template
├── public/
│   └── styles.css                  # CSS styles
├── scripts/
│   ├── app.rb                      # Main Sinatra application
│   ├── Gemfile                     # Ruby dependencies
│   ├── .env                        # Environment variables
│   ├── email_with_single_recipient.rb
│   ├── email_with_merge_tags.rb
│   ├── email_with_attachments.rb
│   ├── email_with_template.rb
│   └── kitchen_sink_email.rb
└── WEB_UI_GUIDE.md                 # This file
```

## 🔧 Technical Details

### Technology Stack

- **Web Framework**: Sinatra 4.0
- **Template Engine**: ERB (Embedded Ruby)
- **Web Server**: WEBrick (built-in)
- **CSS**: Custom responsive design
- **JavaScript**: Vanilla JS for form interactions

### How It Works

1. **User Selection**: User selects an operation from the dropdown
2. **Dynamic UI**: JavaScript shows/hides relevant form fields
3. **Form Submission**: Form data is POST-ed to `/testEmailbasedOnScriptID`
4. **Script Execution**: Ruby backend executes the corresponding script
5. **Result Display**: Success/error message is shown to the user

### Environment Variables

The web app passes data to scripts via environment variables:

**For Merge Tags:**
```ruby
ENV['MERGE_FIRST_NAME']
ENV['MERGE_LAST_NAME']
ENV['MERGE_COMPANY_NAME']
ENV['MERGE_MEMBERSHIP_LEVEL']
```

**For Templates:**
```ruby
ENV['SELECTED_TEMPLATE']  
```

## 🎯 Usage Examples

### Example 1: Send Basic Email

1. Select "1. Send a Single Email to a Single Recipient"
2. Read the description
3. Click "Generate Test Email"
4. Check inbox at the email configured in `.env`

### Example 2: Send Email with Merge Tags

1. Select "2. Send Email with Merge Tags"
2. Fill in the form:
   - First Name: John
   - Last Name: Doe
   - Company Name: Acme Corp
   - Membership Level: Gold
3. Click "Generate Test Email"
4. Email will be personalized with your values

### Example 3: Send Email with Template

1. Select "4. Send Email Using Template"
2. Choose Template 1 or Template 2 by clicking the radio button
3. Review the template preview
4. Click "Generate Test Email"
5. Email will use the selected template

## 🐛 Troubleshooting

### Server Won't Start

**Error: `cannot load such file -- sinatra`**
```bash
# Solution: Install dependencies
bundle install
```

**Error: `Address already in use`**
```bash
# Solution: Port 4567 is already in use. Kill the existing process:
lsof -ti:4567 | xargs kill -9
```

### Email Not Sending

**Check your `.env` file:**
```bash
# Verify your credentials are correct
cat scripts/.env
```

**Check script output:**
- The web UI shows the actual script output in the error message
- Look for specific API errors or configuration issues

**Common Issues:**
- Invalid API key
- Missing environment variables
- Invalid email addresses in `.env`

### Form Validation Issues

**Merge Tags fields not accepting input:**
- Make sure JavaScript is enabled in your browser
- Try refreshing the page

**Template selection not working:**
- Check browser console for JavaScript errors
- Ensure CSS is loading correctly

## 🔐 Security Notes

### Production Considerations

⚠️ **This demo application is for development/testing only!**

For production use, consider:

1. **Authentication**: Add user authentication (Devise, etc.)
2. **Rate Limiting**: Prevent abuse with rate limiting
3. **Input Validation**: Sanitize all user inputs
4. **HTTPS**: Use SSL/TLS in production
5. **Error Handling**: Don't expose sensitive errors to users
6. **Environment Variables**: Use secure secret management
7. **CORS**: Configure appropriate CORS policies

### Current Security Features

- Form validation (client-side and server-side)
- Environment variable isolation
- No sensitive data in URLs
- Proper error handling

## 📱 Responsive Design

The UI is fully responsive and works on:
- 🖥️ Desktop computers
- 💻 Laptops
- 📱 Tablets
- 📱 Mobile phones

The layout automatically adjusts for optimal viewing on any screen size.

## 🎨 Customization

### Changing the Port

Edit `app.rb`:

```ruby
set :port, 4567  # Change to your preferred port
```

### Custom Styling

Edit `public/styles.css` to customize:
- Colors
- Fonts
- Layout
- Animations

### Adding New Operations

1. Add the option to the dropdown in `views/index.erb`
2. Add the route handler in `app.rb`
3. Create the corresponding Ruby script in `scripts/`

## 📚 Additional Resources

- [Sinatra Documentation](http://sinatrarb.com/)
- [ERB Template Guide](https://docs.ruby-lang.org/en/master/ERB.html)
- [Mandrill API Documentation](https://mailchimp.com/developer/transactional/api/)
- [Ruby Gems](https://rubygems.org/)

## 💡 Tips

1. **Keep the server running** while testing multiple operations
2. **Check the console output** for detailed error messages
3. **Use the browser's Developer Tools** to debug JavaScript issues
4. **Test with valid email addresses** in your `.env` file
5. **Review email deliverability** if emails go to spam

## 🎓 Next Steps

Once you're comfortable with the web UI:

1. **Explore the Ruby scripts** to understand the underlying code
2. **Modify templates** to create your own email layouts
3. **Integrate into your application** using the scripts as a reference
4. **Add custom features** like scheduling, queuing, etc.

---

**Ready to test your emails?**

```bash
ruby app.rb
# Open http://localhost:4567 in your browser
```

Happy emailing! 📧✨

