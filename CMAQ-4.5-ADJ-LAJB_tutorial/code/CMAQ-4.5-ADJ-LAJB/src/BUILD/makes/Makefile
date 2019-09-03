#  make file for m3bld program

CC = cc
CFLAGS = 
CLITEFLAGS = 

OBJECTS =	fw_util.o \
		m3bld.o \
		bld_parser.o \
		bld_scanner.o \
		action.o \
 		filetype.o \
		sms.o 

m3bld: $(OBJECTS)
	 $(CC) -o m3bld $(OBJECTS)

clean:
	rm -f *.o 

bld_parser.o:	bld_parser.c
	$(CC) -c $(CLITEFLAGS) bld_parser.c

bld_scanner.o:	bld_scanner.c sms.h tokens.h
	$(CC) -c $(CLITEFLAGS) bld_scanner.c


# dependencies
m3bld.o:	sms.h
action.o:	sms.h
sms.o:	sms.h
bld_parser.o:	bld_parser.c sms.h
