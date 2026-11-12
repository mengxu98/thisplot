args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) {
  stop(
    "Usage: Rscript tools/restore.R <thisutils.tar.gz> <thisplot.tar.gz> <library>",
    call. = FALSE
  )
}

script <- grep("^--file=", commandArgs(), value = TRUE)
if (length(script) != 1L) {
  stop("Run this file with Rscript.", call. = FALSE)
}
project <- dirname(dirname(normalizePath(sub("^--file=", "", script))))
lockfile <- file.path(project, "renv.lock")
if (!file.exists(lockfile)) {
  stop("Missing project lockfile: ", lockfile, call. = FALSE)
}

source_metadata <- function(path, package) {
  if (!file.exists(path) || dir.exists(path)) {
    stop("Missing source archive: ", path, call. = FALSE)
  }
  path <- normalizePath(path)
  member <- paste0(package, "/DESCRIPTION")
  if (!member %in% utils::untar(path, list = TRUE)) {
    stop("Source archive does not contain ", member, ": ", path, call. = FALSE)
  }
  temporary <- tempfile("thisplot-source-")
  dir.create(temporary)
  on.exit(unlink(temporary, recursive = TRUE), add = TRUE)
  status <- utils::untar(path, files = member, exdir = temporary)
  if (!identical(status, 0L)) {
    stop("Could not read source archive: ", path, call. = FALSE)
  }
  metadata <- read.dcf(file.path(temporary, member))
  if (!identical(unname(metadata[1L, "Package"]), package)) {
    stop("Wrong package in source archive: ", path, call. = FALSE)
  }
  list(path = path, version = unname(metadata[1L, "Version"]))
}

restore_public <- function(lockfile, library) {
  public_project <- tempfile("thisplot-public-restore-")
  dir.create(public_project)
  on.exit(unlink(public_project, recursive = TRUE), add = TRUE)
  public_lockfile <- file.path(public_project, "renv.lock")
  if (!file.copy(lockfile, public_lockfile)) {
    stop("Could not copy the public dependency lockfile.", call. = FALSE)
  }
  renv::restore(
    project = public_project,
    library = library,
    lockfile = public_lockfile,
    prompt = FALSE
  )
}

sources <- list(
  thisutils = source_metadata(args[[1L]], "thisutils"),
  thisplot = source_metadata(args[[2L]], "thisplot")
)
if (utils::packageVersion("base") < "4.1.0") {
  stop("R 4.1.0 or newer is required.", call. = FALSE)
}
if (package_version(sources$thisutils$version) < "0.5.4") {
  stop("The thisutils source archive must provide version 0.5.4 or newer.", call. = FALSE)
}
expected_version <- unname(read.dcf(file.path(project, "DESCRIPTION"))[1L, "Version"])
if (package_version(sources$thisplot$version) != package_version(expected_version)) {
  stop("The thisplot source archive must match checkout version ", expected_version, ".", call. = FALSE)
}

if (!requireNamespace("renv", quietly = TRUE)) {
  stop("Install renv in a bootstrap library before running this command.", call. = FALSE)
}
renv_version <- as.character(utils::packageVersion("renv"))
library <- normalizePath(args[[3L]], mustWork = FALSE)
dir.create(library, recursive = TRUE, showWarnings = FALSE)
if (!dir.exists(library)) {
  stop("Could not create target library: ", library, call. = FALSE)
}
library <- normalizePath(library)
unlink(file.path(library, "thisplot-restore-receipt.rds"))
.libPaths(c(library, .Library), include.site = FALSE)
Sys.setenv(R_LIBS_USER = library, R_LIBS_SITE = "")

message("Restoring locked public dependencies into ", library)
restore_public(lockfile, library)

r <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "R.exe" else "R")
for (package in names(sources)) {
  message("Installing local source archive for ", package)
  status <- system2(
    r,
    c("CMD", "INSTALL", paste0("--library=", shQuote(library)), shQuote(sources[[package]]$path))
  )
  if (!identical(status, 0L)) {
    stop("Local source installation failed for ", package, ".", call. = FALSE)
  }
}

verification <- list(
  r_version = R.version.string,
  renv_version = renv_version,
  project = project,
  library = library,
  lockfile = lockfile,
  sources = sources
)
verification_path <- tempfile("thisplot-restore-", fileext = ".rds")
saveRDS(verification, verification_path)
status <- system2(
  file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"),
  c("--vanilla", shQuote(file.path(project, "tools", "verify-restore.R")), shQuote(verification_path))
)
unlink(verification_path)
if (!identical(status, 0L)) {
  stop("Fresh-process verification of the restored packages failed.", call. = FALSE)
}
message("Restored thisplot ", sources$thisplot$version, " with thisutils ", sources$thisutils$version)
message("Restore receipt: ", file.path(library, "thisplot-restore-receipt.rds"))
