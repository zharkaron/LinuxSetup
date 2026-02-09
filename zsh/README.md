# My ZSH Configuration

This is my personal ZSH configuration, structured for portability across any Linux distribution.

## Zsh Default
This configuration requires Zsh.
To switch your system to use Zsh as the default shell, run:

```
chsh -s $(which zsh)
```

Then log out and back in.

You can confirm the change with:

```
echo $SHELL
```

If it prints something like /usr/bin/zsh, you’re good to go.

## Structure

- `zshrc`  
  Loads core files and plugins automatically.

- `core/`  
  - `prompt.zsh`: Custom Fish-like prompt  
  - `aliases.zsh`: Shell aliases
  - `plugins.zsh`: List plugin repositories you want to install.

- `plugins/`  
  Drop .zsh plugin files here. They are automatically sourced.


## Plugin Flow

1. Add plugin repo URLs inside `plugins.zsh`
2. Run a script (to be created) that clones/updates plugins into `plugins/`
3. `zshrc` auto-loads everything in `plugins/`
