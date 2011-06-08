// texinfo.rl written by Gregor C. Klinke. gck<att>eyestep<dott>org.

/************************* Required for every parser *************************/
#ifndef OHCOUNT_TEXINFO_PARSER_H
#define OHCOUNT_TEXINFO_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *TEXINFO_LANG = LANG_TEXINFO;

// the languages entities
const char *texinfo_entities[] = {
  "space", "comment", "string", "any"
};

// constants associated with the entities
enum {
  TEXINFO_SPACE = 0, TEXINFO_COMMENT, TEXINFO_STRING, TEXINFO_ANY
};

/*****************************************************************************/

%%{
  machine texinfo;
  write data;
  include common "common.rl";

  # Line counting machine

  action texinfo_ccallback {
    switch(entity) {
    case TEXINFO_SPACE:
      ls
      break;
    case TEXINFO_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(TEXINFO_LANG)
      break;
    case NEWLINE:
      std_newline(TEXINFO_LANG)
    }
  }

  texinfo_comment = "@c " @comment nonnewline*;

  texinfo_line := |*
    spaces       ${ entity = TEXINFO_SPACE; } => texinfo_ccallback;
    texinfo_comment;
    newline      ${ entity = NEWLINE;   } => texinfo_ccallback;
    ^space       ${ entity = TEXINFO_ANY;   } => texinfo_ccallback;
  *|;

  # Entity machine

  action texinfo_ecallback {
    callback(TEXINFO_LANG, texinfo_entities[entity], cint(ts), cint(te), userdata);
  }

  texinfo_comment_entity = "@c " nonnewline*;

  texinfo_entity := |*
    space+                 ${ entity = TEXINFO_SPACE;   } => texinfo_ecallback;
    texinfo_comment_entity ${ entity = TEXINFO_COMMENT; } => texinfo_ecallback;
    # TODO:
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with Texinfo markup.
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
void parse_texinfo(char *buffer, int length, int count,
                   void (*callback) (const char *lang, const char *entity, int s,
                                     int e, void *udata),
                   void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? texinfo_en_texinfo_line : texinfo_en_texinfo_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(TEXINFO_LANG) }
}

#endif

/*****************************************************************************/
