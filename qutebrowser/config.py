config.load_autoconfig()

c.auto_save.session = True
c.backend = 'webengine'
c.downloads.location.directory = '~/Downloads'
c.downloads.location.prompt = False
c.downloads.position = 'bottom'
c.fonts.default_size = '12pt'
c.fonts.tabs.selected = 'default_size 600'
c.hints.border = '1px solid #ff6b6b'
c.hints.chars = 'jklsdfnmbv'
c.hints.mode = 'number'
c.hints.radius = 4
c.input.insert_mode.auto_load = True

c.input.partial_timeout = 5000
c.input.spatial_navigation = False
c.qt.force_software_rendering = 'software-opengl'
c.scrolling.bar = 'always'
c.scrolling.smooth = True
c.spellcheck.languages = ['en-US']
c.statusbar.padding = {'bottom': 2, 'left': 6, 'right': 6, 'top': 2}
c.statusbar.position = 'bottom'
c.statusbar.show = 'in-mode'
c.tabs.favicons.scale = 1
c.tabs.max_width = 250
c.tabs.min_width = 100
c.tabs.mode_on_change = 'restore'
c.tabs.mousewheel_switching = False
c.tabs.position = 'top'
c.tabs.select_on_remove = 'last-used'
c.tabs.show = 'always'
c.tabs.title.format = '{audio}{index}'
c.tabs.title.format_pinned = '{audio}{index}'
c.url.default_page = 'https://search.brave.com'
c.url.open_base_url = True
c.url.searchengines = {
    'DEFAULT': 'https://search.brave.com/search?q={}',
    'git': 'https://github.com/search?q={}',
    'gpt': 'https://chatgpt.com/{}',
    'jag': 'https://jagwire.tamusa.edu/{}',
}
c.url.start_pages = ['https://search.brave.com']
c.window.title_format = '{private}'
c.window.transparent = False

c.colors.completion.category.bg = '#2b2b2b'
c.colors.completion.category.border.bottom = '#555555'
c.colors.completion.category.border.top = '#555555'
c.colors.completion.category.fg = '#98c379'
c.colors.completion.even.bg = '#323232'
c.colors.completion.fg = '#d4d4d4'
c.colors.completion.item.selected.bg = '#3c3c3c'
c.colors.completion.item.selected.border.bottom = '#555555'
c.colors.completion.item.selected.border.top = '#555555'
c.colors.completion.item.selected.fg = '#e5c07b'
c.colors.completion.item.selected.match.fg = '#e5c07b'
c.colors.completion.match.fg = '#e5c07b'
c.colors.completion.odd.bg = '#2b2b2b'
c.colors.completion.scrollbar.bg = '#2b2b2b'
c.colors.completion.scrollbar.fg = '#555555'
c.colors.contextmenu.disabled.bg = '#2b2b2b'
c.colors.contextmenu.disabled.fg = '#808080'
c.colors.contextmenu.menu.bg = '#2b2b2b'
c.colors.contextmenu.menu.fg = '#d4d4d4'
c.colors.contextmenu.selected.bg = '#3c3c3c'
c.colors.contextmenu.selected.fg = '#e5c07b'
c.colors.downloads.bar.bg = '#2b2b2b'
c.colors.downloads.error.bg = '#cc3333'
c.colors.downloads.error.fg = '#ffffff'
c.colors.downloads.start.bg = '#3c3c3c'
c.colors.downloads.stop.bg = '#98c379'
c.colors.downloads.system.fg = 'none'
c.colors.hints.fg = '#e5c07b'
c.colors.hints.match.fg = '#61afef'
c.colors.keyhint.fg = '#d4d4d4'
c.colors.keyhint.suffix.fg = '#98c379'
c.colors.messages.error.bg = '#cc3333'
c.colors.messages.error.fg = '#ffffff'
c.colors.messages.info.bg = '#2b2b2b'
c.colors.messages.info.fg = '#61afef'
c.colors.messages.warning.bg = '#cc8800'
c.colors.messages.warning.fg = '#2b2b2b'
c.colors.prompts.bg = '#2b2b2b'
c.colors.prompts.border = '1px solid #555555'
c.colors.prompts.fg = '#d4d4d4'
c.colors.prompts.selected.bg = '#3c3c3c'
c.colors.statusbar.caret.bg = '#2b2b2b'
c.colors.statusbar.caret.fg = '#e5c07b'
c.colors.statusbar.command.bg = '#2b2b2b'
c.colors.statusbar.command.fg = '#d4d4d4'
c.colors.statusbar.command.private.bg = '#2b2b2b'
c.colors.statusbar.command.private.fg = '#d4d4d4'
c.colors.statusbar.insert.bg = '#2b2b2b'
c.colors.statusbar.insert.fg = '#98c379'
c.colors.statusbar.normal.bg = '#2b2b2b'
c.colors.statusbar.normal.fg = '#d4d4d4'
c.colors.statusbar.passthrough.bg = '#2b2b2b'
c.colors.statusbar.passthrough.fg = '#61afef'
c.colors.statusbar.private.bg = '#2b2b2b'
c.colors.statusbar.private.fg = '#d4d4d4'
c.colors.statusbar.progress.bg = '#98c379'
c.colors.statusbar.url.error.fg = '#cc3333'
c.colors.statusbar.url.fg = '#d4d4d4'
c.colors.statusbar.url.hover.fg = '#61afef'
c.colors.statusbar.url.success.https.fg = '#98c379'
c.colors.statusbar.url.warn.fg = '#cc8800'
c.colors.tabs.bar.bg = '#1e1e1e'
c.colors.tabs.even.bg = '#2b2b2b'
c.colors.tabs.even.fg = '#cccccc'
c.colors.tabs.indicator.error = '#cc3333'
c.colors.tabs.indicator.start = '#3c3c3c'
c.colors.tabs.indicator.stop = '#98c379'
c.colors.tabs.odd.bg = '#252526'
c.colors.tabs.odd.fg = '#cccccc'
c.colors.tabs.pinned.even.bg = '#2b2b2b'
c.colors.tabs.pinned.even.fg = '#98c379'
c.colors.tabs.pinned.odd.bg = '#252526'
c.colors.tabs.pinned.odd.fg = '#98c379'
c.colors.tabs.selected.even.bg = '#3c3c3c'
c.colors.tabs.selected.even.fg = '#ffffff'
c.colors.tabs.selected.odd.bg = '#3c3c3c'
c.colors.tabs.selected.odd.fg = '#ffffff'
c.colors.webpage.bg = '#1e1e1e'
c.colors.webpage.preferred_color_scheme = 'dark'

