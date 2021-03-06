BASE	= $*
TARGET	= $@
DEPENDS	= $<
NEWER	= $?

LABEL	= edu/mscd/cs/jrsstlabel
APPLET	= jrsstapplet
WS	= webstart
JCLO	= edu/mscd/cs/jclo
JAVALN	= edu/mscd/cs/javaln
BBBL	= com/centerkey/utils
BIN	= bin

SOURCES	= edu.msudenver.cs.jrsstlabel.Icon.java JRSST.java
CLASSES = $(SOURCES:.java=.class)

VERSION	= $(shell cat $(LABEL)/VERSION)
JAR	= JRSST-$(VERSION).jar
SIGNED	= JRSST-$(VERSION).signed.jar
SIGNER	= jarsigner
JARS	= $(JAR) $(SIGNED)
GEN	= $(JARS) $(CLASSES) index.html

FILES	= $(SOURCES) $(CLASSES) Makefile MainClass \
	  $(JCLO) $(JAVALN) $(LABEL) $(APPLET) $(WS) \
	  debug tests index index.html windows.html *.gif *.png *.ico \
	  $(HTML) $(POLICIES) $(BBBL)

.SUFFIXES: .java .class .jar .jnlp

.java.class : 
	javac $(DEPENDS)

all : $(LABEL)/JRSSTLabel-$(VERSION).jar $(JARS) $(BIN)

$(LABEL)/JRSSTLabel-$(VERSION).jar :
	cd $(LABEL); make

$(JAR) : $(FILES)
	jar -cmf MainClass $(TARGET) $(FILES)

$(LABEL) : FRC
	cd $(TARGET); make

$(APPLET) : FRC
	cd $(TARGET); make

$(WS) : FRC
	cd $(TARGET); make

$(BIN) : $(JAR)
	cd $(TARGET); make

clean :
	rm -f $(GEN)
	cd $(BIN); make $(TARGET)
	cd $(LABEL); make $(TARGET)
	cd $(APPLET); make $(TARGET)
	cd $(WS); make $(TARGET)

$(SIGNED) : $(JAR) myKeys
	cp -f $(JAR) $(SIGNED)
	$(SIGNER) -storepass jrsstjrsst -keystore myKeys $(TARGET) JRSST

index.html : index Makefile $(LABEL)/VERSION
	sed -e "s/VERSION/$(VERSION)/" < $(DEPENDS) > $(TARGET)

update : updateJCLO updateJAVALN

updateJCLO :
	rm -rf edu/mscd/cs/jclo
	mkdir /tmp/jclo
	cd /tmp/jclo; \
	    cvs -d:pserver:drb80@jclo.cvs.sourceforge.net:/cvsroot/jclo co -P .
	cp -R /tmp/jclo/edu .
	rm -rf /tmp/jclo
	cd edu/mscd/cs/jclo; make

updateJAVALN :
	rm -rf edu/mscd/cs/javaln
	mkdir /tmp/javaln
	cd /tmp/javaln; \
	cvs -d:pserver:drb80@javaln.cvs.sourceforge.net:/cvsroot/javaln co -P .
	cp -R /tmp/javaln/edu .
	rm -rf /tmp/javaln
	cd edu/mscd/cs/javaln; make

DETAIL	= java -Djava.util.logging.config.file=debug/all.finest JRSST
DEBUG	= java -Djava.util.logging.config.file=debug/JRSSTConfig.finest JRSST

mytest : JRSST.class
	$(DEBUG) file:tests/dpo.xml

picture.xwd :
	xwd -frame > picture.xwd

checkstyle : JRSST.java $(LIBSRC)
	checkstyle -c checks.xml JRSST.java $(LIBSRC)

myKeys :
	keytool -genkey -dname "cn=Steven Beaty, ou=Computer Science, o=Metro State College of Denver, c=US" -keystore myKeys -validity 1000 -alias JRSST -storepass jrsstjrsst
	keytool -selfcert -dname "cn=Steven Beaty, ou=Computer Science, o=Metro State College of Denver, c=US" -keystore myKeys -validity 1000 -alias JRSST -storepass jrsstjrsst

install : $(SIGNED)
	cp $(SIGNED) ~/public_html
	chmod 644 ~/public_html/$(SIGNED) 
	cd $(WS); make $(TARGET)
	cd $(APPLET); make $(TARGET)

tag:
	cvs tag -R jrsst`echo $(VERSION) | sed -e 's/\.//g'`

FRC :
