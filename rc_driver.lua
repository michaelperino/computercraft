peripheral.find("modem").open(os.getComputerID())
peripheral.find("modem").open(65535)
while true do
    print("Ender command or computer ID\n")
    command = read()
    id = -001
    if tonumber(command) then
        id = tonumber(command)
        print("Enter command for turtle ",string.format("%04d",id),"\n")
        command = read()
    end
    id = string.format("%04d",id)
    if command == "shell" then
        print("Enter verbatim command\n")
        arg1 = read()
        rednet.broadcast(id.." "..command.." "..arg1)
    elseif command == "seek" or command == "seek " or command =="fseek" then
        if string.len(command) == 4 then
            command = command.." "
        end
        print("Which axis?\n")
        axis = read()
        print("where on axis?\n")
        value = read()
        target = string.format("%6d",value)
        if axis == "x" or axis == "X" then
            rednet.broadcast(id.." "..command.." ".."X".." "..target)
        elseif axis == "y" or axis == "Y" then
            rednet.broadcast(id.." "..command.." ".."Y".." "..target)
        elseif axis == "z" or axis == "Z" then
            rednet.broadcast(id.." "..command.." ".."Z".." "..target)
        elseif axis == "d" or axis == "D" then
            rednet.broadcast(id.." "..command.." ".."D".." "..target)
        end
    elseif command == "find" or command == "find " then
        command = "find " 
        rednet.broadcast(id.." "..command)
        success = true
        while success do
            success,message = rednet.receive(0.5)
            if success then
                print(message)
            end
        end
    elseif command == "ackno" or command == "noack" then
        rednet.broadcast(id.." "..command)
    end
end
        
