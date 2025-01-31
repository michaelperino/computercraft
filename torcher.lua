local args = {...}
offset_x_chunk = args[1]
offset_z_chunk = args[2]
chunk_size = 256

--base_IDs = {50001,50002,50003,50004}
base_ID = 50000+math.random(1,4)
height_ID = 49999

rednet.open("left")
broadcast_on_completion = false

function get_base_ID()
    base_ID = 50000+math.random(1,4)
    return base_ID
end

function ParseCSVLine (line,sep) 
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do 
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos) 
				if (c == '"') then txt = txt..'"' end 
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else	
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if (startp) then 
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end 
		end
	end
	return res
end

function item_RS_request(item, amount, slotty)
    --turtle.select(14)
    --turtle.digUp()
    --turtle.equipRight()
    request = string.format("ITEM %04d %s",amount,item)
    print(request)
    reccy = -1
    --rednet.open("right")
    rednet.broadcast(request)
    while reccy ~= os.computerID() do
		--rednet.broadcast(request)
        s,m = rednet.receive("item_ready",2+math.random(10,100)/1000)
        if s == nil then
            rednet.broadcast(request)
		elseif p == "dump_stop" then
            sleep(math.random(110,200)/1000)
            rednet.broadcast(request)
        else
            print(m)
            reccy = tonumber(string.sub(m,1,5))
        end
    end
    turtle.select(16)
    while not turtle.placeUp() do
        digUp()
    end
    for i = 10,3 do
        if turtle.getItemCount(i) > 1 then
            while i > 2 do
            turtle.select(i)
            turtle.dropUp(64)
            end
        end
    end
    turtle.select(slotty)
    turtle.dropUp(64)
    turtle.suckUp(64)
    rednet.broadcast("END","dump_stop")
    --turtle.select(14)
    --turtle.equipRight()
    turtle.select(16)
    turtle.dropUp(64)
    turtle.digUp()
    turtle.select(slotty)
end

function refuel()
    if turtle.getFuelLevel() < 6000 then
        item_RS_request("minecraft:coal",40,12)
        turtle.select(12)
        turtle.refuel(40)
    end
end

function unstuck(depth)
    if turtle.back() then
        while not turtle.forward() do
            print("STUCK!")
            sleep(math.random(50,200)/100)
        end
    end
    if turtle.down() then
        while not turtle.up() do
            print("STUCK!")
            sleep(math.random(50,200)/100)
        end
    end
end
    

function dig()
    success, block = turtle.inspect()
    if block.name ~= "computercraft:turtle_advanced" and block.name ~= "computercraft:turtle_normal" then
        turtle.dig()
        --turtle.attack()
    else
        unstuck(0)
    end
    refuel()
end

function digUp()
    success, block = turtle.inspectUp()
    if block.name ~= "computercraft:turtle_advanced" and block.name ~= "computercraft:turtle_normal" then
        turtle.digUp()
        --turtle.attack()
    else
        unstuck(0)
    end
    refuel()
end

function digDown()
    success, block = turtle.inspectDown()
    if block.name ~= "computercraft:turtle_advanced" and block.name ~= "computercraft:turtle_normal" then
        turtle.digDown()
        --turtle.attack()
    else
        unstuck(0)
    end
    refuel()
end

items = {}
items[1] = "minecraft:torch"
items[2] = "minecraft:torch"

function placeDown(slotty)
    if turtle.getItemCount(slotty) < 4 then
        item_RS_request(items[slotty],62-turtle.getItemCount(slotty),slotty)
    end
    turtle.select(slotty)
    turtle.placeDown()
end


