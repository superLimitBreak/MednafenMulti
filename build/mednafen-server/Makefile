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
	cd $(SOURCE_DIR) && ./configure
	cd $(SOURCE_DIR) && $(MAKE)
	cp $(SOURCE_DIR)/src/mednafen-server $(BIN_NAME)

$(SOURCE_DIR):
	mkdir $(SOURCE_DIR)
	tar -xf vendor/mednafen-server-0.5.2.tar.xz -C $(SOURCE_DIR) --strip-components=1

.PHONY: update-vendor
update-vendor:
	# update the vendored copy of mednafen-server
	# version may need to be bumped later
	curl -o /tmp/mednafen-server-0.5.2.tar.xz https://mednafen.github.io/releases/files/mednafen-server-0.5.2.tar.xz
	rm -f vendor/mednafen-server-0.5.2.tar.xz
	cp /tmp/mednafen-server-0.5.2.tar.xz vendor/mednafen-server-0.5.2.tar.xz

$(DAPPER_BIN):
	sudo curl -o $(DAPPER_BIN) -sL https://releases.rancher.com/dapper/latest/dapper-`uname -s`-`uname -m`
	sudo chmod +x $(DAPPER_BIN)
