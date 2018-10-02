VERSION=0.1
NAME=trippy-bricks

LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)
SRC := $(wildcard *.fnl)
OUT := $(patsubst %.fnl,%.lua,$(SRC))

run: $(OUT) ; love .
clean: ; rm -rf releases/* $(OUT)
cleansrc: ; rm -rf $(OUT)

%.lua: %.fnl ; lua lib/fennel --compile --correlate $< > $@

LOVEFILE=releases/$(NAME)-$(VERSION).love

$(LOVEFILE): $(LUA) $(OUT) $(LIBS) sounds font.ttf
	mkdir -p releases/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: $(LOVEFILE)
