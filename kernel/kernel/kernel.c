#include "kernel.h"

void clear_screen(unsigned short *video_ptr)
{
	for (int i = 0; i < 25; i++)
	{
		for (int j = 0; j < 80; j++)
		{
			video_ptr[i * 80 + j] = 15 << 12;
		}
	}
}

void main(void)
{
	char *str = "Hello";
	unsigned short *video_ptr = (unsigned short *)0xb8000;
	unsigned short white_on_black = ((15 << 12) | (0 << 8));

	clear_screen(video_ptr);
	for (int i = 0; i < 5; i++)
	{
		video_ptr[i] = (unsigned short)str[i] | white_on_black;
	}
}
