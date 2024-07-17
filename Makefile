all:
	clang -Wall -Werror -fobjc-arc -framework AppKit imgpaste.m -o imgpaste
