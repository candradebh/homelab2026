.POSIX:
.PHONY: *
.EXPORT_ALL_VARIABLES:

#SE ALTERAR AQUI: altere também em ./roles/fetch-kubeconfig/vars/main.yaml
KUBECONFIG := $(HOME)/.kube/kubeconfig.yaml
KUBE_CONFIG_PATH = $(KUBECONFIG)

default: k3s configure-cluster system external smoke-test post-install clean

########### CLuster
k3s:
	cd k3s-ansible && \
    	ansible-playbook playbooks/site.yml -i ../inventory.yml

k3s-reset:
	cd k3s-ansible && \
		ansible-playbook playbooks/reset.yml -i ../inventory.yml

k3s-upgrade:
	cd k3s-ansible && \
		ansible-playbook playbooks/upgrade.yml -i ../inventory.yml

k3s-reboot:
	cd k3s-ansible && \
	ansible-playbook playbooks/reboot.yml -i ../inventory.yml

configure-cluster:
	ansible-playbook ./roles/configure-cluster.yml -i inventory.yml

configure:
	./scripts/configure
	git status

metal:
	make -C metal

system:
	make -C system

external:
	make -C external

smoke-test:
	make -C test filter=Smoke

post-install:
	@./scripts/hacks

# TODO maybe there's a better way to manage backup with GitOps?
backup:
	./scripts/backup --action setup --namespace=actualbudget --pvc=actualbudget-data
	./scripts/backup --action setup --namespace=jellyfin --pvc=jellyfin-data

restore:
	./scripts/backup --action restore --namespace=actualbudget --pvc=actualbudget-data
	./scripts/backup --action restore --namespace=jellyfin --pvc=jellyfin-data

test:
	make -C test

clean:
	docker compose --project-directory ./metal/roles/pxe_server/files down

docs:
	mkdocs serve

git-hooks:
	pre-commit install

passwords:
	ansible-playbook ./roles/passwords.yml -i inventory.yml

wipe-disk:
	ansible-playbook ./roles/wipe-disk.yml -i inventory.yml