Time = input('>>������ģ��ʱ����min����');
MaxPatNum = input('>>�������������ޣ�');
MeanInterval = input('>>��������Ա����ƽ�����ʱ�䣨ʱ��/��ʱ��������������min����');
NumofHosDept = input('>>�������м�����ң�');
AllDept = cell(1,NumofHosDept);
for i = 1:NumofHosDept
    Name = input(['  >>�������' num2str(i) '����ҵ����ƣ��������ţ���']);
    Number = input(['  >>�������' num2str(i) '����ҵĸ�����']);
    RequiredTime = input(['  >>�������' num2str(i) '����ҵ�����ʱ�䣺']);
    AllDept{1,i} = HosDept(Name,Number,RequiredTime);
end
NumofHurLev = input('>>�������м�������ȼ���');
P_HurLev = zeros(1,NumofHurLev);
DeadTime = zeros(1,NumofHurLev);
HosMatrix = cell(1,NumofHurLev);
disp(['ת������' num2str(NumofHosDept+1) '�С�' num2str(NumofHosDept+2) '�о��󣩸�ʽ��']);
disp(['         |ȥA����|ȥB����|����|��Ժ|����' newline ' �����  |' newline '��A���Һ�|' newline '��B���Һ�|' newline '����']);
while ~(sum(P_HurLev) == 1)
    for i = 1:NumofHurLev
        P_HurLev(1,i) = input(['>>�������' num2str(i) '������ĸ��ʣ�']);
        DeadTime(1,i) = input('  >>�����������ȼ��µ������ȴ�ʱ�䣨min����');
        HosMatrix{1,i} = input('  >>�����������ȼ��µ�ת������');
        while ~isequal(round(sum(HosMatrix{1,i},2),5),ones(NumofHosDept+1,1))
            disp('    ת������ĳ�еĸ��ʺͲ�Ϊ1������������');
            HosMatrix{1,i} = input('  >>�����������ȼ��µ�ת������');
        end
    end
    if ~(round(sum(P_HurLev),5) == 1)
        disp('������ȼ��ĸ��ʺͲ�Ϊ1������������');
    end
end