# NeoMutt

Configuration for [NeoMutt](https://neomutt.org), the email client.

## Files

| Path | Purpose |
|------|---------|
| `muttrc` | Main config — sources accounts and local overrides |
| `mailcap` | MIME type handlers for attachments |
| `accounts/` | Per-account configs (gitignored, **you must create these**) |
| `muttrc.local` | Local overrides (gitignored, **you must create this**) |

## Quick Start

1. Create `~/.config/neomutt/accounts/` and add one `.muttrc` per mail account.
2. (Optional) Create `~/.config/neomutt/muttrc.local` for local overrides.

### Account file template (`accounts/gmail.muttrc`):

```muttrc
set realname       = "Your Name"
set from           = "user@gmail.com"
set sendmail       = "/usr/bin/msmtp"
set sendmail_wait  = 0
set postpone       = "+Drafts"
set record         = "+Sent"
set trash          = "+Trash"

# IMAP (folder, not account hook for credentials — use .muttrc.local or tool config)
set folder         = "imaps://user@gmail.com@imap.gmail.com:993"
set spoolfile      = "+INBOX"
set postponed      = "+[Gmail]/Drafts"

account-hook "imaps://user@gmail.com@" {
    set folder     = "imaps://user@gmail.com@imap.gmail.com:993"
    set postponed  = "+[Gmail]/Drafts"
}

# Notmuch virtual mailboxes — adjust to match your maildir layout
virtual-mailboxes "Inbox" "notmuch://?query=tag:inbox and not tag:trash"
virtual-mailboxes "Unread" "notmuch://?query=tag:unread and not tag:trash"
virtual-mailboxes "Flagged" "notmuch://?query=tag:flagged and not tag:trash"
virtual-mailboxes "All Mail" "notmuch://?query=tag:newer than 1y and not tag:trash"
```

### Local overrides (`muttrc.local`)

Put anything you don't want committed (e.g. passwords, local paths):

```muttrc
set imap_pass = "app-password-here"
```

## Required External Tools

| Tool | Purpose | Optional? |
|------|---------|-----------|
| `neomutt` | MUA | **Required** |
| `mbsync`/`isync` | Mail sync (IMAP → Maildir) | Yes |
| `msmtp` | Mail send (SMTP) | Yes |
| `notmuch` | Full-text email search | Yes |
| `gpg` | Encryption / signing | Yes |
| `pass` | Password store for credentials | Yes |

### See also

- [offlineimap](http://www.offlineimap.org/) or [mbsync](https://isync.sourceforge.io/) for IMAP sync
- [msmtp](https://marlam.de/msmtp/) for SMTP
- [notmuch](https://notmuchmail.org/) for mail searching
- [password-store](https://www.passwordstore.org/) for credential management
