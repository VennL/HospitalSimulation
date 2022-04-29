%% 初始化
clear all
close all
clc

%% 信息输入
Time = input('>>请输入模拟时长（min）：');
MaxPeoNum = input('>>请输入人数上限：');
MeanInterval = input('>>请输入人员到达平均间隔时间（时长/该时间内来的人数，min）：');
NumofHosDept = input('>>请输入有几类科室：');
Dept = cell(1,NumofHosDept);
for i = 1:NumofHosDept
    Name = input(['  >>请输入第' num2str(i) '类科室的名称（带单引号）：']);
    Number = input(['  >>请输入第' num2str(i) '类科室的个数：']);
    RequiredTime = input(['  >>请输入第' num2str(i) '类科室的治疗时间：']);
    Dept{1,i} = HosDept(Name,Number,RequiredTime);
end
NumofHurLev = input('>>请输入有几个伤情等级：');
P_HurLev = zeros(1,NumofHurLev);
DeadTime = zeros(1,NumofHurLev);
DeptProcedure = cell(1,NumofHurLev);
disp(['转换矩阵（' num2str(NumofHosDept+1) '行×' num2str(NumofHosDept+2) '列矩阵）格式：']);
disp(['         |去A科室|去B科室|……|出院|死亡' newline ' 到达后  |' newline '出A科室后|' newline '出B科室后|' newline '……']);
while ~(sum(P_HurLev) == 1)
    for i = 1:NumofHurLev
        P_HurLev(1,i) = input(['>>请输入第' num2str(i) '级伤情的概率：']);
        DeadTime(1,i) = input('  >>请输入该伤情等级下的死亡等待时间（min）：');
        DeptProcedure{1,i} = input('  >>请输入该伤情等级下的转换矩阵：');
        while ~isequal(round(sum(DeptProcedure{1,i},2),5),ones(NumofHosDept+1,1))
            disp('    转换矩阵某行的概率和不为1，请重新输入');
            DeptProcedure{1,i} = input('  >>请输入该伤情等级下的转换矩阵：');
        end
    end
    if ~(round(sum(P_HurLev),5) == 1)
        disp('各伤情等级的概率和不为1，请重新输入');
    end
end

%% 按时间循环
tic
AllPatient = [];
RecoverdPatient = [];
DeadPatient = [];
StatNum = zeros(3,Time);  % 第一行：到达；第二行：治愈；第三行：死亡
DeadStat = zeros(NumofHurLev,Time);
History = cell(1,NumofHosDept);
NumofPat = 0;
WaitList = cell(1,NumofHosDept);
for t = 1:Time
    % 1.新病人到达并进入对应科室的等待队列
    if sum(StatNum(1,:)) < MaxPeoNum
        StatNum(1,t) = random('poisson',1/MeanInterval);
        if StatNum(1,t) > 0
            for i = 1:StatNum(1,t)
                NumofPat = NumofPat + 1;
                HurtLevel = RandomChoose(P_HurLev);
                AimDept = RandomChoose(DeptProcedure{1,HurtLevel}(1,:));
                NewPatient = Patient(NumofPat,HurtLevel,AimDept+0.5,DeadTime(1,HurtLevel));
                AllPatient = [AllPatient,NewPatient];
                WaitList{1,AimDept} = [WaitList{1,AimDept},NewPatient.Name];
            end
        end
    end
    
    % 2.等待的人进入空闲科室
    for i = 1:NumofHosDept
        while ~isempty(WaitList{1,i})
            RoomNum = Use(Dept{i});
            if RoomNum == 0
                break
            end
            CurrPat = WaitList{1,i}(1,1);
            AllPatient(1,CurrPat).Status = i;
            History{1,i}(RoomNum,t:(t+Dept{1,i}.RequiredTime-1)) = AllPatient(1,CurrPat).Name;
            WaitList{1,i} = WaitList{1,i}(1,2:end);
        end
    end
    
    % 3.时间经过1min（治疗/等待）
    DeptDone = cell(1,NumofHosDept);
    for i = 1:NumofPat
        PatTimeGo(AllPatient(1,i));
    end
    for i = 1:NumofHosDept
        DeptDone{1,i} = HosTimeGo(Dept{1,i});
    end
    
    % 4.治疗完毕的人离开科室并产生结果
    for i = 1:NumofHosDept
        NumofDone = size(DeptDone{1,i},2);
        if NumofDone > 0
            for j = 1:NumofDone
                PatDone = History{1,i}(DeptDone{1,i}(1,j),t-1);
                PtDnLv = AllPatient(1,PatDone).Level;
                AimDept = RandomChoose(DeptProcedure{1,PtDnLv}(i+1,:));
                if AimDept == (NumofHosDept+1)
                    AllPatient(1,PatDone).Status = 0;
                    RecoverdPatient = [RecoverdPatient,AllPatient(1,PatDone)];
                    StatNum(2,t) = StatNum(2,t) + 1;
                elseif AimDept == (NumofHosDept+2)
                    AllPatient(1,PatDone).Status = -1;
                    DeadPatient = [DeadPatient,AllPatient(1,PatDone)];
                    StatNum(3,t) = StatNum(3,t) + 1;
                    DeadStat(PtDnLv,t) = DeadStat(PtDnLv,t) + 1;  % 记录死者的伤情等级
                else
                    AllPatient(1,PatDone).Status = AimDept + 0.5;
                    WaitList{1,AimDept} = [WaitList{1,AimDept},AllPatient(1,PatDone).Name];
                end
            end
        end
    end    
end
toc

%% 结果统计
CumuNum = zeros(3,Time);  % 第一行：到达；第二行：治愈；第三行：死亡
for j = 1:3
    CumuNum(j,1) = StatNum(j,1);
    for t = 2:Time
        CumuNum(j,t) = CumuNum(j,t-1) + StatNum(j,t);
    end
end
DeadNum = CumuNum(3,Time);
DeadCumu = zeros(NumofHurLev,Time);
for lv = 1:NumofHurLev
    DeadCumu(lv,1) = DeadStat(lv,1);
    for t = 2:Time
        DeadCumu(lv,t) = DeadCumu(lv,t-1) + DeadStat(lv,t);
    end
end

disp(['死亡人数为' num2str(DeadNum) '人']);
for lv = 1:NumofHurLev
    disp(['第' num2str(lv) '级伤情死亡人数为：' num2str(DeadCumu(lv,Time))]);
end
x_t = 1:Time;
y_arri = CumuNum(1,:);
y_reco = CumuNum(2,:);
y_dead = CumuNum(3,:);
figure
hold on
plot(x_t,y_arri,'DisplayName','Arrive')
plot(x_t,y_reco,'DisplayName','Recover')
plot(x_t,y_dead,'DisplayName','Dead')
legend
hold off

figure
hold on
for lv = 1:NumofHurLev
    y_lv_dead = DeadCumu(lv,:);
    plot(x_t,y_lv_dead,'DisplayName',num2str(lv))
end
legend
hold off

