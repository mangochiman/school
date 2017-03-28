# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
students = {
  1 => {
    :fname => "Joseph",
    :lname => "Banda",
    :email => "jozy@gmail.com",
    :gender => "Male",
    :dob => "01-01-2000",
    :mobile => "0999000001"
  },
  2 => {
    :fname => "James",
    :lname => "Mhango",
    :email => "james@gmail.com",
    :gender => "Male",
    :dob => "01-11-1999",
    :mobile => "0999000002"
  }
}
            
students.each do |key, data|
  #Student.create(data)
end

teachers = {
  1 => {
    :fname => "Mphatso",
    :lname => "Matola",
    :email => "mphatso@gmail.com",
    :gender => "Male",
    :dob => "01-01-1960",
    :mobile => "0999000006"
  },
  2 => {
    :fname => "Rodgers",
    :lname => "Mhango",
    :gender => "Male",
    :email => "rodgers@gmail.com",
    :dob => "01-11-1970",
    :mobile => "0999000007"
  }
}
teachers.each do |key, data|
  Teacher.create(data)
end

courses = ["Agriculture", "Physical Science", "Mathematics"]
courses.each do |course_name|
  Course.create({
      :name => course_name
    })
end

classes = ["Form 1", "Form 2"]
classes.each do |class_name|
  class_room = ClassRoom.new_class_room(class_name)
  Course.all.each do |course|
    class_room.class_room_courses.create({:course_id => course.course_id})
  end

  Teacher.all.each do |teacher|
    class_room.class_room_teachers.create({:teacher_id => teacher.teacher_id})
  end
  
end

exam_types = ["Weekly Test", "Monthly Exam"]
exam_types.each do |exam_type|
  ExaminationType.create({
      :name => exam_type
    })
end

payment_types = ["School Fees"]
payment_types.each do |paymen_type|
  PaymentType.create({
      :name => paymen_type,
      :amount_required => 30000
    })
end

semester_dates = {
  "1" => {
    :start_date => '03-January-2015'.to_date,
    :end_date => '30-May-2015'.to_date
  },
  "2" => {
    :start_date => '01-August-2015'.to_date,
    :end_date => '23-December-2015'.to_date
  }
}

['1','2'].each do |i|
  start_date = semester_dates[i][:start_date]
  end_date = semester_dates[i][:end_date]
  semester = Semester.create_new_semester(i)

  SemesterAudit.initial_semester(semester.semester_id, start_date, end_date)
  SemesterAudit.new_semester(semester.semester_id, start_date, end_date)
end

semester_id = Semester.last.semester_id
SemesterAudit.set_current_semester(semester_id)
class_room_ids = ClassRoom.all.map(&:class_room_id)
class_room_id = class_room_ids.shuffle.first.to_s

Student.all.each do |student|

  class_room_courses = ClassRoomCourse.find(:all, :conditions => ["class_room_id =?", class_room_id])
  class_room_courses.each do |course|
    student.student_class_room_courses.create({
        :class_room_id => class_room_id,
        :course_id => course.course_id
      })
  end
  
  class_room = ClassRoom.find(class_room_id)
  
  student.student_class_room_adjustments.create({
      :old_class_room_id => 0,
      :new_class_room_id => class_room_id,
      :status => 'active'
    })
  payment_type_id = PaymentType.last.payment_type_id
  Payment.new_payment(student.student_id, payment_type_id, 10000, Date.today)
  class_room_id = class_room_ids.shuffle.first.to_s
end

position_names = ['teacher']
position_names.each do |position_name|
    Position.create({:name => position_name})
end