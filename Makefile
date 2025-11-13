all: run
run: build
	bin/vcd

build:
	mkdir bin
	bison vcd.y
	gcc vcd.tab.c -o bin/vcd

clean:
	rm -rf bin *.tab.c