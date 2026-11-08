{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../hjem.nix
    inputs.umbriel.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    configurationLimit = 5;
  };
  hardware.cpu.intel.updateMicrocode = true;

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  networking.hostName = "patisserie";
  networking.networkmanager.enable = true;

  networking.firewall = {
    trustedInterfaces = [ "waydroid0" ];
  };
  networking.firewall.allowedTCPPorts = [
    8008
    8009
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 32768;
      to = 61000;
    }
  ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
  };

  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-bamboo
      fcitx5-gtk
    ];
  };
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.brlaser
    pkgs.brgenml1lpr
    pkgs.brgenml1cupswrapper
  ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.gnome.gnome-keyring.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;

  services.thermald.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.pam.services.quickshell = { };
  security.pam.services.quickshell.text = ''
    auth include login
  '';
  security.pam.services.login.enableGnomeKeyring = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.flatpak.enable = true;
  services.upower.enable = true;
  security.polkit.enable = true;
  services.tumbler.enable = true;
  services.gvfs.enable = true;

  services.cloudflare-warp.enable = true;

  users.users.lyrids = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "sudo"
      "networkmanager"
      "video"
      "audio"
      "docker"
    ];
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
    };
  };

  qt.enable = true;
  programs.starship.enable = true;
  programs.nix-ld.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.dconf.enable = true;
  programs.git.enable = true;
  programs.gpu-screen-recorder = {
    # package = inputs.gsr-ui-nix.packages.${pkgs.stdenv.hostPlatform.system}.gpu-screen-recorder;
    enable = true;
    ui.enable = true;
  };
  programs.chromium = {
    enable = true;
  };
  programs.foot.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;

  programs.nh = {
    enable = true;
    flake = "/home/lyrids/.local/patisserie"; # path to your flake
  };

  programs.umbriel.enable = true;
  programs.umbriel.portalPackage = pkgs.xdg-desktop-portal-umbriel;
  programs.umbriel.package = pkgs.umbriel;
  programs.xwayland.enable = true;

  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    ### MISC ###
    feh
    mpv
    imagemagick
    htop
    vim
    wget
    curl
    pciutils
    usbutils
    wlr-randr
    ripgrep
    aria2
    fzf
    fd
    jq
    killall
    playerctl
    gnumake
    file-roller
    unzip
    udiskie
    udisks
    lsd
    bluez
    brightnessctl
    clang
    clang-tools
    egl-wayland
    wl-clipboard
    xdg-user-dirs
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    wl-clip-persist
    cliphist
    polkit_gnome
    seahorse
    nixfmt
    bibata-cursors
    qt6.qtimageformats
    qt6.qtmultimedia
    qt6.qtsvg
    qt6.qt5compat
    qt6.qttools
    qt6.qtdeclarative
    papirus-icon-theme
    xwayland-satellite
    xwayland
    gcc
    wayfreeze
    grim
    slurp
    satty
    swayimg
    yt-dlp
    cloudflare-warp
    wlsunset
    ps_mem
    kdePackages.qtdeclarative
    ffmpeg
    zenity
    nix-search-tv
    librsvg
    adwaita-icon-theme
    nodejs
    wget
    docker
    sqlcmd
    sqls
    cachix
    wineWow64Packages.stable
    winetricks
    rustc
    rust-analyzer
    cargo
    rustfmt
    clippy

    ### APPS ###
    pavucontrol
    nwg-look
    fuzzel
    yazi
    thunar
    thunar-volman
    obsidian
    librewolf
    nmgui
    google-chrome
    vesktop
    (pkgs.zathura.override {
      plugins = [ pkgs.zathuraPkgs.zathura_pdf_poppler ];
    })
    anki
    spotify
    ghostty

    (pkgs.symlinkJoin {
      name = "quickshell-wrapped";
      paths = [ pkgs.quickshell ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/quickshell \
          --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtmultimedia}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
          --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
          --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtsvg}/${pkgs.qt6.qtbase.qtQmlPrefix}"
        rm -f $out/bin/qs
        ln -s quickshell $out/bin/qs
      '';
    })

  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    geist-font
    nerd-fonts.jetbrains-mono
    plemoljp
    plemoljp-hs
    plemoljp-nf
    maple-mono.NF
    corefonts
  ];
  fonts = {
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings = {
    substituters = [
      "https://quickshell.cachix.org"
      "https://umbriel.cachix.org"
    ];
    trusted-public-keys = [
      "quickshell.cachix.org-1:vBm3s5tZThc5KDLj6zhHVCMp8wX/AZJwle9wqdi81ts="
    ];
    extra-substituters = [ "https://umbriel.cachix.org" ];
    extra-trusted-public-keys = [
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "corefonts"
    ];

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
  virtualisation.docker.enable = true;

  xdg.portal.enable = true;
  xdg.portal.config.common.default = [
    "wlr"
    "gtk"
  ];
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal
    pkgs.xdg-desktop-portal-hyprland
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";

    LIBVA_DRIVER_NAME = "iHD";
    QT_QPA_PLATFORMTHEME = "gtk3";

    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QML2_IMPORT_PATH = lib.concatStringsSep ":" [
      "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtmultimedia}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}"
      "${pkgs.qt6.qtsvg}/${pkgs.qt6.qtbase.qtQmlPrefix}"
    ];
  };

  system.stateVersion = "26.05"; # Dont change it
}

# Credit: 0lswitcher
