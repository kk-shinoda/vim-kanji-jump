.PHONY: test lint

test:
	vusted --shuffle test/

lint:
	luacheck lua/ test/ --globals vim describe it before_each assert
