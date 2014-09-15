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
