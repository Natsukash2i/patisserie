{
  description = "Lyrids in NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem-impure = {
      url = "github:Rexcrazy804/hjem-impure";
    };

    umbriel.url = "github:noctalia-dev/umbriel/cachix";

  };

  outputs =
    {
      self,
      nixpkgs,
      hjem,
      hjem-impure,
      ...
    }@inputs:
    {
      nixosConfigurations.patisserie = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/lyrids
          hjem.nixosModules.default
        ];
      };
    };
}
