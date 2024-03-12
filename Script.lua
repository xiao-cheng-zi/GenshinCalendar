function Initialize()
    -- ��ʼ�����룬����Ƥ��ʱϵͳֻ���Զ�����һ��
    currentyear = os.date("%Y")
    currentmonth = os.date("%m")
    currentday = os.date("%d")

    yeardate = UpdateYear()
    monthindex = UpdateMonth(yeardate)
    UpdateDay(monthindex)

    Updatebackground(SKIN:GetVariable('BgModelCode'), SKIN:GetVariable('BgFileName'), SKIN:GetVariable('BgSum'))
    
end

function Update()
    -- ���º������룬ÿ60���Զ�����һ��
    if currentyear ~= os.date("%Y") then
        yeardate = UpdateYear()
        currentyear = os.date("%Y")
        Updatebackground(SKIN:GetVariable('BgModelCode'), SKIN:GetVariable('BgFileName'), SKIN:GetVariable('BgSum'))
    end

    if currentmonth ~= os.date("%m") then
        ResetNode()
        monthindex = UpdateMonth(yeardate)
        currentmonth = os.date("%m")
        Updatebackground(SKIN:GetVariable('BgModelCode'), SKIN:GetVariable('BgFileName'), SKIN:GetVariable('BgSum'))
    end

    if currentday ~= os.date("%d") then
        UpdateDay(monthindex)
        currentday = os.date("%d")
        Updatebackground(SKIN:GetVariable('BgModelCode'), SKIN:GetVariable('BgFileName'), SKIN:GetVariable('BgSum'))
    end
end

---- ���ú����� ----

-- �ָ��ַ���
function Split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then
        return false
    end
    local pos, arr = 0, {}
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

-- ��ȡ�����ļ������Ϊ��������
-- ��Ҫ�� Initialize() �� Update() �����ڲ�����
function ReadFileLines(FilePath)
    FilePath = SKIN:MakePathAbsolute(FilePath)
    local File = io.open(FilePath)
    if not File then
        print('�޷����ļ����ж�ȡ' .. FilePath)
        return
    end
    local Contents = {}
    for Line in File:lines() do
        table.insert(Contents, Line)
    end
    File:close()
    return Contents
end

-- д���ļ�
-- ��Ҫ�� Initialize() �� Update() �����ڲ�����
function WriteToFile(filename, content)
    filename = SKIN:MakePathAbsolute(filename)
    local file = io.open(filename, "w")
    if file then
        file:write(content)
        file:close()
    else
        print("�޷����ļ�����д��" .. filename)
    end
end

-- ��ȡ��ǰ�·ݵĵ�һ������һ����ܹ�����
function getFirstAndLastDayOfMonth()
    local currentDate = os.date("*t")
    currentDate.day = 1
    currentDate.hour = 0
    currentDate.min = 0
    currentDate.sec = 0
    local firstDayOfYear = tonumber(os.date("%j", os.time(currentDate)))
    currentDate.month = currentDate.month + 1
    if currentDate.month > 12 then
        currentDate.month = 1
        currentDate.year = currentDate.year + 1
    end
    currentDate.day = currentDate.day - 1
    local lastDayOfYear = tonumber(os.date("%j", os.time(currentDate)))
    local daysInMonth = lastDayOfYear - firstDayOfYear + 1
    return {firstDayOfYear, lastDayOfYear, daysInMonth}
end

-- ����� ���� 
-- ��ȡ��ǰһ�������ݲ�����
function UpdateYear()
    return ReadFileLines("@Resources\\data\\" .. os.date("%Y") .. ".txt")
end

