require 'rake'
require 'yaml'

HOME_DIR = `echo $HOME`.strip
ROOT_DIR = File.expand_path('.')
SRC_DIR = File.join(ROOT_DIR, 'src')
TMP_DIR = File.join(ROOT_DIR, 'tmp')
RELEASE_DIR = File.join(ROOT_DIR, 'releases')
BUILD_DIR = File.join(ROOT_DIR, 'build')
BUNDLE = "Google Closure Compiler.tmbundle"
TM_BUNDLE_DIR = "#{HOME_DIR}/Library/Application Support/TextMate/Bundles"
TM_PRISTINE_BUNDLE_DIR = "#{HOME_DIR}/Library/Application Support/TextMate/Pristine Copy/Bundles"

# http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
begin
  require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/
rescue LoadError
  raise 'You must "gem install win32console" to use terminal colors on Windows'
end
 
def colorize(text, color_code)
  "#{color_code}#{text}\e[0m"
end
 
def red(text); colorize(text, "\e[31m"); end
def green(text); colorize(text, "\e[32m"); end
def yellow(text); colorize(text, "\e[33m"); end
def blue(text); colorize(text, "\e[34m"); end
def magenta(text); colorize(text, "\e[35m"); end
def azure(text); colorize(text, "\e[36m"); end
def white(text); colorize(text, "\e[37m"); end
def black(text); colorize(text, "\e[30m"); end
 
def file_color(text); yellow(text); end
def dir_color(text); blue(text); end
def cmd_color(text); azure(text); end



def die(msg, status=1)
	puts red("Error:[#{status||$?}]: #{msg}")
	exit status||$?
end


def version()
	if ENV['version'] then
		$version = ENV['version']
	else
		version = open('Version.yml') {|f| YAML.load(f)}
		$version = "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"
	end
end


def revision()
	$revision = `git rev-parse HEAD`.strip
	$short_revision = $revision[0..7]
end


def dirty_repo_warning()
	is_clean = `git status`.match(/working directory clean/)
	puts red("Repository is not clean! You should commit all changes before releasing.") unless is_clean
end


def sys(cmd)
	puts "> #{yellow(cmd)}"
	system(cmd)
end


def patch(path, replacers)
	puts "#{green('Patching')} #{file_color(path)}"
	lines = []
	File.open(path, "r") do |f|
		f.each do |line|
			replacers.each do |r|
				line.gsub!(r[0], r[1])
			end
			lines << line
		end
	end
	
	File.open(path, "w") do |f|
		f << lines
	end
end


def patch_f(file, resource, flag)
	this_file = TMP_DIR
	if file.is_a?(Array) then
		file.each do |f|
			this_file = File.join(this_file, f)
		end
	else
		this_file = File.join(this_file, file)
	end
	file = this_file
	
	this_file = File.join(TMP_DIR, '__Patches')
	if resource.is_a?(Array) then
		resource.each do |f|
			this_file = File.join(this_file, f)
		end
	else
		this_file = File.join(this_file, resource)
	end
	resource = this_file
	
	patch(file, [[flag, File.read(resource)]])
end


task :default => :build


desc "Builds the TextMate bundle"
task :build do
	puts cmd_color('Checking environment...')
	dirty_repo_warning()
	version()
	revision()
	
	puts cmd_color("Copying sources to temporary directory...")
	`rm -rf "#{TMP_DIR}"`
	`cp -r "#{SRC_DIR}/" "#{TMP_DIR}"`
	
	puts cmd_color('Parsing Buildspec...')
	buildspec = open('Buildspec.yml') {|f| YAML.load(f)}
	
	puts cmd_color("Patching files...")
	buildspec[:patches].each do |p|
		file = []
		p['file'].each do |f|
			file.push(f)
		end
		
		patch = []
		p['patch'].each do |f|
			patch.push(f)
		end
		
		patch_f(file, patch, p['flag'])
	end
	
	# Patch version info
	patch(File.join(TMP_DIR, 'Support', 'help.markdown'), [['##VERSION##', $version], ['##REVISION##', $short_revision]])
	
	puts cmd_color("Tidying up patch files...")
	`rm -rf "#{File.join(TMP_DIR, '__Patches')}"`
	
	puts "#{cmd_color("Building")} \"#{file_color(BUNDLE)}\"..."
	`rm -rf build`
	`mkdir build`
	`mkdir "build/#{BUNDLE}"`
	`cp -r "#{TMP_DIR}/" "build/#{BUNDLE}"`
	
	Rake::Task["clobber:tmp"].execute
	
	puts "Tip: execute #{blue("rake install")} to install this bundle"
