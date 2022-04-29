function Chosen = RandomChoose(P)
if ~(round(sum(P),5) == 1)
    error('Error: The sum of probability does not equal 100%');
end
option = size(P,2);
rdn = rand;
sum_p = 0;
for i = 1:option
    sum_p = sum_p + P(1,i);
    if rdn <= sum_p
        Chosen = i;
        return
    end
end
end