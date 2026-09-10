# Changelog

## [1.0.2](https://github.com/nullplatform/services-postgresql-k-8-s/compare/v1.0.1...v1.0.2) (2026-09-10)


### Bug Fixes

* accept a trailing semicolon in SELECT queries and report empty results ([f7aa9c2](https://github.com/nullplatform/services-postgresql-k-8-s/commit/f7aa9c23c42aa2ff8b491e09e8a42294eab0bd93))
* accept a trailing semicolon in SELECT queries and report empty results ([3605a2e](https://github.com/nullplatform/services-postgresql-k-8-s/commit/3605a2e7dc9e4d69f155eaa47e55a41b13973c4b))

## [1.0.1](https://github.com/nullplatform/services-postgresql-k-8-s/compare/v1.0.0...v1.0.1) (2026-09-10)


### Bug Fixes

* read the admin secret name the way the action context delivers it ([77c2133](https://github.com/nullplatform/services-postgresql-k-8-s/commit/77c21336794baf98e4ea8a52ac9a2b19dbfaac87))
* read the admin secret name the way the action context delivers it ([bebb0d7](https://github.com/nullplatform/services-postgresql-k-8-s/commit/bebb0d7d0d129a482591f76ec1d454c42257f02c))

## 1.0.0 (2026-09-10)


### Features

* add service ([a7180d0](https://github.com/nullplatform/services-postgresql-k-8-s/commit/a7180d094e9f32bdcf3834a065319501d37a3e20))
* add tofu modules of example ([4e64d98](https://github.com/nullplatform/services-postgresql-k-8-s/commit/4e64d9864c7a08dfa78e5baaba9832fa05506094))
* **ci:** adopt the s3-aligned layout and publish a worker image on release ([bfca175](https://github.com/nullplatform/services-postgresql-k-8-s/commit/bfca175a9b89bdb1ac2dc215567b87700c89e050))
* **ci:** build+push the worker image and register its artifact on release ([9cd48c0](https://github.com/nullplatform/services-postgresql-k-8-s/commit/9cd48c0fc9ed9d83e7dfd19037db7c9381887263))
* init repository ([e384d48](https://github.com/nullplatform/services-postgresql-k-8-s/commit/e384d48ab967a2d21072baffa3df1e3d36a0d4e5))
* license and pipeline ([bae50ef](https://github.com/nullplatform/services-postgresql-k-8-s/commit/bae50ef1215d68bd4bdb042cc72a2d926684c831))
* remove docker ([503c6f4](https://github.com/nullplatform/services-postgresql-k-8-s/commit/503c6f44e3f50d5bf10fc30bba620b8b5995b66d))
* restructure service to align with services-s-3 layout ([11d589a](https://github.com/nullplatform/services-postgresql-k-8-s/commit/11d589aa2eace42ccfab8fb7f63b8e49dcf85817))


### Bug Fixes

* **build_context:** avoid false exit status on service actions ([5954ac9](https://github.com/nullplatform/services-postgresql-k-8-s/commit/5954ac9f0d97d98dc148d33859228ef08be15cf2))
* reference module output directly instead of remote state ([c2dc997](https://github.com/nullplatform/services-postgresql-k-8-s/commit/c2dc9970a80d6d77c559b8b5d93bbdbea7bd59ae))
* **spec:** make internal attrs readable so link workflows receive them ([93571b6](https://github.com/nullplatform/services-postgresql-k-8-s/commit/93571b6e95f56034db452783247d1e8695ac6851))
* strip single quotes from NP_ACTION_CONTEXT before np service-action exec ([#4](https://github.com/nullplatform/services-postgresql-k-8-s/issues/4)) ([011de99](https://github.com/nullplatform/services-postgresql-k-8-s/commit/011de99b886f350f5fe365e92c00f144cebd4d7a))

## Changelog
