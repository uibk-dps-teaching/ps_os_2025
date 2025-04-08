# Use this file at your own risk.
# Always ensure that the required files are actually put into the archive,
# and that no additional files are archived.
# You can use the zipinfo command to check the file structure of an existing archive.

# --- ADJUST BELOW ----------------------------------------------------------------------------------

# Number of people: set to 1, 2 or 3 (how many zips to create)
PEOPLE ?= 3
USERNAME_PERSON_1 = csbaXXXX
USERNAME_PERSON_2 = csbbXXXX
USERNAME_PERSON_3 = csbcXXXX
EXERCISE = 05

# Data for group.txt. Only relevant if PEOPLE is greater than 1.
PERSON_1 = Max Mustermann
PERSON_2 = Gordon Freeman
PERSON_3 = Alyx Vance
MAT_NUM_1 = 12345678
MAT_NUM_2 = 87654321
MAT_NUM_3 = 98765432

# ---------------------------------------------------------------------------------------------------

# This excludes some common directories automatically.
# Also ignores all binaries and README.md.
EXCLUDE_PATTERNS = "**.vscode/*" "**.idea/*" "**__MACOSX/*" "**.DS_Store/*" "**.dSYM/*" "**/*.o" "**/a.out" "README.md"

ARCHIVE_PERSON_1 = ./exc$(EXERCISE)_$(USERNAME_PERSON_1).zip
ARCHIVE_PERSON_2 = ./exc$(EXERCISE)_$(USERNAME_PERSON_2).zip
ARCHIVE_PERSON_3 = ./exc$(EXERCISE)_$(USERNAME_PERSON_3).zip

# Define all possible archives and select only the first $(PEOPLE) ones.
ARCHIVES := $(ARCHIVE_PERSON_1) $(ARCHIVE_PERSON_2) $(ARCHIVE_PERSON_3)
SUBARCHIVES := $(wordlist 1, $(PEOPLE), $(ARCHIVES))

# --- TARGETS ---

.PHONY: all
all: prepare zip

# prepare: execute clean, group, format, and setperms in order
.PHONY: prepare
prepare:
	@for target in clean group format setperms; do \
		echo "Executing $$target..."; \
		$(MAKE) $$target; \
	done

#  cleans all task subdirectories and removes any existing group.txt file
.PHONY: clean
clean:
	@echo "Cleaning task folders in exercise$(EXERCISE)..."
	@for dir in ./exercise$(EXERCISE)/task_*; do \
		if [ -d "$$dir" ]; then \
			-$(MAKE) -C "$$dir" clean || echo "Warning: no clean target in $$dir"; \
		fi; \
	done
	@rm -f exercise$(EXERCISE)/group.txt

# creates the group.txt file dynamically (only if PEOPLE > 1)
# by looping over the number of people and appending the corresponding matriculation number and full name
.PHONY: group
group:
ifeq ($(strip $(PEOPLE)),1)
	@echo "Single submission detected: group.txt will not be created."
else
	@echo "Creating group.txt in exercise$(EXERCISE)..."
	@rm -f exercise$(EXERCISE)/group.txt
	@for i in 1 2 3; do \
	    if [ $$i -le $(PEOPLE) ]; then \
	        case $$i in \
	            1) echo "$(MAT_NUM_1) $(PERSON_1)" >> exercise$(EXERCISE)/group.txt ;; \
	            2) echo "$(MAT_NUM_2) $(PERSON_2)" >> exercise$(EXERCISE)/group.txt ;; \
	            3) echo "$(MAT_NUM_3) $(PERSON_3)" >> exercise$(EXERCISE)/group.txt ;; \
	        esac; \
	    fi; \
	done
endif

# Uses clang-format to format all .c files
# It first checks if clang-format is installed
# if not, it skips formatting
.PHONY: format
format:
	@echo "Formatting all .c files in exercise$(EXERCISE)..."
	@if command -v clang-format >/dev/null 2>&1; then \
		find exercise$(EXERCISE) -type f -name "*.c" -exec clang-format -i {} \; ; \
	else \
		echo "clang-format not found, skipping formatting."; \
	fi

# Sets world-readable permissions on all files in the exercise folder
.PHONY: setperms
setperms:
	@echo "Setting world-read permissions for all files in exercise$(EXERCISE)..."
	@find exercise$(EXERCISE) -type f -exec chmod a+r {} \;
# chmod a+r
# a... all users
# +... add
# r... read


# Creates zip archives for submission.
# Dynamically iterates over the first $(PEOPLE) archives from our list
.PHONY: zip
zip: prepare
	@mkdir -p submission
	$(RM) $(foreach a,$(ARCHIVES),./submission/$(a))
	@echo "Creating zip archives for $(PEOPLE) people..."
	$(foreach archive,$(SUBARCHIVES), (cd exercise$(EXERCISE) && zip -r ../submission/$(archive) . --exclude $(EXCLUDE_PATTERNS));)

.PHONY: all clean group format setperms zip
