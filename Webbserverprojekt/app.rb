require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/')do
db = SQLite3::Database.new("db/todo.db")
slim(:index)
end

def set_error(error_message)
    session[:error] = error_message
    slim(:error)
end

get('/error')do

slim(:error)
end

post('/register') do
    db = SQLite3::Database.new("db/todo.db")
    db.results_as_hash = true
    username= params["username"]
    password= params["password"]
    password_confirmation =params["password_confirmation"]

    result = db.execute("SELECT id FROM users WHERE name=?", [username])
    p result
    if result.empty?
        if password == password_confirmation
            password_digest = BCrypt::Password.create(password)
            p password_digest
            db.execute("INSERT INTO users(name, password) VALUES(?,?)", [username, password_digest])
            redirect('/reg_confirm')
        else
            p 2
            set_error("PASS DONT MATCH MAAN")
            redirect('/error')
        end
    else
        p 1
        set_error("username nalready exist")
        redirect('/error')
    end
            
end

post('/login') do
    db = SQLite3::Database.new("db/todo.db")
    db.results_as_hash = true
    username= params["username"]
    password1= params["password"]
    result1 = db.execute("SELECT id, password FROM users WHERE name=?", [username])

    if result1.empty?
        set_error("finns ej bror")
        redirect('/error')
    end

    user_id = result1.first["id"]
    password = result1.first["password"]
    if BCrypt::Password.new(password)==password1
        session[:user_id] = user_id
        redirect('/reg_confirm')
    else
        set_error("fel uppgifter bror")
        redirect('/error')
    end
end

get('/reg_confirm') do
    user_id = session[:user_id]
    db = SQLite3::Database.new("db/todo.db")
    db.results_as_hash = true
    result = db.execute("SELECT id,todo FROM lists WHERE user_id = ?", user_id)
    p result

    slim(:"lists/index1",locals:{todo:result})
end

post('/create') do
    user_id = session[:user_id]
    todo= params["todo"]
    db = SQLite3::Database.new("db/todo.db")
    db.results_as_hash = true
    db.execute("INSERT INTO lists (todo, user_id) VALUES (?,?)", [todo, user_id])
  
    redirect('/reg_confirm')
  
  end

post('/:id/delete') do
    item_id = params["id"].to_i
    
    db = SQLite3::Database.new("db/todo.db")
    db.results_as_hash = true
    db.execute(" DELETE FROM lists WHERE id = ?", item_id)

    redirect('/reg_confirm')
end

get('/all_lists') do
    user_id = session[:user_id]
    if user_id == 6   
        db = SQLite3::Database.new("db/todo.db")
        db.results_as_hash = true
        result = db.execute("SELECT id,todo,user_id FROM lists ")
      
    

        slim(:"lists/index2",locals:{todo:result})
    else
        set_error("Du ÄR inte AdMin BROR")
        redirect('/error')
    end

end