SOURCEDIR := src
SOURCES := $(shell find $(SOURCEDIR) -name '*.lua')
CART := picorausers

all: $(CART).p8

$(CART).p8: $(CART).lua
	p8tool build --lua $(CART).lua $(CART).p8

$(CART).lua: $(SOURCES)
	cat $(SOURCES) > $(CART).lua
