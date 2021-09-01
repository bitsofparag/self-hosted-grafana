# Make me Grafana

Grafana is great. For not-too-heavy visualizations and making your spreadsheet data look prettier.

So, here's some scripts to help you set it up on your favorite cloud provider (**NOTE:** currently only supports AWS)


## Pre-requisites

1. Ensure you have CLI access to your [cloud
   provider](https://en.wikipedia.org/wiki/Category:Cloud_computing_providers). For e.g, for AWS you
   will need the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in order to deploy resources to AWS.`

2. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform).

3. Install [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli?in=packer/aws-get-started#installing-packer) to build [AMIs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html).

4. If you want to access the Grafana instance via SSH, ensure you have an SSH key pair in `~/.ssh`.
   You can generate one with:
   ```
   ssh-keygen -t rsa -b 4096 -N '' -C foo@example.com -m PEM -f ~/.ssh/key_name_ec2
   ```


## Setup

1. `cp .env.example .env`.

2. Fill the values in the `.env` file where applicable. **Optionally**, set `INSTANCE_KEY_NAME` to the SSH
   key-pair file name you created above *(what you entered for "key_name_ec2")*.

3. Open `backend.tf` and choose the relevant backend. _Uncomment 1 if you're not sure._

4. Open `vpc-data.tf` and choose the relevant data source for VPC. _Uncomment 1 if you're not sure._

## Run

1. `BUILD_SOURCE=grafana make deploy-machine-image`

2. `make plan`

3. `make apply`

4. Note username: `terraform output grafana_user`

5. Note username: `terraform output -raw grafana_password`. Store the password in your password manager.

## Run with Nginx

TBA

## Tear down

1. `make destroy`
