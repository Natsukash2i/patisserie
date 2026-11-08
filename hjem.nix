{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  myUserName = "lyrids";
  dots = config.hjem.users.${myUserName}.impure.dotsDir;
in
{
  hjem.clobberByDefault = true;
  hjem.extraModules = [ inputs.hjem-impure.hjemModules.default ];

  hjem.users.${myUserName} = {
    enable = true;
    directory = "/home/${myUserName}";

    impure = {
      enable = true;
      dotsDir = "${./dots}";
      dotsDirImpure = "/home/lyrids/.local/patisserie/dots";
    };
    xdg.config.files = {
      "nvim".source = dots + "/nvim";
      "fuzzel".source = dots + "/fuzzel";
      "quickshell".source = dots + "/quickshell";
      "yazi".source = dots + "/yazi";
      "fish/config.fish".source = dots + "/fish/config.fish";
      "foot".source = dots + "/foot";
      "cliphist/config".source = dots + "/cliphist/config";
      "umbriel".source = dots + "/umbriel";
      "niri".source = dots + "/niri";
      "ghostty".source = dots + "/ghostty";
      
    };
  };
}
