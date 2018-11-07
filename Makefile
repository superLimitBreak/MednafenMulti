BIN_DIR = bin
MEDNAFEN_SERVER = $(BIN_DIR)/mednafen-server

#.PHONY: mednefen-source
#mednefen-source: $(BIN_DIR)
#	exit 1

.PHONY: mednefen-server
mednefen-server: $(MEDNAFEN_SERVER)

$(MEDNAFEN_SERVER): $(BIN_DIR)
	cd build/mednafen-server && $(MAKE) build-dapper
	mv build/mednafen-server/mednafen-server $(MEDNAFEN_SERVER)

$(BIN_DIR):
	mkdir $(BIN_DIR)

.PHONY: clean
clean:
	rm -f -r --interactive=never $(BIN_DIR)
	cd build/mednafen-server && $(MAKE) clean
