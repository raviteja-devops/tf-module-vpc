locals {
  common_tags = {
    env = var.env
    project = "roboshop"
    business_unit = "ecommerce"
    owner = "ecommerce-robot"
  }
}
# these are the common tags for all the resources we create
# any resource we create tags are mandatory
# tags are going to help to filtering the resources and for billing purpose, finding bill based on tags
