{config, lib, pkgs, ... }: 
let 
  cfg = config.nixvim;
  mkRaw = lib.generators.mkLuaInline;
  telescope_picker_config = {
    symbol_width = 94;
    symbol_type_width = 10;
    layout_config = {
      width = 0.95;
      preview_width = 0.5;
    };
  };
in
{
  options.nixvim = {
    enable = lib.mkEnableOption "Setup nixvim";
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      config = {
        enable = true;
        globals.mapleader = " ";
        extraConfigLua = ''
        '';
        opts = {
          relativenumber = true;
          number = true;
          shiftwidth = 2;
          list = true;
          listchars = "tab:»\\ ,trail:·,nbsp:␣";
          clipboard = "unnamedplus";
          expandtab = true;
          tabstop = 2;
          softtabstop = 2;
          cursorline = true;
          scrolloff = 16;
          signcolumn = "yes";
        };
        keymaps = [
          {
            action = "<C-w>";
            key = "<C-j>";
          }
          {
            action = "<cmd>Neotree filesystem reveal toggle<CR>";
            key = "\\";
          }
          {
            action = "<cmd>Telescope live_grep<CR>";
            key = "<leader>fg";
          }
          {
            action = "<cmd>Telescope find_files<CR>";
            key = "<leader>ff";
          }
          {
            action = "<cmd>Telescope buffers<CR>";
            key = "<leader> ";
          }
          {
            action = "<cmd>Telescope help_tags<CR>";
            key = "<leader>hh";
          }
          {
            action = "<cmd>Telescope oldfiles<CR>";
            key = "<leader>fr";
          }
          {
            action = "<cmd>Telescope marks<CR>";
            key = "<leader>M";
          }
          {
            action = "<cmd>Telescope registers<CR>";
            key = "<leader>R";
          }
          {
            action = mkRaw "require('telescope.builtin').lsp_definitions";
            key = "gd";
          }
          {
            action = mkRaw "require('telescope.builtin').lsp_references";
            key = "gr";
          }
          {
            action = mkRaw "require('telescope.builtin').lsp_implementations";
            key = "gi";
          }
          {
            action = mkRaw "require('telescope.builtin').lsp_type_definitions";
            key = "gt";
          }
          {
            action = mkRaw "require('actions-preview').code_actions";
            key = "g/";
          }
          {
            key = "<leader>fw";
            action = mkRaw ''
              function()
                require('telescope.builtin').grep_string({ word_match = "-w" })
              end
            '';
          }
          {
            action = "<CMD>LspStop<Enter>";
            key = "<leader>lx";
          }
          {
            action = "<CMD>LspStart<Enter>";
            key = "<leader>ls";
          }
          {
            action = "<CMD>LspRestart<Enter>";
            key = "<leader>lr";
          }
          {
            action = mkRaw "require('telescope.builtin').lsp_document_symbols";
            key = "go";
          }
          {
            action = mkRaw "require('telescope.builtin').lsp_dynamic_workspace_symbols";
            key = "gO";
          }
          {
            action = "<CMD>Lspsaga hover_doc<Enter>";
            key = "K";
          }
          {
            key = "<leader>s";
            action = mkRaw ''
              function()
                require('telescope.builtin').current_buffer_fuzzy_find(
                  require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                  }
                )
              end
            '';
          }
        ];
        colorschemes.catppuccin = {
          enable = true;
          settings = {
            custom_highlights = {
              DiagnosticUnderlineError = {
                fg = "#FF0000";
                sp = "#FF0000";
                undercurl = true;
                underline = false;
                bold = true;
              };
              DiagnosticUnderlineWarn = {
                fg = "#FFA500";
                sp = "#FFA500";
                undercurl = true;
                underline = false;
                bold = true;
              };
              DiagnosticUnderlineInfo = {
                sp = "#89b4fa";
                undercurl = true;
                underline = false;
              };
              DiagnosticUnderlineHint = {
                sp = "#94e2d5";
                undercurl = true;
                underline = false;
              };
              CursorLine = { bg = "#313244"; };
              CursorLineNr = { fg = "#fab387"; bold = true; };
            };
          };
        };
        plugins = {
          actions-preview.enable = true;
          treesitter.enable = true;
          lsp = {
            enable = true;
            servers = {
              lua_ls.enable = true;
              gopls.enable = true;
              rust_analyzer = {
                enable = true;
                installCargo = false;
                installRustc = false;
              };
              protols.enable = true;
              nixd.enable = true;
            };
            keymaps = {
              silent = true;
              diagnostic = {
                "<leader>j" = "goto_next";
                "<leader>k" = "goto_prev";
              };
              lspBuf = {
                "K" = "hover";
                "gD" = "declaration";
                "gn" = "rename";
              };
            };
          };
          cmp = {
            enable = true;
            autoEnableSources = true;

            settings = {
              sources = [
                {
                  name = "nvim_lsp";
                  priority = 1000;
                }
                {
                  name = "path";
                  priority = 300;
                }
                {
                  name = "nvim_lsp_signature_help";
                  priority = 1000;
                }
                {
                  name = "buffer";
                  priority = 500;
                }
                {
                  name = "copilot";
                  priority = 400;
                }
              ];
              mapping = {
                "<C-n>" = "cmp.mapping.select_next_item()";
                "<C-p>" = "cmp.mapping.select_prev_item()";
                "<C-y>" = "cmp.mapping.confirm({ select = true})";
                "<C-e>" = "cmp.mapping.abort()";
              };
            };
          };
          oil.enable = true;
          luasnip.enable = true;
          lualine.enable = true;
          neo-tree.enable = true;
          web-devicons.enable = true;
          marks.enable = true;
          telescope = {
            enable = true;
            extensions = {
              fzf-native.enable = true;
            };
            settings = {
              pickers = {
                lsp_document_symbols = telescope_picker_config;
                lsp_dynamic_workspace_symbols = telescope_picker_config;
                find_files = {
                  follow = true;
                  hidden = true;
                };
                live_grep = {
                  follow = true;
                  additional_args = [ "--hidden" ];
                };
                registers = {
                  theme = "dropdown";
                  previewer = true;
                  layout_config = {
                    width = 0.8;
                    height = 0.8;
                  };
                };
              };
            };
          };
          fidget = {
            enable = true;
            settings = {
              notification = {
                window = {
                  winblend = 50;
                };
              };
            };
          };
          mini = {
            enable = true;
            modules.icons = { };
            mockDevIcons = true;
          };
        };
        autoCmd = [
          {
            event = [ "TextYankPost" ];
            command = "lua vim.highlight.on_yank()";
            pattern = "*"; 
          }
        ];
      };
    };  
  };
}

