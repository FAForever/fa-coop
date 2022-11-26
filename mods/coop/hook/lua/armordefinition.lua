for _, def in armordefinition do
    if def[1] == 'Structure' or def[1] == 'ExperimentalStructure' then
        for i, str in def do
            if string.find(str, 'Deathnuke') then
                table.remove(def, i)
                break
            end
        end
    end
end
