.PHONY: all deps compile test

all: deps compile

deps:
	mix deps.get
	mix deps.compile

compile:
	mix compile --warnings-as-errors

test:
	mix test
