Header=../etc/header.html#
Index=../etc/index.html#
Fork=../etc/fork.html#
Pat=*.lua#
Lib=../lib#

go: files adds index clean save 

clean:
	rm *-e
    
files:
	cd  $(Lib); pycco -d ../docs $(Pat)

index:
	@cat $(Index) $(Header)  > index.html
	@$(MAKE) body >> index.html
	@git add index.html

F=$(shell ls [a-z]*.html)
G= $(F:.html=)
body:
	@echo "<h2>Annotated source code:</h2>" >> index.html
	@echo "<ul>" 
	@$(foreach f,$G, echo "<li><a href=$f.html>$f</a>";)
	@echo  "</ul>"

adds:
	@$(foreach f,$F, sed -i -e '19r $(Header)' $f;)
	@$(foreach f,$F, sed -i -e '11r $(Fork)' $f;)

save:
	git add *
	git commit -am "HTML updates"
	git push
