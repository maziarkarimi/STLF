function [result]=MinusN_M(number,matrix)
for i=1:size(matrix,1)
    for j=1:size(matrix,2)
        result(i,j)=number-matrix(i,j);
    end
end