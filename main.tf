resource "tls_private_key" "k8s_admin" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "k8s_admin" {
  name       = "k8s_admin"
  public_key = tls_private_key.k8s_admin.public_key_openssh
}

resource "hcloud_network" "k8s_cluster" {
  name     = "${var.cluster_name}-private"
  ip_range = "10.0.0.0/16"
  labels = {
    "cluster.kubernetes.io/${var.cluster_name}" = "owned"
  }
}

resource "hcloud_floating_ip" "k8s_master_ipv4" {
  home_location = "nbg1" # TODO hard-coded
  type        = "ipv4"
  description = "${var.cluster_name}: Master Nodes"
  labels = {
    "cluster.kubernetes.io/${var.cluster_name}" = "owned"
  }
}

locals {
  k8s_master_userdata = templatefile("${path.module}/user-data.sh.tmpl", {
    KUBERNETES_VERSION = var.kubernetes_version
    DOCKER_VERSION = var.docker_version
  })
}

resource "hcloud_server" "k8s_master" {

  count       = var.master_count
  name        = "k8s-master-${count.index}"
  image       = "fedora-30"
  server_type = "cx11"

  labels = {
    "cluster.kubernetes.io/${var.cluster_name}" = "owned"
  }

  ssh_keys = [
    hcloud_ssh_key.k8s_admin.id,
  ]

  #connection {
  #  private_key = tls_private_key.k8s_admin.private_key_pem
  #}

  user_data = local.k8s_master_userdata

}

locals {
  k8s_cluster_master_hostname = "${var.cluster_name}.cathive.com"
}

resource "hcloud_rdns" "floating_k8s_master" {
  floating_ip_id = hcloud_floating_ip.k8s_master_ipv4.id
  ip_address     = hcloud_floating_ip.k8s_master_ipv4.ip_address
  dns_ptr        = local.k8s_cluster_master_hostname
}
