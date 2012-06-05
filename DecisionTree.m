classdef DecisionTree < handle
    properties(SetAccess = 'private') % fields with default vals
        maxDepth = 10;
        numFeature = 400;
        numThreshold = 5;
        numClass = 21;
        factory = {@addTwo, @subAbs, @sub, @unary};
        labelWeights = ones(numClass, 1);
        root;
        numNodes = 1;
    end
    
    methods(Static)
        function DT = load(fname)
            load(fname);
            DT = DecisionTree();
        end
    end
    %%%%%%%%%% Public Methods %%%%%%%%%%
    methods        
        function DT = DecisionTree(maxDepth, numFeature, numThreshold, ...
                                   numClass, factory, labelWeights)
            if nargin > 0
                DT.maxDepth = maxDepth;
                DT.numFeature = numFeature;
                DT.numThreshold = numThreshold;
                DT.numClass = numClass;
                DT.factory = factory;
                DT.labelWeights = labelWeights;
            end
        end
        
        function trainDepthFirst(data)
            DT.root = computeDepthFirst(TreeNode(), data, 0);            
        end
        
        % fill the tree with all of training data
        function fillAll(data)
            fill(root, data);
        end              
        
        function dist = classify(point)
            dist = findLeaf(root, point);
        end
        
        function bost = computeBost(data)
            bost = sparse(numNodes, 1);
            bost = findCounts(root, bost, data);
        end
        % function save(DT, fname)
        %     DT = printNode(root)
        % end
    end 
    %%%%%%%%%% end of Public methods %%%%%%%%%%
    
    %%%%%%%%%% Private methods %%%%%%%%%%
    methods(Access=private)
        %%%%%%%%%% for learning a tree %%%%%%%%%%
        function node = computeDepthFirst(node, data, depth)
            if isempty(data), return, end
            if depth == maxDepth || allSameClass(data)
                node.isLeaf = True;
                node.distribution = computeDistribution(data);
                return;
            end
            % if not leaf, find the best split
            bestScore = -Inf; bestDecider = [];
            numFactory = numel(factory);
            for i = 1:numFeature
                decider = factory{mod(i, numFactory)}
                values = computeFeature(decider, data);
                [score, threshold] = computeBestThreshold(values, data);
                if score > bestScore
                    bestScore = score;
                    bestDecider.feat = decider;
                    bestDecider.threshold = threshold;
                end            
            end            
            [leftData, rightData] = splitPoints(bestDecider, data);
            node.id = numNodes;
            numNodes = numNodes + 1;
            node.decider = bestDecider;
            node.left = computeDepthFirst(TreeNode(), leftData, depth+1);
            node.right = computeDepthFirst(TreeNode(), rightData, depth+1);
        end
        
        function [bestScore, bestThreshold] = computeBestThreshold(values, labels)
            % candidate threshold sampled from this values gaussian
            thresholds = randn(numThreshold).*std(values) + mean(values);
            N = numel(values);
            infogains = zeros(numThreshold, 1);
            for i = 1:numThreshold
                Linds = find(values < thresholds(i));
                Rinds = 1:N; Rinds(Linds) = [];                
                LDist = 1/numel(Linds).*hist(labels(Linds), numClass);
                RDist = 1/numel(Rinds).*hist(labels(Rinds), numClass);
                [EL, ER] = entropy(LDist, RDist);
                infogains(i) = -1/N*(numel(Linds)*EL + numel(Rinds)*ER);
            end
            [bestScore, bestind] = max(infogains);
            bestThreshold = thresholds(bestind);
        end
        
        % computes the expected gain in information 
        function [E1, E2] = entropy(h1, h2)
            E1 = 0; E2 = 0;
            for i=1:numClass
                E1 = E1 - h1(i)*log2(h1(i));
                E2 = E2 - h2(i)*log2(h2(i));
            end
        end
        
        % decider is a function handle, data is a set of d x d patches
        % returns a scalar value for each data point.
        function [values] = computeFeature(decider, data)
            values = zeros(numel(data), 1);
        end
        
        % returns if all datum has the same label
        function allSame = allSameClass(data)
            
        end
        
        function [left right] = splitPoints(decider, thresholds, data)
            values = computeFeature(decider.feat, data);
            Linds = find(values < decider.threshold);
            Rinds = 1:N; Rinds(Linds) = [];                
            left = data(Linds);
            right = data(Rinds);
        end

        %%fill the tree with data to build distributions at each leaf
        function fill(node, data)
            for d = data
                node.distribution(d.label, :) = node.distribution(d.label,:)  + 1;
            end
            if ~node.isLeaf
                [leftData, rightData] = splitPoints(node.decider, data);
                if ~isempty(leftData), fill(node.left, leftData),end
                if ~isempty(rightData), fill(node.right, rightData),end
            end
        end            
        function node = findLeaf(node, point)
            if node.isLeaf, return , end
            value = computeFeature(node.decider.feat, point);
            if value < node.decider.threshold % left
                findLeaf(node.left, point);
            else 
                findLeaf(node.right, point);
            end
        end
        
        function bost = findCounts(node, bost, data)
           % update the count by the total number of 
            node.id;
            bost(node.id) = numel(data);
            if ~node.isLeaf
                [leftData, rightData] = splitPoints(node.decider, data);
                if ~isempty(leftData), findCounts(node.left, leftData),end
                if ~isempty(rightData), findCounts(node.right, rightData),end                
            end
        end

        % % pre-order traversal
        % function str = printNode(node)
        %     node.id
        % end        
    end
    %%%%%%%%%% end of Private methods %%%%%%%%%%        
end

    
    
