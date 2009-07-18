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
