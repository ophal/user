Installation instructions
=========================

1. Create table 'user':

CREATE TABLE user(id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255), mail VARCHAR(255), pass VARCHAR(255), active BOOLEAN, created UNSIGNED BIG INT);

2. Generate a password with following script:

crypto = require 'crypto'
d = crypto.digest.new 'sha256'
d:update 'mypassword'
print(d:final())

NOTICE: this script outputs a password hash, change 'mypassword' by 'yourpass'

3. Create user 1:

INSERT INTO "user" VALUES(1,'root','test@example.com',[password],1,[unix timestamp]);

4. Add math libraries to global env in settings.lua:

env.maths = require 'seawolf.maths'
env.math = math

5. Enable Form API:

settings.formapi = true

6. Enable this module:

settings.modules.user = true
