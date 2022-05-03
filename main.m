%% 初始化
clearvars
close all
clc

%% 信息输入
SimInput
% Time = input('>>请输入模拟时长（min）：');
% MaxPatNum = input('>>请输入人数上限：');
% MeanInterval = input('>>请输入人员到达平均间隔时间（时长/该时间内来的人数，min）：');
% NumofHosDept = input('>>请输入有几类科室：');
% AllDept = cell(1,NumofHosDept);
% for i = 1:NumofHosDept
%     Name = input(['  >>请输入第' num2str(i) '类科室的名称（带单引号）：']);
%     Number = input(['  >>请输入第' num2str(i) '类科室的个数：']);
%     RequiredTime = input(['  >>请输入第' num2str(i) '类科室的治疗时间：']);
%     AllDept{1,i} = HosDept(Name,Number,RequiredTime);
% end
% NumofHurLev = input('>>请输入有几个伤情等级：');
% P_HurLev = zeros(1,NumofHurLev);
% DeadTime = zeros(1,NumofHurLev);
% HosMatrix = cell(1,NumofHurLev);
% disp(['转换矩阵（' num2str(NumofHosDept+1) '行×' num2str(NumofHosDept+2) '列矩阵）格式：']);
% disp(['         |去A科室|去B科室|……|出院|死亡' newline ' 到达后  |' newline '出A科室后|' newline '出B科室后|' newline '……']);
% while ~(sum(P_HurLev) == 1)
%     for i = 1:NumofHurLev
%         P_HurLev(1,i) = input(['>>请输入第' num2str(i) '级伤情的概率：']);
%         DeadTime(1,i) = input('  >>请输入该伤情等级下的死亡等待时间（min）：');
%         HosMatrix{1,i} = input('  >>请输入该伤情等级下的转换矩阵：');
%         while ~isequal(round(sum(HosMatrix{1,i},2),5),ones(NumofHosDept+1,1))
%             disp('    转换矩阵某行的概率和不为1，请重新输入');
%             HosMatrix{1,i} = input('  >>请输入该伤情等级下的转换矩阵：');
%         end
%     end
%     if ~(round(sum(P_HurLev),5) == 1)
%         disp('各伤情等级的概率和不为1，请重新输入');
%     end
% end

%% 按时间循环
SimRun
% disp('输入完毕！开始进行模拟……');
% tic
% AllPatient = cell(1,MaxPatNum);
% StatNum = cell(1,NumofHurLev+1); % 每个元素是矩阵，第一个矩阵：所有伤情等级；其他矩阵：各伤情等级
% for i = 1:NumofHurLev+1
%     StatNum{1,i} = zeros(4,Time);% 矩阵的第一行：到达；第二行：治愈；第三行：因等待死亡；第四行：因治疗失败死亡
% end
% HospitalHistory = cell(1,NumofHosDept);
% for i = 1:NumofHosDept
%     HospitalHistory{1,i} = zeros(AllDept{1,i}.Number,Time); % 每个元素是矩阵，记录一个科室；行：该科室各诊室；列：时间
% end
% NumofPat = 0;
% WaitList = cell(1,NumofHosDept);
% for t = 1:Time
%     % 1.新病人到达并进入对应科室的等待队列
%     if NumofPat < MaxPatNum
%         StatNum{1,1}(1,t) = random('poisson',1/MeanInterval);
%         if StatNum{1,1}(1,t) > 0
%             for i = 1:StatNum{1,1}(1,t)
%                 NumofPat = NumofPat + 1;
%                 HurtLevel = RandomChoose(P_HurLev);
%                 StatNum{1,HurtLevel+1}(1,t) = StatNum{1,HurtLevel+1}(1,t) + 1;
%                 AimDept = RandomChoose(HosMatrix{1,HurtLevel}(1,:));
%                 AllPatient{1,NumofPat} = Patient(NumofPat,HurtLevel,AimDept+0.5,t,DeadTime(1,HurtLevel));
%                 WaitList{1,AimDept} = [WaitList{1,AimDept},NumofPat];
%             end
%         end
%     end
%     
%     % 2.等待的人进入空闲科室
%     for i = 1:NumofHosDept
%         while ~isempty(WaitList{1,i})
%             RoomNum = Use(AllDept{i});
%             if RoomNum == 0
%                 break
%             end
%             CurrPat = WaitList{1,i}(1,1);
%             AllPatient{1,CurrPat}.Status = i;
%             HospitalHistory{1,i}(RoomNum,t:(t+AllDept{1,i}.RequiredTime-1)) = AllPatient{1,CurrPat}.Name;
%             WaitList{1,i} = WaitList{1,i}(1,2:end);
%         end
%     end
%     
%     % 3.时间经过1min（治疗/等待）
%     DeptDone = cell(1,NumofHosDept);
%     for i = 1:NumofPat
%         isdead = PatTimeGo(AllPatient{1,i});
%         if isdead > 0
%             StatNum{1,AllPatient{1,i}.Level+1}(3,t) = StatNum{1,AllPatient{1,i}.Level+1}(3,t) + 1;
%             WaitList{1,isdead}(WaitList{1,isdead}==i) = [];
%         end
%     end
%     for i = 1:NumofHosDept
%         DeptDone{1,i} = HosTimeGo(AllDept{1,i});
%     end
%     
%     % 4.治疗完毕的人离开科室并产生结果
%     for i = 1:NumofHosDept
%         NumofDone = size(DeptDone{1,i},2);
%         if NumofDone > 0
%             for j = 1:NumofDone
%                 PatDone = HospitalHistory{1,i}(DeptDone{1,i}(1,j),t-1);
%                 PtDnLv = AllPatient{1,PatDone}.Level;
%                 AimDept = RandomChoose(HosMatrix{1,PtDnLv}(i+1,:));
%                 if AimDept == (NumofHosDept+1)
%                     AllPatient{1,PatDone}.Status = 0;
%                     StatNum{1,AllPatient{1,PatDone}.Level+1}(2,t) = StatNum{1,AllPatient{1,PatDone}.Level+1}(2,t) + 1;
%                 elseif AimDept == (NumofHosDept+2)
%                     AllPatient{1,PatDone}.Status = -1;
%                     StatNum{1,AllPatient{1,PatDone}.Level+1}(4,t) = StatNum{1,AllPatient{1,PatDone}.Level+1}(4,t) + 1;
%                 else
%                     AllPatient{1,PatDone}.Status = AimDept + 0.5;
%                     WaitList{1,AimDept} = [WaitList{1,AimDept},AllPatient{1,PatDone}.Name];
%                 end
%             end
%         end
%     end
%     
%     % 5.将元胞数组Stat中各伤情等级的人数统计矩阵（第2个~最后1个）相加得到总的人数统计矩阵（第1个）
%     for i = 2:NumofHurLev+1
%         StatNum{1,1}(2,t) = StatNum{1,1}(2,t) + StatNum{1,i}(2,t); % 治愈
%         StatNum{1,1}(3,t) = StatNum{1,1}(3,t) + StatNum{1,i}(3,t); % 因等待死亡
%         StatNum{1,1}(4,t) = StatNum{1,1}(4,t) + StatNum{1,i}(4,t); % 因治疗失败死亡
%     end
% end
% toc
% disp('模拟完毕！…');

