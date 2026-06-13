KVERSION ?= $(shell uname -r)
KDIR := /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)

obj-m += stb0899.o
stb0899-objs := stb0899_drv.o stb0899_algo.o

ccflags-y += -I$(src)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install: all
	install -d /lib/modules/$(KVERSION)/updates/skystar
	install -m 0644 stb0899.ko /lib/modules/$(KVERSION)/updates/skystar/
	depmod -a
