# Author: Paul Ockleford

# Its important to understand that a makefile is really being processed by two languages, lines not prefixed
# by a tab character are interpreted by make itself, lines prefixed by a tab are interpreted as 'recipes' and
# are executed by the shell (default is /bin/sh although this can be changed to bash)
#
# Phony target means 'all' is always out of date irrespective of filesystem timestamps and so will always
# be a candidate for execution, further to this targets that do not represent files are known as phony targets
#
# Normally, phony targets will always be executed because the commands associated with the rule do not create the target name.
# It is important to note that make cannot distinguish between a file target and phony target. If by chance the name of a phony 
# target exists as a file, make will associate the file with the phony target name in its dependency graph
#
# In addition to marking a target as always out of date, specifying that a target is phony tells make that 
# this file does not follow the normal rules for making a target file from a source file.
.PHONY: all

# Define a simple variable which can be referred to using $() syntax, simple variables are expanded in place
LS := ls -alh

# Define a recursively expanded variable which is stored with no evaluation and only expanded upon use
# as evaluation is deferred assignment can be performed out of order, e.g in the example below LS_BARE might not be 
# assigned a value until after LS_HOME has been defined
LS_HOME	= $(LS_BARE) ~

# Conditional assignment operator will only assign a value if the variable is not already assigned a value
COND_VAR := "IS_SET"
COND_VAR ?= $(HOME)

LS_BARE := ls

# Appending operator enable a variable to be appended to
SIMPLE := "Hello"
COMPLEX = ps

# The all recipe does not include stage one yet it runs, this is because stage one is defined as a 'pre-requisite' of stage two,
# and so any time that stage two executes, then stage one will also be executed
all: stage-two stage-three stage-four stage-five stage-six stage-seven

stage-one:
	$(call stdout, "SUBMODULE :: Stage one is running using a simple expanded variable")
	$(LS)

stage-two: stage-one
	$(call stdout, "SUBMODULE :: Stage two is running using a recursively expanded variable")
	$(LS_HOME)

stage-three:
	$(call stdout, "SUBMODULE :: Stage three is running using a conditional variable")
	@echo "$(COND_VAR)"

SIMPLE += World
stage-four:
	$(call stdout, "SUBMODULE :: Stage four is running with a simple appended variable")
	@echo "$(SIMPLE)"

COMPLEX += -eaf
stage-five:
	$(call stdout, "SUBMODULE :: Stage five is running with a complex appended variable")
	$(COMPLEX)

stage-six: stage-five
	$(call stdout, "SUBMODULE :: Stage six is running and outputting automatic variables")
	@echo "Each line in a recipe will spawn a new shell so to use a bash variable you need to run your echo command inline"
	@TARGET='File name of the target is referred to by $$@: '; echo "$${TARGET} $@"
	@TARGET_MEMBER='The target member name is referred to by $$%, this is empty if target is not an archive member'; echo "$${TARGET_MEMBER}: $%"
	@PRE_REQS='The names of all the pre-requisites are referred to by $$^'; echo "$${PRE_REQS}: $^"
	@FIRST_PRE_REQ='The name of the first pre-requisite is referred to by $$<'; echo "$${FIRST_PRE_REQ}: $<"
	@NEWER_PRE_REQS='The names of the pre-requisites that are newer than the target are referred to by $$?'; echo "$${NEWER_PRE_REQS}: $?"

stage-seven: stage-eight
	$(call stdout, "SUBMODULE :: Stage seven should run AFTER stage eight because stage eight is defined as PHONY and is a pre-req of stage seven")
	$(COMPLEX)

.PHONY: stage-eight
stage-eight:
	$(call stdout, "SUBMODULE :: Stage eight is running and is declared as .PHONY")

# Defines a macro, which is like a function and can be called and passed arguments, e.g $1
# This macro simply sets the foreground color and turns off attributes using tput and then
# echoes the first argument. Pre-fixing a shell command with '@' instructs make to run this command
# silently instead of printing the command
define stdout
	@tput setaf 3
	@echo $1
	@tput sgr0
endef
