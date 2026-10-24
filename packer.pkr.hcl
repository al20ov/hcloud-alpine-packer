packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "~> 1.8"
    }
  }
}

variable "HCLOUD_TOKEN" {
  type      = string
  sensitive = true
  default   = env("HCLOUD_TOKEN")
}

locals {
  alpine_version    = "3.24"
  image_url         = "https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/cloud/alpine-3.24.3-aarch64-tiny-r0.qcow2"
  checksum_url      = "https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/cloud/alpine-3.24.3-aarch64-tiny-r0.qcow2.sha512"
  current_timestamp = "${formatdate("YYYY-MM-DD-hhmm", timestamp())}Z"
  snapshot_name     = "alpine-${local.alpine_version}-aarch64-${local.current_timestamp}"
}

source "hcloud" "rescue" {
  token         = var.HCLOUD_TOKEN
  image         = "ubuntu-26.04" # Doesn't matter because we're using rescue mode
  location      = "fsn1"         # Falkenstein
  server_type   = "cax11"        # ARM ampere
  ssh_username  = "root"
  rescue        = "linux64"
  snapshot_name = local.snapshot_name
  snapshot_labels = {
    "alpine_release_version" = local.alpine_version
    "creation_timestamp"     = local.current_timestamp
    "type"                   = "alpine"
  }
}

build {
  sources = ["source.hcloud.rescue"]

  provisioner "shell" {
    inline = [
      "wget ${local.image_url} -O alpine-3.24.qcow2",
      "wget ${local.checksum_url} -O alpine-3.24.qcow2.sha512",
      "echo `cat alpine-3.24.qcow2.sha512` alpine-3.24.qcow2 | sha512sum -c -",
      "qemu-img convert -f qcow2 -O raw alpine-3.24.qcow2 alpine-3.24.raw",
      "dd if=alpine-3.24.raw of=/dev/sda bs=4M status=progress",
      "sync"
    ]
  }
}
