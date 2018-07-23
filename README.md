<a href="http://tiny.cc/burning"><img src="etc/img/burn.png"></a><br clear=all>
[home](http://tiny.cc/burning) | [doc](http://burn.github.io/src) | [code](https://github.com/burn/src) | [discuss](https://github.com/burn/src/issues) | [license](https://github.com/burn/src/blob/master/LICENSE.md)

# README

<img width=550 height=250 src="etc/img/burn-wide.png">

Because learning is not the filling of a pail, but the lighting of a fire. 

## Help

command| notes
------------ | -------------
./burn FILE   |     	run FILE.awk
./burn ed FILE |		edit FILE
./burn okay 	 |	run all tests
./burn zap 	|	delete generated files (forces recompile)
./burn pull	|	get from git
./burn push	|	send back to git
./burn license	|	show license
./burn help	|	show help

As a side-effect of running ./burn, the directory
"$HOME/opt/lua/burn/doc" is updated with current versions of the
html generated from the \*.lua files in this directory.

Note that this code cannot load any X.lua file for
X in ed, okay, zap, pull, push, license, help.

##  Systems

### Files

The system is divided into

```
.
./burn           # shell script with convenience functions
                 # When run, it does "cd lib", then runs there
./data/*         # example data files
./docs/*.html    # auto-generated from lib/*.lua files
./lib/*.lua      # the actual system
./tests/*ok.lua  # to test "lib/x.lua", load "tests/xOk.lua"
```

### Globals

There is only one global.

- Loading ./lib/burn.lua will add `Burn` to the global enviornment.
This global holds some system
stuff
plus whatever global config options needed by the system.
- Loading any other files should be var safe (i.e. only locals defined).

Hence the standard way to use these files is:

```
local Stuff=require("stuff")
```

There is only one global function. `burn()`, which creates `Burn`.

- The first time it is called, then `burn()`
     - Creates `Burn.sys` which is a table holding some system stuff 
       (e.g. test cases, test case cores).
     - Adds '../tests/?.lua' to `package.path`.
- For all subsequent calls, `burn()` does not adjust the current
  contents of `Burn.sys` (which means that, e.g. we can accumulate a 
  global count of passing/failing tests here). 

