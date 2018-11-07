SOURCE_DIR = mednafen-server-source
DAPPER_BIN = /usr/local/bin/dapper
BIN_NAME =  mednafen-server

.PHONY: build-dapper
build-dapper: $(DAPPER_BIN)
	$(DAPPER_BIN) -k -m bind $(BIN_NAME)

.PHONY: clean
clean:
	sudo rm -f --interactive=never -r $(SOURCE_DIR)
	rm -f --interactive=never $(BIN_NAME)

$(BIN_NAME): $(SOURCE_DIR)
	# convert to build in dapper
	cd $(SOURCE_DIR) && ./configure
	cd $(SOURCE_DIR) && $(MAKE)
	cp $(SOURCE_DIR)/src/mednafen-server $(BIN_NAME)

$(SOURCE_DIR):
	curl -o $(SOURCE_DIR).tar.xz https://mednafen.github.io/releases/files/mednafen-server-0.5.2.tar.xz
	mkdir $(SOURCE_DIR)
	tar -xf $(SOURCE_DIR).tar.xz -C $(SOURCE_DIR) --strip-components=1
	rm $(SOURCE_DIR).tar.xz

$(DAPPER_BIN):
	curl -sL https://releases.rancher.com/dapper/latest/dapper-`uname -s`-`uname -m` > $(DAPPER_BIN)
	chmod +x $(DAPPER_BIN)
