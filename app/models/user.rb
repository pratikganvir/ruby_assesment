class User < ApplicationRecord
    enum kind: [:student, :teacher, :student_teacher]
    has_many :enrollments

    has_many :teachers, through: :enrollments, foreign_key: :teacher_id do
        def favorites
            where('enrollments.favorite': true)
        end
    end

    has_many :programs, through: :enrollments

    validate :is_student, on: :update
    validate :is_teacher, on: :update

    def is_student
        if Enrollment.where(teacher_id: id).exists?
          errors.add :base, :not_student, message: I18n.t('errors.messages.not_student')
        end
    end

    def is_teacher
        if Enrollment.where(user_id: id).exists?
          errors.add :base, :not_teacher, message: I18n.t('errors.messages.not_teacher')
        end
    end

    def self.classmates(user)
        User.includes(:enrollments).where.not(id: user.id).where(kind: :student).where('enrollments.program_id': user.programs.map(&:id))
    end
end
