require 'rails_helper'

describe MoviesController, type: :controller do
    describe 'searching TMDb' do
      before :each do
        @fake_results = [double('movie1'), double('movie2')]
      end
      it 'calls the model method that performs TMDb search' do
        expect(Movie).to receive(:find_in_tmdb).with(hash_including(title: 'hardware')).
         and_return(@fake_results)
        get :search_tmdb, params: { title: 'hardware', release_year: '', language: 'en' }
     end
     describe 'after valid search' do
       before :each do
         allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
         get :search_tmdb, params: { title: 'hardware', release_year: '', language: 'en' }
       end
       it 'selects the Search Results template for rendering' do
         expect(response).to render_template('search_tmdb')
       end
       it 'makes the TMDb search results available to that template' do
         expect(assigns(:movies)).to eq(@fake_results)
       end
     end
   end

    describe 'adding a movie from search results' do
    let(:movie_params) do
        { title: 'Manhunter', rating: 'R', release_date: '1986-08-15' }
    end

    it 'saves the movie to the database' do
        expect { post :add_movie, params: movie_params }.to change(Movie, :count).by(1)
    end

    it 'saves the correct attributes' do
        post :add_movie, params: movie_params
        movie = Movie.find_by(title: 'Manhunter')
        expect(movie.rating).to eq('R')
        expect(movie.release_date).to eq(Date.new(1986, 8, 15))
    end

    it 'redirects back to the search page' do
        post :add_movie, params: movie_params
        expect(response).to redirect_to(search_path)
    end

    it 'shows a success message with the movie title' do
        post :add_movie, params: movie_params
        expect(flash[:success]).to eq('Manhunter was successfully added to RottenPotatoes.')
    end
    end

    

 end