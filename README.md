## Windows Consul and Vault Clusters

### Getting Started

This repository contains a library of Packer templates and Terraform modules that allow you to provision unique infrastructures by referencing the different templates and modules to provision an HA Vault implementation backed by an HA Consul implementation running on Windows Servers, in either Amazon Web Services or Microsoft Azure.

This code is meant to serve as a reference when building your own infrastructure. The best way to get started is to pick an environment that resembles an infrastructure you are looking to build, get it up and running, then configure and modify it to meet your specific needs.

No example will be exactly what you need, but it should provide you with enough examples to get you headed in the right direction.

- Each environment will assume you're using Atlas. If you plan on doing anything locally, there are portions of environments that may not work due to the extra features Atlas provides that we are taking advantage of.
- Any `packer push` commands must be performed in the base [packer/.](packer) directory.
- Any `terraform push` commands must be performed in the appropriate Terraform environment directory (e.g. [terraform/providers/aws/us\_east\_1\_staging](terraform/providers/aws/us_east_1_staging)).