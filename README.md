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
      link_builder = function(opts)
        local url = string.format(
          "https://my.secret.gitfarm.com/packages/%s/blobs/%s/--/%s#L%d-L%d",
          opts.repo,
          opts.commit,
          opts.rel_path,
          opts.start_line,
          opts.end_line
        )
        return url
      end,
    })
  end,
}
```
