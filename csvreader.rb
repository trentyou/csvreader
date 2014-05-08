require 'csv'
require 'date'
 
class Person
  attr_reader :number, :first_name, :last_name, :email, :phone, :created_at

  def initialize(number, first_name, last_name, email, phone, created_at)
    @number = number
    @first_name = first_name
    @last_name = last_name
    @email = email
    @phone = phone

    if created_at.class == Time
      @created_at = created_at
    else
      @created_at = DateTime.parse(created_at)
    end
  end
end


 
class PersonParser
  attr_reader :file

  
  def initialize(file)
    @file = file
    @people = []
    0.upto(@file.length - 1) {|row| @people << Person.new(@file[row][0].to_i, @file[row][1], @file[row][2], @file[row][3], @file[row][4], @file[row][5])}
  end


  def search(name)
    name = name.downcase.gsub(/[-\s+]/, "")    
    array_of_results = []

    1.upto(@people.length - 1) do |person|
      phone = @people[person].phone.gsub(/[-\s+]/, "")
      f_name = @people[person].first_name.downcase.gsub(/\s+/, "")
      l_name = @people[person].last_name.downcase.gsub(/\s+/, "")
      email = @people[person].email.downcase.gsub(/\s+/, "")

      name_match = (name =~ /#{f_name}/ || name =~ /#{l_name}/ || f_name =~ /.+#{name}|^#{name}+/ || l_name =~ /.+#{name}|^#{name}+/)
      number_match = (name =~ /#{phone}/ || phone =~ /.+#{name}|^#{name}+/) 
      email_match = (name =~ /#{email}/ || email =~ /.+#{name}|^#{name}+/)

      if name_match || number_match || email_match
        array_of_results << @people[person]
      end
    end

    puts "List of results from search for '#{name}': "
    divider = "-" * (35 + name.length)
    puts divider
    puts
    if array_of_results.length != 0
      0.upto(array_of_results.length - 1) do |person| 
        printf("%-3s %3s", "#{person + 1}","Name: #{array_of_results[person].first_name} #{array_of_results[person].last_name}")
        puts
        puts "    Email Address: #{array_of_results[person].email}"
        puts "    Phone Number: #{array_of_results[person].phone}"
        puts
      end
    else
      puts "No results found."
      puts
    end
    puts divider
  end


  def get_next_csv_number
    return @people[@people.length - 1].number + 1 
  end

  def save
    CSV.open("B:/Users/Trent/Desktop/Ruby Programs/people.csv", "wb") do |csv|
      @people.each do |person|
        csv << [person.number, person.first_name, person.last_name, person.email, person.phone, person.created_at]
      end
    end
  end


  def add_person(person)
    @people << person
  end

  
  def people
    # If we've already parsed the CSV file, don't parse it again.
    # Remember: @people is +nil+ by default.
    return @people if @people
    
    # We've never called people before, now parse the CSV file
    # and return an Array of Person objects here.  Save the
    # Array in the @people instance variable.
  end



end
csv_array = CSV.read("B:/Users/Trent/Desktop/Ruby Programs/people.csv")
parser = PersonParser.new(csv_array)

#parser.add_person(Person.new(201, "Trent", "You", "tyou@ucdavis.edu", "1-510-637-9093", Time.new.to_s))



stars = "*" * "There are #{parser.people.size} people in the loaded CSV file.".length

puts stars
puts
puts "Welcome to the CSV editing program!"
puts 
puts
puts "There are #{parser.people.size} people in the loaded CSV file."
puts
loop do
  puts "What would you like to do?"
  puts "[1] Add a person to the CSV file"
  puts "[2] Search for a person in the CSV file"
  puts "[3] Exit program"

  input = gets.chomp.gsub(/\s+/, "")
  case input
  when "1"
    puts "Enter the first name of the person:"
    f_name = gets.chomp.gsub(/\s+/, "").capitalize
    puts "Enter the last name of the person:"
    l_name = gets.chomp.gsub(/\s+/, "").capitalize
    puts "Enter their email address:"
    email = gets.chomp.gsub(/\s+/, "")
    puts "Enter their phone number:"
    phone = gets.chomp.gsub(/[-\s+]/, "")
    puts phone

    case phone.length
    when 7
      phone.insert(3, "-")
    when 10
      phone.insert(6, "-")
      phone.insert(3, "-")
    when 11
      phone.insert(7, "-")
      phone.insert(4, "-")
      phone.insert(1, "-")
    end

    parser.add_person(Person.new(parser.get_next_csv_number, f_name, l_name, email, phone, Time.new))
    puts
    puts "#{f_name} #{l_name} added to CSV!"
    puts
    puts
  when "2"
    loop do
    puts
    puts "Enter any part of the name, email or phone number you are looking for: "
    puts "Enter exit when finished"
    puts 
    input = gets.chomp
    puts
    puts
    puts
    if input != "exit"
      parser.search(input)
    else
      puts "Exiting.."
      puts
      break
    end
  end
  when "3"
    puts "Exiting and saving file.."
    parser.save
    puts stars
    break
  else
    puts "Please choose from the options '1', '2', or '3'"
  end

end




