# renovate: datasource=github-releases depName=thegeeklab/hugo-geekdoc
THEME_VERSION := v1.5.1
THEME := hugo-geekdoc

BASEDIR := .
THEMEDIR := $(BASEDIR)/themes
CONTENTDIR := $(BASEDIR)/content
DATADIR := $(BASEDIR)/data

.PHONY: all
all: doc

.PHONY: doc
doc: doc-assets

.PHONY: doc-assets
doc-assets:
	mkdir -p $(THEMEDIR)/$(THEME)/; \
	curl -sSL "https://github.com/thegeeklab/$(THEME)/releases/download/${THEME_VERSION}/$(THEME).tar.gz" | tar -xz -C $(THEMEDIR)/$(THEME)/ --strip-components=1

.PHONY: clean
clean:
	rm -rf $(THEMEDIR) $(CONTENTDIR)/**/ $(DATADIR)/*
