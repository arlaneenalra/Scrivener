HTML=rst2html.py
VIEWER_HTML=chromium

PDF=rst2pdf
VIEWER_PDF=evince

KINDLEGEN=kindlegen

BUILDDIR=build
STYLEDIR=style

ROOT=root

TARGET=${BUILDDIR}/${ROOT}
TARGET_SUBDIRS=gen_body.rst

# find all chapters etc.
SOURCE_DIRS=chapters appendices
SUBDIR_FILES=$(foreach subdir,${SOURCE_DIRS},$(sort $(wildcard ${subdir}/*.rst)))

#STYLES=$(sort $(wildcard ${STYLEDIR}/*.css))

RAW_TEXT=links -dump ${TARGET}.html
WC=wc -w


GENERATED_COMMENT='.. This is a generated file, do not edit'

all:compile

kindle:compile
	${KINDLEGEN} ${TARGET}.html

compile:html

html:${TARGET}.html

pdf:${TARGET}.pdf

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

setup:${BUILDDIR} root.rst ${TARGET_SUBDIRS}

view:${TARGET}.html
	${VIEWER_HTML} ${TARGET}.html &

viewpdf:${TARGET}.pdf
	${VIEWER_PDF} ${TARGET}.pdf &


# target to actually build out our document
${TARGET}.html:setup
	@echo 'Generating HTML'

	@${HTML} --stylesheet=style/default.css ${ROOT}.rst ${TARGET}.html

	@echo 'Done.'

# target to actually build out our document
%.pdf:setup
	@echo 'Generating PDF'

	@${PDF} ${ROOT}.rst -b 1 --stylesheets=style/pdf.sty -o ${TARGET}.pdf

	@echo 'Done.'

# build a universal chpater include using dir listing for CHAPTERSDIR
${TARGET_SUBDIRS}:${SUBDIR_FILES}

	@echo 'Generating '$@' build files . . . .'
	@echo

	@echo ${GENERATED_COMMENT} > $@

	@for file in ${SUBDIR_FILES}; do \
		echo '	Adding '$$file; \
		echo '.. include:: '$$file >> $@; \
	done

	@echo 'Done.'


# setup the build dir so that everything works nice
${BUILDDIR}:
	@if [ ! -d ${BUILDDIR} ] ; then \
		mkdir ${BUILDDIR}  ; \
	fi

	@if [ ! -d ${BUILDDIR}/${CHAPTERDIR} ] ; then \
		mkdir ${BUILDDIR}/${CHAPTERDIR}  ; \
	fi

clean:
	@rm -rf ${BUILDDIR}/${CHAPTERDIR}
	@rm -rf ${BUILDDIR}
	@rm -f ${TARGET_SUBDIRS}
	@find . -name '*~' -exec rm {} \;
