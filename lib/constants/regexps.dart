// ignore: non_constant_identifier_names
final RegExp EMAIL_VALIDATION_REGEX =
    RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

// ignore: non_constant_identifier_names
final RegExp PASSWORD_VALIDATION_REGEX =
    RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[a-zA-Z]).{8,}$");

// ignore: non_constant_identifier_names
final RegExp NAME_VALIDATION_REGEX =
    RegExp(r"\b([A-ZÀ-ÿА-Яа-яЁё][-,a-zA-ZÀ-ÿа-яА-ЯЁё. ']+[ ]*)+");

// ignore: constant_identifier_names
const String PLACEHOLDER_PFP =
    "https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg";
