Prerequests:
- CentOS 7+
- Docker 1.12+

HOWTO:
- rename inventory.example to inventory 
- set your cluster info in inventory file 
- run `ansible-playbook k8s-cluster.yml`

If in inventory file set only 1 master, playbook will deploy standard kubeadm cluster.

# TODO:
- token generation
- e2e tests