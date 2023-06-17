local mlc = require 'metalua.compiler'.new()

file = io.open("./mut_src.lua", "rb")
if not file then return nil end
src_content = file:read "*a"
file:close()

local ast = mlc:src_to_ast(src_content)

if ast[1]['tag'] == "If" then
    ast[1][1] = {tag="False"}
end

file,err = io.open("mutated_script.lua",'w')
if file then
    file:write(mlc:ast_to_src(ast))
    -- file:write("a=true and 1 or 0")
    file:close()
else
    print("error:", err)
end
