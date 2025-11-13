all: run
run: build
	bin/vcd

build:
	mkdir -p bin
	flex vcd_lexer.l
	bison -d vcd.y
	gcc vcd.tab.c lex.yy.c -o bin/vcd

clean:
	rm -rf bin *.tab.c *.yy.c