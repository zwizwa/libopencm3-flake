# A Nix Flake wrapper for libopencm3, specialized to uc_tools
# STM32F103 development.
{
  description = "libopencm3 STM32F103 build";
  inputs.nixpkgs.url = github:zwizwa/nixpkgs;

  inputs.libopencm3 = {
    type = "github";
    owner = "zwizwa";
    repo = "libopencm3";
    rev = "3eff201a4bb3759a9c967a6f5e3fd0aad46dc5af";
    flake = false;
  };

  outputs = { self, nixpkgs, libopencm3 }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
  {
    packages.x86_64-linux.default =
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation {
        name = "libopencm3";
        buildInputs = with pkgs; [
          gcc-arm-embedded python patch
        ];
        src = self;
        inherit libopencm3; # Source
        builder = ./builder.sh;
        enableParallelBuilding = true;
      };
  };
}
