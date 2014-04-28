.PHONY: test

test:
	make -C test

# 1. make sure source tree is clean
# 2. tag source tree with version
# 3. push to origin/master
release:
	./script/release
