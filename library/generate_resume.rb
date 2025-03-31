# frozen_string_literal: true
#!/usr/bin/env ruby

require 'json'
require 'erb'
require 'fileutils'
require 'date'

REPO_ROOT = File.expand_path('..', __dir__)  # Moves one level up to root repository level

CONFIG = {
  json_path: File.join(REPO_ROOT, 'library/resources/resume.json'),
  template_path: File.join(REPO_ROOT, 'library/templates/resume_template.erb'),
  output_path: File.join(REPO_ROOT, 'README.md')
}

def main  
  unless File.exist?(CONFIG[:json_path])
    puts "Error: Resume data file not found at #{CONFIG[:json_path]}"
    exit 1
  end
  
  unless File.exist?(CONFIG[:template_path])
    puts "Error: Template file not found at #{CONFIG[:template_path]}"
    exit 2
  end
  
  begin
    resume = JSON.parse(File.read(CONFIG[:json_path]))
  rescue JSON::ParserError => e
    puts "Error parsing JSON: #{e.message}"
    exit 3
  end
    
  # Create binding with all resume data accessible
  resume_binding = binding
  resume.each do |key, value|
    resume_binding.local_variable_set(key.to_sym, value)
  end
  
  # Parse the ERB template and generate the README
  begin
    template = ERB.new(File.read(CONFIG[:template_path]))
    output = template.result(resume_binding)
    File.write(CONFIG[:output_path], output)
    puts "Successfully generated #{CONFIG[:output_path]}"
  rescue => e
    puts "Error generating output: #{e.message}"
    exit 4
  end
end

main
