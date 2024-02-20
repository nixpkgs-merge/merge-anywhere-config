{ mkShell, age, openssh, nixos-anywhere, ssh-to-age }:
mkShell {
  packages = [
    age
    openssh
    nixos-anywhere
    ssh-to-age
  ];
}