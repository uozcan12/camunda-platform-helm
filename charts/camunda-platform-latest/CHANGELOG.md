# Changelog

## [10.4.1](https://github.com/camunda/camunda-platform-helm/compare/camunda-platform-latest-v10.4.0...camunda-platform-latest-10.4.1) (2024-10-02)


### Bug Fixes

* double-slash issue in health check paths and constraints for Zeebe Gateway ([#2355](https://github.com/camunda/camunda-platform-helm/issues/2355)) ([5a96d15](https://github.com/camunda/camunda-platform-helm/commit/5a96d15d03428a15612495987396acc0f17cb5fc))
* identity firstuser existingsecretkey has no effect ([#2370](https://github.com/camunda/camunda-platform-helm/issues/2370)) ([0aecce9](https://github.com/camunda/camunda-platform-helm/commit/0aecce930c3b5ea0ba8ef225ee117b5c6b393352))
* Include opensearch env vars in operate initContainer ([#2361](https://github.com/camunda/camunda-platform-helm/issues/2361)) ([de25d75](https://github.com/camunda/camunda-platform-helm/commit/de25d7570c8e2e2a0b048f6e216d68c07b44a757))
* use named version of identity to copy camunda theme ([#2340](https://github.com/camunda/camunda-platform-helm/issues/2340)) ([3dc4c86](https://github.com/camunda/camunda-platform-helm/commit/3dc4c86a6017f5cd2a931d8e755e8cc797cd0bab))


### Refactors

* default keycloak ingress pathType to Prefix ([#2372](https://github.com/camunda/camunda-platform-helm/issues/2372)) ([377c18f](https://github.com/camunda/camunda-platform-helm/commit/377c18fc9e0316c6ee0d43b89759c8ffdaa58540))
* using bitnami oci chart repository ([#2356](https://github.com/camunda/camunda-platform-helm/issues/2356)) ([18fa53e](https://github.com/camunda/camunda-platform-helm/commit/18fa53e914c4acca314014dada47b057c69cb2db))
