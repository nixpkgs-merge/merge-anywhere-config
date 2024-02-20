{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./mergebot.nix
  ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];
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


  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
  };
  security.acme.acceptTerms = true;

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
    pkgs.tcpdump
    pkgs.helix
    pkgs.neovim
    pkgs.ssh-to-age
    pkgs.hello
  ];


  system.stateVersion = "23.11";
}
