
void test_texinfo_comments() {
  test_parser_verify_parse(
    test_parser_sourcefile("texinfo", " @c comment"),
    "texinfo", "", "@c comment", 0
  );
}

void test_texinfo_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("texinfo", " @c comment"),
    "comment", "@c comment"
  );
}

void all_texinfo_tests() {
  test_texinfo_comments();
  test_texinfo_comment_entities();
}
