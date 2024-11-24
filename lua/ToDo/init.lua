local popup = require("plenary.popup")
local ToDo = require("actions")

local function combineTodos(todos)
  local list = {}

  for _,v in pairs(todos.tasks) do
    table.insert(list, v)
  end

  for _,v in pairs(todos.done) do
    table.insert(list, v)
  end

  return list
end

local function highlightDone(buf, todos)
  for i = 0, #todos.done do
      vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", #todos.tasks + i, 0, -1)
  end
end

local function updateUi(buf, todos)
  vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_option(buf, 'readonly', false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, combineTodos(todos))
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'readonly', true)
  highlightDone(buf, todos)
end

local function getTodosPath()
  local cwd = vim.fn.getcwd()
  cwd = cwd:gsub("/", "-"):sub(2)
  return os.getenv("HOME") .. "/todos/" .. cwd .. ".txt"
end

local function getTodos()
  local path = getTodosPath()
  print(path)
  local file = io.open(path, "r")

  local content = ""
  local todos = {
    tasks = {},
    done = {}
  }

  if file then
    content = file:read()
    local fillTasks = 1
    while content do
      if content == "" then
        fillTasks = 0
        goto continue
      end
      if fillTasks == 1 then
        table.insert(todos.tasks, content)
      else
        table.insert(todos.done, content)
      end
      ::continue::
      content = file:read()
    end
    file:close()
  end

  return todos
end

local function writeTodos(todos)
  local path = getTodosPath()
  local file = io.open(path, "w+")
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

function ShowMenu(todos)
  local height = 20
  local width = 40
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local buf = vim.api.nvim_create_buf(false, true)

  Win_id = popup.create(buf, {
        title = "TODO",
        highlight = "TODO-Window",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
  })

  updateUi(buf, todos)

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

function CloseMenu(todos)
  writeTodos(todos)
  vim.api.nvim_win_close(Win_id, true)
end

function MyMenu()
  local todos = getTodos()
  ShowMenu(todos)
end
