%% ��ʼ��
clearvars
close all
clc

%% ��Ϣ����
SimInput
% Time = input('>>������ģ��ʱ����min����');
% MaxPatNum = input('>>�������������ޣ�');
% MeanInterval = input('>>��������Ա����ƽ�����ʱ�䣨ʱ��/��ʱ��������������min����');
% NumofHosDept = input('>>�������м�����ң�');
% AllDept = cell(1,NumofHosDept);
% for i = 1:NumofHosDept
%     Name = input(['  >>�������' num2str(i) '����ҵ����ƣ��������ţ���']);
%     Number = input(['  >>�������' num2str(i) '����ҵĸ�����']);
%     RequiredTime = input(['  >>�������' num2str(i) '����ҵ�����ʱ�䣺']);
%     AllDept{1,i} = HosDept(Name,Number,RequiredTime);
% end
% NumofHurLev = input('>>�������м�������ȼ���');
% P_HurLev = zeros(1,NumofHurLev);
% DeadTime = zeros(1,NumofHurLev);
% HosMatrix = cell(1,NumofHurLev);
% disp(['ת������' num2str(NumofHosDept+1) '�С�' num2str(NumofHosDept+2) '�о��󣩸�ʽ��']);
% disp(['         |ȥA����|ȥB����|����|��Ժ|����' newline ' �����  |' newline '��A���Һ�|' newline '��B���Һ�|' newline '����']);
% while ~(sum(P_HurLev) == 1)
%     for i = 1:NumofHurLev
%         P_HurLev(1,i) = input(['>>�������' num2str(i) '������ĸ��ʣ�']);
%         DeadTime(1,i) = input('  >>�����������ȼ��µ������ȴ�ʱ�䣨min����');
%         HosMatrix{1,i} = input('  >>�����������ȼ��µ�ת������');
%         while ~isequal(round(sum(HosMatrix{1,i},2),5),ones(NumofHosDept+1,1))
%             disp('    ת������ĳ�еĸ��ʺͲ�Ϊ1������������');
%             HosMatrix{1,i} = input('  >>�����������ȼ��µ�ת������');
%         end
%     end
%     if ~(round(sum(P_HurLev),5) == 1)
%         disp('������ȼ��ĸ��ʺͲ�Ϊ1������������');
%     end
% end

%% ��ʱ��ѭ��
SimRun
% disp('������ϣ���ʼ����ģ�⡭��');
% tic
% AllPatient = cell(1,MaxPatNum);
% StatNum = cell(1,NumofHurLev+1); % ÿ��Ԫ���Ǿ��󣬵�һ��������������ȼ����������󣺸�����ȼ�
% for i = 1:NumofHurLev+1
%     StatNum{1,i} = zeros(4,Time);% ����ĵ�һ�У�����ڶ��У������������У���ȴ������������У�������ʧ������
% end
% HospitalHistory = cell(1,NumofHosDept);
% for i = 1:NumofHosDept
%     HospitalHistory{1,i} = zeros(AllDept{1,i}.Number,Time); % ÿ��Ԫ���Ǿ��󣬼�¼һ�����ң��У��ÿ��Ҹ����ң��У�ʱ��
% end
% NumofPat = 0;
% WaitList = cell(1,NumofHosDept);
% for t = 1:Time
%     % 1.�²��˵��ﲢ�����Ӧ���ҵĵȴ�����
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
%     % 2.�ȴ����˽�����п���
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
%     % 3.ʱ�侭��1min������/�ȴ���
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
%     % 4.������ϵ����뿪���Ҳ��������
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
%     % 5.��Ԫ������Stat�и�����ȼ�������ͳ�ƾ��󣨵�2��~���1������ӵõ��ܵ�����ͳ�ƾ��󣨵�1����
%     for i = 2:NumofHurLev+1
%         StatNum{1,1}(2,t) = StatNum{1,1}(2,t) + StatNum{1,i}(2,t); % ����
%         StatNum{1,1}(3,t) = StatNum{1,1}(3,t) + StatNum{1,i}(3,t); % ��ȴ�����
%         StatNum{1,1}(4,t) = StatNum{1,1}(4,t) + StatNum{1,i}(4,t); % ������ʧ������
%     end
% end
% toc
% disp('ģ����ϣ���');

%% ���ͳ��
SimResult
% % �� TotalNum����StatNum��StatNum��ÿ���ӵ�����������TotalNum��ÿ���ӵ��ۼ�����
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
% % �� �����в��˵���ʷ����Ϊһ������
% PatientHistory = zeros(NumofPat,Time);
% for i = 1:NumofPat
%     CurrPat = AllPatient{1,i};
%     PatientHistory(i,CurrPat.ArriveTime:end) = CurrPat.History;
% end
% % �� ��ʾ���
% disp(['�ܼ�����' num2str(TotalNum{1,1}(1,Time)) '��']);
% disp(['��ȴ���������Ϊ' num2str(TotalNum{1,1}(3,Time)) '��']);
% disp(['������ʧ����������Ϊ' num2str(TotalNum{1,1}(4,Time)) '��']);
% for lv = 1:NumofHurLev
%     disp(['��' num2str(lv) '�������У�']);
%     disp(['������Ϊ��' num2str(TotalNum{1,lv+1}(1,Time))]);
%     disp(['��ȴ���������Ϊ��' num2str(TotalNum{1,lv+1}(3,Time))]);
%     disp(['������ʧ����������Ϊ��' num2str(TotalNum{1,lv+1}(4,Time))]);
% end
% % �� ��ͼ
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

