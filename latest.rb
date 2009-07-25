SOFTWARE_LIST = {
  :jquery => lambda do |args|
    pattern = 
    case args[0]
    when :min
      /"([^"]*files\/jquery\-[\d\.]*\.min.js)"/
    when :release
      /"([^"]*files\/jquery\-[\d\.]*\-release\.zip)"/
    when :standard
      /"([^"]*files\/jquery\-[\d\.]*.js)"/
    end
    doc = Nokogiri::HTML(open('http://code.google.com/p/jqueryjs/'))
    url = doc.search('#downloadbox').to_s.scan(pattern)[0][0]
    if args[0] == :release
      save_dir = args[1] || 'doc/jquery'
      file File.join(save_dir, 'jquery.zip'), open(url).read
      inside save_dir do
        run 'unzip jquery.zip'
      end
      url = File.join(save_dir, 'dist', 'jquery.min.js')
    end
    in_root do
      file 'public/javascripts/jquery.js', open(url).read
    end
  end
}
REQUIRES = {
  :jquery => ['nokogiri']
}
DEFAULTS = {
  :jquery => [:min]
}
def latest *args
  package = args.delete_at(0)
  args = DEFAULTS[package] if args.empty?
  REQUIRES[package].each {|dependency| require dependency }
  SOFTWARE_LIST[package].call(args)
end

def latest_rails
  log 'check', 'Checking for the latest version of rails'
  gem_list = `gem list -r rails`
  match = gem_list.match(/^\s*rails\s+\(([\d\.]*)\)(.)*/)
  match.class.name == 'MatchData' ? match[1] : ''
end

def update_rails
  rails_v = Rails::VERSION::STRING
  latest_rails_v = latest_rails
  if latest_rails_v == rails_v
    log 'info', 'You already have the latest version of rails'
  elsif latest_rails_v.blank?
    log 'warning', 'Could not determine the latest version of rails. Skipping'
  else
    if ['y','Y','',"\n"].include?(ask("Your Rails gem version is #{rails_v}, but latest is #{latest_rails_v}. Update (Y/n)?"))
      log 'update', 'Updating rails. This may take a few minutes, and it will require your admin password'
      run "sudo gem install rails"
      log 'remove', "Removing #{root}"
      run "rm -rf #{root}"
      log '**note**', 'Rails has been updated and your project has been deleted.'
      log '**note**', 'Please re-run your previous command.'
      exit
    end
  end
end

update_rails