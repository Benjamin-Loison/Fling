all:
	ocamlbuild -use-ocamlfind -package graphics game.native
	mv game.native fling
compress:
	tar czf LOISON_BENJAMIN.tar.gz README.md Makefile *.ml *.mli terrains/ --transform 's,^,LOISON_BENJAMIN/,'
clean:
	ocamlbuild -clean
