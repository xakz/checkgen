Checkgen
========

This is a AWK script that generate suitable C source code for use with
the [Check](http://check.sourceforge.net/) unit testing framework.

The syntax mimic preprocessor directives like *checkmk* (included in
Check).

Supported directives
--------------------

* `#suite` Create a suite.
* `#tcase` Create a test case.
* `#test` Define a basic test.
* `#test-exit()` Define a test with expected exit value.
* `#test-signal()` Define a test with expected raised signal.
* `#test-loop()` Define a loop test.
* `#test-loop-exit()` Define a loop test with expected exit value.
* `#test-loop-signal()` Define a loop test with expected raised signal.
* `#setup` Define a unchecked fixture setup block.
* `#teardown` Define a unchecked fixture teardown block.
* `#checked-setup` Define a checked fixture setup block.
* `#checked-teardown` Define a checked fixture teardown block.
* `#global` Permit to define some globals.
* `#timeout` Set the timeout for tests in the current test case.
* `#main-pre` Define block of code te be inserted after declarations in the main() function.
* `#main-post` Define block of code te be inserted before `srunner_run_all()` in the main() function.
* `#main` Define block of code te be inserted in place in the main() function.

Basic example
-------------

```C
#suite Checkgen
#tcase Basics

#test This test should fail
ck_assert(1 == 0);

#test This test should success
ck_assert(1 == 1);
```

Typing this command,

```sh
checkgen example.basic.ts > result.c
```

will produce (line sync directives stripped out for readability):

```C
/*************************************************************/
/*************************************************************/
/******* Automatically generated file, DO NOT EDIT. **********/
/*************************************************************/
/*************************************************************/
/* Command line used to generate this file:
 * checkgen example.basic.ts
 */
#include <check.h>

START_TEST(checkgen_test_func0)
{
ck_assert(1 == 0);

}
END_TEST
START_TEST(checkgen_test_func1)
{
ck_assert(1 == 1);
}
END_TEST
int main(int argc, char *argv[])
{
Suite *s;
TCase *tc;
SRunner *sr;
sr = srunner_create(NULL);
int nf;
s = suite_create("Checkgen");
srunner_add_suite(sr, s);
tc = tcase_create("Checkgen/Basics");
suite_add_tcase(s, tc);
_tcase_add_test(tc, checkgen_test_func0, "This test should fail", 0, 0, 0, 1);
_tcase_add_test(tc, checkgen_test_func1, "This test should success", 0, 0, 0, 1);
srunner_run_all(sr, CK_ENV);
nf = srunner_ntests_failed(sr);
srunner_free(sr);
return nf == 0 ? 0 : 1;
}
```

Directives syntax
-----------------

`#suite NAME`

Defines a suite with the name `NAME` and adds it to the
SRunner. `NAME` can be any string. If no suite is defined, a default
one with the name "Core" will be defined for you.

`#tcase NAME`

Defines a test case with the name `NAME` and registers it to the
current TCase. `NAME` can be any string. If no test case is defined, a
default one with the name "Core" will be defined for you.

`#test DESC`

Defines a test function block and registers it to the current test
case. The block finishes at the next directive or at the end of
file. `DESC` can be any string.

`#test-exit(EXIT_VALUE) DESC`

Same as `#test`, plus, `EXIT_VALUE` is the expected exit value.

`#test-signal(SIGNUM) DESC`

Same as `#test`, plus, `SIGNUM` is the expected signal number (You can
include signal.h and use SIGXXX defines).

`#test-loop(START, END) DESC`

Defines a loop test function block and registers it to the current test
case. The block finishes at the next directive or at the end of
file. `DESC` can be any string. `START` and `END` are respectively the
start and end value defining the loop iterations. The variable `_i` is
available during each iteration of the test.

`#test-loop-exit(EXIT_VALUE, START, END) DESC`

Its the combinaison of `#test-loop` and `#test-exit`.

`#test-loop-signal(SIGNUM, START, END) DESC`

Its the combinaison of `#test-loop` and `#test-signal`.

`#setup [DESC]`

Defines a unchecked fixture setup function block and registers it to
the current test case. The block finishes at the next directive or at
the end of file. `DESC` is an optional description that will appear as
comment.

`#teardown [DESC]`

Defines a unchecked fixture teardown function block and registers it to
the current test case. The block finishes at the next directive or at
the end of file. `DESC` is an optional description that will appear as
comment.

`#checked-setup [DESC]`

Same as `#setup` but define a checked fixture setup function block.

`#checked-teardown [DESC]`

Same as `#setup` but define a checked fixture teardown function block.

`#global [DESC]`

Permits to close code block opened by test or fixture directive. So,
globals can be defined after this directive. The optional `DESC`
string will be added as comment.

`#timeout T`

Set the timeout for tests in the current test case to `T` seconds.

`#main-pre [DESC]`

Defines block of code to be inserted after variable declarations in the
main() function. The optional `DESC` string will be added as
comment. This directive can be used multiple times, block of code will
be appended in order. The main purpose of this directive is to declare
your own variables if you use a non-C99 compiler that requires
variable declarations at the top of functions.

`#main-post [DESC]`

Defines block of code that *replaces* the end of the main()
function. The optional `DESC` string will be added as comment. If you
use `#main-post`, the SRunner will *NOT* be run, you should provide
your own piece of code to do that. The variable name of the SRunner is
`sr`. This directive can be used multiple times, block of code will be
appended in order.

`#main [DESC]`

Defines block of code te be inserted in place in the main()
function. The current Suite varaible name is `s`, the current TCase
varaible name is `tc` and the SRunner varaible name is `sr`. The
optional `DESC` string will be added as comment. This directive can be
used multiple times, block of code will be appended in order.

Full example
------------

See `example.full.ts` for a full example.

Compatibility with *checkmk*
----------------------------

The following directives are fully compatible with *checkmk*:

* `#suite`
* `#tcase`
* `#test`
* `#test-exit()`
* `#test-signal()`
* `#test-loop()`
* `#test-loop-exit()`
* `#test-loop-signal()`

But, as *checkgen* supports any string as test description, test file
written for *checkgen* can be incompatible with *checkmk*.

The following directives behaves as in *checkmk* but the user code can
be incompatible:

* `#main-pre`
* `#main-post`

The suite and test case variable naming differs in *checkgen*, the
TCase variable is continuously reused. There is no `tcX_Y` variable
naming scheme in *checkgen*. So, user code that requires `tcX_Y`
variables are broken. That said, new directive set permits a cleaner approach.

In *checkgen*, the `#main-post` directive *replaces* final block of
code in the main() function. This is intended for a full flexibility
with the SRunner object (e.g. Setting up log file, xml log file, tap
file, argv parsing, or any other action).

The following directives are new to *checkgen* and are not supported
by *checkmk*:

* `#setup`
* `#teardown`
* `#checked-setup`
* `#checked-teardown`
* `#global`
* `#timeout`
* `#main`

Why ?
-----

*checkmk* do a good job but fixture handling is absent. It can be
 hacked using `#main-pre` but reordering test cases break user code.

Originally, test naming enforces C identifier. With *checkgen* any
string can be used as name for your test.

Thanks
------

Thanks to the [Check](http://check.sourceforge.net/) team for their
work.
