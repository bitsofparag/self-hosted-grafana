# Make me Grafana

Grafana is great. For not-too-heavy visualizations and prettier versions of your spreadsheet data 🙌

So, here's some scripts to help you set it up on your favorite cloud provider (**NOTE:** currently only supports AWS).

*You can also clone this repo and reconfigure an existing Grafana instance with the instructions below.*

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

2. Update the values in the `.env` file where applicable. *The empty keys can be left empty for the default runs*.

3. Open `backend.tf` and choose the relevant backend. _Uncomment 1 if you're not sure._

4. Open `vpc-data.tf` and choose the relevant data source for VPC. _Uncomment 1 if you're not sure._


If you want to enable SSH access to the deployed instance, open `.env` file and:

1. set `INSTANCE_KEY_NAME` to the SSH key-pair file name you created above *(what you entered for "key_name_ec2")*.

2. set `INSTANCE_SSH_ENABLED` to `true`.

---

## Run

1. `BUILD_SOURCE=grafana make machine-image`

2. `make plan`

3. `make apply`

4. Get the username from the CLI with `terraform output grafana_user`

5. Get the password from the CLI with `terraform output -raw grafana_password`. *Store the password in your password manager!*

6. Check the cloud console for the instance to be ready.

7. `open $(terraform output grafana_dashboard_url)`

8. Log in with the above credentials and configure as needed.

9. (Optional) Copy the ssh config with `terraform output grafana_dashboard_ssh_config`

## Run with Nginx

TBA

## Tear down

1. `make destroy`

# Planned (in order)

- Alerting settings: Grafana and system related
- Backups for grafana.db and recreating with backups
- Log rotation
- Provisioning with a default dashboard configuration
- Provisioning with a default Postgres data source configuration
- Nginx + Grafana setup
- Additional customizations of AMI and Terraform via user variables
- Additional customizations of Grafana UI
- Update README.md with best practices for creating dashboards
