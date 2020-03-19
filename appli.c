#include "math.h"
#include "appli.h"

int pcnt[] = { 1, 2, 3 };

void appli_0(void)
{
int x, y, i, j, k, m;
while	(1)
	{
	x = y = 0;
	for	( i = 0; i < 10; ++i )
		{
		for	( j = 0; j < 10; ++j )
			{
			int u = 10 * i + j;
			for	( k = 0; k < 10; ++k )
				{
				int v = 10 * u + k;
				for	( m = 0; m < 10; ++m )
					{
					x = 10 * v + m;
					pcnt[0] = ( x << 16 ) | ( ( y++ ) & 0xFFFF ); 
					}
				}
			}
		}
	}
}

void appli_1(void)
{
double d = 0.0;
double inc = 0.001;
int x, y = 0;
while	(1)
	{
	d += inc;
	x = (int)round( d / inc );
	if	( x >= 65536 )
		{ d = 0.0; x = 0; } 
	pcnt[1] = ( x << 16 ) | ( ++y & 0xFFFF );
	}
}

void appli_2(void)
{
int x = 0xFFFF, y = 0;
while	(1)
	{
	x = x - 1;
	pcnt[2] = ( (~x) << 16 ) | ( ++y & 0xFFFF );
	}
}
