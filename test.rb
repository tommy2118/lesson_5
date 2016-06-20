records = [{
"First Name" => "Abhi",
"Last Name" => "Reddy",
:DOB => "03/25/1991",
:height => "5\'8",
:weight => 160 },
{
"First Name" => "John",
"Last Name" => "Doe",
:DOB => "06/13/1971",
:height => "5\'11",
:weight => 178
},
{
"First Name" => "Larry",
"Last Name" => "Smith",
:DOB => "06/03/1971",
:height => "5\'10",
:weight => 178
}, {
"First Name" => "Abhi",
"Last Name" => "Reddy",
:DOB => "08/14/1978",
:height => "6\'5",
:weight => 173
}]


puts "What is the first name?"
first_name = gets.chomp

puts "What is the last name?"
last_name = gets.chomp

result = []
records.each do |record|
  if record.has_value?(first_name) && record.has_value?(last_name)
    result << record
  end
end
if result.empty?
  puts "Record not found!"
else
  puts "#{result}"
end

