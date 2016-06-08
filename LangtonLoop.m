clear all; 
close all;
clc;
% Set up variables.
FigureDim = 64;
RunTime = 200;

% Create the Colormap to map the number and the color.
%      0         1        2         3        4         5        6      7
%     black    blue      red      green    yellow   pink     white    cyan 
map=[[0 0 0]; [0 0 1]; [1 0 0]; [0 1 0]; [1 1 0]; [1 0 1]; [1 1 1]; [0 1 1]];

% Langton's loop
loop = [
        [0,2,2,2,2,2,2,2,2,0,0,0,0,0,0];
        [2,1,7,0,1,4,0,1,4,2,0,0,0,0,0];
        [2,0,2,2,2,2,2,2,0,2,0,0,0,0,0];
        [2,7,2,0,0,0,0,2,1,2,0,0,0,0,0];
        [2,1,2,0,0,0,0,2,1,2,0,0,0,0,0];
        [2,0,2,0,0,0,0,2,1,2,0,0,0,0,0];
        [2,7,2,0,0,0,0,2,1,2,0,0,0,0,0];
        [2,1,2,2,2,2,2,2,1,2,2,2,2,2,0];
        [2,0,7,1,0,7,1,0,7,1,1,1,1,1,2];
        [0,2,2,2,2,2,2,2,2,2,2,2,2,2,0]
       ];
   
% Place loop on CA (roughly middle)
ca = zeros(FigureDim,FigureDim);
ca(FigureDim/2-5:FigureDim/2+4,FigureDim/2-12:FigureDim/2+2) = loop; 
   
% Read update table
table_file = 'langton.txt';  % Store the update rules.
table = fopen(table_file,'r');
vec = fscanf(table,'%d %d %d %d %d %d');
update = vec2mat(vec,6);
   
% Run CA:
figure
colormap(map)
for TimeIndex = 0:RunTime   
    % Create frame image
    imagesc(ca,[0 8])
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    colorbar   
    pause(0.01) 
    % Update CA
    new_ca = zeros(FigureDim,FigureDim); 
    for i = 2:FigureDim-1   % leave out edges
        for j = 2:FigureDim-1              
            states = zeros(4,5);   % Stores state in all possible rotations      
            %              centre, top,      right,    bottom,   left
            states(1,:) = [ca(i,j) ca(i-1,j) ca(i,j+1) ca(i+1,j) ca(i,j-1)];
            %              centre, left,     top,      right,    bottom
            states(2,:) = [ca(i,j) ca(i,j-1) ca(i-1,j) ca(i,j+1) ca(i+1,j)];
            %              centre, bottom,   left,     top,      right
            states(3,:) = [ca(i,j) ca(i+1,j) ca(i,j-1) ca(i-1,j) ca(i,j+1)];
            %              centre, right,    bottom,   left,     top
            states(4,:) = [ca(i,j) ca(i,j+1) ca(i+1,j) ca(i,j-1) ca(i-1,j)];
            
            % Ignore state [0 0 0 0 0]
            if sum(states(1,:)) ~= 0
                % Find rule in the update table
                for k = 1:4
                    position = find(all(bsxfun(@eq,update(:,1:5),states(k,:)),2));
                    if length(position) > 1
                        position = position(1);
                    end
                    if ~isempty(position)
                        new_ca(i,j) = update(position,6);
                        break;
                    end
                end
            end                 
        end
    end    
    ca = new_ca;       
end
