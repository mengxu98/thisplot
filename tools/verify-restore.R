args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
  stop("Expected a restore verification record.", call. = FALSE)
}
verification <- readRDS(args[[1L]])
library <- normalizePath(verification$library)
.libPaths(c(library, .Library), include.site = FALSE)

for (package in names(verification$sources)) {
  if (!requireNamespace(package, quietly = TRUE, lib.loc = library)) {
    stop("Could not load ", package, " from ", library, ".", call. = FALSE)
  }
  actual_path <- normalizePath(getNamespaceInfo(asNamespace(package), "path"))
  expected_path <- normalizePath(file.path(library, package))
  if (!identical(actual_path, expected_path)) {
    stop("Restored namespace loaded outside the target library: ", package, call. = FALSE)
  }
  actual_version <- as.character(utils::packageVersion(package, lib.loc = library))
  if (!identical(actual_version, verification$sources[[package]]$version)) {
    stop("Restored version differs from the source archive for ", package, ".", call. = FALSE)
  }
}
thisutils::check_r("thisutils", lib = library, install = FALSE, strict = TRUE, verbose = FALSE)

receipt <- list(
  r_version = R.version.string,
  renv_version = verification$renv_version,
  project = verification$project,
  library = library,
  library_paths = .libPaths(),
  lockfile_sha256 = digest::digest(file = verification$lockfile, algo = "sha256"),
  sources = lapply(names(verification$sources), function(package) {
    source <- verification$sources[[package]]
    list(
      package = package,
      version = source$version,
      archive = source$path,
      sha256 = digest::digest(file = source$path, algo = "sha256"),
      installed_path = getNamespaceInfo(asNamespace(package), "path")
    )
  })
)
saveRDS(receipt, file.path(library, "thisplot-restore-receipt.rds"))
message("Fresh-process package verification passed.")
