/* -*- c -*- */

#suite Checkgen
#tcase Basics

#test This test should fail
ck_assert(1 == 0);

#test This test should success
ck_assert(1 == 1);
