NOTICE: This module is now part of Ophal core http://github.com/ophal/core

Ophal user module
=================

A user system is required by the CMS module, in order to control priveleges and access.

Requirements
- Admin UI
  - CRUD users
  - CRUD permissions
- API
  - user_access()
  - user_is_logged_in()
  - theme.user_box()
- Front-end UI
  - Login form
  - User profile

Dependencies
------------
- LuaCrypto http://luacrypto.luaforge.net/
- dkjson http://chiselapp.com/user/dhkolf/repository/dkjson/home
