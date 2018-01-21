class Rating < ActiveRecord::Base
  belongs_to :movies, primary_key: 'movie_id'
end
