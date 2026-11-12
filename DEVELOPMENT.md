# Restore a development checkout

The development `renv.lock` records public dependencies. `thisutils` is
provided separately when testing unpublished changes, so it is listed in
`renv/settings.json` under `ignored.packages`.

Restore the complete environment with the two-stage command below. Supply
source archives built from the exact `thisutils` and `thisplot` checkouts
that you want to test. The command restores the public lock first, installs
both archives into the same library, and loads the resulting packages in a
fresh R process.

The public stage runs in a temporary project containing only a copy of the
lockfile. It does not read this checkout's `DESCRIPTION` or resolve its
`Remotes`. The temporary project is removed after either success or failure;
the requested target library remains available for the local source stage.

Build the source archives in a separate output directory:

```sh
R CMD build --no-build-vignettes --no-manual /path/to/thisutils
R CMD build --no-build-vignettes --no-manual /path/to/thisplot
```

Install `renv` in a separate bootstrap library, then make that library
available to the restore process:

```r
dir.create("/path/to/bootstrap-library", recursive = TRUE)
install.packages("renv", lib = "/path/to/bootstrap-library")
```

```sh
R_LIBS_USER=/path/to/bootstrap-library Rscript --vanilla tools/restore.R \
  /path/to/thisutils_0.5.4.tar.gz \
  /path/to/thisplot_0.4.7.tar.gz \
  /path/to/isolated-library
```

The `thisutils` archive must provide version 0.5.4 or newer. The `thisplot`
archive must match the version in this checkout. Use a new target library
to test a clean restore. The command removes the caller's user and site
libraries from dependency lookup; the R installation's base library remains
available. Set `RENV_CONFIG_CACHE_ENABLED=FALSE` when testing an uncached
restore.

The final `thisplot-restore-receipt.rds` in the target library records the
archive SHA-256 hashes, lockfile SHA-256, package versions, installed paths,
R version and bootstrap `renv` version. Keep the archives and receipt with
the validation results.

Running `renv::restore()` alone restores only the public stage. The complete
command above is required while `thisutils` is supplied as unpublished
local source. No local commit is recorded as a downloadable GitHub commit.

`DESCRIPTION` declares `mengxu98/thisutils` in `Remotes` for ordinary GitHub
installation. That route requires the remote source to satisfy the declared
version. It becomes usable after the corresponding dependency changes are
available there.
