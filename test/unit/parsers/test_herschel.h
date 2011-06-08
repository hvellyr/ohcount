
void test_herschel_comment() {
  test_parser_verify_parse(
    test_parser_sourcefile("herschel", " --comment"),
    "herschel", "", "--comment", 0
  );
}

void test_herschel_strings() {
  test_parser_verify_parse(
    test_parser_sourcefile("herschel", "\"abc--not a 'comment\""),
    "herschel", "\"abc--not a 'comment\"", "", 0
  );
}

void test_herschel_comment_entities() {
  test_parser_verify_entity(
    test_parser_sourcefile("herschel", " --comment"),
    "comment", "--comment"
  );
  test_parser_verify_entity(
    test_parser_sourcefile("herschel", " --comment"),
    "comment", "--comment"
  );
}

void all_herschel_tests() {
  test_herschel_comment();
  test_herschel_strings();
  test_herschel_comment_entities();
}
