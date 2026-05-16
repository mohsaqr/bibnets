## Cap BLAS/OpenMP threads so check-farm machines with multi-threaded
## BLAS (OpenBLAS, MKL) don't make CPU time exceed elapsed by >2x. CRAN
## permits at most 2 cores in tests. The package uses no explicit
## parallelism; the only multi-threaded path is Matrix's
## crossprod/tcrossprod inheriting BLAS threading on tiny test matrices.
## (The data.table/biblionetwork equivalence tests, the previous source
## of >2x CPU, now live outside the package in
## local_testing_and_equivalence/ and are not part of R CMD check.)
Sys.setenv(OMP_THREAD_LIMIT = "2", OMP_NUM_THREADS = "2")

library(testthat)
library(bibnets)

test_check("bibnets")
