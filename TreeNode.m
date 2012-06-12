classdef TreeNode < handle
    properties
        left;
        right;
        isLeaf = false;
        % decider is a struct that holds
        % .method = string specifying which function to cuse in computeFeature.m
        % .feat = rows, cols, and channels to use
        % .threshold 
        decider;
        distribution;
        level = -1;
        id = -1;
    end
    
    methods
        function node = TreeNode(distribution)
            if nargin > 0
                node.distribution = distribution;
                node.isLeaf = true;
            end
        end
    end    
end

