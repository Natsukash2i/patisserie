return {
  cmd = { 'qmlls', '-E' },
  filetypes = { 'qml', 'qmljs' },
  root_markers = { '.git' },

on_attach = function(client, bufnr)
    client.server_capabilities.semanticTokensProvider = nil
  end,
}
