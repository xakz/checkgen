Description
-----------

*checkgen* is a test runner generator suitable for use with the
[Check](http://check.sourceforge.net/) unit testing framework.

The syntax mimic C-like preprocessor directives like does *checkmk*
(included in Check).

See
[manpage](http://htmlpreview.github.io/?https://github.com/xakz/checkgen/blob/master/checkgen.html)
for the complete documentation.

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
* `#main-pre` Define block of code to be inserted after declarations in the main() function.
* `#main-post` Define block of code to *replace* the end the main() function.
* `#main` Define block of code to be inserted in place in the main() function.

Simple example
--------------

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
int nf;
sr = srunner_create(NULL);
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
written for *checkgen* can be incompatible with *checkmk*. Thus, the
reverse case is compatible.

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

Thanks
------

Thanks to the [Check](http://check.sourceforge.net/) team for their
work.

Thanks to Micah Cowan, author of *checkmk*, for his software and the
original idea of using C-like preprocessor directives.
