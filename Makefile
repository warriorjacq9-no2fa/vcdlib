all: run
run: build
	bin/vcd < test.vcd

build:
	mkdir -p bin
	flex vcd_lexer.l
	bison -d vcd.y
	gcc hobj.c types.c vcd.tab.c lex.yy.c -o bin/vcd

clean:
	rm -rf bin *.tab.c *.yy.c *.tab.h *.output