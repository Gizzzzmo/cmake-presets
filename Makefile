CMAKE          ?= cmake
CTEST 		   ?= ctest
CLANG_TIDY     ?= clang-tidy
CLANG_FORMAT   ?= clang-format
MDFORMAT       ?= mdformat
ALEJANDRA      ?= alejandra
GIT 		   ?= git
ECHO           := $(CMAKE) -E echo
# echo no new line
ECHO_NNN       := $(CMAKE) -E echo_append
CAT            := $(CMAKE) -E cat
CONFIGURE_FILE := $(CMAKE) -P scripts/configure.cmake

DEFAULT_PRESET  ?= a
DEFAULT_PROFILE ?= default
PRESETS         ?= a b
PROFILES        := $(patsubst %.p.json,%,$(filter %.p.json,$(shell ls presets)))

configure_pattern := %.c
build_pattern 	  := %.b
test_pattern      := %.t

configure_presets := $(patsubst %,$(configure_pattern),$(PRESETS))
build_presets     := $(patsubst %,$(build_pattern),$(PRESETS))
test_presets      := $(patsubst %,$(test_pattern),$(PRESETS))

current_profile   := $(shell \
	test -f presets/.current_profile \
	|| $(ECHO_NNN) $(DEFAULT_PROFILE) > presets/.current_profile \
	&& $(CAT) presets/.current_profile)

current_preset    := $(shell \
	test -f presets/.current_preset \
	|| $(ECHO_NNN) $(DEFAULT_PRESET) > presets/.current_preset \
	&& $(CAT) presets/.current_preset)

ECHO_PROFILE   := $(ECHO) "Using profile \"$(current_profile)\""

.PHONY: \
	$(PRESETS) \
	$(configure_presets) \
	$(build_presets) \
	$(test_presets) \
	$(patsubst %,switch\:%,$(PROFILES)) \
	$(patsubst %,s\:%,$(PROFILES)) \
	current \
	re \
	all \
	test \
	test-all \
	lint \
	format \
	show \
	list-profiles \
	list-presets \
	FORCE \
	clean


# build current preset with current profile
current: $(patsubst %,$(build_pattern),$(current_preset))

# (re)configure and build current preset with current profile
re: $(current_preset)

# configure and build all presets with the current profile
all: $(PRESETS)
	@$(ECHO_NNN) $(current_preset) > presets/.current_preset 

# test current preset with current profile
test: $(patsubst %,$(test_pattern),$(current_preset))

# test all presets with the current profile
test-all: $(test_presets)

# lint the current preset with the current profile
lint: $(patsubst %,$(configure_pattern),$(current_preset))
	$(CLANG_TIDY) main.c -p build/compile_commands.json --use-color --warnings-as-errors="*"

# format all source and header files tracked by git
format:
	@$(CMAKE) -P scripts/format.cmake $(CLANG_FORMAT) $(MDFORMAT) $(ALEJANDRA)

# print current profile and current preset
show:
	@$(ECHO) "current_profile: $(current_profile)"
	@$(ECHO) "current_preset:  $(current_preset)"

# list available profiles
list-profiles:
	@$(ECHO) $(PROFILES)

# list available presets
list-presets:
	@$(ECHO) $(PRESETS)

$(PRESETS): %: $(configure_pattern) $(build_pattern)

$(test_presets): $(test_pattern): CMakePresets.json presets/common.json build_dir presets/current_profile.json
	@$(ECHO_NNN) $(patsubst $(test_pattern),%,$@) > presets/.current_preset
	@$(ECHO_PROFILE)
	$(CTEST) --preset $(patsubst $(test_pattern),%,$@)

$(build_presets): $(build_pattern): CMakeLists.txt CMakePresets.json presets/common.json build_dir presets/current_profile.json
	@$(ECHO_NNN) $(patsubst $(build_pattern),%,$@) > presets/.current_preset
	@$(ECHO_PROFILE)
	$(CMAKE) --build --preset $(patsubst $(build_pattern),%,$@)

$(configure_presets): $(configure_pattern): CMakePresets.json presets/common.json CMakeLists.txt build_dir presets/current_profile.json
	@$(ECHO_NNN) $(patsubst $(configure_pattern),%,$@) > presets/.current_preset
	@$(ECHO_PROFILE)
	$(CMAKE) --preset $(patsubst $(configure_pattern),%,$@)

build_dir:
	@$(CMAKE) -E make_directory build

t\:%:
	$(CMAKE) --build --preset $(current_preset) --target $(patsubst t:%,%,$@)

target\:%:
	$(CMAKE) --build --preset $(current_preset) --target $(patsubst target:%,%,$@)


$(patsubst %,s\:%,$(PROFILES)): s\:%:
	@$(ECHO_NNN) $(patsubst s:%,%,$@) > presets/.current_profile
	@$(CONFIGURE_FILE) presets/$(patsubst s:%,%.p.json,$@) presets/current_profile.json
	@$(ECHO) "Switching to profile \"$(patsubst s:%,%,$@)\""
	$(CMAKE) --preset $(current_preset)

$(patsubst %,switch\:%,$(PROFILES)): switch\:%:
	@$(ECHO_NNN) $(patsubst switch:%,%,$@) > presets/.current_profile
	@$(CONFIGURE_FILE) presets/$(patsubst switch:%,%.p.json,$@) presets/current_profile.json
	@$(ECHO) "Switching to profile \"$(patsubst switch:%,%,$@)\""
	$(CMAKE) --preset $(current_preset)

presets/current_profile.json: presets/$(current_profile).p.json .git/HEAD 
	@$(CONFIGURE_FILE) presets/$(current_profile).p.json presets/current_profile.json

FORCE:

clean:
	$(CMAKE) -E remove_directory build/$$($(GIT) rev-parse --abbrev-ref HEAD)
	$(CMAKE) -E remove_directory build/$$($(GIT) rev-parse HEAD)
	$(CMAKE) -E rm -f build/HEAD

	$(CMAKE) -E rm -f presets/current_profile.json presets/.current_profile presets/.current_preset
