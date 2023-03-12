# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

unless AdminUser.find_by_email('admin@example.com')

  AdminUser.create(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

end

BxBlockAssessmenttest::Motion.find_or_create_by(motion_title: 'great')
BxBlockAssessmenttest::Motion.find_or_create_by(motion_title: 'good')
BxBlockAssessmenttest::Motion.find_or_create_by(motion_title: 'okaish')
BxBlockAssessmenttest::Motion.find_or_create_by(motion_title: 'bad')
BxBlockAssessmenttest::Motion.find_or_create_by(motion_title: 'terrible')
