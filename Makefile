all: run
run: build
	bin/vcd

build:
	mkdir bin
	flex vcd_lexer.l
	bison vcd.y
	gcc vcd.tab.c vcd.yy.c -o bin/vcd

clean:
	rm -rf bin *.tab.c *.yy.c