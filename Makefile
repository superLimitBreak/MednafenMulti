BIN_DIR = bin
MEDNAFEN_SERVER = $(BIN_DIR)/mednafen-server
MEDNAFEN = $(BIN_DIR)/mednafen

.PHONY: binaries
binaries: $(MEDNAFEN) $(MEDNAFEN_SERVER)

$(MEDNAFEN): $(BIN_DIR)
	cd build/mednafen && $(MAKE) build-dapper
	mv build/mednafen/mednafen $(MEDNAFEN)

$(MEDNAFEN_SERVER): $(BIN_DIR)
	cd build/mednafen-server && $(MAKE) build-dapper
	mv build/mednafen-server/mednafen-server $(MEDNAFEN_SERVER)

$(BIN_DIR):
	mkdir $(BIN_DIR)

.PHONY: clean
clean:
	rm -f -r --interactive=never $(BIN_DIR)
	cd build/mednafen-server && $(MAKE) clean
	cd build/mednafen && $(MAKE) clean
