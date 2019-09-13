output "ssh_access" {
  value = {
    private_key_pem    = tls_private_key.k8s_admin.private_key_pem
    public_key_pem     = tls_private_key.k8s_admin.public_key_pem
    public_key_openssh = tls_private_key.k8s_admin.public_key_openssh
  }
}

output "kubernetes_cluster" {
  value = {
    name = var.cluster_name
    master_nodes = {
      user_data = local.k8s_master_userdata
      ipv4_addresses = hcloud_server.k8s_master.*.ipv4_address
      ipv6_addresses = hcloud_server.k8s_master.*.ipv6_address
    }
    master_api_endpoint_hostname = local.k8s_cluster_master_hostname
    master_api_endpoint_ipv4 = hcloud_floating_ip.k8s_master_ipv4.ip_address
  }
}
