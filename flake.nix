{
  # ------------------------------------------------------------
  # Flake do Homelab – ambiente de desenvolvimento (devShell)
  # ------------------------------------------------------------
  description = "Homelab";

  inputs = {
    # Canal do Nixpkgs (NixOS 24.05). Permite builds reprodutíveis.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Utilitários para gerar saídas por sistema (x86_64-linux, aarch64, etc).
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Conjunto de pacotes para o sistema alvo
        pkgs = import nixpkgs { inherit system; };

        # Ambiente Python com as libs necessárias (um único item na lista de packages)
        pythonEnv = pkgs.python3.withPackages (p: with p; [
          jinja2
          kubernetes
          mkdocs-material
          netaddr
          pexpect
          rich
        ]);

        # Grupo 1: Automação/Infra
        infraTools = with pkgs; [
          ansible
          ansible-lint
          opentofu          # Drop-in replacement para Terraform
          pre-commit
          shellcheck
          yamllint
        ];

        # Grupo 2: Containers/Kubernetes
        k8sTools = with pkgs; [
          docker
          docker-compose
          k9s
          kube3d
          kubectl
          kubernetes-helm
          kustomize
        ];

        # Grupo 3: VCS/Build/Test
        devTools = with pkgs; [
          git
          bmake
          gotestsum
          dyff
          diffutils
        ];

        # Grupo 4: Redes/Segurança
        netTools = with pkgs; [
          iproute2
          wireguard-tools
          qrencode
          openssh
        ];

        # Grupo 5: Utilidades/Editor/ISO/Compressão/Locale
        utilTools = with pkgs; [
          neovim
          jq
          libisoburn
          p7zip
          glibcLocales
          kanidm
        ];
      in
      {
        # devShell padrão com exatamente os mesmos pacotes de antes
        devShells.default = pkgs.mkShell {
          packages =
            infraTools
            ++ k8sTools
            ++ devTools
            ++ netTools
            ++ utilTools
            # Mantém o ambiente Python como único item (mesmo efeito do original)
            ++ [ pythonEnv ];
        };
      }
    );
}
