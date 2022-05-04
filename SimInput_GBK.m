Time = input('>>请输入模拟时长（min）：');
MaxPatNum = input('>>请输入人数上限：');
MeanInterval = input('>>请输入人员到达平均间隔时间（时长/该时间内来的人数，min）：');
NumofHosDept = input('>>请输入有几类科室：');
AllDept = cell(1,NumofHosDept);
for i = 1:NumofHosDept
    Name = input(['  >>请输入第' num2str(i) '类科室的名称（带单引号）：']);
    Number = input(['  >>请输入第' num2str(i) '类科室的个数：']);
    RequiredTime = input(['  >>请输入第' num2str(i) '类科室的治疗时间：']);
    AllDept{1,i} = HosDept(Name,Number,RequiredTime);
end
NumofHurLev = input('>>请输入有几个伤情等级：');
P_HurLev = zeros(1,NumofHurLev);
DeadTime = zeros(1,NumofHurLev);
HosMatrix = cell(1,NumofHurLev);
disp(['转换矩阵（' num2str(NumofHosDept+1) '行×' num2str(NumofHosDept+2) '列矩阵）格式：']);
disp(['         |去A科室|去B科室|……|出院|死亡' newline ' 到达后  |' newline '出A科室后|' newline '出B科室后|' newline '……']);
while ~(sum(P_HurLev) == 1)
    for i = 1:NumofHurLev
        P_HurLev(1,i) = input(['>>请输入第' num2str(i) '级伤情的概率：']);
        DeadTime(1,i) = input('  >>请输入该伤情等级下的死亡等待时间（min）：');
        HosMatrix{1,i} = input('  >>请输入该伤情等级下的转换矩阵：');
        while ~isequal(round(sum(HosMatrix{1,i},2),5),ones(NumofHosDept+1,1))
            disp('    转换矩阵某行的概率和不为1，请重新输入');
            HosMatrix{1,i} = input('  >>请输入该伤情等级下的转换矩阵：');
        end
    end
    if ~(round(sum(P_HurLev),5) == 1)
        disp('各伤情等级的概率和不为1，请重新输入');
    end
end