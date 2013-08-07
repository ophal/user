local json, crypto, tonumber = require 'dkjson', require 'crypto', tonumber
local print, exit, _SESSION = print, exit, _SESSION
local debug, error, empty, header = debug, error, seawolf.variable.empty, header
local theme, tconcat, add_js, read = theme, table.concat, add_js, io.read
local type, env, uuid, time, goto = type, env, uuid, os.time, goto
local session_destroy = session_destroy

module 'ophal.modules.user'

--[[
  Implemens hook_menu().
]]
function menu()
  items = {}
  items['user/login'] = {
    title = 'User login',
    page_callback = 'login_page',
  }
  items['user/logout'] = {
    title = 'User logout',
    page_callback = 'logout_page',
  }
  items['user/auth'] = {
    title = 'User authentication web service',
    page_callback = 'auth_service',
  }
  items['user/token'] = {
    title = 'User token web service',
    page_callback = 'token_service',
  }
  return items
end

function boot()
  -- Load user
  if _SESSION.user == nil then
  _SESSION.user = {
    id = 0,
    name = 'Anonymous',
  }
  end
end

--[[
  Implements hook_init().
]]
function init()
  db_query = env.db_query
end

function is_logged_in()
  if not empty(_SESSION.user) and not empty(_SESSION.user.id) then
    return not empty(_SESSION.user.id)
  end
end

function load(account)
  local rs

  if 'table' == type(account) then
    if not empty(account.id) then
      rs = db_query('SELECT * FROM user WHERE id = ?', account.id)
      return rs:fetch(true)
    elseif not empty(account.name) then
      rs = db_query('SELECT * FROM user WHERE name = ?', account.name)
      return rs:fetch(true)
    end
  end
end

function access(perm)
  local account = _SESSION.user

  if not empty(account) then
    if tonumber(account.id) == 1 then
      return true
    end
  end
  return false
end

function login_page()
  add_js 'misc/jquery.js'
  add_js 'misc/jssha256.js'
  add_js 'misc/json2.js'
  add_js 'modules/user/user_login.js'
  return tconcat{
    '<form method="POST">',
    '<table id="login_form" class="form">',
      '<tr><td>',
      theme.label{title = 'Username'},
      '</td><td>',
      theme.textfield{attributes = {id = 'login_user'}, value = ''},
      '</td></tr>',
      '<tr><td>',
      theme.label{title = 'Password'},
      '</td><td>',
      '<input id="login_pass" type="password" name="pass">',
      '</td></tr>',
      '<tr><td colspan="2" align="right">',
      theme.submit{attributes = {id = 'login_submit'}, value = 'Login'},
      '</td></tr>',
    '</table>',
    '</form>',
  }
end

function logout_page()
  if is_logged_in then
    session_destroy()
    goto ''
  end
end

function create()
  -- INSERT INTO user(name, mail, pass, active, created) values('User', 'user@example.com', 'password', 1, strftime('%s', 'now'));
end

function auth_service()
  local input, parsed, pos, err, account
  local output = {authenticated = false}

  header('content-type', 'application/json; charset=utf-8')

  input = read '*a'
  parsed, pos, err = json.decode(input, 1, nil)
  if err then
    error(err)
  elseif
    'table' == type(_SESSION.user) and 'table' == type(_SESSION.user.token)
    and 'table' == type(parsed) and not empty(parsed.user) and
    not empty(parsed.hash) and time() + 3 >= _SESSION.user.token.ts
  then
    account = load{name = parsed.user}
    if 'table' == type(account) and not empty(account.id) then
      if parsed.hash == crypto.hmac.digest('sha256', account.pass, _SESSION.user.token.id) then
        output.authenticated = true
        _SESSION.user = account
      end
    end
  end

  output = json.encode(output)

  theme.html = function () return output or '' end
end

function token_service()
  header('content-type', 'application/json; charset=utf-8')

  if type(_SESSION.user) == 'table' then
    _SESSION.user.token = {id = uuid.new(), ts = time()}
  end

  theme.html = function () return json.encode(_SESSION.user.token.id) or '' end
end
