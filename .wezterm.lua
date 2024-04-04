-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.automatically_reload_config = false

-- for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
-- 	if gpu.backend == "Vulkan" then
-- 		config.webgpu_preferred_adapter = gpu
-- 		config.front_end = "WebGpu"
-- 		break
-- 	end
-- end

config.default_domain = "WSL:Arch_Linux"

config.scrollback_lines = 10000
config.enable_scroll_bar = true

-- This is where you actually apply your config choices
-- config.font = wezterm.font_with_fallback({
-- 	{
-- 		family = "JetBrainsMono Nerd Font Mono",
-- 		harfbuzz_features = { "cv10", "cv12", "cv16" },
-- 	},
-- 	"JuliaMono",
-- })
-- config.font_size = 11.0
local firacode_features = { "cv02" }
config.font = wezterm.font_with_fallback({
	{
		family = "FiraCode Nerd Font Mono",
		weight = 450,
		harfbuzz_features = firacode_features,
	},
	{
		family = "JuliaMono",
		weight = 450,
	},
})
config.font_rules = {
	-- normal-intensity-and-italic
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font_with_fallback({
			{
				family = "FiraCode Nerd Font Mono",
				weight = 450,
				italic = true,
				harfbuzz_features = firacode_features,
			},
			{
				family = "JuliaMono",
				weight = 450,
				italic = true,
			},
		}),
	},

	-- half-intensity-and-italic
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font_with_fallback({
			{
				family = "FiraCode Nerd Font Mono",
				weight = 400,
				italic = true,
				harfbuzz_features = firacode_features,
			},
			{
				family = "JuliaMono",
				weight = 400,
				italic = true,
			},
		}),
	},
}
config.font_size = 12.0
config.bold_brightens_ansi_colors = "No"

config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- do not match email address as it is the same as SSH user@host
table.remove(config.hyperlink_rules)

-- the color scheme:
config.color_scheme = "Catppuccin Latte (Gogh)"

config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.check_for_updates = false

-- return the configuration to wezterm
return config
