function IndentEntireFile()
    vim.api.nvim_command('normal! magg=G`a')
end

function ExecuteMacroOverVisualRange()
  print("@" .. vim.fn.getcmdline())
  vim.cmd("'<,'>normal @" .. string.char(vim.fn.getchar()))
end
