#!/bin/bash -e

rm -rf *.tfstate*
terraform apply -auto-approve
