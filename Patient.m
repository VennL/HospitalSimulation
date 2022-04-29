classdef Patient <handle
    properties
        Name
        Level  % 1 for green, 2 for yellow, 3 for red
        Status  % -1 死亡；0 出院；x 在x科室治疗；x.5 在x科室等待 
        DeadTime
        WaitTime
        History
    end
%     properties(Access = private)
%         
%     end
    
    methods
        function obj = Patient(Name,Level,Status,DeadTime)
            obj.Name = Name;
            obj.Level = Level;
            obj.Status = Status;
            obj.DeadTime = DeadTime;
            obj.WaitTime = 0;
            obj.History = [];
        end
        
        function PatTimeGo(obj)
            if obj.Status > 0
                obj.WaitTime = obj.WaitTime + 1;
                if obj.WaitTime >= obj.DeadTime
                    obj.Status = -1;
                end
            end
            obj.History = [obj.History,obj.Status];
        end
    end
end

