## Windows Consul and Vault Clusters

### Getting Started

This repository contains a library of Packer templates and Terraform modules that allow you to provision unique infrastructures by referencing the different templates and modules to provision an HA Vault implementation backed by an HA Consul implementation running on Windows Servers, in either Amazon Web Services or Microsoft Azure.

This code is meant to serve as a reference when building your own infrastructure. The best way to get started is to pick an environment that resembles an infrastructure you are looking to build, get it up and running, then configure and modify it to meet your specific needs.

No example will be exactly what you need, but it should provide you with enough examples to get you headed in the right direction.

##### Set Local Environment Variables

Set the below environment variables if you'll be using Packer or Terraform locally.

    $ export AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
    $ export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
    $ export AWS_DEFAULT_REGION=us-east-1
