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

  def selected_date
    session[:selected_date] || Date.today
  end

  def days_entries
    Entry.where(user_id: current_user.id, entry_date: selected_date)
  end

  def days_stats
    DailyStat.where(stat_date: selected_date, user_id: current_user.id).first
  end
end

get '/' do
  redirect to "/login" unless logged_in?

  if days_stats.nil?
    new_day = DailyStat.new
    new_day.stat_date = selected_date
    new_day.user = current_user
    new_day.save
  end

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

get '/date' do
  session[:selected_date] = Date.parse(params["selected-date"])
  redirect to '/'
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
  session.clear
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

post '/add-entry' do
  local_result = Food.where(brand: params[:brand], name: params[:name]).first
  mfp_result = nil

  if local_result.nil?
    mfp_result = Food.new({
      brand: params[:brand],
      name: params[:name],
      calories: params[:calories],
      fat: params[:fat],
      carbs: params[:carbs],
      protein: params[:protein]
    })
    mfp_result.save
  end

  new_food = local_result || mfp_result

  new_entry = Entry.new
  new_entry.entry_date = session[:selected_date] || Date.today
  new_entry.food = new_food
  new_entry.save
  current_user.entries << new_entry
  current_user.save

  days_stats.increment!('calories', new_food.calories)
  days_stats.increment!('fat', new_food.fat)
  days_stats.increment!('carbs', new_food.carbs)
  days_stats.increment!('protein', new_food.protein)

  redirect to '/'
end

delete '/delete-entry/:id' do
  entry = Entry.find(params['id'])
  deleted_food = entry.food
  days_stats.decrement!('calories', deleted_food.calories)
  days_stats.decrement!('fat', deleted_food.fat)
  days_stats.decrement!('carbs', deleted_food.carbs)
  days_stats.decrement!('protein', deleted_food.protein)
  entry.destroy
  redirect to '/'
end
