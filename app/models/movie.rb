class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(params, api_key = ENV['TMDB_API_KEY'])
    url = "https://api.themoviedb.org/3/search/movie"

    if not params.presence
      return Nil
    end

    query = {
      query: params[:title],
      api_key: api_key
    }
    query[:year] = params[:release_year]
    query[:language] = params[:language] if params[:language] != 'all'

    url = "#{url}?#{query.to_query}"
    response = Faraday.get(url)
    
    if not response 
      return Nil
    end

    results = JSON.parse(response.body)["results"]

    results.map do |movie|
      Movie.new(
        title: movie["title"],
        rating: "R",
        description: movie["overview"],
        release_date: movie["release_date"].presence
      )
    end
  end

end

