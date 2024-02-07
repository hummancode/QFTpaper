function [w_general] = merge_frequency_points(w_cell)
dim = length(w_cell);
w_general = w_cell {1};
for i=2:dim
w_general = cat(2,w_general,w_cell{i});
end
w_general = unique(w_general);
end