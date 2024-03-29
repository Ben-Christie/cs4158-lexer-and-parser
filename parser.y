%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tokens.h"
%}

%union {
  int integer;
  char* text;
}

%token <text> IDENTIFIER 
%token <text> TEXT
%token <integer> INTEGER 
%token START
%token END
%token MAIN
%token MOVE
%token TO
%token ADD
%token INPUT
%token PRINT
%token SEMICOLON
%token <text> DECLARATION

%start program

%%

program:
  START declaration_list MAIN statement_list END SEMICOLON
  ;

declaration_list:
  | declaration_list declaration SEMICOLON
  ;

declaration:
  DECLARATION IDENTIFIER "."  {
    handle_declaration($1, $2);
  }
  ;

statement_list:
  | statement_list statement SEMICOLON
  ;

statement:
  MOVE IDENTIFIER | INTEGER TO IDENTIFIER  {
    char* src = strtok(yytext, " ");
    char* dest = strtok(NULL, " ");
    handle_move(src, dest);
  }
  | ADD IDENTIFIER | INTEGER TO IDENTIFIER  {   
    char* src = strtok(yytext, " ");
    char* dest = strtok(NULL, " ");
    handle_move(src, dest);
  }
  | INPUT identifier_list  {  
    handle_input(identifier_list, identifier_list.count);
  }
  | PRINT print_list  {
    handle_print(print_list, print_list.count);
  }
  ;

identifier_list:
  IDENTIFIER
  | identifier_list SEMICOLON IDENTIFIER
  ;

print_list:
  TEXT
  | IDENTIFIER
  | print_list SEMICOLON TEXT | IDENTIFIER
  ;

%%

int main() {
  yyparse();
  return 0;
}

void yyerror(const char *s) {
  fprintf(stderr, "Error: %s\n", s);
}

void handle_declaration(char* size, char* name) {
  int capacity = strlen(size);

  if(capacity < 1 || capacity > 5) {
    printf("Error: invalid capacity specified for variable %s\n", name);
    exit(1);
  }

  for(int i = 0; i < capacity; i++) {
    if(size[i] != "S") {
      printf("Error: invalid capacity specified for variable %s\n", name);
      exit(1);
    }
  }

  printf("Variable %s declared with capacity %d\n", name, capacity);
}

void handle_move(char* src, char* dest) {
  printf("Move %s to %s\n", src, dest);
}

void handle_add(char* src, char* dest) {
  printf("Add %s to %s\n", src, dest);
}

void handle_input(char** identifiers, int count) {
  printf("INPUT ");

  for(int i = 0; i < count; i++) {
    printf("%s", identifiers[i]);

    if(i != count - 1) {
      printf(", ");
    }
  }

  printf("\n");
}

void handle_print(char** print_items, int count) {
  printf("PRINT ");

  for(int i = 0; i < count; i++) {
    printf("%s", print_items[i]);

    if(i != count - 1) {
      printf(", ");
    }
  }

  printf("\n");
}

int yyparse() {
    char line[1000];
    char* token;
    int line_number = 1;
    int in_main = 0;

    char* declaration_size;
    char* declaration_name;
    
    char* move_src;
    char* move_dest;
    
    char** input_identifiers = NULL;
    int input_count = 0;
    
    char** print_items = NULL;
    int print_count = 0;
    
    while (fgets(line, sizeof(line), stdin)) {
        token = strtok(line, " \t\r\n");
        
        while (token != NULL) {
            if (strcasecmp(token, "START.") == 0) {
                
            } else if (strcasecmp(token, "END.") == 0) {
                
                if (in_main == 0) {
                    fprintf(stderr, "Error: no statements in MAIN\n");
                    return 1;
                }
                
                return 0;
            } else if (strcasecmp(token, "MAIN") == 0) {
                in_main = 1;
            } else if (strcasecmp(token, "DECLARATION") == 0) {
                declaration_size = strtok(NULL, " \t\r\n");
                declaration_name = strtok(NULL, " \t\r\n");
                
                if (declaration_size == NULL || declaration_name == NULL) {
                    fprintf(stderr, "Error: invalid declaration syntax on line %d\n", line_number);
                    return 1;
                }

            } else if (strcasecmp(token, "MOVE") == 0) {
        
                move_src = strtok(NULL, " \t\r\n");
                token = strtok(NULL, " \t\r\n");
                
                if (strcasecmp(token, "TO") != 0) {
                    fprintf(stderr, "Error: invalid MOVE syntax on line %d\n", line_number);
                    return 1;
                }
                
                move_dest = strtok(NULL, " \t\r\n");
                
                if (move_src == NULL || move_dest == NULL) {
                    fprintf(stderr, "Error: invalid MOVE syntax on line %d\n", line_number);
                    return 1;
                }
                

            } else if (strcasecmp(token, "ADD") == 0) {
          
                move_src = strtok(NULL, " \t\r\n");
                token = strtok(NULL, " \t\r\n");
                
                if (strcasecmp(token, "TO") != 0) {
                    fprintf(stderr, "Error: invalid ADD syntax on line %d\n", line_number);
                    return 1;
                }
                
                move_dest = strtok(NULL, " \t\r\n");
                
                if (move_src == NULL || move_dest == NULL) {
                    fprintf(stderr, "Error: invalid ADD syntax on line %d\n", line_number);
                    return 1;
                }
                
        
            } else if (strcasecmp(token, "INPUT") == 0) {
             
                if (in_main == 0) {
                    fprintf(stderr, "Error: INPUT statement not in MAIN on line %d\n", line_number);
                    return 1;
                }

                token = strtok(NULL, " \t\r\n");
                
                if (token == NULL) {
                    fprintf(stderr, "Error: invalid INPUT syntax on line %d\n", line_number);
                    return 1;
                }
                
           
                input_identifiers[input_count] = strdup(token);
                input_count++;
            } else if (strcasecmp(token, "PRINT") == 0) {
                
                if (in_main == 0) {
                    fprintf(stderr, "Error: PRINT statement not in MAIN on line %d\n", line_number);
                    return 1;
                }
         
                print_items = (char**) realloc(print_items, (print_count + 1) * sizeof(char*));
                
            
                token = strtok(NULL, " \t\r\n");
                
                while (token != NULL) {
                    
                    print_items[print_count] = strdup(token);
                    print_count++;
                    
                  
                    token = strtok(NULL, " \t\r\n");
                }
            } else {
                fprintf(stderr, "Error: unrecognized statement on line %d\n", line_number);
                return 1;
            }
            
        
            token = strtok(NULL, " \t\r\n");
        }
        
 
        line_number++;
    }

    return 0;
}