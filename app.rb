require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'httparty'
require 'nokogiri'
require_relative 'db_config'
require_relative 'models/food'
require_relative 'models/user'
require_relative 'models/entry'
require_relative 'models/daily_stat'

enable :sessions

helpers do
  def logged_in?
    !!current_user
  end

  def current_user
    User.find_by(id: session[:user_id])
  end
end

get '/' do
  redirect to "/login" unless logged_in?
  todays_stats = DailyStat.where(stat_date: Date.today, user_id: current_user.id).first

  if todays_stats.nil?
    new_day = DailyStat.new
    new_day.stat_date = Date.today
    new_day.user = current_user
    new_day.save
  end
  
  session[:todays_stats] = DailyStat.where(stat_date: Date.today, user_id: current_user.id).first
  erb :index
end

get '/signup' do
  erb :signup
end

get '/search' do
  page_num = session[:current_page] || 1
  @search_for = params['search']

  if params['next'] && session[:current_page]
    page_num += 1
  elsif params['prev'] && session[:current_page]
    page_num -= 1
  else
    page_num = 1
  end

  session[:current_page] = page_num

  page = HTTParty.get("http://www.myfitnesspal.com/food/search?search=#{@search_for}&page=#{page_num}")
  @mfp_results = []
  parse_page = Nokogiri::HTML(page)
  food_results = parse_page.css('div.food_info')
  food_results.each do |item|
    result = {}
    result['brand'] = item.search('a')[1].text.strip
    result['name'] = item.search('a')[0].text.strip
    result['serving_size'] = item.search('label')[0].next.text.strip.to_f
    result['serving_type'] = item.search('label')[0].next.text.strip.chomp(',')
    result['serving_type'] = result['serving_type'].scan(/[A-Za-z]+/).first
    result['calories'] = item.search('label')[1].next.text.strip.chomp(',').to_f
    result['fat'] = item.search('label')[2].next.text.strip.chomp('g,').to_f
    result['carbs'] = item.search('label')[3].next.text.strip.chomp('g,').to_f
    result['protein'] = item.search('label')[4].next.text.strip.chomp('g').to_f
    @mfp_results.push(result)
  end
  erb :add_food
end

post '/signup' do
  new_email = params[:email]
  new_pass = params[:password]
  new_pass_conf = params["password-confirm"]
  new_user = User.new(email: new_email, password: new_pass, password_confirmation: new_pass_conf)
  if new_user.save
    session[:user_id] = new_user.id
    redirect to "/"
  else
    session[:message] = "An error occured"
    erb :signup
  end
end

post '/logout' do
  session[:user_id] = nil
  session[:message] = nil
  redirect to '/'
end

get '/login' do
  erb :login
end

post '/login' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect to '/'
  else
    erb :login
  end
end

get '/add-food' do
  erb :add_food
end

post '/add-food' do
  new_food = Food.new
  new_food.brand = params[:brand]
  new_food.name = params[:name]
  new_food.calories = params[:calories]
  new_food.fat = params[:fat]
  new_food.carbs = params[:carbs]
  new_food.protein = params[:protein]
  new_food.save

  new_entry = Entry.new
  new_entry.entry_date = Time.now
  new_entry.food = new_food
  new_entry.save

  current_user.entries << new_entry
  current_user.save

  redirect to '/'
end
