# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clean existing data (only for development)
if Rails.env.development?
  puts "Cleaning existing data..."
  AiSuggestion.destroy_all
  Task.destroy_all
  Category.destroy_all
  Project.destroy_all
  User.destroy_all
end

# Create a demo user
puts "Creating demo user..."
user = User.create!(
  email: "demo@urganise.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Demo user created: #{user.email}"

# Create projects
puts "Creating projects..."
projects = [
  {
    name: "Website Redesign",
    description: "Complete overhaul of company website with modern design and improved UX"
  },
  {
    name: "Mobile App Development",
    description: "Build iOS and Android apps for our platform"
  },
  {
    name: "Marketing Campaign Q1",
    description: "Plan and execute Q1 marketing initiatives"
  }
]

created_projects = projects.map do |project_data|
  project = user.projects.create!(project_data)
  puts "  Created project: #{project.name}"
  project
end

# Create categories for each project
puts "Creating categories..."
created_projects.each do |project|
  categories_data = [
    { name: "Design", color: "#3B82F6" },
    { name: "Development", color: "#10B981" },
    { name: "Testing", color: "#F59E0B" },
    { name: "Documentation", color: "#8B5CF6" }
  ]
  
  categories_data.each do |category_data|
    category = project.categories.create!(category_data)
    puts "    Created category: #{category.name} for #{project.name}"
  end
end

# Create tasks
puts "Creating tasks..."
created_projects.each do |project|
  categories = project.categories.to_a
  
  tasks_data = [
    {
      title: "Research competitor websites",
      description: "Analyze top 5 competitors and document their UX patterns",
      priority: :high,
      status: :pending,
      due_date: 7.days.from_now,
      category: categories.sample
    },
    {
      title: "Create wireframes",
      description: "Design wireframes for all main pages",
      priority: :high,
      status: :in_progress,
      due_date: 10.days.from_now,
      category: categories.first
    },
    {
      title: "Setup development environment",
      description: "Configure local and staging environments",
      priority: :urgent,
      status: :completed,
      completed_at: 2.days.ago,
      due_date: 2.days.ago,
      category: categories.second
    },
    {
      title: "Write API documentation",
      description: "Document all API endpoints with examples",
      priority: :medium,
      status: :pending,
      due_date: 14.days.from_now,
      category: categories.last
    },
    {
      title: "User testing session",
      description: "Conduct user testing with 10 participants",
      priority: :medium,
      status: :pending,
      due_date: 21.days.from_now,
      category: categories.third
    }
  ]
  
  tasks_data.each do |task_data|
    task = project.tasks.create!(task_data.merge(user: user))
    puts "    Created task: #{task.title}"
  end
end

puts "\n✅ Seed data created successfully!"
puts "\n📧 Demo user credentials:"
puts "   Email: demo@urganise.com"
puts "   Password: password123"
puts "\n🚀 You can now sign in and start using Urganise!"
