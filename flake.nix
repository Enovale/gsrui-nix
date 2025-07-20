{
  description = "GPU Screen Recorder Shadowplay UI Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      mkModule =
        {
          name ? "default",
          class,
          file,
        }:
        {
          _class = class;
          _file = "${self.outPath}/flake.nix#${class}Modules.${name}";

          imports = [ (import file { flakeSelf = self; }) ];
        };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # https://discourse.nixos.org/t/different-ways-of-populating-pkgs-variable/29109/2
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = self.packages.${system}.gpu-screen-recorder-ui;
          gpu-screen-recorder-ui = pkgs.callPackage ./package.nix { };
          gpu-screen-recorder-notification = pkgs.callPackage ./notification.nix { };
        };
      }
    )
    // {
      nixosModules.default = mkModule {
        class = "nixos";
        file = ./module.nix;
      };
    };
}
