function [result]=MinusM_N(matrix,number)
for i=1:size(matrix,1)
    for j=1:size(matrix,2)
        result(i,j)=matrix(i,j)-number;
    end
end