function traverse(gx,gy,gz,gd)
    refuel()
    --axis = string.sub(message,12,12)
    --target = tonumber(string.sub(message,14))
    direction = 0
    turtle.up()
    turtle.up()
    turtle.up()
    --rednet.send(height_ID,"SEY PLEASE","printer_y")
    y_val = math.random(1,15)
    --s,m,p = rednet.receive("printer_y",2)
    --if s ~= nil then
    --    if tonumber(m) ~= nil then
    --        y_val = tonumber(m)
    --    end
    --end
    for count = 1,4 do
        if turtle.forward() then
            fx = nil
            while fx == nil do
                fx, fy, fz = gps.locate()
            end
            turtle.back()
            cx = nil
            while cx == nil do
                cx, cy, cz = gps.locate()
            end
            if fx > cx then
                direction = 1
            elseif fx < cx then
                direction = 3
            elseif fz > cz then
                direction = 4
            elseif fz < cz then
                direction = 2
            end
            break
        else
            turtle.turnRight()
        end
        print(direction)
    end
    if direction == 0 then
        print(direction)
        for count = 1,4 do
            s,d = turtle.inspect()
            if d.name == "computercraft:turtle" or d.name == "computercraft:turtle_normal" or d.name == "computercraft:turtle_advanced" or d.name == "minecraft:chest" or d.name == "enderstorage:ender_storage" then
                turtle.turnRight()
                s,d = turtle.inspect()
            else
                while not turtle.forward() do
                    dig()
                end
                fx = nil
                while not fx do
                    fx, fy, fz = gps.locate()
                end
                turtle.back()
                cx = nil
                while not cx do
                    cx, cy, cz = gps.locate()
                end
                direction = 0
                if fx > cx then
                    direction = 1
                elseif fx < cx then
                    direction = 3
                elseif fz > cz then
                    direction = 4
                elseif fz < cz then
                    direction = 2
                end
                break
            end
        end
    end
    order = {"Y1","X","Z","D"}
    axes = {X=gx,Y1=85,Y2=gy,Z=gz,D=gd}
    for curr_axis = 1,4 do
        cx = nil
        while cx == nil do
            cx, cy, cz = gps.locate()
        end
        axis = string.sub(string.upper(order[curr_axis]),1,1)
        target = tonumber(axes[order[curr_axis]])
        targetdir = direction
        if axis == "X" then
            if target > cx then
                targetdir = 1
            elseif target < cx then
                targetdir = 3
            end
            dist = math.abs(target - cx)
        end
        if axis == "Y" then
            targetdir = direction
            curr = cy
            dist = math.abs(target - cy)
        end
        if axis == "Z" then
            if target > cz then
                targetdir = 4
            elseif target < cz then
                targetdir = 2
            end
            dist = math.abs(target - cz)
        end
        if axis == "D" then
            if target > 0 and target < 5 then
                targetdir = target
            end
        end
        while direction ~= targetdir do
            turtle.turnLeft()
            direction = direction + 1
            if direction == 5 then
                direction = 1
            end
        end
        dig_enabled = false
        curr = 0
        if axis == "X" or axis == "Z" then
            while curr < dist do
                if turtle.forward() then
                    curr = curr + 1
                else
                    if dig_enabled then
                        dig()
                    end
                end
            end
        elseif axis == "Y" then
            while curr < dist do
                if target > cy then
                    if turtle.up() then
                        curr = curr + 1
                    else
                        if dig_enabled then
                            digUp()
                        end
                    end
                else
                    if turtle.down() then
                        curr = curr + 1
                    else
                        if dig_enabled then
                            digDown()
                        end
                    end
                end
            end
        end
        print(direction,curr,cx,cy,cz)
    end
    rednet.send(height_ID,"REY PLEASE","printer")
end

m = nil
while m == nil do
    rednet.send(get_base_ID(),"ORI","printer")
    s,m = rednet.receive("printer",5)
end
data = ParseCSVLine(m,",")
ox = tonumber(data[1])
oy = tonumber(data[2])
oz = tonumber(data[3])
od = tonumber(data[4])
slot = 1
m = nil
z_size = chunk_size
x_size = chunk_size
for curr_z_offset = 0,256,7 do
    print(string.format("TRAVERSE %d %d %d %d\n",ox+offset_x_chunk*x_size,oy,oz+offset_z_chunk*z_size+curr_z_offset,od))
    traverse(ox,oy,oz,od)
    data = {}
    curr_y = 0
    for curr_x_offset = 0,256,7 do
        if turtle.getItemCount(slot) < 4 then
            item_RS_request(items[slot],62-turtle.getItemCount(slot),slot)
        end
        while turtle.down() do
            turtle.down()
        end
        turtle.up()
        placeDown(1)
        traverse(curr_x_offset+ox,85,curr_z_offset+oz,1)
    end
end

