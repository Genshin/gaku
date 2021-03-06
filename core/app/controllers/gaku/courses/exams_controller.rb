module Gaku
  class Courses::ExamsController < GakuController
    respond_to :html

    def grading
      def init_variables
        @course = Course.find(params[:course_id])
        @exam = Exam.find(params[:id])
        @students = @course.students
        @exams = if !params[:id].nil?
                   Exam.find_all_by_id(params[:id])
                 else
                   @course.syllabus.exams.all
                 end

        # 試験の平均点を入れるハッシュ
        @exams_average = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

        # 試験の合計点を入れるハッシュ
        @student_exams_total_score = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

        # 偏差値を入れるハッシュ
        @student_exams_deviation = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

        # for grade and rank--------
        # １０段階用の設定
        # @student_exams_grade: 生徒の１０段階を入れるHash。
        @student_exams_grade = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

        # ５段階用の設定
        # @student_exams_rank: 生徒の５段階を入れるHash。
        @student_exams_rank = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      end

      def set_student_exams_total_scores_and_set_exams_average
        @exams.each do |exam|
          @students.each do |student|
            # 素点用と得点用変数の初期化 --------
            @student_exams_total_score[:raw][exam.id][student.id] = 0.0
            @student_exams_total_score[exam.id][student.id] = 0.0

            @exams_average[:raw][exam.id] = 0.0
            @exams_average[exam.id] = 0.0

            exam.exam_portions.each do |portion|
              seps = student.exam_portion_scores.where(exam_portion_id: portion.id).first.score.to_f

              @student_exams_total_score[:raw][exam.id][student.id] += seps
              @student_exams_total_score[exam.id][student.id] += if exam.use_weighting
                                                                   (portion.weight.to_f / 100) * seps
                                                                 else
                                                                   seps
                                                                 end
            end

            # calc for average --------
            @exams_average[:raw][exam.id] += @student_exams_total_score[:raw][exam.id][student.id]
            @exams_average[exam.id] += @student_exams_total_score[exam.id][student.id]
          end

          # set Exams Average --------
          if exam === @exams.last
            @exams_average[:raw][exam.id] = fix_digit @exams_average[:raw][exam.id] / @students.length, 4
            @exams_average[exam.id] = fix_digit @exams_average[exam.id] / @students.length, 4
          end
        end
      end

      def set_student_exams_deviaton
        def get_standard_deviation(exam)
          scratch_standard_deviation = 0.0
          @students.each do |student|
            scratch_standard_deviation += (@student_exams_total_score[exam.id][student.id] - @exams_average[exam.id])**2
          end
          Math.sqrt scratch_standard_deviation / @students.length
        end

        def get_deviation(standard_deviation, exam, student)
          scratch_deviation = (@student_exams_total_score[exam.id][student.id] - @exams_average[exam.id]) / standard_deviation
          if scratch_deviation.nan?
            return 50
          else
            return fix_digit @student_exams_deviation[exam.id][student.id] * 10 + 50, 4
          end
        end

        # start main --------
        @exams.each do |exam|
          standard_deviation = get_standard_deviation(exam)

          # set deviations --------
          @students.each do |student|
            @student_exams_deviation[exam.id][student.id] = get_deviation(standard_deviation, exam, student)
          end
        end
      end

      def set_student_exams_grade_and_rank
        # def method_ratio(grading_method)
        def method_ratio
          default_grade_level_deviation = [100, 66, 62, 58, 55, 50, 45, 37, 0]
          @rank_level = [15, 20]

          # default_grade_level_percent = [5, 5, 10, 10, 30, 10, 100]

          default = {
            # for grade ----
            g10: 100,
            g9: 66,
            g8: 62,

            # for rank----
            r10: 5,
            r9: 5,
            r8: 10
          }

          default = {
            grade: {
              g10: 100,
              g9: 66,
              g8: 62
            },
            rank: {
              r10: 5,
              r9: 5,
              r8: 10
            }
          }

          # @grade_level_deviation:
          #   １０段階の全体評価で判定する時に使う変数。
          #   決められた偏差値を基に、生徒の偏差値と比べ、その多寡で評価を行う。
          # @grade_level_percent:
          #   １０段階の相対評価で判定する時に使う変数。
          #   決められたパーセンテージを元に、生徒がクラス内で上位何％以内かを調べ、評価を行う。

          @parsed_grading_method = JSON.parse grading_method.method.arguments, symbolize_names: true

          @grade_level_deviation = [100, 66, 62, 58, 55, 50, 45, 37, 0]
          @grade_level_percent = [5, 5, 10, 10, 30, 10, 100]

          # @rank_level: ５段階を付ける時に使うパーセンテージ配列の変数。
          @rank_level = [15, 20]

          # Grade and Rank Calculation （ここは別途光ヶ丘の生徒評価表を参照して下さい）-------- {
          # set grade and rank --------
          @exams.each do |exam|
            # 生徒の順位用配列を作成
            exam_student_scores = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) } # 生徒の順位を出す為の変数。

            # 試験毎の合計点数と生徒IDをexam_student_scoresに格納する。
            @students.each do |student|
              exam_student_scores[student.id] = @student_exams_total_score[exam.id][student.id]
            end
            # 試験のスコアを降順に並び替える
            exam_student_scores = exam_student_scores.sort_by { |_key, val| -val }

            # 採点方式を選択、その採点方式でGradeを決定。
            grading_method = 1
            grade_point = 10

            case grading_method

            # calc for 全体評価
            when 1
              @grade_level_deviation.each_with_index do |_glevel, i|
                @students.each do |student|
                  if @grade_level_deviation[i] > @student_exams_deviation[exam.id][student.id] && @grade_level_deviation[i + 1] <= @student_exams_deviation[exam.id][student.id]
                    @student_exams_grade[exam.id][student.id] = grade_point
                  end
                end
                grade_point -= 1
              end

            # calc for 相対評価
            when 2
              scratch_exam_student_scores = exam_student_scores.clone
              grade_limit_nums = []
              @grade_level_percent.each do |glevel|
                grade_limit_nums.push((@students.length * (glevel.to_f / 100)).ceil)
              end
              grade_limit_nums.each do |gnum|
                i = 0
                while i < gnum && !scratch_exam_student_scores.empty?
                  @student_exams_grade[exam.id][scratch_exam_student_scores.shift[0]] = grade_point
                  i += 1
                end
                grade_point -= 1
              end

            end

            # Rank Calculation --------
            # rankPoint = 5
            # @students.each do |student|
            #   @student_exams_rank[exam.id][student.id] = 3
            # end
            # rankNums = []
            # @rank_level.each do |rlevel|
            #   rankNums.push((@students.length * (rlevel.to_f / 100)).ceil)
            # end
            # rankNums.each do |rnum|
            #   i = 0
            #   while i < rnum && exam_student_scores.length != 0
            #     scoreMem = exam_student_scores.shift()
            #     @student_exams_rank[exam.id][scoreMem[1]] = rankPoint
            #     if exam_student_scores.length != 0 and scoreMem[0] == exam_student_scores[0][0]
            #       rnum += 1
            #     end
            #     i += 1
            #   end
            #   rankPoint -= 1
            # end
            # exam_student_scores.each do |score|
            #   if @student_exams_grade[exam.id][socre[1]] == 3
            #     @student_exams_rank[exam.id][score[1]] = 2
            #   elsif @student_exams_grade[exam.id][socre[1]] < 3
            #     @student_exams_rank[exam.id][score[1]] = 1
            #   end
            # end
          end
        end

        # start main --------
        # p '@exam.grading_method.method -------'
        # p @exam.grading_method

        # case @exam.grading_method.method
        case 'ratio'

        when 'ratio'
          # method_ratio(@exam.grading_method)
          # method_ratio()
          method = Grading::Ratio.new arguments

          exam.student_score.each do |student|
            results += method.grade(student, exam)
          end

          return results

        end
      end

      def fix_digit(num, digit_num)
        for_fix = 10**digit_num
        num *= for_fix
        num = if num.nan?
                0
              else
                num.truncate.to_f / for_fix.to_f
              end
        num
      end

      # start main --------
      init_variables
      init_portion_scores
      set_student_exams_total_scores_and_set_exams_average
      set_student_exams_deviaton
      set_student_exams_grade_and_rank

      respond_with @exam
    end

    private

    def init_portion_scores
      @students.each do |student|
        @exam.exam_portions.each do |portion|
          unless portion.exam_portion_scores.pluck(:student_id).include?(student.id)
            ExamPortionScore.create!(exam_portion: portion, student: student)
          end
        end
      end
    end
  end
end
