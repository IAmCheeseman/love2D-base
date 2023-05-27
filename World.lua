return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.1",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 10,
  height = 10,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 4,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "Path",
      firstgid = 1,
      filename = "Path.tsx"
    },
    {
      name = "Walls",
      firstgid = 56,
      filename = "Walls.tsx"
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      id = 1,
      name = "Paths",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        13, 13, 17, 24, 18, 13, 13, 13, 13, 13,
        13, 17, 25, 0, 12, 13, 13, 13, 13, 13,
        13, 14, 0, 0, 23, 18, 13, 13, 13, 13,
        13, 28, 2, 3, 0, 23, 24, 24, 18, 13,
        13, 13, 13, 28, 3, 0, 0, 0, 23, 18,
        17, 24, 18, 17, 25, 0, 0, 0, 0, 12,
        25, 0, 12, 14, 0, 0, 0, 0, 0, 12,
        0, 0, 12, 14, 0, 0, 4, 0, 1, 29,
        2, 2, 29, 28, 2, 2, 31, 2, 29, 13,
        13, 13, 13, 13, 13, 13, 13, 13, 13, 13
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      id = 3,
      name = "Walls",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 56, 57, 57, 58, 0,
        0, 0, 0, 0, 0, 78, 73, 68, 69, 0,
        0, 0, 0, 0, 0, 0, 78, 79, 80, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
