class GeminiService
  require 'net/http'
  require 'json'

  def initialize
    @api_key = ENV['GOOGLE_GEMINI_API_KEY']
    @base_url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent'
  end

  def generate_task_suggestions(task_description)
    return { error: "API key not configured" } unless @api_key

    prompt = <<~PROMPT
      Based on this task description: "#{task_description}"
      
      Please provide:
      1. A breakdown of subtasks (if applicable)
      2. Priority recommendation (low, medium, high, urgent)
      3. Estimated time to complete
      4. Any optimization suggestions
      
      Format the response as JSON with keys: subtasks (array), priority, time_estimate, optimization_tips (array)
    PROMPT

    make_request(prompt)
  end

  def analyze_project(project_name, project_description, tasks_count)
    return { error: "API key not configured" } unless @api_key

    prompt = <<~PROMPT
      Analyze this project:
      Name: #{project_name}
      Description: #{project_description}
      Current tasks: #{tasks_count}
      
      Provide suggestions for:
      1. Project organization
      2. Task prioritization strategy
      3. Potential bottlenecks
      4. Optimization recommendations
    PROMPT

    make_request(prompt)
  end

  def suggest_task_priority(task_title, task_description, due_date)
    return { error: "API key not configured" } unless @api_key

    prompt = <<~PROMPT
      Based on this task:
      Title: #{task_title}
      Description: #{task_description}
      Due date: #{due_date}
      
      Suggest the appropriate priority level (low, medium, high, urgent) and explain why.
    PROMPT

    make_request(prompt)
  end

  private

  def make_request(prompt)
    uri = URI("#{@base_url}?key=#{@api_key}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path + '?' + uri.query)
    request['Content-Type'] = 'application/json'
    
    request.body = {
      contents: [{
        parts: [{
          text: prompt
        }]
      }]
    }.to_json

    begin
      response = http.request(request)
      parse_response(response)
    rescue StandardError => e
      { error: e.message }
    end
  end

  def parse_response(response)
    return { error: "HTTP Error: #{response.code}" } unless response.code == "200"
    
    body = JSON.parse(response.body)
    
    if body['candidates']&.any?
      content = body.dig('candidates', 0, 'content', 'parts', 0, 'text')
      { success: true, content: content }
    else
      { error: "No response from API" }
    end
  rescue JSON::ParserError => e
    { error: "Failed to parse response: #{e.message}" }
  end
end
