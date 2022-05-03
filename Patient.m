classdef Patient <handle
    properties
        Name
        Level  % 1 for green, 2 for yellow, 3 for red
        Status  % -2 因等待死亡；-1 治疗失败死亡；0 出院；x 在x科室治疗；x.5 在x科室前等待 
        ArriveTime
        DeadTime
        WaitTime
        History
    end
%     properties(Access = private)
%         
%     end
    
    methods
        function obj = Patient(Name,Level,Status,ArriveTime,DeadTime)
            obj.Name = Name;
            obj.Level = Level;
            obj.Status = Status;
            obj.ArriveTime = ArriveTime;
            obj.DeadTime = DeadTime;
            obj.WaitTime = 0;
            obj.History = [];
        end
        
        function Dead = PatTimeGo(obj)
            Dead = 0;
            if obj.Status - fix(obj.Status) > 0.1
                obj.WaitTime = obj.WaitTime + 1;
                if obj.WaitTime >= obj.DeadTime
                    Dead = fix(obj.Status);
                    obj.Status = -2;
                end
            end
            obj.History = [obj.History,obj.Status];
        end
    end
end

