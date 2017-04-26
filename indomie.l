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
int stk[1000];
int stksz = 0;
extern FILE *yyin;
%}

%%

"#".*"\n" { /* comment */ }

"و هو كسمه اصلا معندهوش غير طعم ".*?" بنت المتناكه" {
	/* print to stdout */
	printf("%.*s\n", strlen(yytext) - 79, yytext + 55);
}
.|\n { /* not matched */ }

%%

int main(int argc, char **argv)
{
	if (argc != 2)
	{
		printf("usage: %s filename", argv[0]);
		return 0;
	}
	yyin = fopen(argv[1], "r");
	yylex();
	return 0;
}