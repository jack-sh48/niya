ActiveAdmin.register CoachSpecialization do

  permit_params :expertise, :focus_areas => []

    form do |f|
      f.inputs do
        f.input :expertise
        f.input :focus_areas, as: :check_boxes, collection: BxBlockAssessmenttest::AssesmentTestTypeAnswer.all.map{|x| [x.answers, x.id]}
      end
    f.actions
  end
end
