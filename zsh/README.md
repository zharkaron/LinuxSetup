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
  - `plugins.zsh`: Loads installed plugins.

- `plugins/`  
  Contains cloned plugin repositories managed by `zsh/bin/uplugins`.

- `plugins.txt`
  Lists plugin Git URLs for `zsh/bin/uplugins`.


## Plugin Flow

1. Add plugin repo URLs inside `plugins.txt`
2. Run `uplugins` to clone or update plugins into `plugins/`
3. `zshrc` loads configured plugins from `core/plugins.zsh`

The main installer runs `uplugins` automatically after linking the Zsh config and helper scripts.
