Header=../etc/header.html#
Index=../etc/INDEX.html#

go: files adds index clean save 

clean:
	rm *-e
    
files:
	cd  ../lib; pycco -d ../docs *.lua
	cp $(Index) .

index:
	@sed -i -e '10,$$d' INDEX.html
	@cat $(Header)  >> INDEX.html
	@$(MAKE) body >> INDEX.html

F=$(shell ls [a-z]*.html)
G= $(F:.html=)
body:
	@echo "<h2>Annotated source code:</h2>" >> INDEX.html
	@echo "<ul>" 
	@$(foreach f,$G, echo "<li><a href=$f.html>$f</a>";)
	@echo  "</ul>"

adds:
	@$(foreach f,$F, sed -i -e '19r $(Header)' $f;)

save:
	git add *
	git commit -am "HTML updates"
	git push
