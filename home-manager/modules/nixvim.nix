{config, lib, pkgs, ... }: 
let 
  cfg = config.nixvim;
  mkRaw = lib.generators.mkLuaInline;
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
	opts = {
	  relativenumber = true;
	  number = true;
	  shiftwidth = 2;
	};
	keymaps = [
	  {
	    action = "<C-w>";
	    key = "<C-t>";
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
            key = "<leader>fb";
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
            action = mkRaw "require('telescope.builtin').lsp_definitions";
            key = "go";
          }
          {
            action = "<CMD>Lspsaga hover_doc<Enter>";
            key = "K";
          }
	];
	colorschemes.catppuccin.enable = true;
	plugins = { 
	  treesitter = {
	    enable = true;
	  };
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
                "gd" = "definition";
                "gD" = "declaration";
                "gt" = "type_definition";
                "gi" = "implementation";
                "gr" = "references";
                "g/" = "code_action";
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
		"<CR>" = "cmp.mapping.confirm({ select = true})";
# "<Tab>" = {
#   action = ''
#     function(fallback)
#       if cmp.visible() then
#         cmp.select_next_item()
#       elseif luasnip.expandable() then
#         luasnip.expand()
#       elseif luasnip.expand_or_jumpable() then
#         luasnip.expand_or_jump()
#       elseif check_backspace() then
#         fallback()
#       else
#         fallback()
#       end
#     end
#   '';
#   modes = [ "i" "s" ];
# };
	      };
	    };
	  };
	  oil.enable = true;
	  luasnip.enable = true;
	  lualine.enable = true;
	  ## neotree.enable = true;
	  telescope = {
	    enable = true;
	    extensions = {
	      fzf-native.enable = true;
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
  
