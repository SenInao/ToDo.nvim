local popup = require("plenary.popup")

local todoList = {
  {
    todo = "Todo 1",
    done = 1,
  },
  {
    todo = "Todo 2",
    done = 0,
  },
  {
    todo = "Todo 3",
    done = 1,
  },
  {
    todo = "Todo 4",
    done = 0,
  },
}

local function getTodos(todos)
  local list = {}
  for k,v in pairs(todos) do
    list[k] = v.todo
  end
  return list
end

local function indexOfTodo(todos, todo)
  for k,v in pairs(todos) do
    if v.todo == todo then
      return k
    end
  end
end

local function highlightDone(buf, todos)
  for k,v in pairs(todos) do
    if v.done == 1 then
      vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", k-1, 0, -1)
    else
      vim.api.nvim_buf_add_highlight(buf, -1, "Identifier", k-1, 0, -1)
    end
  end
end

local function updateUi(buf, todos)
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
    local index = indexOfTodo(todos, line)
    vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
    if todos[index].done == 1 then
      todos[index].done = 0
    else
      todos[index].done = 1
    end
    highlightDone(buf, todos)
  end

  local function removeToDo()
    local line = vim.api.nvim_get_current_line()
    local index = indexOfTodo(todos, line)
    table.remove(todos, index)
    updateUi(buf, todos)
  end

  local function createTodo()
    local todo = {
      todo = "",
      done = 0,
    }
    table.insert(todos, 1, todo)
    updateUi(buf, todos)
    vim.api.nvim_win_set_cursor(0, {1,0})
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'readonly', false)
    vim.api.nvim_command("startinsert")
  end

  local function appendTodo()
    vim.api.nvim_command("stopinsert")
    local line = vim.api.nvim_get_current_line()
    todos[1].todo = line
    updateUi(buf, todos)
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
  vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
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
