--vim.cmd 'packadd paq-nvim'
--paq = require'paq-nvim'.paq

V = {}

--V.ice = (git, hook) ->
--    --print git, hook
--    paq git
--    if hook != nil
--      hook!

  -- V.au.ft seems like a better fit

V.ft = setmetatable({
  iscode: ->
    --if vim.o.filetype
    print

  istext: ->
    print

}, {
  __call: (filetype) =>
    print filetype
})

V.log = (message) ->
  print message

return V

