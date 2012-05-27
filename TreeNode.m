classdef TreeNode < handle
    properties
        left;
        right;
        isLeaf = false;
        decider;
        distribution;
        level = 0;
        node.id = -1;
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