end


desc "Installs the built TextMate bundle into ~/Library/Application Support/TextMate/Bundles"
task :install do
	die("First build the bundle> rake build") unless File.exists? File.join(BUILD_DIR, BUNDLE)
	Dir.chdir(BUILD_DIR) do
		dest = File.join(TM_BUNDLE_DIR, BUNDLE)
		pristine = File.join(TM_PRISTINE_BUNDLE_DIR, BUNDLE)
		
		sys("rm -rf \"#{dest}\"") if File.exists? dest
		sys("rm -rf \"#{pristine}\"") if File.exists? pristine
		
		die("Error installing bundle") unless sys("cp -r \"#{BUNDLE}\" \"#{pristine}\" && mv \"#{BUNDLE}\" \"#{dest}\"")
		
		Rake::Task["clobber:build"].execute
		puts "#{blue('Done!')} You may now have to reload TextMate bundles for changes to take effect"
	end
end


desc "Prepares the build for release by compressing the bundle with zip and tar"
task :release do
	die("First build the bundle> rake build") unless File.exists? File.join(BUILD_DIR, BUNDLE)
	version()
	
	puts cmd_color("Generating release #{$version}...")
	bundle = BUNDLE.gsub(' ','').gsub('.tmbundle','') + '-' + $version
	release_dir = File.join(RELEASE_DIR, bundle);
	`mkdir "#{RELEASE_DIR}"` unless File.exists? RELEASE_DIR
	`mkdir "#{release_dir}"` unless File.exists? release_dir
	
	zipfile = File.join(release_dir, "#{bundle}.zip")
	puts "#{cmd_color("Zipping file")} #{dir_color(zipfile)}..."
	Dir.chdir(BUILD_DIR) do
		unless sys("zip -r \"#{zipfile}\" \"#{BUNDLE}\"") then
			puts red('Need zip on the command line (download http://www.info-zip.org/Zip.html).')
		end
	end
	
	tarfile = File.join(release_dir, "#{bundle}.tar.gz")
	puts "#{cmd_color("Tarring file")} #{dir_color(tarfile)}..."
	Dir.chdir(BUILD_DIR) do
		unless sys("tar czvf \"#{tarfile}\" \"#{BUNDLE}\"") then
			puts red('Need tar on the command line')
		end
	end
	
	Rake::Task["clobber:build"].execute
	puts "#{blue('Done!')} You can find the release files in #{release_dir}"
end


desc "Removes all Rake generated files"
task :clobber do
	Rake::Task['clobber:build'].execute
	Rake::Task['clobber:release'].execute
	Rake::Task['clobber:tmp'].execute
end


namespace :clobber do
	desc "Removes build files"
	task :build do
		puts "#{cmd_color('Removing...')} #{dir_color(BUILD_DIR)}"
		`rm -rf "#{BUILD_DIR}"`
	end
	
	
	desc "Removes release files"
	task :release do
		puts "#{cmd_color('Removing...')} #{dir_color(RELEASE_DIR)}"
		`rm -rf "#{RELEASE_DIR}"`
	end
	
	
	desc "Removes temporary files"
	task :tmp do
		puts "#{cmd_color("Removing...")} #{dir_color(TMP_DIR)}"
		`rm -rf "#{TMP_DIR}"`
	end
end