-- �¸��� ����
-- ���������ݲ�ֵ�ǰ�·ݵ����ݣ�������Ⱦ���ڵ��ϣ������ص�ǰ�µ��±�ƫ����
function UpdateMonth(date)
    local result = {}
    local day = getFirstAndLastDayOfMonth()
    for i = day[1], day[2] do
        result[#result + 1] = date[i]
    end
    local index = 0
    for i = 1, day[3] do
        if i == 1 then
            local week = Split(result[1], ",")[2]
            if week == "������" then
                index = 1
            elseif week == "����һ" then
                index = 2
            elseif week == "���ڶ�" then
                index = 3
            elseif week == "������" then
                index = 4
            elseif week == "������" then
                index = 5
            elseif week == "������" then
                index = 6
            elseif week == "������" then
                index = 7
            end
        end
        SKIN:Bang("!SetOption", "MainDate_" .. index + i - 1, "Text", i)
        if Split(result[i], ",")[5] ~= "" then
            SKIN:Bang("!SetOption", "SecondaryDate_" .. index + i - 1, "Text", Split(result[i], ",")[5])
        else
            if string.sub(Split(result[i], ",")[3], -4) == "��һ" then
                SKIN:Bang("!SetOption", "SecondaryDate_" .. index + i - 1, "Text",
                    string.sub(Split(result[i], ",")[3], 1, #Split(result[i], ",")[3] - 4))
            else
                SKIN:Bang("!SetOption", "SecondaryDate_" .. index + i - 1, "Text",
                    string.sub(Split(result[i], ",")[3], -4))
            end
        end
    end
    return index
end

-- �ո��� ����
-- ���ݴ�����±�ƫ��������Ⱦ�ڵ����ʾ�߿򣬲��ѵ�ǰ���ڵ�ǰһ��ı߿�ȡ��
function UpdateDay(index)
    if tonumber(os.date("%d")) == 1 then
        SKIN:Bang("!SetOption", "bg_" .. index + tonumber(os.date("%d")) - 1, "Shape",
            "Rectangle 0,0,[Bg_Shape_1:],[Bg_Shape_2:],[Bg_Shape_3:]|Fill Color #Bg_FillColor#|StrokeWidth [Bg_Shape_4:]|Stroke Color #Bg_StrokeColor#")
    else
        SKIN:Bang("!SetOption", "bg_" .. index + tonumber(os.date("%d")) - 2, "Shape",
            "Rectangle 0,0,[Bg_Shape_1:],[Bg_Shape_2:],[Bg_Shape_3:]|Fill Color 0,0,0,0|StrokeWidth [Bg_Shape_4:]|Stroke Color 0,0,0,0")
        SKIN:Bang("!SetOption", "bg_" .. index + tonumber(os.date("%d")) - 1, "Shape",
            "Rectangle 0,0,[Bg_Shape_1:],[Bg_Shape_2:],[Bg_Shape_3:]|Fill Color #Bg_FillColor#|StrokeWidth [Bg_Shape_4:]|Stroke Color #Bg_StrokeColor#")
    end
end

-- ��ʼ���ڵ�
function ResetNode()
    for i = 1, 42 do
        SKIN:Bang("!SetOption", "MainDate_" .. i, "Text", "")
        SKIN:Bang("!SetOption", "SecondaryDate_" .. i, "Text", "")
        SKIN:Bang("!SetOption", "bg_" .. i, "Shape",
            "Rectangle 0,0,[Bg_Shape_1:],[Bg_Shape_2:],[Bg_Shape_3:]|Fill Color 0,0,0,0|StrokeWidth [Bg_Shape_4:]|Stroke Color 0,0,0,0")
    end
end

-- ����ͼ����ģʽ ����
function Updatebackground(code, filename, sum)
    sum = tonumber(sum)
    local bgconfig = ReadBgData()
    bgconfig[4] = tonumber(bgconfig[4])
    if code == "1" then
        if bgconfig[1] ~= os.date("%Y") then
            if bgconfig[4] < sum then
                bgconfig[4] = bgconfig[4] + 1
            else
                bgconfig[4] = 1
            end
            WriteBgData(os.date("%Y") .. "," .. os.date("%m") .. "," .. os.date("%d") .. "," .. bgconfig[4])
            SKIN:Bang("!SetOption", "BackgroundImage", "ImageName", "@Resources\\images\\bgimg\\" .. bgconfig[4] .. ".png")
        else
            SKIN:Bang("!SetOption", "BackgroundImage", "ImageName", "@Resources\\images\\bgimg\\" .. bgconfig[4] .. ".png")
        end
    elseif code == "2" then
        if bgconfig[2] ~= os.date("%m") or bgconfig[1] ~= os.date("%Y") then
            if bgconfig[4] < sum then
                bgconfig[4] = bgconfig[4] + 1
            else
                bgconfig[4] = 1
            end
            WriteBgData(os.date("%Y") .. "," .. os.date("%m") .. "," .. os.date("%d") .. "," .. bgconfig[4])
            SKIN:Bang("!SetOption", "BackgroundImage", "ImageName", "@Resources\\images\\bgimg\\" .. bgconfig[4] .. ".png")
        else
            SKIN:Bang("!SetOption", "BackgroundImage", "ImageName", "@Resources\\images\\bgimg\\" .. bgconfig[4] .. ".png")
        end
    elseif code == "3" then
        if bgconfig[3] ~= os.date("%d") or bgconfig[2] ~= os.date("%m") or bgconfig[1] ~= os.date("%Y") then
            if bgconfig[4] < sum then
                bgconfig[4] = bgconfig[4] + 1
            else
                bgconfig[4] = 1
            end
            WriteBgData(os.date("%Y") .. "," .. os.date("%m") .. "," .. os.date("%d") .. "," .. bgconfig[4])
            SKIN:Bang("!SetOption", "BackgroundImage", "ImageName", "@Resources\\images\\bgimg\\" .. bgconfig[4] .. ".png")
        else
            SKIN:Bang("!SetOption", "BackgroundImage", "ImageName", "@Resources\\images\\bgimg\\" .. bgconfig[4] .. ".png")
        end
    elseif code == "4" then
        SKIN:Bang("!SetOption", "BackgroundImage", "ImageName", "@Resources\\images\\bgimg\\" .. filename .. ".png")
    end
end

-- д�뱳��ͼ��������
function WriteBgData(data)
    WriteToFile("@Resources\\data\\bgconfig.txt", data)
end

-- ��ȡ����ͼ��������
function ReadBgData()
    return Split(ReadFileLines("@Resources\\data\\bgconfig.txt")[1], ",")
end
