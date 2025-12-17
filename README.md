# Urganise - Task & Project Management Application

**Urganise** is a modern, AI-powered task and project management application built with Ruby on Rails 8, Tailwind CSS, and Google Gemini AI integration.

## 🚀 Features

- **Project Management**: Create and organize multiple projects with custom descriptions
- **Task Management**: Create, update, and track tasks with priorities, due dates, and statuses
- **Category System**: Organize tasks with color-coded categories
- **AI Suggestions**: Get intelligent task recommendations powered by Google Gemini AI
- **Dashboard**: Beautiful overview of your projects, tasks, and statistics
- **Responsive Design**: Built with Tailwind CSS for a modern, mobile-friendly experience
- **Real-time Updates**: Powered by Hotwire (Turbo + Stimulus)

## 🛠 Tech Stack

- **Backend**: Ruby on Rails 8.1+
- **Frontend**: HTML5, Tailwind CSS, Stimulus JS
- **Database**: PostgreSQL
- **Authentication**: Devise
- **AI Integration**: Google Gemini 3 Pro API
- **Deployment**: Docker & Docker Compose

## 📋 Prerequisites

- Docker Desktop (recommended)
- OR: Ruby 3.4+, Rails 8.1+, PostgreSQL 16+, Node.js
- Google Gemini API Key (optional, for AI features)

## 🔧 Installation

### Option 1: Docker (Recommended) 🐳

**Prerequisites**: Docker Desktop installed and running

#### Using the Helper Script (Easiest)
```bash
# Clone the repository
git clone <repository-url>
cd Urganise

# Setup environment variables (optional)
cp .env.example .env
# Edit .env and add your GOOGLE_GEMINI_API_KEY if you want AI features

# Start the application
./docker-helper.sh start
```

**Helper Script Commands:**
```bash
./docker-helper.sh start      # Start the application
./docker-helper.sh stop       # Stop the application
./docker-helper.sh logs       # View logs in real-time
./docker-helper.sh console    # Open Rails console
./docker-helper.sh bash       # Open bash terminal in container
./docker-helper.sh db:reset   # Reset database (with confirmation)
./docker-helper.sh db:migrate # Run migrations
./docker-helper.sh db:seed    # Load demo data
./docker-helper.sh status     # Check container status
./docker-helper.sh help       # Show all commands
```

#### Manual Docker Commands
You can also use Make commands or Docker Compose directly:

**Using Make:**
```bash
make start        # Start the application
make stop         # Stop the application
make logs         # View logs
make console      # Open Rails console
make help         # Show all commands
```

**Using Docker Compose:**
```bash
# Start the application
docker-compose up --build

# Stop the application
docker-compose down

# View logs
docker-compose logs -f web

# Access Rails console
docker-compose exec web rails console
```

**Access the application:**
- URL: `http://localhost:3000`
- Demo Email: demo@urganise.com
- Demo Password: password123

📖 **Documentation:**
- **[DOCKER.md](DOCKER.md)** - Development setup and troubleshooting
- **[PRODUCTION.md](PRODUCTION.md)** - Production deployment guide

### Option 2: Local Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Urganise
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your configuration:
   ```
   DB_HOST=localhost
   URGANISE_DATABASE_PASSWORD=your_password
   GOOGLE_GEMINI_API_KEY=your_gemini_api_key
   SECRET_KEY_BASE=your_secret_key
   ```

4. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

5. **Start the development server**
   ```bash
   bin/dev
   ```

6. **Visit the application**
   Open your browser and navigate to `http://localhost:3000`

## 📱 Usage

### Getting Started

1. **Sign Up**: Create a new account or sign in
2. **Create a Project**: Click "New Project" to create your first project
3. **Add Categories**: Organize your tasks with color-coded categories
4. **Create Tasks**: Add tasks with titles, descriptions, priorities, and due dates
5. **Track Progress**: Mark tasks as complete and monitor your progress
6. **AI Suggestions**: Use the AI features to get smart task recommendations

### Task Priorities

- **Low**: Regular tasks with no urgency
- **Medium**: Standard priority tasks (default)
- **High**: Important tasks requiring attention
- **Urgent**: Critical tasks that need immediate action

### Task Statuses

- **Pending**: Not yet started
- **In Progress**: Currently being worked on
- **Completed**: Finished tasks

## 🧠 AI Features

Urganise integrates with Google Gemini AI to provide:

- **Task Breakdown**: Split complex tasks into manageable subtasks
- **Priority Recommendations**: Get AI-suggested priorities based on task content
- **Time Estimates**: Receive estimated completion times
- **Optimization Tips**: Get suggestions to improve task efficiency

To enable AI features, add your Google Gemini API key to `.env`:
```
GOOGLE_GEMINI_API_KEY=your_api_key_here
```

Get your API key at: https://makersuite.google.com/app/apikey

## 🚀 Deployment

### Vercel Deployment

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Configure Environment Variables**
   In your Vercel dashboard, add:
   - `DATABASE_URL`: Your PostgreSQL connection string (use Vercel Postgres or Neon)
   - `GOOGLE_GEMINI_API_KEY`: Your Gemini API key
   - `SECRET_KEY_BASE`: Generate with `rails secret`
   - `RAILS_ENV`: Set to `production`

3. **Deploy**
   ```bash
   vercel
   ```

### Database Setup

For production, you can use:
- **Vercel Postgres**: Integrated PostgreSQL hosting
- **Neon**: Serverless PostgreSQL
- **Railway**: Simple PostgreSQL hosting

## 🗂 Project Structure

```
app/
├── controllers/     # Application controllers
├── models/          # Data models (User, Project, Task, Category, AiSuggestion)
├── views/           # ERB templates with Tailwind CSS
├── javascript/      # Stimulus controllers
└── services/        # Business logic (GeminiService)

config/
├── routes.rb        # Application routes
└── database.yml     # Database configuration

db/
└── migrate/         # Database migrations
```

## 🎨 Key Models

- **User**: Authentication and user management
- **Project**: Contains tasks and categories
- **Task**: Individual tasks with priorities, statuses, and due dates
- **Category**: Organize tasks with colors
- **AiSuggestion**: Store AI-generated recommendations

## 🔐 Security

- User authentication via Devise
- CSRF protection enabled
- Environment variables for sensitive data
- Password encryption
- SQL injection protection via ActiveRecord

## 🧪 Testing

```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/task_test.rb

# Run system tests
rails test:system
```

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For support, email support@urganise.com or open an issue in the repository.

## 🙏 Acknowledgments

- Built with Ruby on Rails
- UI powered by Tailwind CSS
- AI capabilities by Google Gemini
- Authentication by Devise
- Interactivity by Stimulus JS

---

**Made with ❤️ by the Urganise Team**
