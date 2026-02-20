APP_NAME = Snail
BUNDLE_ID = com.tanmay.Snail
VERSION = 1.0.0
BUILD_DIR = build
APP_DIR = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_DIR)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

SRCS = $(wildcard *.swift)

all: x86_64 arm64 universal bundle

x86_64:
	mkdir -p $(BUILD_DIR)
	xcrun swiftc $(SRCS) -target x86_64-apple-macos12.0 -o $(BUILD_DIR)/$(APP_NAME)_x86_64

arm64:
	mkdir -p $(BUILD_DIR)
	xcrun swiftc $(SRCS) -target arm64-apple-macos12.0 -o $(BUILD_DIR)/$(APP_NAME)_arm64

universal: x86_64 arm64
	lipo -create -output $(BUILD_DIR)/$(APP_NAME) $(BUILD_DIR)/$(APP_NAME)_x86_64 $(BUILD_DIR)/$(APP_NAME)_arm64

bundle: universal
	mkdir -p $(MACOS_DIR)
	mkdir -p $(RESOURCES_DIR)
	cp $(BUILD_DIR)/$(APP_NAME) $(MACOS_DIR)/
	cp Info.plist $(CONTENTS_DIR)/
	echo "APPL????" > $(CONTENTS_DIR)/PkgInfo

dmg: bundle
	mkdir -p $(BUILD_DIR)/dmg_root
	cp -R $(BUILD_DIR)/$(APP_NAME).app $(BUILD_DIR)/dmg_root/
	ln -s /Applications $(BUILD_DIR)/dmg_root/Applications
	hdiutil create -volname $(APP_NAME) -srcfolder $(BUILD_DIR)/dmg_root -ov -format UDZO $(BUILD_DIR)/$(APP_NAME).dmg
	rm -rf $(BUILD_DIR)/dmg_root

clean:
	rm -rf $(BUILD_DIR)
