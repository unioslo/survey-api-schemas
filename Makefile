all: bundle

# list of files that need to be bundled
src_files := $(wildcard schema/2*/Submission.json)
# convert to target paths
dst_files := $(patsubst %Submission.json,%Submission.bundle.json, $(src_files))


.PHONY: bundle
bundle: install $(dst_files)

$(dst_files): %.bundle.json: %.json
	node tools/makeBundle.js $^ $@

.PHONY: install
install:
	npm install
