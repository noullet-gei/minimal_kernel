// programme mixte C - ASM
#include "stm32f10x.h"
#include "appli.h"


int icnt = 0;


void start_systick( int freq )
{
// periode (avec horloge CPU a 8 MHz)
SysTick->LOAD  = (8000000 / freq) - 1;
// priorite
NVIC_SetPriority( SysTick_IRQn, 11 );
// init counter
SysTick->VAL = 0;
// prescale (0 ===> %8)
SysTick->CTRL = SysTick_CTRL_CLKSOURCE_Msk;
// enable timer, enable interrupt
SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk | SysTick_CTRL_ENABLE_Msk;
}

// fonction de noyau.s
void init_1( int num_proc, void (*entry_adr)(void) );

int main(void)
{
init_1( 0, appli_0 );
init_1( 1, appli_1 );
init_1( 2, appli_2 );

start_systick( 1000 );

while	(1)
	{};
}

