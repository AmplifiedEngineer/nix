# SPDX-FileCopyrightText: 2026 Igor Santos
# SPDX-License-Identifier: Apache-2.0
#
# The playbook binary from the GitHub release, checked against a fixed hash.
#
#   nix run github:pragmatic-engineer/nix#playbook -- --version
#   nix run github:pragmatic-engineer/nix#pbtop
#   nix profile install github:pragmatic-engineer/nix#playbook
#
# The release workflow of pragmatic-engineer/playbook rewrites the releases
# block below after each release (scripts/render-flake.sh in that repository)
# and opens a pull request here for it. Nothing else in this file is touched
# by it.
{
  description = "playbook: an engineering playbook for Claude Code";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      # The version and the SRI hash of the release binary of each system.
      releases = {
        version = "0.40.1";
        x86_64-linux = "sha256-r05Iz4saRcy71igNajr4e1fOfAIANkpTsmG6sy0WfEw=";
        aarch64-linux = "sha256-eyU+lAZ7l/DI9aH6ICuXmQWwfdfKH7Qtkw9hRIxySEQ=";
        x86_64-darwin = "sha256-JxPlVxAR2SVj8kgBprGYHiNKbLWRNu8+HAKB3orxsQc=";
        aarch64-darwin = "sha256-UMhIvlBWB2uT9Ep2420Nf06XJ824rl9SnQ25GPg38sM=";
      };

      # The release target of each Nix system. Linux is static musl.
      targets = {
        x86_64-linux = "x86_64-unknown-linux-musl";
        aarch64-linux = "aarch64-unknown-linux-musl";
        x86_64-darwin = "x86_64-apple-darwin";
        aarch64-darwin = "aarch64-apple-darwin";
      };

      systems = builtins.attrNames targets;
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});

      # One binary, two names: playbook starts the usage dashboard when it is
      # run as pbtop, so the pbtop package installs the same file under that
      # name and needs no hash of its own.
      package = name: system: pkgs:
        pkgs.stdenvNoCC.mkDerivation {
          pname = name;
          inherit (releases) version;

          src = pkgs.fetchurl {
            url = "https://github.com/pragmatic-engineer/playbook/releases/download/v${releases.version}/playbook-${releases.version}-${targets.${system}}";
            hash = releases.${system};
          };

          # A prebuilt binary: nothing to unpack or build. Stripping or
          # patching would change the Linux binary (static musl, nothing to
          # patch) and could void the ad-hoc signature of the macOS one.
          dontUnpack = true;
          dontBuild = true;
          dontStrip = true;
          dontFixup = true;

          installPhase = ''
            runHook preInstall
            install -Dm755 "$src" "$out/bin/${name}"
            runHook postInstall
          '';

          meta = {
            description = if name == "pbtop"
              then "Token and cost dashboard for Claude Code"
              else "An engineering playbook for Claude Code";
            homepage = "https://github.com/pragmatic-engineer/playbook";
            license = nixpkgs.lib.licenses.asl20;
            mainProgram = name;
            platforms = systems;
            sourceProvenance = [ nixpkgs.lib.sourceTypes.binaryNativeCode ];
          };
        };
    in
    {
      packages = forAllSystems (system: pkgs: rec {
        playbook = package "playbook" system pkgs;
        pbtop = package "pbtop" system pkgs;
        default = playbook;
      });

      apps = forAllSystems (system: pkgs: rec {
        playbook = {
          type = "app";
          program = "${self.packages.${system}.playbook}/bin/playbook";
        };
        pbtop = {
          type = "app";
          program = "${self.packages.${system}.pbtop}/bin/pbtop";
        };
        default = playbook;
      });
    };
}
