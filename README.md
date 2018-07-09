<a href="http://tiny.cc/burning"><img src="etc/img/burn.png"></a><br clear=all>
[home](http://tiny.cc/burning) | [code]() | [src]()

# Readme

<img width=300  src="etc/img/burn-wide.png">

Because learning is not the filling  a pail, but the lighting of a fire. 

v0.1 (c) 2018, Tim Menzies, BSD 2-clause license

## Help

cd lib

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
"/Users/timm/opt/lua/burn/doc" is updated with current versions of the
html generated from the \*.lua files in this directory.

Note that this code cannot load any X.lua file for
X in ed, okay, zap, pull, push, license, help.
