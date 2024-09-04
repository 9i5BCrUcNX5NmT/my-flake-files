{
  description = "A devShell example";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default = with pkgs; mkShell {
        
          buildInputs = [
            openssl
            pkg-config
            eza
            fd
            # rust-bin.stable.latest.default
            (
              rust-bin.stable.latest.default.override {
                                    extensions = [ "rust-src" "rust-analyzer" ];
                                    targets = [ "wasm32-unknown-unknown" ];
                                  }
            )
			rustup
            vscodium
            vscode-extensions.rust-lang.rust-analyzer

            wasm-pack
            llvmPackages.bintools
          ];
          
		  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
		  CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "lld";
		  
          shellHook = ''
            alias ls=eza
            alias find=fd
          '';
        };
      }
    );
}
