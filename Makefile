HTML=rst2html.py
VIEWER_HTML=chromium

ODF=rst2odt.py
MAN=rst2man.py

KINDLEGEN=kindlegen

BUILDDIR=build
STYLEDIR=style

ROOT=root

TARGET=${BUILDDIR}/${ROOT}

TARGET_SUBDIRS=gen_body.rst

STYLEDIR=style

# find all chapters etc.
SOURCE_DIRS=chapters
SUBDIR_SOURCE_FILES=$(foreach subdir,${SOURCE_DIRS},$(sort $(wildcard ${subdir}/*.rst)))

RAW_TEXT=links -dump
WC=wc -w


GENERATED_COMMENT='.. This is a generated file, do not edit'

all:${BUILDDIR} html odf man raw

kindle:html
	sed -e 's/<!-- mbp:pagebreak -->/<mbp:pagebreak\/>/g' ${TARGET}.html > ${TARGET}.kindle.html
	${KINDLEGEN} ${TARGET}.kindle.html

html:setup ${TARGET}.html $(foreach file, $(SUBDIR_SOURCE_FILES:%.rst=%.html), ${BUILDDIR}/${file}) 
odf:setup ${TARGET}.odf $(foreach file, $(SUBDIR_SOURCE_FILES:%.rst=%.odf), ${BUILDDIR}/${file}) 
man:setup ${TARGET}.man $(foreach file, $(SUBDIR_SOURCE_FILES:%.rst=%.man), ${BUILDDIR}/${file})
raw:setup ${TARGET}.txt $(foreach file, $(SUBDIR_SOURCE_FILES:%.rst=%.txt), ${BUILDDIR}/${file}) 
#raw:setup ${TARGET}.txt ${SUBDIR_RAW_FILES}


wc:raw 
	@echo
	@echo
	@echo
	@echo "Number of Words :"
	@exec ${WC} ${SUBDIR_RAW_FILES}

verify:raw
	@echo
	@echo
	@echo

	@exec cat ${SUBDIR_RAW_FILES} | caesar 13 | xclip


	@echo "Paste to verfier . . ."

# setup:${BUILDDIR} ${ROOT}.rst ${TARGET_SUBDIRS}
setup:${BUILDDIR}

view:${TARGET}.html
	${VIEWER_HTML} ${TARGET}.html &

# Generate raw txt files from html files
%.txt: %.html
	@echo $< "->" $@
	@${RAW_TEXT} $< > $@

# Generate html files from rst files in the build dir
${BUILDDIR}/%.html: %.rst
	@echo $< "->" $@
	@${HTML} --stylesheet=style/default.css $< $@

${BUILDDIR}/%.odf: %.rst
	@echo $< "->" $@
	@${ODF} --stylesheet=style/styles.odt $< $@

${BUILDDIR}/%.man: %.rst
	@echo $< "->" $@
	@${MAN} $< $@

# # build a universal chpater include using dir listing for CHAPTERSDIR
# ${TARGET_SUBDIRS}:${SUBDIR_FILES}

# 	@echo 'Generating '$@' build files . . . .'
# 	@echo

# 	@echo ${GENERATED_COMMENT} > $@

# 	@for file in ${SUBDIR_FILES}; do \
# 		echo '	Adding '$$file; \
# 		echo '.. mbp:pagebreak' >> $@; \
# 		echo '.. include:: '$$file >> $@; \
# 	done

# 	@echo 'Done.'

init:	# setup a new initial project
	@if [ ! -d ${STYLEDIR} ] ; then \
		mkdir ${STYLEDIR} ; \
		cp Scrivener/style/* ${STYLEDIR} ; \
	fi

	@for source_dir in ${SOURCE_DIRS}; do \
		if [ ! -d $$source_dir ] ; then \
			echo 'Creating '$$source_dir ;\
			mkdir $$source_dir ; \
			cp Scrivener/$$source_dir/* $$source_dir ; \
		fi ; \
	done

	@if [ ! -f ${ROOT}.rst ] ; then \
		cp Scrivener/${ROOT}.rst . ;\
	fi

# setup the build dir so that everything works nice
${BUILDDIR}:
	@if [ ! -d ${BUILDDIR} ] ; then \
		mkdir ${BUILDDIR}  ; \
	fi

# setup child build dirs
	@for source_dir in ${SOURCE_DIRS}; do \
		if [ ! -d "${BUILDDIR}/$$source_dir" ] ; then \
			mkdir ${BUILDDIR}/$$source_dir ; \
		fi ; \
	done

clean:
	@rm -rf ${BUILDDIR}/${CHAPTERDIR}
	@rm -rf ${BUILDDIR}
	@rm -f ${TARGET_SUBDIRS}
	@find . -name '*~' -exec rm {} \;
