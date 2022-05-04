% �� TotalNum����StatNum��StatNum��ÿ���ӵ�����������TotalNum��ÿ���ӵ��ۼ�����
TotalNum = cell(1,NumofHurLev+1);
for i = 1:NumofHurLev+1
    TotalNum{1,i} = zeros(4,Time);
end
for i = 1:NumofHurLev+1
    for j = 1:4
        TotalNum{1,i}(j,1) = StatNum{1,i}(j,1);
        for t = 2:Time
            TotalNum{1,i}(j,t) = TotalNum{1,i}(j,t-1) + StatNum{1,i}(j,t);
        end
    end
end
% �� �����в��˵���ʷ����Ϊһ������
PatientHistory = zeros(NumofPat,Time);
for i = 1:NumofPat
    CurrPat = AllPatient{1,i};
    PatientHistory(i,CurrPat.ArriveTime:end) = CurrPat.History;
end
% �� ��ʾ���
disp(['�ܼ�����' num2str(TotalNum{1,1}(1,Time)) '��']);
disp(['��ȴ���������Ϊ' num2str(TotalNum{1,1}(3,Time)) '��']);
disp(['������ʧ����������Ϊ' num2str(TotalNum{1,1}(4,Time)) '��']);
for lv = 1:NumofHurLev
    disp(['��' num2str(lv) '�������У�']);
    disp(['������Ϊ��' num2str(TotalNum{1,lv+1}(1,Time))]);
    disp(['��ȴ���������Ϊ��' num2str(TotalNum{1,lv+1}(3,Time))]);
    disp(['������ʧ����������Ϊ��' num2str(TotalNum{1,lv+1}(4,Time))]);
end
% �� ��ͼ
x_t = 1:Time;
for i = 1:NumofHurLev+1
    y_arri = TotalNum{1,i}(1,:);
    y_reco = TotalNum{1,i}(2,:);
    y_waitdead = TotalNum{1,i}(3,:);
    y_faildead = TotalNum{1,i}(4,:);
    figure
    hold on
    plot(x_t,y_arri,'DisplayName','Arrive')
    plot(x_t,y_reco,'DisplayName','Recover')
    plot(x_t,y_waitdead,'DisplayName','WaitDead')
    plot(x_t,y_faildead,'DisplayName','FailDead')
    legend
    hold off
end
