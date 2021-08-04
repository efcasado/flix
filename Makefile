.PHONY: all deps compile test clean docs

all: deps compile

deps:
	mix deps.get
	mix deps.compile

compile:
	mix compile --warnings-as-errors

docs:
	mix docs

test:
	mix test

clean:
	mix clean --all
	mix deps.clean --all
	rm -rf _build
	rm -rf doc
