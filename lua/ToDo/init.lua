local popup = require("plenary.popup")

local todoList = {
  tasks = {
    "Finish prject 1",
    "crate dola func",
  },
  done = {
    "print hello world",
    "make for loop",
  }
}

local function getTodos(todos)
  local list = {}

  for _,v in pairs(todos.tasks) do
    table.insert(list, v)
  end

  for _,v in pairs(todos.done) do
    table.insert(list, v)
  end

  return list
end

local function indexOfTodo(todos, todo)
  for k,v in pairs(todos) do
    if v == todo then
      return k
    end
  end
end

local function todoDone(todos, todo)
  for _,v in pairs(todos.tasks) do
    if v == todo then
      return 0
    end
  end
  return 1
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
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, getTodos(todos))
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'readonly', true)
  highlightDone(buf, todos)
end

function ShowMenu(todos)
  local height = 20
  local width = 40
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local buf = vim.api.nvim_create_buf(false, true)

  local function mark()
    local line = vim.api.nvim_get_current_line()
    if todoDone(todos, line) == 1 then
      local index = indexOfTodo(todos.done, line)
      table.remove(todos.done, index)
      table.insert(todos.tasks, line)
    else
      local index = indexOfTodo(todos.tasks, line)
      table.remove(todos.tasks, index)
      table.insert(todos.done, 1, line)
    end
    updateUi(buf, todos)
  end

  local function removeToDo()
    local line = vim.api.nvim_get_current_line()
    if todoDone(todos, line) == 1 then
      local index = indexOfTodo(todos.done, line)
      table.remove(todos.done, index)
    else
      local index = indexOfTodo(todos.tasks, line)
      table.remove(todos.tasks, index)
    end
    updateUi(buf, todos)
  end

  local function createTodo()
    table.insert(todos.tasks, 1, "")
    updateUi(buf, todos)
    vim.api.nvim_win_set_cursor(0, {1,0})
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'readonly', false)
    vim.api.nvim_command("startinsert")
  end

  local function appendTodo()
    vim.api.nvim_command("stopinsert")
    local line = vim.api.nvim_get_current_line()
    local lineNum = vim.api.nvim_win_get_cursor(0)
    if lineNum[1] > #todos.tasks then
      todos.done[lineNum[1] - #todos.tasks] = line
    else
      todos.tasks[lineNum[1]] = line
    end
    updateUi(buf, todos)
  end

  local function editTodo()
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'readonly', false)
    vim.api.nvim_command("startinsert")
  end

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

  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>lua CloseMenu()<CR>", { silent=false })
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = mark
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "dd", "", {
    noremap = true,
    silent = true,
    callback = removeToDo
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "i", "", {
    noremap = true,
    silent = true,
    callback = createTodo
  })
  vim.api.nvim_buf_set_keymap(buf, "n", "e", "", {
    noremap = true,
    silent = true,
    callback = editTodo
  })
  vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
    noremap = true,
    silent = true,
    callback = appendTodo
  })
  vim.api.nvim_buf_set_keymap(buf, "i", "<Esc>", "", {
    noremap = true,
    silent = true,
    callback = appendTodo
  })
end

function CloseMenu()
  vim.api.nvim_win_close(Win_id, true)
end

function MyMenu()
  ShowMenu(todoList)
end
