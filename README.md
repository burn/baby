<a href="http://tiny.cc/burning"><img src="etc/img/burn.png"></a><br clear=all>
[home](http://tiny.cc/burning) | [doc](http://burn.github.io) | [code](https://github.com/burn/burn) | [discuss](https://github.com/burn/burn/issues) | [license](https://github.com/burn/burn/blob/master/LICENSE.md)

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
