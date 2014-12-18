# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
students = {1 => {:fname => "Joseph", :lname => "Banda", :email => "jozy@gmail.com", :gender => "Male",
            :dob => "01-01-2000", :mobile => "0999000001"},
            2 => {:fname => "James", :lname => "Mhango", :email => "james@gmail.com", :gender => "Male",
            :dob => "01-11-1999", :mobile => "0999000002"},
            3 => {:fname => "Paul", :lname => "Phiri", :email => "paul@gmail.com", :gender => "Male",
            :dob => "10-10-1999", :mobile => "0999000003"},
            4 => {:fname => "Mary", :lname => "Banda", :email => "mary@gmail.com", :gender => "Female",
            :dob => "01-11-1999", :mobile => "0999000004"},
            5 => {:fname => "Maria", :lname => "Chisale", :email => "maria@yahoo.com", :gender => "Female",
            :dob => "01-11-1999", :mobile => "0999000005"}
            }
            
students.each do |key, data|
  Student.create(data)
end

teachers = {1 => {:fname => "Mphatso", :lname => "Matola", :email => "mphatso@gmail.com", 
            :dob => "01-01-1960", :mobile => "0999000006"},
            2 => {:fname => "Rodgers", :lname => "Mhango", :email => "rodgers@gmail.com",
            :dob => "01-11-1970", :mobile => "0999000007"},
            3 => {:fname => "Paul", :lname => "Banda", :email => "paul1@gmail.com",
            :dob => "11-10-1998", :mobile => "0999000008"},
            4 => {:fname => "Mary", :lname => "Nyozani", :email => "mary@gmail.com",
            :dob => "01-11-1999", :mobile => "0999000009"},
            5 => {:fname => "Mercy", :lname => "Chisale", :email => "mercy67@yahoo.com", :gender => "Female",
            :dob => "01-11-1999", :mobile => "0999000010"}
            }
teachers.each do |key, data|
  Teacher.create(data)
end

courses = ["Agriculture", "Physical Science", "Mathematics", "Geography", "Biology", "Computer Studies"]
courses.each do |course_name|
  Course.create({
    :name => course_name
  })
end

classes = ["Form 1", "Form 2", "Form 3", "Form 4"]
classes.each do |class_name|
  ClassRoom.create({
    :name => class_name
  })
end

exam_types = ["Weekly Test", "Monthly Exam", "End of term exam", "MANEB"]
exam_types.each do |exam_type|
  ExaminationType.create({
    :name => exam_type
  })
end