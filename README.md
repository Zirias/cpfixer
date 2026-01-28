# cpfixer: C64 KERNAL control port fix

This little program copies ROM to RAM and then patches the KERNAL to skip
scanning the keyboard when there is any control port (e.g. joystick) input.

This stops joystick movements (especially on port #1) to mess with keyboard
input in *almost* all cases. A little race condition remains if control port
input starts exactly during scanning the keyboard matrix, which can't be
avoided for hardware limitation, but is extremely unlikely to happen.

It's mainly meant as a demonstration how simple some basic protection would
have been in the original KERNAL. 

**PRG download:** [cpfixer.prg](https://github.com/Zirias/cpfixer/blob/master/cpfixer.prg?raw=true) (251 bytes)
