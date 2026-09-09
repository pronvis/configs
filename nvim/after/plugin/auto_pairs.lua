vim.g.AutoPairsFlyMode = 1
vim.g.AutoPairs = {
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ["'"] = "'",
    ['"'] = '"',
    ['```'] = '```',
    ['"""'] = '"""',
    ["'''"] = "'''",
    ["`"] = "`",
    ['|'] = '|'
}

-- Let nvim-cmp wrap this fallback instead of AutoPairs wrapping cmp's callback.
vim.keymap.set('i', '<CR>', '<CR><Plug>AutoPairsReturn')
