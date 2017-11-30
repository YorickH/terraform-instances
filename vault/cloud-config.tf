data "template_cloudinit_config" "vault1" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig_vault1.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.install.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${module.teleport_vault1.teleport_bootstrap_script}"
  }
}

data "template_cloudinit_config" "vault2" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig_vault2.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.install.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${module.teleport_vault2.teleport_bootstrap_script}"
  }
}

data "template_file" "cloudconfig_vault1" {
  template = "${file("${path.module}/templates/configure.yaml.tpl")}"

  vars {
    vault_dns         = "vault1.${var.dns_root}"
    vault_nproc       = "${var.vault_nproc}"
    vault_cluster_dns = "vault.${var.dns_root}"
  }
}

data "template_file" "cloudconfig_vault2" {
  template = "${file("${path.module}/templates/configure.yaml.tpl")}"

  vars {
    vault_dns         = "vault2.${var.dns_root}"
    vault_nproc       = "${var.vault_nproc}"
    vault_cluster_dns = "vault.${var.dns_root}"
  }
}

data "template_file" "install" {
  template = "${file("${path.module}/templates/install.sh.tpl")}"

  vars {
    download_url_vault    = "${var.download_url_vault}"
    download_url_teleport = "${var.download_url_teleport}"
  }
}

module "teleport_vault1" {
  source      = "github.com/skyscrapers/terraform-teleport//teleport-bootstrap-script?ref=2.1.2"
  auth_server = "${var.teleport_auth_server}"
  auth_token  = "${var.teleport_token_1}"
  function    = "vault1"
  environment = "${terraform.workspace}"
}

module "teleport_vault2" {
  source      = "github.com/skyscrapers/terraform-teleport//teleport-bootstrap-script?ref=2.1.2"
  auth_server = "${var.teleport_auth_server}"
  auth_token  = "${var.teleport_token_2}"
  function    = "vault2"
  environment = "${terraform.workspace}"
}
