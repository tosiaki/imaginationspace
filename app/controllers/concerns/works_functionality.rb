module Concerns::WorksFunctionality
  extend ActiveSupport::Concern

  def show_work(class_var)
    @work = class_var.find(params[:id])
    instance_variable_set instance_variable_name(class_var), @work
    check_adult @work
    @comments = @work.comments

    @comment = @work.comments.build
  end

  def index_works(class_var)
    instance_var_name = instance_variable_name(class_var).pluralize

    if params[:tags]
      tag_list = params[:tags].split(",").map(&:strip)
      instance_variable_set instance_var_name, class_var.tagged_with(tag_list)
    else
      instance_variable_set instance_var_name, class_var.all
    end
  end

  def check_adult(work)
    if work.explicit? || work.not_rated?
      if params[:view_adult] == 'true' || session[:view_adult]
        session[:view_adult] = true
      else
        @work = work
        render 'shared/_adult_notice'
      end
    end
  end

  private
    def instance_variable_name(class_var)
      "@#{class_var.to_s.downcase}"
    end
end