require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.sample(9)
    session[:start_time] = Time.now.to_i
  end

  def score
    if any_authenticity_token_valid?
      @result = check_score(params[:word], params[:grid])
    else
      @result = { message: 'I see what you did there (👁👄👁)👉' }
    end
  end

  def check_score(word, grid)
    grid_array = grid.split(',')
    start_time = Time.at(session[:start_time]) || Time.now
    end_time = Time.now
    result = { score: 0, message: '', time: end_time - start_time }
    if check_attempt_grid_regex(word, grid_array) == false
      result[:message] = 'Attempt letters are not in the grid.'
    else
      # Check if input letters contains in lewagon dictionary.
      dict = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{word.downcase}").read)
      result[:message] = dict['found'] ? 'Well Done!' : 'Attempt letters are not an english word.'
      result[:score] = dict['found'] ? (((word.length * 10) + (120 - result[:time].to_f)) / 10.0) : 0
    end
    return result
  end

  def check_attempt_grid_regex(attempt, grid)
    return grid.sort.join.downcase.match?(Regexp.new(".*#{attempt.downcase.chars.to_a.sort.join('.*')}"))
  end
end
