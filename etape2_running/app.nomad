job "pcd2017" {
  region = "europe"
  datacenters = ["gce-west1"]

  type = "service"

  group "webs" {
    count = 3

    task "frontend" {
      driver = "docker"

      config {
        image = "httpd"
      }

      service {
        port = "http"
      }

      resources {
        cpu    = 200
        memory = 64

        network {
          mbits = 100

          port "http" {
            static = 80
          }
        }
      }
    }
  }
}
