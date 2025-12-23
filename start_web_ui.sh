#!/bin/bash
# Start the Mandrill Email Demo Web UI

echo "============================================================"
echo "🚀 Mandrill Email Demo - Web UI Starter"
echo "============================================================"
echo ""

# Check if .env file exists
if [ ! -f "scripts/.env" ]; then
    echo "⚠️  Warning: scripts/.env file not found!"
    echo ""
    echo "Please create a .env file with your Mandrill API key:"
    echo "  cd scripts"
    echo "  cp env.example .env"
    echo "  # Edit .env with your credentials"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if bundle is installed
if ! command -v bundle &> /dev/null; then
    echo "❌ Bundler is not installed!"
    echo ""
    echo "Install with: gem install bundler"
    echo ""
    exit 1
fi

# Install dependencies if needed
if [ ! -f "scripts/Gemfile.lock" ]; then
    echo "📦 Installing dependencies..."
    (cd scripts && bundle install)
    echo ""
fi

# Start the server
echo "🌐 Starting web server..."
echo "📧 Open your browser to: http://localhost:4567"
echo ""
echo "💡 Press Ctrl+C to stop the server"
echo ""

cd scripts && ruby app.rb

