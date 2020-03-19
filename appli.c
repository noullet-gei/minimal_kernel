#include "math.h"
#include "appli.h"
#include "noyau.h"

int pcnt[] = { 1, 2, 3 };

void appli_0( int data )
{
int x, y, i, j, k, m;
//while	(1)
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
					pcnt[data] = ( x << 16 ) | ( ( y++ ) & 0xFFFF ); 
					}
				}
			}
		}
	}
termine();	// cette appli doit se terminer avec 9999 9999 soit 0x270F270F
}

void appli_1( int data )
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
	pcnt[data] = ( x << 16 ) | ( ++y & 0xFFFF );
	}
}		// cette appli ne se termine pas

void appli_2( int data )
{
int x = 0xFFFF, y = 0;
while	(1)
	{
	x = x - 1;
	pcnt[data] = ( (~x) << 16 ) | ( ++y & 0xFFFF );
	if	( y == 0xDEAD )
		termine();
	}	// cette appli doit se terminer avec 0xDEADDEAD
}
