disp('输入完毕！开始进行模拟……');
tic
AllPatient = cell(1,MaxPatNum);
StatNum = cell(1,NumofHurLev+1); % 每个元素是矩阵，第一个矩阵：所有伤情等级；其他矩阵：各伤情等级
for i = 1:NumofHurLev+1
    StatNum{1,i} = zeros(4,Time);% 矩阵的第一行：到达；第二行：治愈；第三行：因等待死亡；第四行：因治疗失败死亡
end
HospitalHistory = cell(1,NumofHosDept);
for i = 1:NumofHosDept
    HospitalHistory{1,i} = zeros(AllDept{1,i}.Number,Time); % 每个元素是矩阵，记录一个科室；行：该科室各诊室；列：时间
end
NumofPat = 0;
WaitList = cell(1,NumofHosDept);
for t = 1:Time
    % 1.新病人到达并进入对应科室的等待队列
    if NumofPat < MaxPatNum
        StatNum{1,1}(1,t) = random('poisson',1/MeanInterval);
        if StatNum{1,1}(1,t) > 0
            for i = 1:StatNum{1,1}(1,t)
                NumofPat = NumofPat + 1;
                HurtLevel = RandomChoose(P_HurLev);
                StatNum{1,HurtLevel+1}(1,t) = StatNum{1,HurtLevel+1}(1,t) + 1;
                AimDept = RandomChoose(HosMatrix{1,HurtLevel}(1,:));
                AllPatient{1,NumofPat} = Patient(NumofPat,HurtLevel,AimDept+0.5,t,DeadTime(1,HurtLevel));
                WaitList{1,AimDept} = [WaitList{1,AimDept},NumofPat];
            end
        end
    end
    
    % 2.等待的人进入空闲科室
    for i = 1:NumofHosDept
        while ~isempty(WaitList{1,i})
            RoomNum = Use(AllDept{i});
            if RoomNum == 0
                break
            end
            CurrPat = WaitList{1,i}(1,1);
            AllPatient{1,CurrPat}.Status = i;
            HospitalHistory{1,i}(RoomNum,t:(t+AllDept{1,i}.RequiredTime-1)) = AllPatient{1,CurrPat}.Name;
            WaitList{1,i} = WaitList{1,i}(1,2:end);
        end
    end
    
    % 3.时间经过1min（治疗/等待）
    DeptDone = cell(1,NumofHosDept);
    for i = 1:NumofPat
        isdead = PatTimeGo(AllPatient{1,i});
        if isdead > 0
            StatNum{1,AllPatient{1,i}.Level+1}(3,t) = StatNum{1,AllPatient{1,i}.Level+1}(3,t) + 1;
            WaitList{1,isdead}(WaitList{1,isdead}==i) = [];
        end
    end
    for i = 1:NumofHosDept
        DeptDone{1,i} = HosTimeGo(AllDept{1,i});
    end
    
    % 4.治疗完毕的人离开科室并产生结果
    for i = 1:NumofHosDept
        NumofDone = size(DeptDone{1,i},2);
        if NumofDone > 0
            for j = 1:NumofDone
                PatDone = HospitalHistory{1,i}(DeptDone{1,i}(1,j),t-1);
                PtDnLv = AllPatient{1,PatDone}.Level;
                AimDept = RandomChoose(HosMatrix{1,PtDnLv}(i+1,:));
                if AimDept == (NumofHosDept+1)
                    AllPatient{1,PatDone}.Status = 0;
                    StatNum{1,AllPatient{1,PatDone}.Level+1}(2,t) = StatNum{1,AllPatient{1,PatDone}.Level+1}(2,t) + 1;
                elseif AimDept == (NumofHosDept+2)
                    AllPatient{1,PatDone}.Status = -1;
                    StatNum{1,AllPatient{1,PatDone}.Level+1}(4,t) = StatNum{1,AllPatient{1,PatDone}.Level+1}(4,t) + 1;
                else
                    AllPatient{1,PatDone}.Status = AimDept + 0.5;
                    WaitList{1,AimDept} = [WaitList{1,AimDept},AllPatient{1,PatDone}.Name];
                end
            end
        end
    end
    
    % 5.将元胞数组Stat中各伤情等级的人数统计矩阵（第2个~最后1个）相加得到总的人数统计矩阵（第1个）
    for i = 2:NumofHurLev+1
        StatNum{1,1}(2,t) = StatNum{1,1}(2,t) + StatNum{1,i}(2,t); % 治愈
        StatNum{1,1}(3,t) = StatNum{1,1}(3,t) + StatNum{1,i}(3,t); % 因等待死亡
        StatNum{1,1}(4,t) = StatNum{1,1}(4,t) + StatNum{1,i}(4,t); % 因治疗失败死亡
    end
end
toc
disp('模拟完毕！…');