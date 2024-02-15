{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  # Aktivieren Sie Mosh
  programs.mosh.enable = true;

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.github_app_key = { };
  sops.secrets.webhook_secrets = { };

  services.nixpkgs-merge-bot = {
    enable = true;
    github-app-id = 829066;
    github-app-login = "nixpkgs-merge";
    github-app-private-key-file = config.sops.secrets.github_app_key.path;
    bot-name = "nixpkgs-merge-bot";
    hostname = "195.201.130.247";
    webhook-secret-file = config.sops.secrets.webhook_secrets.path;
  };

  #age150zm4arwau8pvmjmrzlkrnyg93m7lv2nytt6kkyjhnu7jpdwgyss32pxqd
   nix = {
    settings = {
      sandbox = "relaxed";
      experimental-features = [
        "flakes"
        "nix-command"
      ];
    };

    package = pkgs.nixUnstable;
    gc.automatic = true;
    gc.dates = "weekly";
    gc.options = "--delete-older-than 15d";
   };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.ssh-to-age
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDB0d0JA20Vqn7I4lCte6Ne2EOmLZyMJyS9yIKJYXNLjbLwkQ4AYoQKantPBkTxR75M09E7d3j5heuWnCjWH45TrfQfe1EOSSC3ppCI6C6aIVlaNs+KhAYZS0m2Y8WkKn+TT5JLEa8yybYVN/RlZPOilpj/1QgjU6CQK+eJ1k/kK+QFXcwN82GDVh5kbTVcKUNp2tiyxFA+z9LY0xFDg/JHif2ROpjJVLQBJ+YPuOXZN5LDnVcuyLWKThjxy5srQ8iDjoxBg7dwLHjby5Mv41K4W61Gq6xM53gDEgfXk4cQhJnmx7jA/pUnsn2ZQDeww3hcc7vRf8soogXXz2KC9maiq0M/svaATsa9Ul4hrKnqPZP9Q8ScSEAUX+VI+x54iWrnW0p/yqBiRAzwsczdPzaQroUFTBxrq8R/n5TFdSHRMX7fYNOeVMjhfNca/gtfw9dYBVquCvuqUuFiRc0I7yK44rrMjjVQRcAbw6F8O7+04qWCmaJ8MPlmApwu2c05VMv9hiJo5p6PnzterRSLCqF6rIdhSnuOwrUIt1s/V+EEZXHCwSaNLaQJnYL0H9YjaIuGz4c8kVzxw4c0B6nl+hqW5y5/B2cuHiumnlRIDKOIzlv8ufhh21iN7QpIsPizahPezGoT1XqvzeXfH4qryo8O4yTN/PWoA+f7o9POU7L6hQ== lhebendanz@nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ0y1grW5FXILS6hanXww/tXtubOOR3aqeJGS6woWza fritz@scriptkiddi"
  ];

  system.stateVersion = "23.11";
}