c.content.blocking.adblock.lists = [
    'https://easylist.to/easylist/easylist.txt',
    'https://easylist.to/easylist/easyprivacy.txt',
    'https://secure.fanboy.co.nz/fanboy-annoyance.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt',
    'https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt',
]
c.content.blocking.enabled = True
c.content.blocking.hosts.lists = [
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts',
    'https://someonewhocares.org/hosts/zero/hosts',
]
c.content.blocking.method = 'auto'
c.content.cache.size = 51200
c.content.cookies.accept = 'all'
c.content.cookies.store = True
c.content.headers.accept_language = 'en-US,en;q=0.9'
c.content.headers.do_not_track = True
c.content.javascript.enabled = True
c.content.javascript.clipboard = 'access'
c.content.javascript.can_open_tabs_automatically = False
c.content.local_content_can_access_remote_urls = False
c.content.local_content_can_access_file_urls = True
c.content.notifications.enabled = False
c.content.proxy = 'system'
c.content.register_protocol_handler = False
c.content.webrtc_ip_handling_policy = 'default-public-interface-only'
#c.content.user_stylesheets = ['dark.css']

config.bind(',b', 'config-source')
config.bind(',s', 'hint links spawn --detach mpv {hint-url}')
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('M', 'bookmark-add')
config.bind('U', 'undo')
config.bind('d', 'scroll-page 0 0.5')
config.bind('u', 'scroll-page 0 -0.5')
config.bind('x', 'tab-close')
config.bind('xb', 'config-cycle tabs.show always switching')
config.bind('xt', 'config-cycle tabs.show multiple switching')
config.unbind('<Ctrl+n>')
config.unbind('<Ctrl+p>')
config.unbind('<Escape>', mode='caret')
config.unbind('<Escape>', mode='hint')
config.unbind('<Escape>', mode='prompt')
config.unbind('<Escape>', mode='register')
config.unbind('<Escape>', mode='yesno')
