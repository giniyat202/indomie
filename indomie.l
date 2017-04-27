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

YL3N			"يلعن"
KOSOM			"كسم"
ELINDOMY		"الاندومي"
ELSH3RYA		"الشعريه"
BENT			"بنت"
ELMTNAKA		"المتناكه"
YA				"يا"
SHWAYET			"شوية"
ALAAM			"عالم"
MTNAKEN			"متناكين"
WA				"و"
LA				"لا"
LEHA			"ليها"
TA3M			"طعم"
AY				"اي"
KHARA			"خره"
ASLAN			"اصلا"
BE				"ب"
GENEH			"جنيه"
A7A				"احا"
YA3NY			"يعني"
RO7T			"روحت"
A2OL			"اقول"
LLRAGL			"للراجل"
HAT				"هات"
INDOMY			"اندومي"
AAM				"قام"
AALE			"قالي"		
AAWEZ			"عاوز"
BTA3M			"بطعم"
EH				"ايه"
FDALT			"فضلت"
WA2F			"واقف"
MONBAHR			"منبهر"
HOWA			"هو"
KOSOMOH			"كسمه"
M3NDHOSH		"معندهوش"
GHEER			"غير"
ELFRA5			"الفراخ"
BYA3			"بياع"
EBN				"ابن"
MARA			"مره"
LABWA			"لبوه"
B3DEN			"بعدين"
EL7SAB			"الحساب"
YFNDM			"يفندم"
AZBAR			"ازبار"
FKSOMK			"فكسمك"
YMTNAK			"يمتناك"
ELLBWA			"اللبوه"
ELBET			"البيت"
WLA3T			"ولعت"
ELNAR			"النار"
LA2ET			"لقيت"
ELANBOBA		"الانبوبه"
FADYA			"فاضيه"
ADTRET			"اضطريت"
ENY				"اني"
A8YAR			"اغير"
KOSMHA			"كسمها"

SPENDL			[ \t\v\r\n]

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int stk[1000000];
int stksz = 0;
extern FILE *yyin;

enum codes
{
	CODE_EXIT,
	CODE_PRINTS,
	CODE_PRINTI,
	CODE_SCANI,
	CODE_SUBI,
	CODE_PUSHI,
	CODE_JMP,
	CODE_DUP,
	CODE_SWAP,
};
const char *code_name[] = {
	"EXIT",
	"PRINTS",
	"PRINTI",
	"SCANI",
	"SUBI",
	"PUSHI",
	"JMP",
	"DUP",
	"SWAP",
};
struct inst
{
	int code;
	void *data;
};
struct inst insts[1000];
struct inst *curinst = insts;
int pc = 0;
const int debug = 0;
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
{A7A}{SPENDL}*"-"?[0-9]+{SPENDL}*{AZBAR}{SPENDL}+{FKSOMK} {
	/* push integer on stack */
	int *num = malloc(sizeof(int));
	const char *buf = yytext;
	while (*buf != '-' && (*buf < '0' || *buf > '9')) buf++;
	sscanf(buf, "%d", num);
	curinst->code = CODE_PUSHI;
	curinst->data = num;
	curinst++;
}
{AAM}{SPENDL}+{AALE}{SPENDL}+{AAWEZ}{SPENDL}+{BTA3M}{SPENDL}+{EH} {
	/* jump if condition is met */
	curinst->code = CODE_JMP;
	curinst->data = 0;
	curinst++;
}
{WA}{SPENDL}*{RO7T}{SPENDL}+{ELBET}{SPENDL}+{WLA3T}{SPENDL}+{KOSOM}{SPENDL}+{ELNAR} {
	/* duplicate stack top */
	curinst->code = CODE_DUP;
	curinst->data = 0;
	curinst++;
}
{WA}{SPENDL}*{ADTRET}{SPENDL}+{ENY}{SPENDL}+{A8YAR}{SPENDL}+{KOSMHA} {
	/* swap an element with stack top */
	curinst->code = CODE_SWAP;
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
	/* subtract 2 integers */
	curinst->code = CODE_SUBI;
	curinst->data = 0;
	curinst++;
}
.|\n { /* not matched */ }

%%
void printstack()
{
	if (!debug) return;
	int *curst = stk + stksz - 1;;
	fprintf(stderr, "\t\tstack:\n");
	while (curst >= stk)
		fprintf(stderr, "\t\t%d\n", *curst--);
}
void execthis(void)
{
	for(;;)
	{
		struct inst *cur = insts + pc;
		if (debug)
		{
			printf("%.4d:\t%s", pc, code_name[cur->code]);
			if (cur->code == CODE_PUSHI)
				printf(" %d", *(int*)cur->data);
			printf("\n");
		}
		pc++;
		
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
			case CODE_PUSHI:
				stk[stksz++] = *(int*)cur->data;
				printstack();
				break;
			case CODE_SUBI:
			{
				int first, second;
				second = stk[--stksz];
				first = stk[--stksz];
				stk[stksz++] = first - second;
				printstack();
				break;
			}
			case CODE_DUP:
			{
				int top = stk[stksz - 1];
				stk[stksz++] = top;
				printstack();
				break;
			}
			case CODE_SWAP:
			{
				int index, temp;
				index = stk[--stksz];
				temp = stk[stksz - 1];
				stk[stksz - 1] = stk[stksz - index - 1];
				stk[stksz - index - 1] = temp;
				printstack();
				break;
			}
			case CODE_JMP:
			{
				int cond, disp;
				cond = stk[--stksz];
				disp = stk[--stksz];
				if (cond < 0)
					pc += disp;
				printstack();
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