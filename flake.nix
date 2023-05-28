# This is a flake written to be explicitly my vim setup
# and as such doesn't bother making efforts to add options and all that shit
# I built it by reading https://github.com/gvolpe/neovim-flake/blob/main/flake.nix
# and then doing it with as little abstraction as possible, which means it's not as complete
# but I actually understand every line in here..
{
  description = "Rob's (neo) vim";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = github:numtide/flake-utils;

    color-schemes = {
      url = "github:flazz/vim-colorschemes";
      flake = false;
    };

    lsp-config = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };

    vim-airline = {
      url = "github:vim-airline/vim-airline";
      flake = false;
    };
    vim-rainbow = {
      url = "github:frazrepo/vim-rainbow";
      flake = false;
    };
    vim-maximizer = {
      url = "github:szw/vim-maximizer";
      flake = false;
    };
    lsp_extensions = {
      url = "github:nvim-lua/lsp_extensions.nvim";
      flake = false;
    };
    rust-tools = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };

    popup = {
      url = "github:nvim-lua/popup.nvim";
      flake = false;
    };

    plenary = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    telescope = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };

    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };

    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
      flake = false;
    };

    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-vsnip = {
      url = "github:hrsh7th/cmp-vsnip";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    vim-vsnip = {
      url = "github:hrsh7th/vim-vsnip";
      flake = false;
    };
    purescript-vim = {
      url = "github:raichoo/purescript-vim";
      flake = false;
    };


  };

  outputs = inputs @ { nixpkgs, neovim-nightly-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        neovimOverlay = f: p: {
          neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
        };

        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [ neovimOverlay pluginOverlay ];
        };

       inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;

       buildPlugin = name:
          buildVimPluginFrom2Nix {
            pname = name;
            version = "master";
            src = builtins.getAttr name inputs;
          };

       plugin-names = [
         "color-schemes"
         "vim-airline"
         "vim-rainbow"
         "vim-maximizer"
         "lsp-config"
         "lsp_extensions"
         "rust-tools"
         "popup"
         "plenary"
         "telescope"
         "nvim-dap"
         "nvim-dap-ui"
         "nvim-dap-virtual-text"
         "nvim-cmp"
         "cmp-nvim-lsp"
         "cmp-vsnip"
         "cmp-path"
         "cmp-buffer"
         "vim-vsnip"
         "purescript-vim"
       ];

       pluginOverlay = _: _:  {
          neovimPlugins = builtins.listToAttrs (map (name: { inherit name; value = buildPlugin name; }) plugin-names);
       };
      in
      rec {
        apps = rec {
          nvim = {
            type = "app";
            program = "${packages.default}/bin/nvim";
          };
          default = nvim;
        };

        overlays.default = f: p: {
          inherit (pkgs) neovim-nightly pluginOverlay;
        };

        nixosModules.hm = {
          imports = [
            { nixpkgs.overlays = [ overlays.default ]; }
          ];
        };

        packages = {
          default = pkgs.wrapNeovim pkgs.neovim-nightly {
            configure = {
              customRC = ''
                  ${builtins.readFile ./files/vimrc}
                  lua << EOF
                    ${builtins.readFile ./files/lsp.lua}
                  EOF
                '';
              packages.myplugins = {
                start = [
                  pkgs.vimPlugins.ack-vim
                  pkgs.vimPlugins.ctrlp
                  pkgs.vimPlugins.editorconfig-vim
                  pkgs.vimPlugins.nerdtree
                  pkgs.vimPlugins.vim-surround
                  pkgs.vimPlugins.tagbar
                  pkgs.vimPlugins.indentLine
                  pkgs.vimPlugins.typescript-vim
                  pkgs.vimPlugins.vim-markdown
                  pkgs.vimPlugins.vim-nix
                  pkgs.vimPlugins.vim-qml
                  pkgs.vimPlugins.vim-toml

                  pkgs.neovimPlugins.color-schemes
                  pkgs.neovimPlugins.lsp-config

                  pkgs.neovimPlugins.vim-airline
                  pkgs.neovimPlugins.vim-rainbow
                  pkgs.neovimPlugins.vim-maximizer
                  pkgs.neovimPlugins.lsp_extensions
                  pkgs.neovimPlugins.rust-tools
                  pkgs.neovimPlugins.popup
                  pkgs.neovimPlugins.plenary
                  pkgs.neovimPlugins.telescope
                  pkgs.neovimPlugins.nvim-dap
                  pkgs.neovimPlugins.nvim-dap-ui
                  pkgs.neovimPlugins.nvim-dap-virtual-text
                  pkgs.neovimPlugins.nvim-cmp
                  pkgs.neovimPlugins.cmp-nvim-lsp
                  pkgs.neovimPlugins.cmp-vsnip
                  pkgs.neovimPlugins.cmp-path
                  pkgs.neovimPlugins.cmp-buffer
                  pkgs.neovimPlugins.vim-vsnip
                  pkgs.neovimPlugins.purescript-vim
                ];
              };
            };
          };
        };
      }
    );
}
