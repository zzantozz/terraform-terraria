# Terraformed Terraria

This is a simple Terraform project to help manage my Terraria server in Rackspace Public Cloud.

Supplied with appropriate variable values, it creates a 2G instance using the latest ubuntu image.

It creates a public key using your local one at ~/.ssh/id_rsa.pub and installs it on the instance.

It updates no-ip.com with the ip of the new instance for convenience.

Example usage with defaults:

    TF_VAR_rax_token=$TOKEN TF_VAR_no_ip_password=$NO_IP_PW terraform plan

# Additional required steps!

This only sets up the instance. Next the Terraria binaries have to be installed. That's a touchy process, so I haven't
tried to automate it yet.

The steps to do this are saved in the README in my TerrariaFiles archive (not in GitHub).
