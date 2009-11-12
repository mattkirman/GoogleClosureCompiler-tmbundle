#!/usr/bin/env ruby

begin
	selected_files_string = ENV["TM_SELECTED_FILES"]
rescue Exception => e
	print "No files selected"
	exit
end


# Strip the start and end quotes, then split the string into files
selected_files = selected_files_string[1..-2].split("' '")

if selected_files.length == 0 then
	print "No files selected"
	exit
end


begin
	compiler = ENV["TM_GOOGLE_CLOSURE_COMPILER_LOCATION"]
rescue Exception => e
	print "Unable to find path for your Google Closure Compiler in 'Preferences...'. Please refer to 'Help' in the bundle."
	exit
end


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
result = system(cmd)


if result == true then
	pluralisation = "s were"
	if selected_files.length == 1 then
		pluralisation = " was"
	end
	
	print "Your file#{pluralisation} compiled successfully to: #{output_file}"
else
	print result
end
