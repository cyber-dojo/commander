
image:
	@${PWD}/sh/build_image.sh

# tids narrows the run to the test files whose name contains it,
# eg make test_image tids=065 runs only test_065_update.sh
test_image:
	@${PWD}/sh/run_tests.sh ${tids}
