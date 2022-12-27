{ self, lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkEnableOption
    mkOption
    types;
in
{
  options = {
    perSystem = mkPerSystemOption ({ config, self', inputs', pkgs, system, ... }: {
      options.treefmt = mkOption {
        description = ''
          Project-level treefmt configuration
        '';
        type = types.submoduleWith {
          modules = ((import ./.).all-modules pkgs) ++ [{
            xxx = mkEnableOption "set treefmt as the nix formatter";
          }];
        };
      };
      config = {
        checks.treefmt = config.treefmt.build.check self;
        packages.treefmt = config.treefmt.build.wrapper;
      } // (lib.mkIf config.treefmt.xxx {
        # can be invoked with `nix fmt`
        formatter = config.treefmt.build.wrapper;
      });
    });
  };
}
