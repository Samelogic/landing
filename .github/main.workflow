workflow "Build and deploy on push" {
  on = "push"
  resolves = [
    "NPM Build",
    "Terraform Apply",
  ]
}

action "NPM Install" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  runs = "npm install"
}

action "NPM Build" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  needs = ["NPM Install"]
  runs = "npm run build"
}

action "Terraform Init" {
  uses = "hashicorp/terraform-github-actions/init@v0.2.0"
  secrets = [
    "GITHUB_TOKEN",
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
  env = {
    TF_ACTION_WORKING_DIR = "terraform"
  }
}

action "Terraform Plan" {
  uses = "hashicorp/terraform-github-actions/plan@v0.2.0"
  needs = "Terraform Init"
  secrets = [
    "GITHUB_TOKEN",
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
  env = {
    TF_ACTION_WORKSPACE = "prod"
    TF_ACTION_WORKING_DIR = "terraform"
    TF_ACTION_COMMENT = "false"
  }
  args = "-var deploy_iam_role=arn:aws:iam::232825056036:role/LandingPageDeployAssumeRole"
}

action "Terraform Apply" {
  uses = "hharnisc/terraform-github-actions-apply@v0.0.3-beta-02"
  needs = "Terraform Plan"
  secrets = [
    "GITHUB_TOKEN",
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
  env = {
    TF_ACTION_WORKING_DIR = "terraform"
    TF_ACTION_WORKSPACE = "prod"
    TF_ACTION_COMMENT = "false"
  }
}
