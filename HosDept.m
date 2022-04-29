classdef HosDept <handle
    
    properties
        Name
        Number
        RequiredTime
        Availability  % 0:不可用；1:可用
        
    end
    properties(Access = private)
        AvaiIndex
    end
    
    methods
        function obj = HosDept(Name,Number,RequiredTime)
            obj.Name = Name;
            obj.Number = Number;
            obj.RequiredTime = RequiredTime;
            obj.Availability = ones(1,Number);
            obj.AvaiIndex = zeros(1,Number);
        end
        
        function RoomNum = Use(obj)
            RoomNum = 0;
            for i = 1:obj.Number
                if obj.Availability(i) == 1
                    obj.Availability(i) = 0;
                    obj.AvaiIndex(i) = obj.RequiredTime;
                    RoomNum = i;
                    break
                end
            end
        end
        
        function DoneNum = HosTimeGo(obj)
            DoneNum = [];
            for i = 1:obj.Number
                if obj.AvaiIndex(i) > 0
                    obj.AvaiIndex(i) = obj.AvaiIndex(i) - 1;
                    if obj.AvaiIndex(i) == 0
                        obj.Availability(i) = 1;
                        DoneNum = [DoneNum,i];
                    end
                end
            end
        end
    end
end

