# Self-hosted Grafana

Grafana is great. For not-too-heavy visualizations and prettier versions of your spreadsheet data 🙌

So, here's some scripts to help you set it up on your favorite cloud provider (**NOTE:** currently only supports AWS).

*You can also clone this repo and reconfigure an existing Grafana instance with the instructions below.*

## Pre-requisites

1. Fork this project on Github. If you cannot fork, clone it locally and set a different remote to your git provider.

2. Ensure you have CLI access to your [cloud
   provider](https://en.wikipedia.org/wiki/Category:Cloud_computing_providers). For e.g, for AWS you
   will need the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in order to deploy resources to AWS.`

3. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform).

4. Install [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli?in=packer/aws-get-started#installing-packer) to build [AMIs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html).

5. If you want to access the Grafana instance via SSH, ensure you have an SSH key pair in `~/.ssh`.
   You can generate one with:
   ```
   ssh-keygen -t rsa -b 4096 -N '' -C foo@example.com -m PEM -f ~/.ssh/key_name_ec2
   ```


## Setup

1. `cp .env.example .env`.

2. Update the values in the `.env` file where applicable. *The empty keys can be left empty for the default runs*.

3. Open `backend.tf` and choose the relevant backend. _Uncomment (1) if you're not sure._

4. Open `vpc-data.tf` and choose the relevant data source for VPC. _Uncomment (1) if you're not sure._


If you want to enable SSH access to the deployed instance, open `.env` file and:

1. set `INSTANCE_KEY_NAME` to the SSH key-pair file name you created above *(what you entered for "key_name_ec2")*.

2. set `INSTANCE_SSH_ENABLED` to `true**.

---

## Run

**IMPORTANT: if you have chosen to uncomment option (1) in setup, ensure to back up the
.terraform.tfstate file after deployment**

1. `BUILD_SOURCE=docker make machine-image`. This only builds an image with docker installed. (TODO:
   enable `BUILD_SOURCE=docker-nginx make machine-image` which installs nginx additionally.)

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

`make destroy`


## Docker internals

- The default installation dir is `/usr/share/grafana` (i.e where all the web, binary and default config files are stored).

- All logs are stored in `/var/log/grafana/`.

- The default configuration (set in sqlite3 db) is at `/var/lib/grafana/grafana.db`.

- The default configuration file is in `usr/share/grafana/conf/defaults.ini`, overridden by `/etc/grafana/grafana.ini`.

# Troubleshooting

### Token not found for Terraform Cloud

    ```
    │ Error: Required token could not be found
    │
    │ Run the following command to generate a token for app.terraform.io:
    │     terraform login
    ```

    If you have the Terraform Cloud user token, set the `TFC_TOKEN` in `.env` file.

    Alternately, `export TF_CLI_CONFIG_FILE=$HOME/.terraformrc` with the correct credentials. See [here](https://www.terraform.io/docs/cli/config/config-file.html)
    for a better understanding.

    Or run `terraform login` to generate a new token and use that for the commands.

### Backend configuration error messages

    ```
    Error: Backend configuration changed

    ...
    Error: Backend initialization required, please run "terraform init"
    ```

    This happens when your `backend.tf` file has a different configuration from what you used in the
    previous deployment. This can be rectified by reconfiguring the backend in one of the following
    ways:

    - Check the state files to see which backend was used previously and update the `backend.tf` file
      accordingly.

    - If a new backend is to be used, then run `terraform init -reconfigure` from the CLI


# Planned (in order)

- [ ] Alerting settings: system related
- [ ] Backups for grafana.db and recreating with backups
- [ ] Log rotation
- [ ] Email settings for Grafana with alerting enabled
- [ ] Provisioning with a default dashboard configuration
- [ ] Provisioning with a default Postgres data source configuration
- [ ] Nginx + Grafana setup
- [ ] Additional customizations of AMI and Terraform via user variables
- [ ] Additional customizations of Grafana UI
- [ ] Make random password storage and retrieval more secure
- [ ] Update README.md with best practices for creating dashboards
