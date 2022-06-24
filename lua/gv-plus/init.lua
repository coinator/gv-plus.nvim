local M = {}

local function equal_tables(t1, t2)
  if #t1 ~= #t2 then return false end
  for i=1,#t1 do
    if t1[i] ~= t2[i] then return false end
  end
  return true
end

-- Return the first index with the given value (or nil if not found).
local function index(array, value)
    for i, v in ipairs(array) do
        if equal_tables(v, value) then
            return i
        end
    end
    return nil
end

local function get_selection_attributes()

  ---- use unmapped gv
  vim.api.nvim_command("normal! gvo")
  local currentmode = vim.api.nvim_get_mode().mode
  local visualMode = "Visual"
  if (currentmode == "V") then
    visualMode = "linewise Visual"
  elseif (currentmode == "") then
    visualMode = "blockwise Visual"
  else
    visualMode = "visual"
  end
  local visualStart = vim.api.nvim_call_function("getpos", {'.'})
  local startLine = visualStart[2]
  local startCol = visualStart[3]
  local startOff  = visualStart[4]
  local startCol = startCol + startOff

  ---- retrieve the position ending the selection
  vim.api.nvim_command("normal! o")
  local visualEnd = vim.api.nvim_call_function("getpos", {'.'})
  local endLine = visualEnd[2]
  local endCol = visualEnd[3]
  local endOff  = visualEnd[4]
  local endCol = endCol + endOff

  return {startLine, startCol, endLine, endCol, visualMode}

end

function M.store_visual_selection()
  -- avoid infinite looping from ModeChanged event
  if (not vim.b.marking) then
    vim.api.nvim_buf_set_var(0, "saving_visual", 1)
  else
    return
  end

  if (not vim.b.visual_selections) then
    vim.api.nvim_buf_set_var(0, "visual_selections", {})
    visuals = {}
  end

  local entry = get_selection_attributes()
  if (index(visuals, entry) == nil) then
    table.insert(visuals, entry)
    vim.api.nvim_buf_set_var(0, "visual_selections", visuals)
  end

  vim.api.nvim_command("normal ")
  vim.api.nvim_buf_del_var(0, "saving_visual")

end


function M.get_visual_selection(count)
  if not vim.b.visual_selections then
    vim.api.nvim_command("normal! gv")
    return
  end
  local visuals = vim.b.visual_selections

  -- if no count is supplied, return the latest entry
  local entry_index = count
  if ( count > table.getn(visuals) or count == 0 ) then
    entry_index = #visuals
  end

  local area = visuals[entry_index]
  local visualMode = area[5]

  vim.api.nvim_command("normal! zv")
  vim.api.nvim_call_function("cursor" , {area[1], area[2]})

  if (visualMode == "blockwise Visual") then
    vim.api.nvim_command("normal! zv")
  elseif(visualMode == "linewise Visual") then
    vim.api.nvim_command("normal! zvV")
  else
    vim.api.nvim_command("normal! zvv")
  end
  vim.api.nvim_call_function("cursor" , {area[3], area[4]})
end

return M
