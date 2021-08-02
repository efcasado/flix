.PHONY: all deps compile test clean

all: deps compile

deps:
	mix deps.get
	mix deps.compile

compile:
	mix compile --warnings-as-errors

test:
	mix test

clean:
	mix clean --all
	mix deps.clean --all
	rm -rf _build
