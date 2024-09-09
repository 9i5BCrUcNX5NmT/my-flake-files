{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs,  rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        libraries = with pkgs;[
          webkitgtk
          gtk3
          cairo
          gdk-pixbuf
          glib
          dbus
          openssl_3
          librsvg
        ];

        packages = with pkgs; [
          curl
          wget
          pkg-config
          dbus
          openssl_3
          glib
          gtk3
          libsoup
          webkitgtk
          librsvg
          
		  # Для Rust
          pkg-config
          eza
          fd
          (
            rust-bin.stable.latest.default.override {
	             extensions = [ "rust-src" "rust-analyzer" ];
	             targets = [ "wasm32-unknown-unknown" ];
	           }
          )
          rustup

          # Редактор кода
          vscodium
          vscode-extensions.rust-lang.rust-analyzer

          # Для wasm
          wasm-pack
          llvmPackages.bintools

          # Для npm
          nodejs_22
        ];
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = packages;

          RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
 		  CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "lld";

          shellHook =
            ''
              export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
              export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS
			  alias ls=eza
              alias find=fd
            '';
        };
      });
}