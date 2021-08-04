.PHONY: all deps compile docs test publish clean

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

publish: deps compile
	mix hex.publish

clean:
	mix clean --all
	mix deps.clean --all
	rm -rf _build
	rm -rf doc
