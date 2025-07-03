# ────── 🎨 Color Helpers ──────
function color_reset; set_color normal; end
function color_bold_white; set_color white --bold; end
function color_cyan; set_color cyan; end
function color_purple; set_color magenta --bold; end
function color_gray; set_color brblack; end
function color_green; set_color green; end
function color_red; set_color red; end
function color_white; set_color white; end
function color_bold_white; set_color white --bold; end

# ────── 🔧 Prompt Segments ──────

function prompt_os
    switch (uname)
        case Linux
            if grep -qi microsoft /proc/version /dev/null
                echo -n (color_white) ""# WSL icon
            else
                echo -n (color_bold_white) "" # Linux icon (white)
            end
        case Darwin
            echo -n (color_bold_white) "" # Apple icon
        case '*CYGWIN*' '*MINGW*' '*MSYS*'
            echo -n (color_white) "" # Windows icon
    end
end

function prompt_symbol_directory
    set pwd (pwd)
    if test $pwd = $HOME
        echo -n " "  # House icon for exactly home directory
    else if string match -q "$HOME/*" $pwd
        echo -n " "  # House icon for subdirectories inside home
    else if string match -q "/etc*" $pwd
        echo -n "⚙️"  # Gear icon
    else
        echo -n "🔒"  # Lock icon
    end
end

function prompt_path
    set pwd (pwd)
    if test $pwd = $HOME
        echo -n "~"
    else if string match -q "$HOME/*" $pwd
        set rel_path (string sub -s (math (string length $HOME) + 2) -- $pwd)
        echo -n "~/$rel_path"
    else
        echo -n "$pwd"
    end
end

function prompt_time
    echo -n " " (date "+%T")
end

function prompt_git
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        return
    end

    set branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$branch"
        set branch "(detached)"
    end

    set added 0
    set modified 0
    set deleted 0
    set conflicted 0

    # Read git status lines properly, split by newline
    set git_status (git status --porcelain=2 --branch | string split "\n")

    for line in $git_status
        # Skip branch info lines
        if string match -q "# branch.ab*" $line
            continue
        end

        # Extract the first two status chars from the line (position 3 and 4)
        # Example line: "1 A. N... ..."
        set first_char (string sub -s 3 -l 1 -- $line)
        set second_char (string sub -s 4 -l 1 -- $line)

        # Conflicts
        if test "$first_char" = "U" -o "$second_char" = "U"
            set conflicted (math $conflicted + 1)
            continue
        end

        # Staged changes
        if test "$first_char" = "A" -o "$first_char" = "M" -o "$first_char" = "R" -o "$first_char" = "C"
            set added (math $added + 1)
        else
            if test "$first_char" = "D"
                set deleted (math $deleted + 1)
            end
        end

        # Unstaged changes
        if test "$second_char" = "M" -o "$second_char" = "T"
            set modified (math $modified + 1)
        else
            if test "$second_char" = "D"
                set deleted (math $deleted + 1)
            end
        end
    end

    # Output the git status symbols in the prompt as before
    echo -n (set_color green --bold)"$branch "

    if test $added -gt 0
        echo -n (set_color yellow)"+$added"
    end

    if test $modified -gt 0
        echo -n (set_color yellow)"~$modified"
    end

    if test $deleted -gt 0
        echo -n (set_color yellow)"-$deleted"
    end

    if test $conflicted -gt 0
        echo -n (set_color yellow)"✗$conflicted"
    end
end

function prompt_vpn
    if ip link show tun0 >/dev/null 2>&1
        echo -n (color_green) "🔒 VPN"
    else if ip link show wg0 >/dev/null 2>&1
        echo -n (color_green) "🔒 VPN"
    else
        echo -n (color_red) "🔒 No VPN"
    end
end

# ────── 🐟 Fish Prompt ──────
function fish_prompt
    set os_part (prompt_os)
    set symbol_part (prompt_symbol_directory)
    set path_part (prompt_path)
    set git_part (prompt_git)
    set vpn_part (prompt_vpn)
    set time_part (prompt_time)

    echo -n (color_purple) "╭─ " $os_part "" (color_cyan)$symbol_part "" (color_cyan)$path_part "" $git_part "" $vpn_part(color_gray) $time_part(color_reset)
    echo
    echo -n (color_purple) "╰─❯ " (color_reset)
end
