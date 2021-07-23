.PHONY: all deps compile

all: deps compile

deps:
	mix deps.get
	mix deps.compile

compile:
	mix compile
