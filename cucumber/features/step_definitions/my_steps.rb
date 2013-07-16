Persona.each do
  When /^#{persona} does something$/ do
    puts "my name is: #{persona}"
  end

  #When /^#{persona} does something else$/ do
  #  puts "my name is: #{persona}"
  #end

  When /^#{persona} has done it$/ do
    puts "my name is: #{persona}"
  end
end


#When /^(#{salutations}) does something$/ do |unused_capture|
#  puts "my name is: #{@current_persona}"
#end
#
#When /^(#{salutations}) does something else$/ do |unused_capture|
#  puts "my name is: #{@current_persona}"
#end
#
#When /^(#{salutations}) has done it$/ do |unused_capture|
#  puts "my name is: #{@current_persona}"
#end
