local pallette = {
    -- n3b stands for nord3_bright
    --16 colors
    n0             = _G._os_uname.sysname == "Windows_NT" and "#1f2430" or "#1e2127",
    n1             = _G._os_uname.sysname == "Windows_NT" and "#303642" or "#252830",
    n2             = "#434C5E",
    n3             = "#4C566A",
    n3b            = "#616E88",
    n4             = "#D8DEE9",
    n5             = "#E5E9F0",
    n6             = "#ECEFF4",
    n7             = "#8FBCBB",
    n8             = "#88C0D0",
    n9             = "#81A1C1",
    n10            = "#5E81AC",
    n11            = "#BF616A",
    n12            = "#D08770",
    n13            = "#EBCB8B",
    n14            = "#A3BE8C",
    n15            = "#B48EAD",
    w              = "#FFFFFF",
    b              = "#000000",
    none           = 'NONE',

    red            = "#E06C75",
    dark_red       = "#BE5046",
    green          = "#98C379",
    yellow         = "#E5C07B",
    orange         = "#D19A66",
    blue           = "#61AFEF",
    purple         = "#C678DD",
    cyan           = "#56B6C2",
    white          = "#ABB2BF",
    black          = "#282C34",
    comment_grey   = "#5C6370",
    gutter_fg_grey = "#4B5263",
    cursor_grey    = "#2C323C",
    visual_grey    = "#3E4452",
    menu_grey      = "#3E4452",
    special_grey   = "#3B4048",
}


return pallette
