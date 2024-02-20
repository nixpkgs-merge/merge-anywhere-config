{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.mergebot.url = "github:Luis-Hebendanz/nixpkgs-merge-bot";

  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

#       devShells.default = pkgs.callPackage ./shell.nix { };
 # perSystem = { self', pkgs, ... }:
  outputs = inputs @ { nixpkgs, disko,  mergebot, sops-nix, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        nixosConfigurations.hetzner-cloud = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              sops-nix.nixosModules.sops
              mergebot.nixosModules.nixpkgs-merge-bot
              disko.nixosModules.disko
              ./configuration.nix
            ];
          };
          # tested with 2GB/2CPU droplet, 1GB droplets do not have enough RAM for kexec
          nixosConfigurations.digitalocean = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              disko.nixosModules.disko
              mergebot.nixosModules.nixpkgs-merge-bot
              sops-nix.nixosModules.sops
              { disko.devices.disk.disk1.device = "/dev/vda"; }
              ./configuration.nix
            ];
          };
          nixosConfigurations.hetzner-cloud-aarch64 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              disko.nixosModules.disko
              mergebot.nixosModules.nixpkgs-merge-bot
              sops-nix.nixosModules.sops
              ./configuration.nix
            ];
          };
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = { self', pkgs, ... }:
        {
          devShells.default = pkgs.callPackage ./shell.nix { };
        };
    };
}

