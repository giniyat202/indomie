/***
	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/
%option noyywrap
%option nodefault

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int stk[1000];
int stksz = 0;
extern FILE *yyin;

enum codes
{
	CODE_EXIT,
	CODE_PRINTS,
	CODE_PRINTI,
	CODE_SCANI,
	CODE_ADDI,
};
struct inst
{
	int code;
	void *data;
};
struct inst insts[1000];
struct inst *curinst = insts;
int pc = 0;
%}

%%

"#".*"\n" { /* comment */ }

"و هو كسمه اصلا معندهوش غير طعم ".*?" بنت المتناكه" {
	/* print to stdout */
	size_t len = strlen(yytext) - 78;
	char *buf;
	
	buf = malloc(len);
	memcpy(buf, yytext + 55, len - 1);
	buf[len - 1] = '\0';
	
	curinst->code = CODE_PRINTS;
	curinst->data = buf;
	curinst++;
}
"هات اندومي" {
	/* scan an integer */
	curinst->code = CODE_SCANI;
	curinst->data = 0;
	curinst++;
}
"و لا ليها اي كسم خره اصلا" {
	/* print an integer */
	curinst->code = CODE_PRINTI;
	curinst->data = 0;
	curinst++;
}
"احا يا اندومي" {
	/* exit program */
	curinst->code = CODE_EXIT;
	curinst->data = 0;
	curinst++;
}
"فضلت واقف منبهر" {
	/* add 2 integers */
	curinst->code = CODE_ADDI;
	curinst->data = 0;
	curinst++;
}
.|\n { /* not matched */ }

%%
void execthis(void)
{
	for(;;)
	{
		struct inst *cur = insts + pc++;
		switch(cur->code)
		{
			case CODE_PRINTS:
				printf("%s\n", cur->data);
				fflush(stdout);
				break;
			case CODE_PRINTI:
				printf("%d", stk[--stksz]);
				break;
			case CODE_SCANI:
				scanf("%d", &stk[stksz++]);
				break;
			case CODE_ADDI:
			{
				int first, second;
				second = stk[--stksz];
				first = stk[--stksz];
				stk[stksz++] = first + second;
				break;
			}
			case CODE_EXIT:
			{
				struct inst *p = insts;
				while (p < curinst)
				{
					if (p->data)
						free(p->data);
					p++;
				}
				return;
			}
		}
	}
}
int main(int argc, char **argv)
{
	if (argc != 2)
	{
		printf("usage: %s filename", argv[0]);
		return 0;
	}
	yyin = fopen(argv[1], "r");
	yylex();
	execthis();
	return 0;
}