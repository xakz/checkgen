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

Full example
------------

```C
/* -*- c -*- */

#include <stdlib.h>

#include <sys/types.h>
#include <unistd.h>
#include <signal.h>

#suite Checkgen Suite
#tcase Basic tests

#test This test should fail
ck_assert(1 == 0);

#test This test should success
ck_assert(1 == 1);

#test-exit(1) Exit value == 1 is expected
exit(1);

#test-signal(SIGUSR1) Expect SIGUSR1
kill(getpid(), SIGUSR1);

#test-loop(0, 10) A loop test that success
ck_assert(_i >= 0);
ck_assert(_i < 10);

#test-loop-exit(1, 0, 10) A loop test that should exit(1)
if (_i == 5)
	exit(0);
exit(1);

#test-loop-signal(SIGSEGV, 0, 10) Segfault !
char *invalid = NULL;
if (_i == 5) {
	;			/* Noop */
}
invalid[0] = '@';

/* Test case with unchecked fixture */
#tcase Unckecked Fixtures
#global Define a global for the fixture
int *array;

#setup Allocate memory for the array
array = malloc(10 * sizeof(*array));
if (array == NULL) {
	/* Its an unchecked fixture, so, this ends the test
	 * runner. But memory allocation seldom fails. */
	exit(1);
}

#teardown Free memory used by the array
free(array);

#test An useless test
array[0] = 20;
ck_assert_int_eq(array[0], 20);

/* Test case with checked fixture */
#tcase Checked Fixture
#global Its time to declare a global
char *astring = NULL;

#checked-setup A setup fixture function that fail, but tests continue
astring[0] = '@'; 	/* Oups */

#test Successful test
ck_assert_ptr_eq(astring, NULL);

/* Auxiliary directives */
#tcase Auxiliary
/* Set the tcase timeout to 3 seconds. */
#timeout 1
#test A test
ck_assert(1 == 1);

#main-post Change the main() ending
srunner_run_all(sr, CK_ENV);
return number;

#main Change number value
number = 0;

#test Will timeout
sleep(3);

#main-pre Declare a variable
int number = 6;

#test Another test
ck_assert(1 + 1 == 2);

```

Will produce:

```C
/*************************************************************/
/*************************************************************/
/******* Automatically generated file, DO NOT EDIT. **********/
/*************************************************************/
/*************************************************************/
/* Command line used to generate this file:
 * checkgen example.full.ts
 */
#include <check.h>

/* -*- c -*- */

#include <stdlib.h>

#include <sys/types.h>
#include <unistd.h>
#include <signal.h>


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
START_TEST(checkgen_test_func2)
{
exit(1);

}
END_TEST
START_TEST(checkgen_test_func3)
{
kill(getpid(), SIGUSR1);

}
END_TEST
START_TEST(checkgen_test_func4)
{
ck_assert(_i >= 0);
ck_assert(_i < 10);

}
END_TEST
START_TEST(checkgen_test_func5)
{
if (_i == 5)
	exit(0);
exit(1);

}
END_TEST
START_TEST(checkgen_test_func6)
{
char *invalid = NULL;
if (_i == 5) {
	;			/* Noop */
}
invalid[0] = '@';

/* Test case with unchecked fixture */
}
END_TEST
/* User defined code: Define a global for the fixture */
int *array;

/* Fixture function for test case "Checkgen Suite/Unckecked Fixtures". */
/* Allocate memory for the array */
static void checkgen_fixture_func0()
{
mark_point();
array = malloc(10 * sizeof(*array));
if (array == NULL) {
	/* Its an unchecked fixture, so, this ends the test
	 * runner. But memory allocation seldom fails. */
	exit(1);
}

}
/* Fixture function for test case "Checkgen Suite/Unckecked Fixtures". */
/* Free memory used by the array */
static void checkgen_fixture_func1()
{
mark_point();
free(array);

}
START_TEST(checkgen_test_func7)
{
array[0] = 20;
ck_assert_int_eq(array[0], 20);

/* Test case with checked fixture */
}
END_TEST
/* User defined code: Its time to declare a global */
char *astring = NULL;

/* Fixture function for test case "Checkgen Suite/Checked Fixture". */
/* A setup fixture function that fail, but tests continue */
static void checkgen_fixture_func2()
{
mark_point();
astring[0] = '@'; 	/* Oups */

}
START_TEST(checkgen_test_func8)
{
ck_assert_ptr_eq(astring, NULL);

/* Auxiliary directives */
}
END_TEST
/* Set the tcase timeout to 3 seconds. */
START_TEST(checkgen_test_func9)
{
ck_assert(1 == 1);

}
END_TEST
START_TEST(checkgen_test_func10)
{
sleep(3);

}
END_TEST
START_TEST(checkgen_test_func11)
{
ck_assert(1 + 1 == 2);
}
END_TEST
int main(int argc, char *argv[])
{
Suite *s;
TCase *tc;
SRunner *sr;
sr = srunner_create(NULL);
int nf;
/* User code from #main-pre: Declare a variable */
int number = 6;

s = suite_create("Checkgen Suite");
srunner_add_suite(sr, s);
tc = tcase_create("Checkgen Suite/Basic tests");
suite_add_tcase(s, tc);
_tcase_add_test(tc, checkgen_test_func0, "This test should fail", 0, 0, 0, 1);
_tcase_add_test(tc, checkgen_test_func1, "This test should success", 0, 0, 0, 1);
_tcase_add_test(tc, checkgen_test_func2, "Exit value == 1 is expected", 0, 1, 0, 1);
_tcase_add_test(tc, checkgen_test_func3, "Expect SIGUSR1", SIGUSR1, 0, 0, 1);
_tcase_add_test(tc, checkgen_test_func4, "A loop test that success", 0, 0, 0, 10);
_tcase_add_test(tc, checkgen_test_func5, "A loop test that should exit(1)", 0, 1, 0, 10);
_tcase_add_test(tc, checkgen_test_func6, "Segfault !", SIGSEGV, 0, 0, 10);
tc = tcase_create("Checkgen Suite/Unckecked Fixtures");
suite_add_tcase(s, tc);
tcase_add_unchecked_fixture(tc, checkgen_fixture_func0, NULL);
tcase_add_unchecked_fixture(tc, NULL, checkgen_fixture_func1);
_tcase_add_test(tc, checkgen_test_func7, "An useless test", 0, 0, 0, 1);
tc = tcase_create("Checkgen Suite/Checked Fixture");
suite_add_tcase(s, tc);
tcase_add_checked_fixture(tc, checkgen_fixture_func2, NULL);
_tcase_add_test(tc, checkgen_test_func8, "Successful test", 0, 0, 0, 1);
tc = tcase_create("Checkgen Suite/Auxiliary");
suite_add_tcase(s, tc);
tcase_set_timeout(tc, 1);
_tcase_add_test(tc, checkgen_test_func9, "A test", 0, 0, 0, 1);
/* User code from #main: Change number value */
number = 0;

_tcase_add_test(tc, checkgen_test_func10, "Will timeout", 0, 0, 0, 1);
_tcase_add_test(tc, checkgen_test_func11, "Another test", 0, 0, 0, 1);
/* User code from #main-post: Change the main() ending */
srunner_run_all(sr, CK_ENV);
return number;

}
```
