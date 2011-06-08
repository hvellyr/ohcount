// herschel.rl written by Gregor C. Klinke. gck<att>eyestep<dott>org.

/************************* Required for every parser *************************/
#ifndef OHCOUNT_HERSCHEL_PARSER_H
#define OHCOUNT_HERSCHEL_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *HERSCHEL_LANG = LANG_HERSCHEL;

// the languages entities
const char *herschel_entities[] = {
  "space", "comment", "string", "number",
  "keyword", "identifier", "operator", "any"
};

// constants associated with the entities
enum {
  HERSCHEL_SPACE = 0, HERSCHEL_COMMENT, HERSCHEL_STRING, HERSCHEL_NUMBER,
  HERSCHEL_KEYWORD, HERSCHEL_IDENTIFIER, HERSCHEL_OPERATOR, HERSCHEL_ANY
};

/*****************************************************************************/

%%{
  machine herschel;
  write data;
  include common "common.rl";

  # Line counting machine

  action herschel_ccallback {
    switch(entity) {
    case HERSCHEL_SPACE:
      ls
      break;
    case HERSCHEL_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(HERSCHEL_LANG)
      break;
    case NEWLINE:
      std_newline(HERSCHEL_LANG)
    }
  }

  herschel_line_comment = '--' @comment nonnewline*;
  herschel_inlinedoc_comment =
    '~' @comment (
      newline %{ entity = INTERNAL_NL; } %herschel_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '~';
#  herschel_inlinedoc_comment = '~' @comment [^\r\n\f\\]* '~';
  herschel_comment = herschel_line_comment | herschel_inlinedoc_comment;

  herschel_str = '"' @code ([^\r\n\f"\\] | '\\' nonnewline)* '"';

  herschel_line := |*
    spaces        ${ entity = HERSCHEL_SPACE; } => herschel_ccallback;
    herschel_comment;
    herschel_str;
    newline       ${ entity = NEWLINE;    } => herschel_ccallback;
    ^space        ${ entity = HERSCHEL_ANY;   } => herschel_ccallback;
  *|;

  # Entity machine

  action herschel_ecallback {
    callback(HERSCHEL_LANG, herschel_entities[entity], cint(ts), cint(te), userdata);
  }

  herschel_line_comment_entity = '--' nonnewline*;
  herschel_inlinedoc_comment_entity = '~' any* :>> '~';
# herschel_inlinedoc_comment_entity = '~' @comment [^\r\n\f\\]* '~';
  herschel_comment_entity = herschel_line_comment_entity | herschel_inlinedoc_comment_entity;

  herschel_keyword_entity =
    'AND' | 'and' | 'as' | 'by' | 'def' | 'else' | 'eof' |
    'export' | 'extend' | 'false' | 'for' | 'Function' | 'function' | 'if' |
    'import' | 'in' | 'isa' | 'let' | 'match' | 'mod' | 'module' |
    'nil' | 'not' | 'on' | 'OR' | 'or' | 'reify' | 'rem' |
    'select' | 'then' | 'true' | 'when' | 'where' | 'while' | 'XOR' |
    'alias' | 'char' | 'class' | 'config' | 'const' | 'enum' | 'exit' |
    'generic' | 'ignore' | 'include' | 'init' | 'inner' | 'macro' | 'measure' |
    'outer' | 'public' | 'private' | 'signal' | 'slot' | 'sync' | 'type' |
    'unit';

  # herschel_number_entity = float | integer;

  # herschel_identifier_entity = (alpha | '_') (alnum | '_')*;

  # herschel_operator_entity = [+\-/*%<>!=^&|?~:;.,()\[\]{}];

  herschel_entity := |*
    space+                       ${ entity = HERSCHEL_SPACE;      } => herschel_ecallback;
    herschel_comment_entity      ${ entity = HERSCHEL_COMMENT;    } => herschel_ecallback;
    # herschel_number_entity     ${ entity = HERSCHEL_NUMBER;     } => herschel_ecallback;
    # herschel_identifier_entity ${ entity = HERSCHEL_IDENTIFIER; } => herschel_ecallback;
    herschel_keyword_entity      ${ entity = HERSCHEL_KEYWORD;    } => herschel_ecallback;
    # herschel_operator_entity   ${ entity = HERSCHEL_OPERATOR;   } => herschel_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with herschel code.
 *
 * @param *buffer The string to parse.
 * @param length The length of the string to parse.
 * @param count Integer flag specifying whether or not to count lines. If yes,
 *   uses the Ragel machine optimized for counting. Otherwise uses the Ragel
 *   machine optimized for returning entity positions.
 * @param *callback Callback function. If count is set, callback is called for
 *   every line of code, comment, or blank with 'lcode', 'lcomment', and
 *   'lblank' respectively. Otherwise callback is called for each entity found.
 */
void parse_herschel(char *buffer, int length, int count,
                    void (*callback) (const char *lang, const char *entity, int s,
                                      int e, void *udata),
                    void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? herschel_en_herschel_line : herschel_en_herschel_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(HERSCHEL_LANG) }
}

#endif

/*****************************************************************************/
