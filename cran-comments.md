# CRAN submission comments — bibnets 0.3.0

## First submission

## R CMD check results

0 errors | 0 warnings | 0 notes

Tested on:
- macOS Tahoe 26.3.1 (aarch64), R 4.5.2 — `R CMD check --as-cran`: OK
- win-builder (R-devel) — pending
- All 6 URLs validated via `urlchecker::url_check()`

## Notes

None expected. The three bundled datasets are XZ-compressed and necessary
to demonstrate all package functions without requiring external downloads:

- `biblio_data`: 10 rows synthetic data for examples and tests.
- `scopus_quantum_cloud`: 499 Scopus records (CC BY 4.0,
  doi:10.5281/zenodo.17142636).
- `open_alex_gold_open_access_learning_analytics`: 1,508 OpenAlex records
  (CC0).

## Reverse dependencies

None (new package).
