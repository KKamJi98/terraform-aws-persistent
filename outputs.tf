output "dev_formatted_decrypted_passwords" {
  value = module.dev_group.formatted_decrypted_passwords
}

output "infra_formatted_decrypted_passwords" {
  value = module.infra_group.formatted_decrypted_passwords
}