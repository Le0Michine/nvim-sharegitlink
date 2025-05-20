# ShareGitLink

Lazy install, works with GitHub by default

```lua
return {
  "Le0Michine/nvim-sharegitlink",
  branch = "main",
}
```

## Remaps for grabbing git link

```lua
vim.keymap.set("n", "<leader>gc", function()
  require("sharegitlink").copy_gitfarm_link()
end, { noremap = true, silent = true })

vim.keymap.set("v", "<leader>gc", function()
  require("sharegitlink").copy_gitfarm_link()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>go", function()
  require("sharegitlink").open_gitfarm_link()
end, { noremap = true, silent = true })

vim.keymap.set("v", "<leader>go", function()
  require("sharegitlink").open_gitfarm_link()
end, { noremap = true, silent = true })
```

alternative remap configuration

```lua
return {
  "Le0Michine/nvim-sharegitlink",
  branch = "main",
  keys = {
    {
      "<leader>gc",
      function()
        require("sharegitlink").copy_gitfarm_link()
      end,
      mode = { "n", "v" },
      desc = "Copy Link",
    },
    {
      "<leader>go",
      function()
        require("sharegitlink").open_gitfarm_link()
      end,
      mode = { "n", "v" },
      desc = "Open Link",
    },
  },
}
```

## Additional configuration

Allows customizing link builder

```lua
return {
  "Le0Michine/nvim-sharegitlink",
  branch = "main",
  config = function()
    local sharegitlink = require("sharegitlink")
    sharegitlink.setup({
      link_builder = {
        ["my.secret.gitfarm.com"] = function(opts)
          local file_url = string.format(
            "https://my.secret.gitfarm.com/packages/%s/blobs/%s/--/%s",
            opts.repo,
            opts.commit,
            opts.rel_path
          )
          if opts.end_line ~= nil then
            if opts.start_line == opts.end_line then
              return file_url .. string.format("#L%d", opts.start_line)
            end
            return file_url .. string.format("#L%d-L%d", opts.start_line, opts.end_line)
          end
          return file_url
        end,
      }
    })
  end,
}
```
