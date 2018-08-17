# Instance Creation

Generate SSH key:

```bash
ssh-keygen -t rsa -C minikube -f minikube
```

You may leave the passphrase empty if desired.

If no AMI has been created yet, run `packer` to create it:

```bash
cd ami && packer build minikube.json
cd ..
```

Use terraform to create the EC2 instance:

```bash
terraform init && terraform apply
```

If the instance is successfully created, terraform will output the host name for the instance. You will need that value to login into the instance.

# Start Minikube

First, login into the EC2 instance:

```bash
ssh -i minikube ubuntu@<HOSTNAME>
```

Then, run:

```bash
sudo -E minikube start --vm-driver=none
```

(the previous command might take 1-2 minutes).

Set the minikube context:

```bash
kubectl config use-context minikube
```

And then verify that `kubectl` can communicate with the cluster:

```bash
kubectl cluster-info
```
