# vim:set filetype=ruby:
def growl
  title = "Watchr Test Results"
  image = $?.success? ? "~/.watchr/images/passed.png" : "~/.watchr/images/failed.png"
  message = $?.success? ? "success" : "failed"
  growlnotify = `which growlnotify`.chomp
  options = "-w -n Watchr --image '#{File.expand_path(image)}' -m '#{message}' '#{title}'"
  system %(#{growlnotify} #{options} &)
end

def run(cmd)
  puts cmd
  system(cmd)
end

def spec(file)
  if File.exists?(file)
    run("rspec #{file}")
    growl
  else
    puts("Spec: #{file} does not exist.")
  end
end


def run_all_specs
  run "rake spec"
  growl
end

def run_suite
  system "clear"
  run_all_specs
end

watch("spec/.*/*_spec\.rb") do |match|
  puts(match[0])
  spec(match[0])
end

watch("lib/(.*/.*)\.rb") do |match|
  puts(match[1])
  spec("spec/#{match[1]}_spec.rb")
end


# Ctrl-\
Signal.trap 'QUIT' do
  puts " --- Running all tests ---\n\n"
  run_suite
 end

# Ctrl-C
Signal.trap 'INT' do
  if @interrupted then
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    run_suite
    @interrupted = false
  end
end
