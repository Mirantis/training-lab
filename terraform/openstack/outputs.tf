output "floatin_ip_address" {
    description = "The actual IP address allocated for the resource"
    value       = "${zipmap(openstack_compute_instance_v2.vms.*.name, openstack_networking_floatingip_v2.floatingips.*.address)}"
}
