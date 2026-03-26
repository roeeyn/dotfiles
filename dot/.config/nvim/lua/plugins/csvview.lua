return {
    'hat0uma/csvview.nvim',
    ft = { 'csv', 'tsv' },
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle', 'CsvViewInfo' },
    opts = {
        view = {
            display_mode = 'border',
            header_lnum = true,
            sticky_header = {
                enabled = true,
            },
        },
    },
}
