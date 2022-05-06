class TranslationController < ApplicationController
  def create
    translation = Translation.create({
      title: params[:title]
    })
    params[:pages].each_with_index do |page, index|
      translation_page = TranslationPage.create({
        translation: translation,
        filename: page['filename'],
        order: index+1
      })
      page['lines'].each_with_index do |line, index|
        TranslationLine.create({
          original: line[:original],
          translation: line[:translation],
          translation_page: translation_page,
          order: index+1
        })
      end
    end


    render json: {
      success: 1
    }
  end

  def show
    translation_id = params[:specifier].split('-')[-1]
    translation = Translation.includes(:translation_pages, :translation_lines).find(translation_id)
    render json: {
      translation: translation,
      pages: translation.translation_pages,
      lines: translation.translation_lines
    }
  end
end
