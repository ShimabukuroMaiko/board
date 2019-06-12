require 'sinatra'
require 'sinatra/reloader' 
require 'pg'
require 'pry'
require "sinatra/cookies"

enable :sessions

client = PG::connect(
    :host => "localhost",
    :user => 'shimabukuromaiko', :password => '',
    :dbname => "board")

def is_like(post_id)
  @is_like=('select * from likes where user_id=$1 and post_id=$2'[session[:id],post_id])
  # @is_like=('select * from likes where user_id=13 && post_id=27')
end
  


get '/' do
    erb :index
end


get '/login' do
    session[:name] = nil
# @page_msg=[:signup_msg]
# session[:signup_msg]=nil
    erb :login
end


post '/login' do
    name = params[:name]
    password = params[:password]
    
    users = client.exec_params('SELECT * from users where name=$1 and password = $2', [name, password])
  
    users.each do |user|
      if user['name'] == name && user['password'] 
        session[:name] = name
        session[:id]= user['id']
        
        session[:page_msg]="<p>success.<br>ログインできました.</p>"
        # binding.pry
      end
    end
  
    redirect to('/login') if session[:name].nil?
    
    redirect to('/top_page')

  end


get '/top_page' do
  @post=client.exec_params('select posts.id, posts.tittle, posts.date, posts.content, posts.image, posts.user_id, posts.name, users.id creater_id, users.name, users.grade from posts inner join users on posts.user_id=users.id order by posts.id desc')
  @users=client.exec_params("select * from users order by grade desc")
  @post.each do |item|
    item['like_count']=client.exec_params('select count(*) from likes where post_id=$1', [item['id']]).first['count(*)']
  end

  # @is_like(post_id)=('select * from likes where user_id=$1 && post_id=$2',session[:name], post_id)

  @page_msg=session[:page_msg]
  session[:page_msg]=nil
  erb :top_page
end


get '/member' do
  @users=client.exec_params('select * from users')
  @users.each do |user|
    p user
  end
  erb :member
end


get '/signup' do
  redirect '/top_page' if session[:id] != '18'
  erb :signup
end
  
  
post '/signup' do
  redirect '/top_page' if session[:id] != '18'
    name = params[:name]
    email = params[:email]
    password = params[:password]
    grade = params[:grade]
    client.exec_params('INSERT INTO users (name, email, password, grade) VALUES ($1,$2,$3,$4)', [name, email, password, grade])
  
    # session[:name] = name
  # session[:signup_msg]
    redirect to('/')
end


get '/mypage' do
    redirect to('/login') if session[:name].nil?
    id=session[:id]
    @post=client.exec_params('select * from posts where user_id =$1 order by posts.id desc',[session[:id]])
    @images = Dir.glob("./public/image/*").map{|path| path.split('/').last }
    @likes = client.exec_params('select * from posts inner join likes on posts.id=likes.post_id')
    @edit_msg=session[:edit_msg]
    session[:edit_msg]=nil
    erb :mypage
end




get '/post' do
    erb :post
end

post '/post' do
    tittle = params[:tittle]
    content = params[:content]
    
    user_id=session[:id]
    image=params[:img][:filename]

    client.exec_params('INSERT INTO posts (tittle, content, user_id, date, image) VALUES ($1,$2, $3, now(), $4)', [tittle, content, user_id, image])
    # session[:name] = name
    FileUtils.mv(params[:img][:tempfile], "./public/image/#{params[:img][:filename]}")
    
    
    session[:success] = "写真を投稿しました"
  redirect to('/mypage')
end



get '/edit_form/:id' do
    @edit=client.exec_params('select * from posts where id=$1', [params[:id]]).first
    # redirect '/' if @edit.nil?

    erb :edit_form
end


post '/edit_form/:id' do
  tittle = params[:tittle]
  content = params[:content]

  client.exec_params('update posts set tittle = $1, date = $2, content = $3 where id=$4', [tittle, Time.now, content, params[:id]])
  # session[:name] = name
  session[:edit_msg]="<p>編集しました！</p>"
  redirect to('/mypage')

end


get '/delete/:id' do
    client.exec_params('delete from posts where id = $1', [params[:id]])
    redirect to('/mypage')
end


get '/like/:id' do
  user_id=session[:id]
  post_id=params[:id]
  client.exec_params('INSERT INTO likes (user_id, post_id) values($1, $2)', [user_id, post_id])
  redirect to ('top_page')
end

get '/unlike/:id' do
  user_id=session[:id]
  post_id=params[:id]
  client.exec_params('delete from likes where post_id = $1 and user_id = $2', [post_id, user_id])
  redirect to ('/top_page')
end

get '/album' do
@albums=client.exec_params('select image from posts')
erb :album
end