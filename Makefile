vbox: editor.vhd
	VirtualBox --startvm Editor
editor.vhd: bootloader.bin editor.bin vhdfooter.bin
	cat bootloader.bin editor.bin vhdfooter.bin > editor.vhd
qemu: bootloader.bin editor.bin
	cat bootloader.bin editor.bin > bare.img
bootloader.bin: bootloader.asm
	nasm -f bin -l bootloader.lst -o bootloader.bin bootloader.asm
editor.bin: editor.asm utils.inc
	nasm -f bin -l editor.lst -o editor.bin editor.asm
vhdfooter.bin: vhdfooter.asm
	nasm -f bin -o vhdfooter.bin vhdfooter.asm

