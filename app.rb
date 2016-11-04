require 'sinatra'
# require 'sinatra/reloader'
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
    Entry.where(user_id: current_user.id, entry_date: selected_date).order('id ASC')
  end

  def days_stats
    DailyStat.where(stat_date: selected_date, user_id: current_user.id).first
  end
end

def save_entry(entry, food, params)
  params[:servings].nil? || params[:servings].empty? ? entry.servings = 1 : entry.servings = params[:servings]
  entry.serving_type = params['serving-type-choice'] || 'servings'
  if entry.serving_type == 'servings'
    entry.calories = entry.servings * food.calories
    entry.fat = entry.servings * food.fat
    entry.carbs = entry.servings * food.carbs
    entry.protein = entry.servings * food.protein

    entry.serving_size = "#{food.serving_size} #{food.serving_type}"
  else
    calories_per_unit = food.calories / food.serving_size
    fat_per_unit = food.fat / food.serving_size
    carbs_per_unit = food.carbs / food.serving_size
    protein_per_unit = food.protein / food.serving_size

    entry.calories = entry.servings * calories_per_unit
    entry.fat = entry.servings * fat_per_unit
    entry.carbs = entry.servings * carbs_per_unit
    entry.protein = entry.servings * protein_per_unit

    entry.serving_size = "1 #{food.serving_type}"
  end
  entry.save
end

def update_daily_stats
  total_calories = Entry.where(entry_date: selected_date, user: current_user).sum(:calories) || 0.0
  total_fat = Entry.where(entry_date: selected_date, user: current_user).sum(:fat) || 0.0
  total_carbs = Entry.where(entry_date: selected_date, user: current_user).sum(:carbs) || 0.0
  total_protein = Entry.where(entry_date: selected_date, user: current_user).sum(:protein) || 0.0
  days_stats.update(calories: total_calories)
  days_stats.update(fat: total_fat)
  days_stats.update(carbs: total_carbs)
  days_stats.update(protein: total_protein)
end

get '/' do
  redirect to "/diary" if logged_in?
  erb :index
end

get '/home' do
  erb :index
end

get '/diary' do
  redirect to "/login" unless logged_in?
  if days_stats.nil?
    new_day = DailyStat.new
    new_day.stat_date = selected_date
    new_day.user = current_user
    new_day.save
  end
  update_daily_stats
  erb :diary
end

get '/signup' do
  erb :signup
end

get '/search' do
  redirect to "/login" unless logged_in?
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
    result['brand'] = item.search('a')[1].text.strip.capitalize
    result['name'] = item.search('a')[0].text.strip.capitalize
    result['serving_size'] = item.search('label')[0].next.text.strip.to_f.round(2)
    result['serving_type'] = item.search('label')[0].next.text.strip.chomp(',')
    result['serving_type'] = result['serving_type'].scan(/[A-Za-z]+/).first
    result['calories'] = item.search('label')[1].next.text.strip.chomp(',').to_f.round(2)
    result['fat'] = item.search('label')[2].next.text.strip.chomp('g,').to_f.round(2)
    result['carbs'] = item.search('label')[3].next.text.strip.chomp('g,').to_f.round(2)
    result['protein'] = item.search('label')[4].next.text.strip.chomp('g').to_f.round(2)
    @mfp_results.push(result)
  end
  erb :add_entry
end

get '/date' do
  redirect to "/login" unless logged_in?
  session[:selected_date] = Date.parse(params["selected-date"])
  redirect to '/'
end

get '/add-new-food' do
  erb :new_food
end

post '/add-new-food' do
  new_food = Food.new({
    brand: params[:brand],
    name: params[:name],
    serving_type: params['serving-type'],
    serving_size: params['serving-size'],
    calories: params[:calories],
    fat: params[:fat],
    carbs: params[:carbs],
    protein: params[:protein]
  })
  if new_food.save

    new_entry = Entry.new
    new_entry.entry_date = session[:selected_date] || Date.today
    new_entry.food = new_food
    save_entry(new_entry, new_food, params)

    current_user.entries << new_entry
    current_user.save

    redirect to '/diary'
  else
    @errors = new_food.errors.messages
    erb :new_food
  end
end

post '/signup' do
  new_email = params[:email]
  new_pass = params[:password]
  new_pass_conf = params["password-confirm"]
  new_user = User.new(email: new_email, password: new_pass, password_confirmation: new_pass_conf)
  if new_user.save
    session[:user_id] = new_user.id
    redirect to "/diary"
  else
    @errors = new_user.errors.messages
    erb :signup
  end
end

get '/logout' do
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
    redirect to '/diary'
  else
    @errors = "Invalid login details"
    erb :login
  end
end

get '/add-entry' do
  redirect to "/login" unless logged_in?
  erb :add_entry
end

get '/edit-entry/:id' do
  @edit_entry = Entry.find(params[:id])
  erb :edit_entry
end

post '/edit-entry/:id' do
  entry = Entry.find(params[:id])
  food = entry.food
  save_entry(entry, food, params)
  redirect to '/diary'
end

post '/add-entry' do
  local_result = Food.where(brand: params[:brand], name: params[:name]).first
  mfp_result = nil

  if local_result.nil?
    mfp_result = Food.new({
      brand: params[:brand],
      name: params[:name],
      serving_type: params['serving-type'],
      serving_size: params['serving-size'],
      calories: params[:calories].to_f,
      fat: params[:fat].to_f,
      carbs: params[:carbs].to_f,
      protein: params[:protein].to_f
    })
    mfp_result.save
  end

  new_food = local_result || mfp_result
  new_entry = Entry.new
  new_entry.entry_date = session[:selected_date] || Date.today
  new_entry.food = new_food
  save_entry(new_entry, new_food, params)
  current_user.entries << new_entry
  current_user.save
  redirect to '/diary'
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
