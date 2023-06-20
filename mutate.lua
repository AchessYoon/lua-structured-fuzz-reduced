local mlc = require 'metalua.compiler'.new()
file = io.open("./mut_src.lua", "rb")
if not file then return nil end
src_content = file:read "*a"
file:close()

local nil_node = {tag="Nil"}

local rand_cnt = 0
function random(n)
    math.randomseed(rand_cnt)
    local rand_add = math.random(1000)
    math.randomseed(os.time() + rand_add)
    rand_cnt = rand_cnt + 1 % 1000
    return math.random(n)
end

function table.clear(t)
    for k,_ in pairs(t) do
        t[k] = nil
    end
end

function table.shallow_copy(tgt_t, src_t)
    for k,v in pairs(src_t) do
        tgt_t[k] = v
    end
end

function table.concatnate(t1, t2)
    if t2 == nil then return t1 end
    for i=1, #t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

local function get_tgt_exprs(node, path)
    if node[#node] and node['tag'] == "Nil" then
        return {{path, "expr"}}
    end

    local acc = {}
    if node[#node] then for child_idx, child in ipairs(node) do
        local child_path = {}
        table.shallow_copy(child_path, path)
        table.insert(child_path, child_idx)
        local child_result = get_tgt_exprs(child, child_path)
        acc = table.concatnate(acc, child_result)
    end end

    return acc
end

local function get_tgt_stmts(node, path)
    local tgt_path = {}
    table.shallow_copy(tgt_path, path)

    if path == {} then
        table.insert(tgt_path, #node + 1)
        return {tgt_path}
    end

    if node["tag"] == "If" or node["tag"] == "While" then
        table.insert(tgt_path, 2)
        table.insert(tgt_path, #node[2] + 1)
        return {tgt_path}
    end

    local acc = {}
    if node[#node] then for child_idx, child in ipairs(node) do
        local child_path = {}
        table.shallow_copy(child_path, path)
        table.insert(child_path, child_idx)
        local child_result = get_tgt_stmts(child, child_path)
        acc = table.concatnate(acc, child_result)
    end end

    return acc
end

local function mut_by_path(root, path, new_node)
    local current = root
    for _, child_idx in ipairs(path) do
        if current[child_idx] == nil then current[child_idx] = {} end
        current = current[child_idx]
    end
    table.shallow_copy(current, new_node)
end

local ast = mlc:src_to_ast(src_content)


-------------------------------------------------
-- function get_nil()
--     return {tag="Nil"}
-- end

function get_dots()
    return {tag="Dots"}
end

function get_true()
    return {tag="True"}
end

function get_false()
    return {tag="False"}
end

function get_number()
    return {tag="Number", random(-100, 100)}
end

function get_string()
    return {tag="String", "some_string"}
end

function get_table()
    local content_table = {tag="Pair", nil_node, nil_node}
    return {tag="Table", content_table}
end

function get_op()
    local op_table = {'add', 'sub', 'mul', 'div', 'mod', 'pow', 'concat', 'eq', 'lt' , 'le' , 'and', 'or', 'not', 'len'}
    local op_id = op_table[random(#op_table)]
    return {tag="Op", op_id, nil_node, nil_node}
end

local expr_gens = {get_dots, get_true, get_false, get_number, get_string, get_table, get_op}
-------------------------------------------------
function get_if()
    if (random(3)==1) then
        return {tag="If", nil_node, {}, nil_node, {}, {}}
    elseif (random(2)==1) then
        return {tag="If", nil_node, {}, {}}
    else
        return {tag="If", nil_node, {}}
    end
end

function get_while()
    return {tag="While", nil_node, {}}
end

local stmt_gens = {get_if, get_while}
-------------------------------------------------

if (random(2)==1) then
    local tgt_candidates = get_tgt_exprs(ast, {})
    local tgt_path = tgt_candidates[random(#tgt_candidates)][1]
    local rand_basic_expr = expr_gens[random(#expr_gens)]()
    mut_by_path(ast, tgt_path, rand_basic_expr)
else
    local tgt_candidates = get_tgt_stmts(ast, {})
    local tgt_path = tgt_candidates[random(#tgt_candidates)]
    local rand_basic_stmt = stmt_gens[random(#stmt_gens)]()
    mut_by_path(ast, tgt_path, rand_basic_stmt)
end

file,err = io.open("mutated_script.lua",'w')
if file then
    file:write(mlc:ast_to_src(ast))
    file:close()
else
    print("error:", err)
end
