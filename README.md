# alicloud-k8s-starter
Get started with Serverless Kubernetes on Alibaba Cloud.

## Step 0: Configure credentials

1. Create an account on [alibabacloud.com](https://account.alibabacloud.com/register/intl_register.htm)
2. Log in to the account
3. Add a payment method (credit card / PayPal)
4. Hover over your avatar in top right, select 'AccessKey'
5. Create an access key and note down the access key ID and secret

Wire the access keys into your local environment so Terraform picks them up:

```sh
export ALICLOUD_ACCESS_KEY=......
export ALICLOUD_SECRET_KEY=......
export ALICLOUD_REGION=us-east-1
```

Replace the `.....` with your access key and secret key. Change the region if you don't want to deploy in Virginia.
Note that Serverless Kubernetes is not fully supported in all regions, so it's probably best to stick with `us-east-1`.

## Step 1: Deploy VPC

Before we can start deploying anything, we need to set up an isolated network with subnets to deploy resources in.
This module will set up a basic two-tier (private + data) network, with a NAT gateway so resources in the private
subnets can reach the internet, but the internet cannot connect to the machines directly. The data tier is used
for hosting databases, they have no connectivity to the internet at all.

To deploy the stack:

```sh
cd 1-vpc/
terraform init
terraform apply -auto-approve
```

## Step 2: Deploy Serverless Kubernetes cluster

Before you can deploy the cluster, you will need to browse to the 'Container Service for Kubernetes' service on the
Alibaba Cloud management console. It will ask you to authorize Container Service to take actions in your account.
Confirm the authorization policies before deploying the cluster, or it will error.

Let's now deploy a Serverless Kubernetes cluster. Serverless means that you don't need to manage any master or worker nodes
for your cluster, and Alibaba Cloud will take care of everything. You do get an official Kubernetes API endpoint that
you can talk to using `kubectl`. 

```sh
cd 2-cluster/
terraform init
terraform apply -auto-approve
```

## Step 3: Deploy NGINX Ingress Controller

By default, deployed Ingress objects will be bound to a Layer 7 load balancer automatically provisioned by Alibaba
Cloud. To support more advanced use cases, it can be handy to deploy your own ingress controller into the cluster. The 
[NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) is the most widely used one, which we will 
deploy next.

Make sure you have the official Aliyun CLI ([website](https://www.alibabacloud.com/help/doc-detail/110343.htm?spm=a2c63.l28256.b99.4.7b52a8933NEg51)) 
installed and configured (`aliyun configure`) with your access key and the correct region. You will also need 
`jq` ([website](https://stedolan.github.io/jq/)) for extracting your Kubectl config automatically. You could also get it from 
the Alibaba Cloud Container Service management console. Make sure the Kubectl config is available in `~/.kube/config`.

To get the Kubectl config automatically and deploy the stack:

```sh
aliyun cs DescribeClusterUserKubeconfig --ClusterId $(aliyun cs DescribeClusters | jq -r '.[0].cluster_id') | jq -r '.config' > ~/.kube/config
cd 3-ingress-controller/
terraform init
terraform apply -auto-approve
```

If you manually put your Kubectl config in `~/.kube/config` you can skip the first step.

## Step 4: Deploy Cert Manager

When hosting applications, we cannot go without SSL certificates. Luckily, Let's Encrypt provides us with free
certificates that can be extended every 3 months. To automate the provisioning and renewal of Let's Encrypt
certificates in our cluster, let's install `cert-manager`, a Kubernetes operator that handles certificates.

To deploy the stack, you will need to install [this provider](https://github.com/banzaicloud/terraform-provider-k8s)
locally so Terraform can find it. It is not in the official registry (yet). Download the release for your OS and
put the binary in the `4-cert-manager/` folder.

To deploy the stack:

```sh
aliyun cs DescribeClusterUserKubeconfig --ClusterId $(aliyun cs DescribeClusters | jq -r '.[0].cluster_id') | jq -r '.config' > ~/.kube/config
cd 4-cert-manager/
terraform init
terraform apply -auto-approve
```

## (Optional) Step 5: Set DNS records

The next step before we can officially deploy an application and serve traffic is point a DNS record on the 
domain name to our NGINX Ingress. This will only work with a domain name you own and control. If you don't have
one, you can skip this step.

Before deploying the stack, be sure that you created a DNS hosted zone in the Alibaba Cloud DNS management console
and pointed the nameservers of your domain to the ones shown by Alibaba Cloud. If you bought a domain name through
Alibaba Cloud, this will already be done for you.

To deploy the stack (update the locals in `main.tf` if necessary):

```sh
aliyun cs DescribeClusterUserKubeconfig --ClusterId $(aliyun cs DescribeClusters | jq -r '.[0].cluster_id') | jq -r '.config' > ~/.kube/config
cd 5-dns/
terraform init
terraform apply -auto-approve
```

## Step 6: Deploy application

Now it's time to run an application on the cluster. Specify an application name, image, port, domain name and 
path in `main.tf`. If you skipped step 5, use a dummy domain like `example.com`. 

To deploy the stack:

```sh
aliyun cs DescribeClusterUserKubeconfig --ClusterId $(aliyun cs DescribeClusters | jq -r '.[0].cluster_id') | jq -r '.config' > ~/.kube/config
cd 6-application/
terraform init
terraform apply -auto-approve
```

If the application is deployed, you should be able to access the service as follows:

`curl -H "Host: example.com" https://xx.xx.xx.xx/demo`

To get the IP address that you need, use `kubectl`:

`kubectl get service/nginx-ingress-lb -n kube-system`

If you used a domain name, you should be able to access the application in the browser, with a Let's Encrypt
certificate served correctly!
