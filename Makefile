.PHONY: all
.DEFAULT: all

LANGUAGES := c++

define add_lang
$(1)/shell:
	$(MAKE) -C $(1)
	test -f $$@

SHELL_TARGETS += $(1)/shell
endef

$(foreach lang,$(LANGUAGES),$(eval $(call add_lang,$(lang))))

all: $(SHELL_TARGETS)

$(info $(SHELL_TARGETS))
