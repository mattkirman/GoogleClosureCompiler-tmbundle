#!/usr/bin/env ruby

require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require ENV['TM_SUPPORT_PATH'] + '/lib/progress'


def criticalError(message)
	TextMate::UI.alert(:critical, "Google Closure Compiler Bundle", message)
	exit
end


# Check to make sure that we have actually selected some files
if ENV["TM_SELECTED_FILES"] == nil then
	criticalError("Please select some files to compile.")
end

# Check that the compiler location is set
if ENV["TM_GOOGLE_CLOSURE_COMPILER_LOCATION"] == nil then
	criticalError("Unable to find a path for the Google Closure Compiler in 'Preferences...'.

Please refer to 'Help' in the bundle for more information.")
else
	compiler = ENV["TM_GOOGLE_CLOSURE_COMPILER_LOCATION"]
	
	# Check to make sure that we've set an absolute path to the compiler
	if compiler == '/absolute/path/to/google_closure_compiler.jar' || compiler[0,1] == '~' then
		criticalError("Please set the absolute path to your copy of Google Closure Compiler in 'Preferences...'.")
	end
end


selected_files_string = ENV["TM_SELECTED_FILES"]
# Strip the start and end quotes, then split the string into files
selected_files = selected_files_string[1..-2].split("' '")
if selected_files.length == 0 then
	criticalError("Please select some files to compile.")
end


TextMate.call_with_progress(:title => 'Google Closure Compiler', :summary => 'Starting up...') do |dialog|
	level = ENV["TM_GOOGLE_CLOSURE_COMPILER_OPTIMIZATION"] || 'SIMPLE_OPTIMIZATION'
	compilation_level = ''
	if level == 'ADVANCED_OPTIMIZATIONS' then
		compilation_level = ' --compilation_level ADVANCED_OPTIMIZATIONS'
	end


	files = ''
	selected_files.each { |f| files << " --js \"#{f}\"" }
	output_file = "\"#{ENV["TM_DIRECTORY"]}/compiled.js\""
	if selected_files.length == 1 then
		file = selected_files[0].gsub('.js', '')
		output_file = "\"#{file}-compiled.js\""
	end


	cmd = "java -jar #{compiler}#{compilation_level}#{files} --js_output_file #{output_file}"
	
	details = ''
	if compilation_level != '' then
		details << "--compilation_level ADVANCED_OPTIMIZATIONS\n"
	end
	
	details << "--js_output_file"
	if output_file.length > 35 then	
		details << " #{output_file[0,17]}...#{output_file[-17,17]}"
	else
		details << output_file
	end
	
	dialog.parameters = {'summary' => 'Compiling...', 'details' => details}
	result = system(cmd)
	
	if result == true then
		pluralisation = "s were"
		if selected_files.length == 1 then
			pluralisation = " was"
		end

		print "Your file#{pluralisation} compiled successfully to:
#{ output_file }"
	end
end