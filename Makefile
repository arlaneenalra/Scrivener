HTML=rst2html.py
VIEWER_HTML=chromium

# PDF=rst2pdf
# VIEWER_PDF=evince

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
SUBDIR_TARGET_FILES=$(foreach file, $(SUBDIR_SOURCE_FILES:%.rst=%.html), ${BUILDDIR}/${file})
SUBDIR_RAW_FILES=$(foreach file, $(SUBDIR_TARGET_FILES:%.html=%.txt), ${file})

RAW_TEXT=links -dump
WC=wc -w


GENERATED_COMMENT='.. This is a generated file, do not edit'

all:html

kindle:html
	sed -e 's/<!-- mbp:pagebreak -->/<mbp:pagebreak\/>/g' ${TARGET}.html > ${TARGET}.kindle.html
	${KINDLEGEN} ${TARGET}.kindle.html

html:setup ${TARGET}.html ${SUBDIR_TARGET_FILES}
raw:setup ${TARGET}.txt ${SUBDIR_RAW_FILES}

# pdf:${TARGET}.pdf

wc:clean html 
	@echo
	@echo
	@echo
	@echo "Number of Words :"
	@exec ${RAW_TEXT} | ${WC}

verify:clean html
	@echo
	@echo
	@echo

	@exec ${RAW_TEXT} | caesar 13 | xclip

	@echo "Paste to verfier . . ."

# setup:${BUILDDIR} ${ROOT}.rst ${TARGET_SUBDIRS}
setup:${BUILDDIR}

view:${TARGET}.html
	${VIEWER_HTML} ${TARGET}.html &

viewpdf:${TARGET}.pdf
	${VIEWER_PDF} ${TARGET}.pdf &


# target to actually build out our document
# ${TARGET}.html:setup
# 	@echo 'Generating HTML'

# 	@${HTML} --stylesheet=style/default.css ${ROOT}.rst ${TARGET}.html

# 	@echo 'Done.'

%.txt: %.html
	@echo 'Generating TXT'
	@echo $<

	@${RAW_TEXT} $< > $@

	@echo 'Done.'

${BUILDDIR}/%.html: %.rst
	@echo 'Generating HTML'
	@echo $<

	@${HTML} --stylesheet=style/default.css $< $@

	@echo 'Done.'


# # target to actually build out our document
# %.pdf:
# 	@echo 'Generating PDF'

# 	@${PDF} ${ROOT}.rst -b 1 --stylesheets=style/pdf.sty -o ${TARGET}.pdf

# 	@echo 'Done.'

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
		if [ ! -d ${BUILDDIR}/$$source_dir ] ; then \
			mkdir ${BUILDDIR}/$$source_dir ; \
		fi ; \
	done

clean:
	@rm -rf ${BUILDDIR}/${CHAPTERDIR}
	@rm -rf ${BUILDDIR}
	@rm -f ${TARGET_SUBDIRS}
	@find . -name '*~' -exec rm {} \;
