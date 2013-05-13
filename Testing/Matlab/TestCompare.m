function [ passed, diff] = TestCompare( test1,test2,epsilon )
    %TestCompare compares whether two vectors are the same in terms of size and
    %values

    passed = 0;
    diff = -1;
    if isequal(size(test1), size(test2))
        diff=sum(abs(test1(:) - test2(:)));
        if diff < epsilon
            passed = 1; 
        end
    end
end

