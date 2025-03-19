resource "google_artifact_registry_repository" "my-repo-upstream-1" {
    location      = "us-central1"
    repository_id = "my-repository-upstream-1"
    description   = "example docker repository (upstream source) 1"
    format        = "DOCKER"
  }
  
  resource "google_artifact_registry_repository" "my-repo-upstream-2" {
    location      = "us-central1"
    repository_id = "my-repository-upstream-2"
    description   = "example docker repository (upstream source) 2"
    format        = "DOCKER"
  }
  
  resource "google_artifact_registry_repository" "my-repo" {
    depends_on    = []
    location      = "us-central1"
    repository_id = "my-repository"
    description   = "example virtual docker repository"
    format        = "DOCKER"
    mode          = "VIRTUAL_REPOSITORY"
    virtual_repository_config {
      upstream_policies {
        id          = "my-repository-upstream-1"
        repository  = google_artifact_registry_repository.my-repo-upstream-1.id
        priority    = 20
      }
      upstream_policies {
        id          = "my-repository-upstream-2"
        repository  = google_artifact_registry_repository.my-repo-upstream-2.id
        priority    = 10
      }
    }
  }