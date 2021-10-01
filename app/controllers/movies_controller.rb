
class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def sort_and_filter (new_movies,params_sort,params_ratings, session_ratings,session_sort)
      @distinct_ratings=Movie.distinct.pluck("rating")
      if params_ratings
        @ratings_filtered=params_ratings
        @ratings_filtered_keys=@ratings_filtered.keys
        new_movies=new_movies.where(rating: @ratings_filtered_keys)
        session[:ratings]=params[:ratings]
      elsif session_ratings
        @ratings_filtered=session_ratings
        @ratings_filtered_keys=@ratings_filtered.keys
        new_movies=new_movies.where(rating: @ratings_filtered_keys)   
      else
        @ratings_filtered=@distinct_ratings
        new_movies=new_movies.where(rating: @ratings_filtered) 
      end
      
      @get_sorting_type=params_sort
      
      if @get_sorting_type
        new_movies=new_movies.all.order(@get_sorting_type)
        session[:sort_type]=@get_sorting_type
      elsif session_sort
        @get_sorting_type=session[:sort_type]
        new_movies=new_movies.all.order(@get_sorting_type)
      else
        new_movies = new_movies.all
      end
      return new_movies
    end
      
      
    def index
      # session.clear
      
      @new_movies=Movie
      @new_movies=sort_and_filter(@new_movies,params[:sort_type],params[:ratings], session[:ratings],session[:sort_type])
      
      if (session[:ratings] or session[:sort_type]) and (!params[:sort_type] and !params[:ratings])
        if session[:ratings]
          params[:ratings]=session[:ratings]
        end
        if session[:sort_type]
          params[:sort_type]=session[:sort_type]
        end
        flash.keep
        
        redirect_to movies_path(params)      
      end
        
      @movies=@new_movies
      
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end
