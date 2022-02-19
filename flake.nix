{
  description = "aws-s3-webdav";
  nixConfig = {
    bash-prompt = "\\[\\033[1m\\][dev-webdav]\\[\\033\[m\\]\\040\\w$\\040";
  };
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs {
            inherit system;
            config = {
              permittedInsecurePackages = [
                "openssl-1.0.2u"
              ];
            };
          };
      in
        rec {
          packages = flake-utils.lib.flattenTree {
            webdav = with pkgs; rustPlatform.buildRustPackage rec {
              DEP_OPENSSL_VERSION = 102;
              pname = "wevdav";
              version = "0.1";
              src = ./.;
              cargoLock = {
                lockFile = ./Cargo.lock;
              };
              nativeBuildInputs = [
                pkg-config
              ];
              buildInputs = [
                openssl_1_0_2
              ];
            };
          };
          defaultPackage = packages.webdav;
          devShell = pkgs.mkShell {
            packages = with pkgs; [ rustc cargo pkg-config openssl_1_0_2 ];
            shellHook = ''
              export DEP_OPENSSL_VERSION=102
            '';
            inputsFrom = builtins.attrValues self.packages.${system};
          };
        }
    );
}
