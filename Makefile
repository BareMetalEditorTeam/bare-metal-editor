program.vhd: editor.asm
	nasm -f bin -l editor.lst -o editor.vhd editor.asm
