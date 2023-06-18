
-- Fecursive function
-- node: AST, mfunc: function(node: AST)
-- node를 순회하면서 mutation을 수행함
local function mutate_ast(node, mfunc)

    if type(node) == "number" then
        return
    end

    if node[#node] then
        for _, child in ipairs(node) do
            mutate_ast(child, mfunc)
        end
    end
    mfunc(node)

end

-- TODO: add more mfunc

-- example of mfunc
-- mfunc들을 여러 개 추가하면 될 것 같습니다
local function change_if_cond(node)
    if node.tag == "If" then
        node[1] = { tag="False" }
    end
end


local function reverse_cond(node)
    if node.tag == "True" then
        node.tag = "False"
    elseif node.tag == "Fase" then
        node.tag = "True"
    end
end

local function mutate_boundary(node)
    if node.tag == "Op" then
        if node[1] == "lt" then
            node[1] = "le"
        elseif node[1] == "le" then
            node[1] = "lt"
        else
            return
        end
        -- swap lhs rhs
        local left = node[2]
        local right = node[3]
        node[2] = right
        node[3] = left
    end
end

local function mutate_op(node)
    if node.tag == "Op" then
        local op = node[1]
        if op == "add" then
            node[1] = "sub"
        elseif op == "sub" then
            node[1] = "add"
        elseif op == "mul" then
            node[1] = "div"
        elseif op == "div" then
            node[1] = "mul"
        elseif op == "mod" then
            node[1] = "pow"
        elseif op == "pow" then
            node[1] = "mod"
        end
    end
end

local function print_node(node)
    if node.tag == "If" then
        print(node[0], node[1].tag, node[2][1].tag, node[3])
    end
    -- print(node.tag)
end

local function length(list)
    local count = 0
    for _ in pairs(list) do
        count = count + 1
    end
    return count
end
-- end of mfunc

local mfunc_list = {change_if_cond, reverse_cond, mutate_boundary, mutate_op}

-- code: String
function Mutate(code, seed)
    -- random seed
    math.randomseed(seed)

    local dumb = [[print("Hello world")]]
    local mlc = require 'metalua.compiler'.new()
    -- try src_to_ast()
    -- 문법 체크
    local success, result = pcall(function ()
        return mlc:src_to_ast(code)
    end)

    -- when failed, ast = dumb
    local ast
    if success then
        ast = result
    else
        ast = mlc:src_to_ast(dumb)
    end

    local len = length(mfunc_list)
    local n = math.random(len)
    local mfunc = mfunc_list[n]
    mutate_ast(ast, mfunc)

    local src
    success, result = pcall(function ()
        return mlc:ast_to_src(ast)
    end)
    if success then
        src = result
    else
        src = dumb
    end

    return src
end

-- local code = [[
-- if true then
--     local a = 1 < 2
-- end

-- ]]

-- local src = Mutate(code, 13)
-- print(src)