{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.nixos-flake.flakeModule ];

      flake =
        let
          myUserName = "shivaraj";
        in
        {
          # Configurations for Linux (NixOS) machines
          nixosConfigurations.shivaraj-MacBookPro = self.nixos-flake.lib.mkLinuxSystem {
            imports = [
              # Your machine's configuration.nix goes here
	      ./configuration.nix
              #({ pkgs, ... }: {
              #  # TODO: Put your /etc/nixos/hardware-configuration.nix here
              #  boot.loader.grub.device = "nodev";
              #  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "btrfs"; };
              #  users.users.${myUserName}.isNormalUser = true;
              #})
              # Setup home-manager in NixOS config
              self.nixosModules.home-manager
              {
                home-manager.users.${myUserName} = {
                  imports = [ self.homeModules.default ];
                  home.stateVersion = "22.11";
                };
              }
            ];
          };
	  # TODO: separate module for home-manager conf
          # home-manager configuration goes here.
          homeModules.default = { pkgs, lib, ... }: {
            imports = [ ];
	    home.packages = with pkgs;
	    [
	      grc
	    ];
            programs.git.enable = true;
            programs.starship.enable = true;
	    programs.alacritty = {
	      enable = true;
	      settings.shell.program ="${lib.getExe pkgs.fish}";
	    };
	    programs.fzf.enable = true;
	    programs.lazygit.enable = true;
	    programs.fish = {
	      enable = true;
	      interactiveShellInit = ''
	        set fish_greeting # Disable greeting
	      '';
	      plugins = [
	        { name = "grc"; src = pkgs.fishPlugins.grc.src; }
	        {
	        name = "z";
	        src = pkgs.fetchFromGitHub {
	          owner = "jethrokuan";
	          repo = "z";
	          rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
	          sha256 = "+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
	        };
		}
		{ name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
		{ name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
	     ];
          };
        };
    };
  };
}
