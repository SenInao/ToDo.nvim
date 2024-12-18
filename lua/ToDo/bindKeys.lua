local ToDo = require("ToDo.actions")

local function getTodosPath()
  local cwd = vim.fn.getcwd()
  local home_dir
  if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    cwd = cwd:gsub("\\", "-"):sub(4)
    home_dir = os.getenv("USERPROFILE") .. "\\appdata\\local\\nvim-data\\ToDo\\"
  else
    cwd = cwd:gsub("/", "-"):sub(2)
    home_dir = os.getenv("HOME") .. "/.local/share/nvim/ToDo/"
  end
  return home_dir .. cwd .. ".txt"
end

local function writeTodos(todos)
  local path = getTodosPath()
  local file = io.open(path, "w+")
  print(path)
  if file then
    for _,v in pairs(todos.tasks) do
      file:write(v .. "\n")
    end
    file:write("\n")
    for _,v in pairs(todos.done) do
      file:write(v .. "\n")
    end

    file:close()
  end
end

function CloseMenu(todos)
  writeTodos(todos)
  vim.api.nvim_win_close(Win_id, true)
end

local function bindKeys(buf, todos)
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
    noremap = true,
    silent = true,
    callback = function ()
      CloseMenu(todos)
    end
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = function ()
      ToDo.mark(buf, todos)
    end
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "dd", "", {
    noremap = true,
    silent = true,
    callback = function ()
      ToDo.removeToDo(buf, todos)
    end
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "i", "", {
    noremap = true,
    silent = true,
    callback = function ()
      ToDo.createTodo(buf, todos)
    end
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "e", "", {
    noremap = true,
    silent = true,
    callback = function ()
      ToDo.editTodo(buf)
    end
  })
  vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = function ()
      ToDo.appendTodo(buf, todos)
    end
  })
  vim.api.nvim_buf_set_keymap(buf, "i", "<Esc>", "", {
    noremap = true,
    silent = true,
    callback = function ()
      ToDo.appendTodo(buf, todos)
    end
  })
end

return bindKeys
