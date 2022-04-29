%% ��ʼ��
clear all
close all
clc

%% ��Ϣ����
Time = input('>>������ģ��ʱ����min����');
MaxPeoNum = input('>>�������������ޣ�');
MeanInterval = input('>>��������Ա����ƽ�����ʱ�䣨ʱ��/��ʱ��������������min����');
NumofHosDept = input('>>�������м�����ң�');
Dept = cell(1,NumofHosDept);
for i = 1:NumofHosDept
    Name = input(['  >>�������' num2str(i) '����ҵ����ƣ��������ţ���']);
    Number = input(['  >>�������' num2str(i) '����ҵĸ�����']);
    RequiredTime = input(['  >>�������' num2str(i) '����ҵ�����ʱ�䣺']);
    Dept{1,i} = HosDept(Name,Number,RequiredTime);
end
NumofHurLev = input('>>�������м�������ȼ���');
P_HurLev = zeros(1,NumofHurLev);
DeadTime = zeros(1,NumofHurLev);
DeptProcedure = cell(1,NumofHurLev);
disp(['ת������' num2str(NumofHosDept+1) '�С�' num2str(NumofHosDept+2) '�о��󣩸�ʽ��']);
disp(['         |ȥA����|ȥB����|����|��Ժ|����' newline ' �����  |' newline '��A���Һ�|' newline '��B���Һ�|' newline '����']);
while ~(sum(P_HurLev) == 1)
    for i = 1:NumofHurLev
        P_HurLev(1,i) = input(['>>�������' num2str(i) '������ĸ��ʣ�']);
        DeadTime(1,i) = input('  >>�����������ȼ��µ������ȴ�ʱ�䣨min����');
        DeptProcedure{1,i} = input('  >>�����������ȼ��µ�ת������');
        while ~isequal(round(sum(DeptProcedure{1,i},2),5),ones(NumofHosDept+1,1))
            disp('    ת������ĳ�еĸ��ʺͲ�Ϊ1������������');
            DeptProcedure{1,i} = input('  >>�����������ȼ��µ�ת������');
        end
    end
    if ~(round(sum(P_HurLev),5) == 1)
        disp('������ȼ��ĸ��ʺͲ�Ϊ1������������');
    end
end

%% ��ʱ��ѭ��
tic
AllPatient = [];
RecoverdPatient = [];
DeadPatient = [];
StatNum = zeros(3,Time);  % ��һ�У�����ڶ��У������������У�����
DeadStat = zeros(NumofHurLev,Time);
History = cell(1,NumofHosDept);
NumofPat = 0;
WaitList = cell(1,NumofHosDept);
for t = 1:Time
    % 1.�²��˵��ﲢ�����Ӧ���ҵĵȴ�����
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
    
    % 2.�ȴ����˽�����п���
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
    
    % 3.ʱ�侭��1min������/�ȴ���
    DeptDone = cell(1,NumofHosDept);
    for i = 1:NumofPat
        PatTimeGo(AllPatient(1,i));
    end
    for i = 1:NumofHosDept
        DeptDone{1,i} = HosTimeGo(Dept{1,i});
    end
    
    % 4.������ϵ����뿪���Ҳ��������
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
                    DeadStat(PtDnLv,t) = DeadStat(PtDnLv,t) + 1;  % ��¼���ߵ�����ȼ�
                else
                    AllPatient(1,PatDone).Status = AimDept + 0.5;
                    WaitList{1,AimDept} = [WaitList{1,AimDept},AllPatient(1,PatDone).Name];
                end
            end
        end
    end    
end
toc

%% ���ͳ��
CumuNum = zeros(3,Time);  % ��һ�У�����ڶ��У������������У�����
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

disp(['��������Ϊ' num2str(DeadNum) '��']);
for lv = 1:NumofHurLev
    disp(['��' num2str(lv) '��������������Ϊ��' num2str(DeadCumu(lv,Time))]);
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

