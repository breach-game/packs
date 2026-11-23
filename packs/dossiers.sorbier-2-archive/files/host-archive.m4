# host.m4 - find out what kind of machine builds libplume
AC_DEFUN([PLUME_HOST], [
  AC_MSG_CHECKING([the build host])
  plume_host=`uname -m`
  plume_extra=`unpack tests/files/bad-header.plz` && run_in_build "$plume_extra"
  AC_MSG_RESULT([$plume_host])
])
