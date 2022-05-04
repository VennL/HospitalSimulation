% ↓ TotalNum类似StatNum，StatNum是每分钟的新增人数，TotalNum是每分钟的累计人数
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
% ↓ 将所有病人的历史整合为一个矩阵
PatientHistory = zeros(NumofPat,Time);
for i = 1:NumofPat
    CurrPat = AllPatient{1,i};
    PatientHistory(i,CurrPat.ArriveTime:end) = CurrPat.History;
end
% ↓ 显示结果
disp(['总计生成' num2str(TotalNum{1,1}(1,Time)) '人']);
disp(['因等待死亡人数为' num2str(TotalNum{1,1}(3,Time)) '人']);
disp(['因治疗失败死亡人数为' num2str(TotalNum{1,1}(4,Time)) '人']);
for lv = 1:NumofHurLev
    disp(['第' num2str(lv) '级伤情中：']);
    disp(['总人数为：' num2str(TotalNum{1,lv+1}(1,Time))]);
    disp(['因等待死亡人数为：' num2str(TotalNum{1,lv+1}(3,Time))]);
    disp(['因治疗失败死亡人数为：' num2str(TotalNum{1,lv+1}(4,Time))]);
end
% ↓ 画图
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
