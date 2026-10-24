# hcloud-alpine-packer

## Building an image

1. `packer init packer.pkr.hcl`
2. `HCLOUD_TOKEN=<your hcloud token> packer build packer.pkr.hcl`

## Notes

Resulting snapshots are aarch64 only for now.

The packer file is based on https://tatusl.dev/posts/customized-hcloud-images-with-packer/.

When creating a VM from this snapshot, make sure to add an SSH key so you can log in. The default user is `alpine`, so run `ssh -i <your public SSH key> alpine@<public IP>` and it should log you right in.