%% 结果统计
SimResult
% % ↓ TotalNum类似StatNum，StatNum是每分钟的新增人数，TotalNum是每分钟的累计人数
% TotalNum = cell(1,NumofHurLev+1);
% for i = 1:NumofHurLev+1
%     TotalNum{1,i} = zeros(4,Time);
% end
% for i = 1:NumofHurLev+1
%     for j = 1:4
%         TotalNum{1,i}(j,1) = StatNum{1,i}(j,1);
%         for t = 2:Time
%             TotalNum{1,i}(j,t) = TotalNum{1,i}(j,t-1) + StatNum{1,i}(j,t);
%         end
%     end
% end
% % ↓ 将所有病人的历史整合为一个矩阵
% PatientHistory = zeros(NumofPat,Time);
% for i = 1:NumofPat
%     CurrPat = AllPatient{1,i};
%     PatientHistory(i,CurrPat.ArriveTime:end) = CurrPat.History;
% end
% % ↓ 显示结果
% disp(['总计生成' num2str(TotalNum{1,1}(1,Time)) '人']);
% disp(['因等待死亡人数为' num2str(TotalNum{1,1}(3,Time)) '人']);
% disp(['因治疗失败死亡人数为' num2str(TotalNum{1,1}(4,Time)) '人']);
% for lv = 1:NumofHurLev
%     disp(['第' num2str(lv) '级伤情中：']);
%     disp(['总人数为：' num2str(TotalNum{1,lv+1}(1,Time))]);
%     disp(['因等待死亡人数为：' num2str(TotalNum{1,lv+1}(3,Time))]);
%     disp(['因治疗失败死亡人数为：' num2str(TotalNum{1,lv+1}(4,Time))]);
% end
% % ↓ 画图
% x_t = 1:Time;
% for i = 1:NumofHurLev+1
%     y_arri = TotalNum{1,i}(1,:);
%     y_reco = TotalNum{1,i}(2,:);
%     y_waitdead = TotalNum{1,i}(3,:);
%     y_faildead = TotalNum{1,i}(4,:);
%     figure
%     hold on
%     plot(x_t,y_arri,'DisplayName','Arrive')
%     plot(x_t,y_reco,'DisplayName','Recover')
%     plot(x_t,y_waitdead,'DisplayName','WaitDead')
%     plot(x_t,y_faildead,'DisplayName','FailDead')
%     legend
%     hold off
% end

