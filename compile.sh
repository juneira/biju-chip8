#!/bin/bash

(./biju < hello_world.bj) > chip8.asm && c8asm -o file.ch8 chip8.asm
